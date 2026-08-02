import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/challans/domain/challan_models.dart';

/// Last-known challan list for the active user and organization.
///
/// The challan screen can render this snapshot immediately while the live
/// server query refreshes in the background. The snapshot is scoped to both
/// identity values so a different account or organization can never see the
/// previous user's challans during a cold start.
class ChallanCacheSnapshot {
  const ChallanCacheSnapshot({
    required this.userId,
    required this.organizationId,
    required this.challans,
  });

  static const schemaVersion = 1;

  final String userId;
  final String organizationId;
  final List<EPassChallan> challans;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'userId': userId,
    'organizationId': organizationId,
    'challans': challans.map((challan) => challan.toJson()).toList(),
  };

  static ChallanCacheSnapshot? fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) return null;
    final userId = json['userId'];
    final organizationId = json['organizationId'];
    final rawChallans = json['challans'];
    if (userId is! String || organizationId is! String || rawChallans is! List) {
      return null;
    }

    final challans = <EPassChallan>[];
    for (final raw in rawChallans) {
      if (raw is! Map) continue;
      try {
        challans.add(
          EPassChallan.fromJson(Map<String, dynamic>.from(raw)),
        );
      } catch (_) {
        // A malformed cached row must not hide the valid rows or block startup.
      }
    }

    return ChallanCacheSnapshot(
      userId: userId,
      organizationId: organizationId,
      challans: List<EPassChallan>.unmodifiable(challans),
    );
  }
}

/// Reads and writes the most recent compact challan list.
class ChallanCache {
  ChallanCacheSnapshot? _value;

  ChallanCacheSnapshot? get value => _value;

  static const _fileName = 'challan_cache.json';

  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return;
      _value = ChallanCacheSnapshot.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      _value = null;
    }
  }

  Future<void> save({
    required String userId,
    required String organizationId,
    required List<EPassChallan> challans,
  }) async {
    _value = ChallanCacheSnapshot(
      userId: userId,
      organizationId: organizationId,
      challans: List<EPassChallan>.unmodifiable(challans),
    );

    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(_value!.toJson()), flush: true);
      if (await file.exists()) await file.delete();
      await temp.rename(file.path);
    } catch (_) {
      // Caching is best-effort; a write failure must never affect the screen.
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }
}

/// Overridden in `main()` with the instance preloaded before the first frame.
final challanCacheProvider = Provider<ChallanCache>((ref) {
  return ChallanCache();
});
