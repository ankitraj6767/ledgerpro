import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import 'infra_home_screen.dart' show ProjectCard;

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  final _searchController = TextEditingController();
  InfraProjectStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: InfraColors.navy,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.newProject),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by name, city, category',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All', null),
                _filterChip('Active', InfraProjectStatus.active),
                _filterChip('Planning', InfraProjectStatus.planning),
                _filterChip('On Hold', InfraProjectStatus.onHold),
                _filterChip('Completed', InfraProjectStatus.completed),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateView(
                message: 'Could not load projects: $error',
                onRetry: () => ref.invalidate(projectsProvider),
              ),
              data: (projects) {
                var filtered = projects;
                if (_statusFilter != null) {
                  filtered = filtered
                      .where((p) => p.status == _statusFilter)
                      .toList();
                }
                if (query.isNotEmpty) {
                  filtered = filtered.where((p) {
                    final hay =
                        '${p.name} ${p.locationCity ?? ''} ${p.locationState ?? ''} ${p.category ?? ''}'
                            .toLowerCase();
                    return hay.contains(query);
                  }).toList();
                }
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No matching projects',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(projectsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final project = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onLongPress: () => _confirmDeleteProject(project),
                          child: ProjectCard(project: project),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, InfraProjectStatus? status) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = status),
      ),
    );
  }

  Future<void> _confirmDeleteProject(InfraProject project) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          'This will remove "${project.name}" along with all its investments, '
          'government funds, receipts, and expenses. This cannot be undone '
          'from the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: InfraColors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(infraRepositoryProvider).softDeleteProject(project.id);
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('"${project.name}" deleted.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete project: $error')),
      );
    }
  }
}
