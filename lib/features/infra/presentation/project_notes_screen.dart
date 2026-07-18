import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/refresh/pull_to_refresh.dart';
import '../../../core/richtext/rich_text_editor.dart';
import '../../../core/richtext/rich_text_view.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichTextEditorField(
                  controller: _note,
                  label: 'Add a note',
                  icon: Icons.note_add_outlined,
                  hintText: 'Write a note. Use the toolbar to format…',
                  minLines: 3,
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _saving ? null : _add,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Add note'),
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
                  return RefreshIndicator(
                    onRefresh: () => ref.refreshProject(widget.projectId),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.sticky_note_2_outlined,
                          title: 'No notes yet',
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refreshProject(widget.projectId),
                  child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2, right: 12),
                                  child: Icon(Icons.notes_outlined, size: 20),
                                ),
                                Expanded(child: RichTextView(note.note)),
                              ],
                            ),
                            if (note.createdAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy HH:mm',
                                  ).format(note.createdAt!.toLocal()),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
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
