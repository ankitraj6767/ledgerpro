import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../shared/models/infra_models.dart';

/// Last-known financial data for a single project, persisted to disk so a
/// returning user sees real values on the project detail Overview tab instantly
/// on cold start instead of spinners while the network request is in flight
/// (stale-while-revalidate), mirroring the home dashboard cache.
class ProjectDetailSnapshot {
  const ProjectDetailSnapshot({
    required this.projectId,
    required this.summary,
    required this.expenses,
    required this.savedAt,
  });

  final String projectId;
  final ProjectFinancialSummary summary;
  final List<ProjectExpense> expenses;

  /// When this entry was written; used to keep the most recently viewed
  /// projects and evict the oldest so the cache file cannot grow unbounded.
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'summary': summary.toJson(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'savedAt': savedAt.toIso8601String(),
  };

  static ProjectDetailSnapshot? fromJson(Map<String, dynamic> json) {
    final projectId = json['projectId'];
    final summary = json['summary'];
    if (projectId is! String || summary is! Map) return null;
    return ProjectDetailSnapshot(
      projectId: projectId,
      summary: ProjectFinancialSummary.fromJson(
        Map<String, dynamic>.from(summary),
      ),
      expenses: (json['expenses'] as List? ?? const [])
          .whereType<Map>()
          .map((raw) => ProjectExpense.fromJson(Map<String, dynamic>.from(raw)))
          .toList(),
      savedAt:
          DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Reads/writes per-project [ProjectDetailSnapshot]s to a single JSON file,
/// scoped to one Supabase user so a different account can never see the
/// previous user's cached data. The last loaded values are kept in memory so
/// the detail screen can read them synchronously on the first frame.
class ProjectDetailCache {
  String? _userId;
  final Map<String, ProjectDetailSnapshot> _byProject = {};

  /// The user the currently cached snapshots belong to.
  String? get userId => _userId;

  /// The most recently persisted snapshot for [projectId], if any.
  ProjectDetailSnapshot? snapshot(String projectId) => _byProject[projectId];

  static const _fileName = 'project_detail_cache.json';
  static const schemaVersion = 1;

  /// Keep at most this many projects cached (most recently viewed win) so the
  /// file stays small regardless of how many projects the org has.
  static const _maxProjects = 60;

  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return;
      final json = Map<String, dynamic>.from(decoded);
      if (json['schemaVersion'] != schemaVersion) return;
      _userId = json['userId']?.toString();
      final projects = json['projects'];
      if (projects is Map) {
        projects.forEach((key, value) {
          if (value is Map) {
            final snap = ProjectDetailSnapshot.fromJson(
              Map<String, dynamic>.from(value),
            );
            if (snap != null) _byProject[key.toString()] = snap;
          }
        });
      }
    } catch (_) {
      _userId = null;
      _byProject.clear();
    }
  }

  Future<void> save({
    required String userId,
    required ProjectDetailSnapshot snapshot,
  }) async {
    // A different account must never inherit the previous user's cache.
    if (_userId != userId) {
      _userId = userId;
      _byProject.clear();
    }
    _byProject[snapshot.projectId] = snapshot;

    // Evict the oldest entries beyond the cap (LRU by savedAt).
    if (_byProject.length > _maxProjects) {
      final ordered = _byProject.entries.toList()
        ..sort((a, b) => b.value.savedAt.compareTo(a.value.savedAt));
      _byProject
        ..clear()
        ..addEntries(ordered.take(_maxProjects));
    }

    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      final payload = {
        'schemaVersion': schemaVersion,
        'userId': _userId,
        'projects': {
          for (final entry in _byProject.entries)
            entry.key: entry.value.toJson(),
        },
      };
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(payload), flush: true);
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

/// Overridden in `main()` with the instance whose snapshots are preloaded
/// before the first frame. Defaults to an empty cache so any early or
/// non-overridden read is harmless (it simply yields no cached data).
final projectDetailCacheProvider = Provider<ProjectDetailCache>((ref) {
  return ProjectDetailCache();
});
