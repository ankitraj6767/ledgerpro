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
    final permissions = ref.watch(currentOrgPermissionsProvider);
    if (!permissions.canAddNotes) {
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
                                if (permissions.canEditNotes ||
                                    permissions.canDeleteNotes)
                                  _noteMenu(
                                    note,
                                    canEdit: permissions.canEditNotes,
                                    canDelete: permissions.canDeleteNotes,
                                  ),
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

  Widget _noteMenu(
    ProjectNote note, {
    required bool canEdit,
    required bool canDelete,
  }) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      tooltip: 'Note actions',
      onSelected: (value) {
        if (value == 'edit') {
          _editNote(note);
        } else if (value == 'delete') {
          _deleteNote(note);
        }
      },
      itemBuilder: (context) => [
        if (canEdit)
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (canDelete)
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Future<void> _editNote(ProjectNote note) async {
    final controller = TextEditingController(text: note.note);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var saving = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit note',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  RichTextEditorField(
                    controller: controller,
                    label: 'Note',
                    icon: Icons.notes_outlined,
                    hintText: 'Update the note. Use the toolbar to format…',
                    minLines: 3,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            if (controller.text.trim().isEmpty) return;
                            setSheetState(() => saving = true);
                            try {
                              await ref
                                  .read(infraRepositoryProvider)
                                  .updateNote(
                                    noteId: note.id,
                                    note: controller.text.trim(),
                                  );
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop(true);
                              }
                            } catch (error) {
                              setSheetState(() => saving = false);
                              if (sheetContext.mounted) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not update note: $error',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    icon: saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    if (saved == true) {
      ref.invalidate(projectNotesProvider(widget.projectId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note updated.')));
      }
    }
  }

  Future<void> _deleteNote(ProjectNote note) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text(
          'This note will be removed. This cannot be undone from the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(infraRepositoryProvider).deleteNote(note.id);
      ref.invalidate(projectNotesProvider(widget.projectId));
      messenger.showSnackBar(const SnackBar(content: Text('Note deleted.')));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete note: $error')),
      );
    }
  }
}
