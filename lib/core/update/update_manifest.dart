import 'package:flutter/foundation.dart';

/// The platforms for which we ship self-updating builds.
///
/// `unsupported` covers web, Linux, iOS and any platform where we do not (yet)
/// distribute an in-app updatable artifact.
enum UpdatePlatform { android, windows, macos, unsupported }

/// Resolves the [UpdatePlatform] for the current runtime.
UpdatePlatform currentUpdatePlatform() {
  if (kIsWeb) return UpdatePlatform.unsupported;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => UpdatePlatform.android,
    TargetPlatform.windows => UpdatePlatform.windows,
    TargetPlatform.macOS => UpdatePlatform.macos,
    _ => UpdatePlatform.unsupported,
  };
}

/// A semantic version (`major.minor.patch`) plus an optional build number,
/// mirroring the `version: x.y.z+build` convention used in `pubspec.yaml`.
///
/// Comparison is by major, then minor, then patch, and finally by build number
/// (a missing build number is treated as `0`). Any pre-release/build metadata
/// after a `-` is ignored for comparison purposes.
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, {this.build});

  final int major;
  final int minor;
  final int patch;
  final int? build;

  /// Parses a version string such as `1.2.3`, `v1.2.3` or `1.2.3+4`.
  ///
  /// Returns `null` when [raw] is null/blank or cannot be parsed into at least
  /// a major component.
  static AppVersion? tryParse(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('v') || value.startsWith('V')) {
      value = value.substring(1);
    }

    int? build;
    final plusIndex = value.indexOf('+');
    if (plusIndex != -1) {
      build = int.tryParse(value.substring(plusIndex + 1).trim());
      value = value.substring(0, plusIndex);
    }

    // Drop any pre-release suffix (e.g. "1.2.3-beta.1") before splitting.
    final dashIndex = value.indexOf('-');
    if (dashIndex != -1) {
      value = value.substring(0, dashIndex);
    }

    final parts = value.split('.');
    if (parts.isEmpty || parts.first.trim().isEmpty) return null;

    int component(int index) =>
        index < parts.length ? (int.tryParse(parts[index].trim()) ?? 0) : 0;

    final major = int.tryParse(parts[0].trim());
    if (major == null) return null;

    return AppVersion(major, component(1), component(2), build: build);
  }

  /// Builds an [AppVersion] from a separate version string and build number,
  /// which is how both the running app (package_info) and the manifest expose
  /// their values.
  static AppVersion? from(String? version, {int? build}) {
    final parsed = tryParse(version);
    if (parsed == null) return null;
    return AppVersion(
      parsed.major,
      parsed.minor,
      parsed.patch,
      build: build ?? parsed.build,
    );
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return (build ?? 0).compareTo(other.build ?? 0);
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  /// `1.2.3` without the build suffix.
  String get shortLabel => '$major.$minor.$patch';

  /// `1.2.3 (4)` style label for display.
  String get displayLabel => build == null ? shortLabel : '$shortLabel ($build)';

  @override
  String toString() => build == null ? shortLabel : '$shortLabel+$build';

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch &&
      other.build == build;

  @override
  int get hashCode => Object.hash(major, minor, patch, build);
}

/// A single platform's latest release as described by the update manifest.
@immutable
class PlatformRelease {
  const PlatformRelease({
    required this.version,
    required this.url,
    this.buildNumber,
    this.sha256,
    this.notes,
    this.minSupportedVersion,
    this.mandatory = false,
    this.fileName,
  });

  /// Marketing version, e.g. `1.0.2`.
  final String version;

  /// Absolute https URL of the downloadable artifact (APK / ZIP).
  final String url;

  /// Optional build number used as a tie-breaker against the running build.
  final int? buildNumber;

  /// Lower-case hex SHA-256 of the artifact. Strongly recommended: when present
  /// the downloaded file is verified before it is installed.
  final String? sha256;

  /// Human readable release notes shown in the update prompt.
  final String? notes;

  /// Versions strictly below this are forced to update (blocking prompt).
  final String? minSupportedVersion;

  /// When true the update is always presented as mandatory.
  final bool mandatory;

  /// Optional preferred file name to save the artifact as.
  final String? fileName;

  AppVersion get appVersion =>
      AppVersion.from(version, build: buildNumber) ?? const AppVersion(0, 0, 0);

  static PlatformRelease? fromJson(Object? json) {
    if (json is! Map) return null;
    final map = json.cast<String, dynamic>();
    final version = (map['version'] as Object?)?.toString().trim();
    final url = (map['url'] as Object?)?.toString().trim();
    if (version == null || version.isEmpty || url == null || url.isEmpty) {
      return null;
    }
    return PlatformRelease(
      version: version,
      url: url,
      buildNumber: _asInt(map['buildNumber'] ?? map['build']),
      sha256: (map['sha256'] as Object?)?.toString().trim(),
      notes: (map['notes'] as Object?)?.toString(),
      minSupportedVersion:
          (map['minSupportedVersion'] as Object?)?.toString().trim(),
      mandatory: map['mandatory'] == true,
      fileName: (map['fileName'] as Object?)?.toString().trim(),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}

/// The full update manifest (the "appcast") describing the latest release for
/// each platform.
@immutable
class UpdateManifest {
  const UpdateManifest({this.android, this.windows, this.macos});

  final PlatformRelease? android;
  final PlatformRelease? windows;
  final PlatformRelease? macos;

  PlatformRelease? forPlatform(UpdatePlatform platform) => switch (platform) {
    UpdatePlatform.android => android,
    UpdatePlatform.windows => windows,
    UpdatePlatform.macos => macos,
    UpdatePlatform.unsupported => null,
  };

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    return UpdateManifest(
      android: PlatformRelease.fromJson(json['android']),
      windows: PlatformRelease.fromJson(json['windows']),
      macos: PlatformRelease.fromJson(json['macos']),
    );
  }
}
