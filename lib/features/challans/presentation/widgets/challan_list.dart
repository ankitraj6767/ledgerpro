import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/infra_theme.dart';
import '../../../../data/repositories/infra_repository.dart';
import '../../../../shared/components/infra_components.dart';
import '../../application/challan_providers.dart';
import '../../domain/challan_models.dart';
import '../../domain/challan_status.dart';
import '../../domain/material_type.dart';
import 'challan_card.dart';

/// Searchable, filterable list of saved challans.
class ChallanList extends ConsumerStatefulWidget {
  const ChallanList({super.key, this.onAddChallan, this.shrinkWrap = false});

  /// Wired to the empty state's primary action.
  final VoidCallback? onAddChallan;

  /// True when embedded inside another scrollable (desktop split layout).
  final bool shrinkWrap;

  @override
  ConsumerState<ChallanList> createState() => _ChallanListState();
}

class _ChallanListState extends ConsumerState<ChallanList> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(challanFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challansAsync = ref.watch(challansProvider);
    final filter = ref.watch(challanFiltersProvider);

    final content = challansAsync.when(
      loading: () => const _ChallanListSkeleton(),
      error: (error, _) => ErrorStateView(
        message: _errorMessage(error),
        onRetry: () => ref.invalidate(challansProvider),
      ),
      data: (challans) {
        if (challans.isEmpty) {
          return filter.isActive
              ? _noMatches()
              : EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No challans saved yet',
                  message:
                      'Verify an e-Pass challan from the Bihar Government '
                      'portal to add a material entry.',
                  action: widget.onAddChallan == null
                      ? null
                      : FilledButton.icon(
                          onPressed: widget.onAddChallan,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Challan'),
                        ),
                );
        }
        return ListView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: challans.length,
          itemBuilder: (context, index) {
            final challan = challans[index];
            return ChallanCard(
              challan: challan,
              onTap: () => context.push(AppRoutes.challanDetail(challan.id)),
            );
          },
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _searchField(),
        const SizedBox(height: 10),
        _filterBar(filter),
        const SizedBox(height: 12),
        if (widget.shrinkWrap) content else Expanded(child: content),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search challan or vehicle number',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: _search.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _search.clear();
                  ref.read(challanFiltersProvider.notifier).setQuery('');
                  setState(() {});
                },
              ),
      ),
      onChanged: (value) {
        ref.read(challanFiltersProvider.notifier).setQuery(value);
        setState(() {});
      },
    );
  }

  Widget _filterBar(ChallanFilter filter) {
    final projects = ref.watch(projectsProvider).value ?? const [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip<String>(
            label: 'Project',
            value: filter.projectId,
            display: (id) =>
                projects.where((p) => p.id == id).firstOrNull?.name ??
                'Project',
            options: [for (final p in projects) (p.id, p.name)],
            onSelected: (value) =>
                ref.read(challanFiltersProvider.notifier).setProject(value),
          ),
          const SizedBox(width: 8),
          _FilterChip<ChallanMaterialType>(
            label: 'Material',
            value: filter.materialType,
            display: (m) => m.label,
            options: [for (final m in ChallanMaterialType.values) (m, m.label)],
            onSelected: (value) =>
                ref.read(challanFiltersProvider.notifier).setMaterial(value),
          ),
          const SizedBox(width: 8),
          _FilterChip<ChallanVerificationStatus>(
            label: 'Status',
            value: filter.status,
            display: (s) => s.shortLabel,
            options: [
              for (final s in ChallanVerificationStatus.values)
                (s, s.shortLabel),
            ],
            onSelected: (value) =>
                ref.read(challanFiltersProvider.notifier).setStatus(value),
          ),
          const SizedBox(width: 8),
          _dateRangeChip(filter),
          if (filter.isActive) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                _search.clear();
                ref.read(challanFiltersProvider.notifier).clear();
                setState(() {});
              },
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: Text('Clear (${filter.activeCount})'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateRangeChip(ChallanFilter filter) {
    final format = DateFormat('dd MMM');
    final hasRange = filter.fromDate != null || filter.toDate != null;
    final label = hasRange
        ? '${filter.fromDate == null ? '…' : format.format(filter.fromDate!)}'
              ' – '
              '${filter.toDate == null ? '…' : format.format(filter.toDate!)}'
        : 'Date range';

    return FilterChip(
      label: Text(label),
      selected: hasRange,
      avatar: const Icon(Icons.date_range_outlined, size: 16),
      onSelected: (_) async {
        if (hasRange) {
          ref.read(challanFiltersProvider.notifier).setDateRange();
          return;
        }
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 6),
          lastDate: DateTime(now.year + 1, 12, 31),
        );
        if (picked == null || !mounted) return;
        ref
            .read(challanFiltersProvider.notifier)
            .setDateRange(from: picked.start, to: picked.end);
      },
    );
  }

  Widget _noMatches() {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No challans match these filters',
      message: 'Try a different search term or clear the filters.',
      action: OutlinedButton.icon(
        onPressed: () {
          _search.clear();
          ref.read(challanFiltersProvider.notifier).clear();
          setState(() {});
        },
        icon: const Icon(Icons.filter_alt_off_outlined),
        label: const Text('Clear filters'),
      ),
    );
  }

  /// Keeps raw exception text out of the UI.
  static String _errorMessage(Object error) {
    return 'Could not load challans. Pull to refresh to try again.';
  }
}

/// Generic single-select filter chip with a popup menu.
class _FilterChip<T> extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.display,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final T? value;
  final String Function(T value) display;
  final List<(T, String)> options;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value != null;
    return PopupMenuButton<T?>(
      tooltip: label,
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem<T?>(
          value: null,
          child: Text('All ${label.toLowerCase()}s'),
        ),
        const PopupMenuDivider(),
        for (final option in options)
          PopupMenuItem<T?>(value: option.$1, child: Text(option.$2)),
      ],
      child: Chip(
        label: Text(selected ? display(value as T) : label),
        avatar: Icon(
          selected ? Icons.check : Icons.expand_more,
          size: 16,
          color: selected ? InfraColors.royalBlue : InfraColors.textSecondary,
        ),
        backgroundColor: selected
            ? InfraColors.royalBlue.withValues(alpha: 0.1)
            : null,
      ),
    );
  }
}

class _ChallanListSkeleton extends StatelessWidget {
  const _ChallanListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, index) => const Card(
        margin: EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 160, height: 14),
              SizedBox(height: 10),
              SkeletonBox(width: 110, height: 11),
              SizedBox(height: 12),
              SkeletonBox(height: 11),
            ],
          ),
        ),
      ),
    );
  }
}
