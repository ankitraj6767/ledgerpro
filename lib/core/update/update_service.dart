import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/constants/supabase_config.dart';
import 'update_manifest.dart';

/// Outcome of an update check for the running platform.
enum UpdateStatus {
  /// The running build is the latest (or newer than) the manifest entry.
  upToDate,

  /// A newer build exists and the user may choose to install it.
  optional,

  /// A newer build exists and the user must install it to keep using the app.
  mandatory,

  /// This platform does not support in-app updates (web/Linux/iOS).
  unsupportedPlatform,
}

@immutable
class UpdateAvailability {
  const UpdateAvailability({
    required this.status,
    this.release,
    this.currentVersion,
  });

  final UpdateStatus status;
  final PlatformRelease? release;
  final AppVersion? currentVersion;

  bool get hasUpdate =>
      status == UpdateStatus.optional || status == UpdateStatus.mandatory;

  bool get isMandatory => status == UpdateStatus.mandatory;

  static const none = UpdateAvailability(status: UpdateStatus.upToDate);
  static const unsupported =
      UpdateAvailability(status: UpdateStatus.unsupportedPlatform);
}

/// Where to read the update manifest from, and which platform we are running.
///
/// The manifest URL is configurable at build time via
/// `--dart-define=UPDATE_MANIFEST_URL=...`. When unset it defaults to a public
/// object in the project's Supabase Storage bucket, which is reachable without
/// authentication (the GitHub repository is private, so release assets there
/// are not an option for clients).
@immutable
class UpdateConfig {
  const UpdateConfig({required this.manifestUrl, required this.platform});

  final String manifestUrl;
  final UpdatePlatform platform;

  static const _envManifestUrl = String.fromEnvironment('UPDATE_MANIFEST_URL');
  static const _bucket =
      String.fromEnvironment('UPDATE_BUCKET', defaultValue: 'app-releases');
  static const _manifestObject = String.fromEnvironment(
    'UPDATE_MANIFEST_OBJECT',
    defaultValue: 'update-manifest.json',
  );

  /// Default manifest URL derived from the configured Supabase project.
  static String get defaultManifestUrl {
    if (_envManifestUrl.isNotEmpty) return _envManifestUrl;
    final base = SupabaseConfig.url.trim();
    if (base.isEmpty) return '';
    final origin = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$origin/storage/v1/object/public/$_bucket/$_manifestObject';
  }

  factory UpdateConfig.resolve() => UpdateConfig(
    manifestUrl: defaultManifestUrl,
    platform: currentUpdatePlatform(),
  );

  bool get isConfigured => manifestUrl.isNotEmpty;
}

/// Thrown when an update check or install fails in a way worth surfacing.
class UpdateException implements Exception {
  const UpdateException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Loads the current app version. Injectable so the decision logic can be unit
/// tested without the package_info plugin.
typedef CurrentVersionLoader = Future<AppVersion> Function();

class UpdateService {
  UpdateService({
    required this.config,
    required this.currentVersionLoader,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final UpdateConfig config;
  final CurrentVersionLoader currentVersionLoader;
  final http.Client _client;

  /// Pure decision function: given the running [current] version and the
  /// manifest [release] for this platform, decide what (if anything) to offer.
  ///
  /// Kept static and side-effect free so it is fully unit testable.
  static UpdateAvailability evaluate({
    required AppVersion current,
    required PlatformRelease? release,
  }) {
    if (release == null) {
      return UpdateAvailability(
        status: UpdateStatus.upToDate,
        currentVersion: current,
      );
    }

    final remote = release.appVersion;
    if (remote <= current) {
      return UpdateAvailability(
        status: UpdateStatus.upToDate,
        currentVersion: current,
      );
    }

    final minSupported = AppVersion.tryParse(release.minSupportedVersion);
    final mandatory =
        release.mandatory || (minSupported != null && current < minSupported);

    return UpdateAvailability(
      status: mandatory ? UpdateStatus.mandatory : UpdateStatus.optional,
      release: release,
      currentVersion: current,
    );
  }

  /// Fetches the manifest and evaluates availability for the current platform.
  ///
  /// Network/parsing failures are surfaced as [UpdateException]; callers should
  /// treat a thrown check as "could not check" rather than "up to date".
  Future<UpdateAvailability> check() async {
    if (config.platform == UpdatePlatform.unsupported) {
      return UpdateAvailability.unsupported;
    }
    if (!config.isConfigured) {
      throw const UpdateException('Update server is not configured.');
    }

    final current = await currentVersionLoader();
    final manifest = await _fetchManifest();
    final release = manifest.forPlatform(config.platform);
    return evaluate(current: current, release: release);
  }

  Future<UpdateManifest> _fetchManifest() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(config.manifestUrl),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const UpdateException('Timed out contacting the update server.');
    } catch (error) {
      throw UpdateException('Could not reach the update server: $error');
    }

    if (response.statusCode != 200) {
      throw UpdateException(
        'Update server returned HTTP ${response.statusCode}.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const UpdateException('Update manifest is malformed.');
      }
      return UpdateManifest.fromJson(decoded);
    } on UpdateException {
      rethrow;
    } catch (_) {
      throw const UpdateException('Update manifest is malformed.');
    }
  }

  void dispose() => _client.close();
}
