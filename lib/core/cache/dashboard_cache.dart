import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../shared/models/infra_models.dart';

/// Last-known home dashboard data, persisted to disk so a returning user sees
/// real values instantly on cold start instead of empty placeholders while the
/// network request is in flight (stale-while-revalidate).
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.userId,
    required this.orgName,
    required this.summary,
    required this.projects,
    this.role,
  });

  /// The Supabase user the snapshot belongs to. Used to ensure a different
  /// account can never briefly see the previous user's cached data.
  final String userId;
  final String orgName;

  /// Last-known role of [userId] in the org. Cached so permission-gated UI
  /// (e.g. the "Add Project" button) renders correctly on the first frame
  /// instead of waiting for the workspace network round-trip.
  final OrgMemberRole? role;
  final InfraDashboardSummary summary;
  final List<InfraProject> projects;

  static const schemaVersion = 2;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'userId': userId,
    'orgName': orgName,
    'role': role?.dbValue,
    'summary': summary.toJson(),
    'projects': projects.map((project) => project.toJson()).toList(),
  };

  static DashboardSnapshot? fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) return null;
    final userId = json['userId'];
    final summary = json['summary'];
    if (userId is! String || summary is! Map) return null;
    final roleValue = json['role'];
    return DashboardSnapshot(
      userId: userId,
      orgName: json['orgName']?.toString() ?? '',
      role: roleValue == null
          ? null
          : OrgMemberRoleMapping.fromDb(roleValue.toString()),
      summary: InfraDashboardSummary.fromJson(
        Map<String, dynamic>.from(summary),
      ),
      projects: (json['projects'] as List? ?? const [])
          .whereType<Map>()
          .map((raw) => InfraProject.fromJson(Map<String, dynamic>.from(raw)))
          .toList(),
    );
  }
}

/// Reads/writes the [DashboardSnapshot] to a JSON file. The last loaded value is
/// kept in memory so the router/home screen can read it synchronously on the
/// first frame.
class DashboardCache {
  DashboardSnapshot? _value;

  DashboardSnapshot? get value => _value;

  static const _fileName = 'dashboard_cache.json';

  Future<DashboardSnapshot?> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      _value = DashboardSnapshot.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      _value = null;
    }
    return _value;
  }

  Future<void> save(DashboardSnapshot snapshot) async {
    _value = snapshot;
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
      if (await file.exists()) await file.delete();
      await temp.rename(file.path);
    } catch (_) {
      // Caching is best-effort; a write failure must never break the app.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }
}

/// Overridden in `main()` with the instance whose snapshot is preloaded before
/// the first frame. Defaults to an empty cache so any early or non-overridden
/// read is harmless (it simply yields no cached data).
final dashboardCacheProvider = Provider<DashboardCache>((ref) {
  return DashboardCache();
});
