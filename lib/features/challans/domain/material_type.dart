/// Material selected by the user in step 1.
///
/// The selection is a *hint* only. After the portal capture the extracted
/// "Mineral Name" is stored separately in `portal_mineral_name`, and a mismatch
/// is surfaced to the user rather than silently overwritten.
enum ChallanMaterialType {
  sand,
  stone,
  brick,
  aggregate,
  boulder,
  dust,
  gitti,
  balu,
  other,
}

extension ChallanMaterialTypeMapping on ChallanMaterialType {
  static const _labels = <ChallanMaterialType, String>{
    ChallanMaterialType.sand: 'Sand',
    ChallanMaterialType.stone: 'Stone',
    ChallanMaterialType.brick: 'Brick',
    ChallanMaterialType.aggregate: 'Aggregate',
    ChallanMaterialType.boulder: 'Boulder',
    ChallanMaterialType.dust: 'Dust',
    ChallanMaterialType.gitti: 'Gitti',
    ChallanMaterialType.balu: 'Balu',
    ChallanMaterialType.other: 'Other',
  };

  String get label => _labels[this]!;

  String get dbValue => name;

  static ChallanMaterialType? fromDb(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final type in ChallanMaterialType.values) {
      if (type.name == normalized) return type;
    }
    return null;
  }

  /// Hindi/English synonyms the Bihar portal uses for each mineral, used to
  /// decide whether the portal's mineral name agrees with the user's selection.
  static const _synonyms = <ChallanMaterialType, List<String>>{
    ChallanMaterialType.sand: ['sand', 'balu', 'बालू', 'रेत', 'ret'],
    ChallanMaterialType.stone: ['stone', 'patthar', 'पत्थर', 'shiladdar'],
    ChallanMaterialType.brick: ['brick', 'eent', 'ईंट', 'int', 'brick kiln'],
    ChallanMaterialType.aggregate: [
      'aggregate',
      'gitti',
      'गिट्टी',
      'chips',
      'grit',
    ],
    ChallanMaterialType.boulder: ['boulder', 'bolder', 'बोल्डर'],
    ChallanMaterialType.dust: ['dust', 'stone dust', 'डस्ट', 'धूल'],
    ChallanMaterialType.gitti: [
      'gitti',
      'गिट्टी',
      'grit',
      'chips',
      'stone chips',
      'aggregate',
    ],
    ChallanMaterialType.balu: ['balu', 'बालू', 'sand', 'रेत', 'ret'],
  };

  /// True when [portalMineralName] plausibly refers to this material.
  ///
  /// `other` matches anything because the user explicitly declined to classify.
  bool matchesPortalMineral(String? portalMineralName) {
    if (this == ChallanMaterialType.other) return true;
    final mineral = portalMineralName?.trim().toLowerCase();
    if (mineral == null || mineral.isEmpty) return true;
    final terms = _synonyms[this] ?? const <String>[];
    for (final term in terms) {
      if (mineral.contains(term)) return true;
    }
    return false;
  }
}

/// Indian financial year helpers.
///
/// Financial years run 1 April → 31 March and are rendered as `2026-2027`,
/// which is the format the Bihar portal dropdown uses. The selectable range is
/// separate from the clock-based calculation of the current financial year.
class FinancialYear {
  const FinancialYear._();

  static const firstSelectableStartYear = 2024;
  static const lastSelectableStartYear = 2030;

  /// The financial year containing [now], e.g. `2026-2027`.
  static String current([DateTime? now]) {
    final date = now ?? DateTime.now();
    // Jan/Feb/Mar still belong to the financial year that started last April.
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    return format(startYear);
  }

  static String format(int startYear) => '$startYear-${startYear + 1}';

  /// The current financial year when supported, otherwise the nearest choice.
  /// Keeps initial/reset selections valid even outside the selectable range.
  static String defaultSelection([DateTime? now]) {
    final currentStart = int.parse(current(now).split('-').first);
    return format(
      currentStart.clamp(firstSelectableStartYear, lastSelectableStartYear),
    );
  }

  /// The supported entry years, newest first. Saved records retain their years.
  static List<String> options() => [
    for (
      var year = lastSelectableStartYear;
      year >= firstSelectableStartYear;
      year--
    )
      format(year),
  ];
}
