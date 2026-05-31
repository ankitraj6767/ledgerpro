import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import '../../../shared/widgets/access_denied_screen.dart';

class ProjectNotesScreen extends ConsumerStatefulWidget {
  const ProjectNotesScreen({super.key, required this.projectId, this.project});

  final String projectId;
  final InfraProject? project;

  @override
  ConsumerState<ProjectNotesScreen> createState() => _ProjectNotesScreenState();
}

class _ProjectNotesScreenState extends ConsumerState<ProjectNotesScreen> {
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canAddNotes) {
      return const AccessDeniedScreen();
    }

    final notesAsync = ref.watch(projectNotesProvider(widget.projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Project Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _note,
                    decoration: const InputDecoration(
                      hintText: 'Add a note',
                      prefixIcon: Icon(Icons.note_add_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _add,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(
                message: 'Could not load notes: $e',
                onRetry: () =>
                    ref.invalidate(projectNotesProvider(widget.projectId)),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: 'No notes yet',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.notes_outlined),
                        title: Text(note.note),
                        subtitle: note.createdAt == null
                            ? null
                            : Text(
                                DateFormat(
                                  'dd MMM yyyy HH:mm',
                                ).format(note.createdAt!.toLocal()),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_note.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      await ref
          .read(infraRepositoryProvider)
          .addNote(
            organizationId: org.id,
            projectId: widget.projectId,
            note: _note.text.trim(),
          );
      _note.clear();
      ref.invalidate(projectNotesProvider(widget.projectId));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not add note: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
