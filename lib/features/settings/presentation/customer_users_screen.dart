import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../core/refresh/pull_to_refresh.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import '../../../shared/widgets/access_denied_screen.dart';

class CustomerUsersScreen extends ConsumerStatefulWidget {
  const CustomerUsersScreen({super.key});

  @override
  ConsumerState<CustomerUsersScreen> createState() =>
      _CustomerUsersScreenState();
}

class _CustomerUsersScreenState extends ConsumerState<CustomerUsersScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);

    return roleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Customers')),
        body: ErrorStateView(
          message: 'Could not load permissions: $error',
          onRetry: () => ref.invalidate(currentOrgRoleProvider),
        ),
      ),
      data: (role) {
        final permissions = OrgPermissions(role);
        if (!permissions.canManageUsers) {
          return const AccessDeniedScreen();
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Customers')),
          body: RefreshIndicator(
            onRefresh: () {
              ref.invalidate(customerMembersProvider);
              return ref.awaitRefresh(
                ref.read(customerMembersProvider.future),
              );
            },
            child: ResponsiveFormArea(
            maxWidth: 760,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  title: 'Create customer login',
                  icon: Icons.person_add_alt_1,
                  child: Column(
                    children: [
                      _field(_name, 'Customer name', Icons.person_outline),
                      const SizedBox(height: 12),
                      _field(
                        _email,
                        'Customer email',
                        Icons.mail_outline,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _password,
                        'Password',
                        Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _phone,
                        'Phone',
                        Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _notes,
                        'Notes',
                        Icons.notes_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _createCustomer,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1),
                          label: const Text('Create Customer'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _CustomerList(),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Future<void> _createCustomer() async {
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    if (name.isEmpty || email.isEmpty || password.length < 8) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Enter name, email, and an 8+ character password.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      await ref
          .read(infraRepositoryProvider)
          .createCustomerUser(
            organizationId: org.id,
            fullName: name,
            email: email,
            password: password,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      _name.clear();
      _email.clear();
      _password.clear();
      _phone.clear();
      _notes.clear();
      ref.invalidate(customerMembersProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Customer login created.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not create customer: ${_clean(error)}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _clean(Object error) {
    final text = error.toString();
    final marker = RegExp(r'error: ([^}]+)');
    final match = marker.firstMatch(text);
    return match?.group(1)?.trim() ?? text;
  }
}

class _CustomerList extends ConsumerWidget {
  const _CustomerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerMembersProvider);
    return SectionCard(
      title: 'Customer users',
      icon: Icons.group_outlined,
      child: customersAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => ErrorStateView(
          message: 'Could not load customers: $error',
          onRetry: () => ref.invalidate(customerMembersProvider),
        ),
        data: (customers) {
          if (customers.isEmpty) {
            return const Text(
              'No customer users yet.',
              style: TextStyle(color: InfraColors.textSecondary),
            );
          }
          return Column(
            children: [
              for (final entry in customers.indexed) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const SizedBox.square(
                    dimension: 44,
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFEAF1FF),
                      child: Icon(
                        Icons.person_outline,
                        color: InfraColors.royalBlue,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.$2.fullName ?? entry.$2.email ?? 'Customer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          if ((entry.$2.email ?? '').isNotEmpty) entry.$2.email,
                          if ((entry.$2.phone ?? '').isNotEmpty) entry.$2.phone,
                          entry.$2.role.label,
                        ].whereType<String>().join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((entry.$2.notes ?? '').isNotEmpty)
                        Text(
                          entry.$2.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: InfraColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<_CustomerAction>(
                    tooltip: 'Customer actions',
                    onSelected: (action) {
                      switch (action) {
                        case _CustomerAction.projects:
                          _showProjectAssignments(context, ref, entry.$2);
                        case _CustomerAction.edit:
                          _showEditCustomer(context, ref, entry.$2);
                        case _CustomerAction.delete:
                          _confirmDeleteCustomer(context, entry.$2);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _CustomerAction.projects,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.assignment_outlined),
                          title: Text('Projects'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _CustomerAction.edit,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _CustomerAction.delete,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_outline,
                            color: InfraColors.red,
                          ),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.$1 != customers.length - 1) const Divider(),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditCustomer(
    BuildContext context,
    WidgetRef ref,
    CustomerMember customer,
  ) async {
    final name = TextEditingController(text: customer.fullName ?? '');
    final email = TextEditingController(text: customer.email ?? '');
    final password = TextEditingController();
    final phone = TextEditingController(text: customer.phone ?? '');
    final notes = TextEditingController(text: customer.notes ?? '');
    final formKey = GlobalKey<FormState>();
    var saving = false;

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> save() async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                setDialogState(() => saving = true);
                try {
                  final org = await ref.read(infraWorkspaceProvider.future);
                  await ref
                      .read(infraRepositoryProvider)
                      .updateCustomerUser(
                        organizationId: org.id,
                        userId: customer.userId,
                        fullName: name.text.trim(),
                        email: email.text.trim(),
                        password: password.text.trim().isEmpty
                            ? null
                            : password.text,
                        phone: phone.text.trim().isEmpty
                            ? null
                            : phone.text.trim(),
                        notes: notes.text.trim().isEmpty
                            ? null
                            : notes.text.trim(),
                      );
                  ref.invalidate(customerMembersProvider);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Could not update customer: ${_clean(error)}',
                        ),
                      ),
                    );
                  }
                } finally {
                  if (dialogContext.mounted) {
                    setDialogState(() => saving = false);
                  }
                }
              }

              return AlertDialog(
                title: const Text('Edit customer'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dialogField(
                          name,
                          'Customer name',
                          Icons.person_outline,
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Customer name is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          email,
                          'Customer email',
                          Icons.mail_outline,
                          keyboard: TextInputType.emailAddress,
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) return 'Email is required.';
                            if (!text.contains('@') || !text.contains('.')) {
                              return 'Enter a valid email.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          password,
                          'New password (optional)',
                          Icons.lock_reset_outlined,
                          obscure: true,
                          validator: (value) {
                            final text = value ?? '';
                            if (text.isNotEmpty && text.length < 8) {
                              return 'Use at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          phone,
                          'Phone',
                          Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          notes,
                          'Notes',
                          Icons.notes_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: saving ? null : save,
                    icon: saving
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saved == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${customer.fullName ?? customer.email ?? 'Customer'} updated.',
            ),
          ),
        );
      }
    } finally {
      name.dispose();
      email.dispose();
      password.dispose();
      phone.dispose();
      notes.dispose();
    }
  }

  Future<void> _showProjectAssignments(
    BuildContext context,
    WidgetRef ref,
    CustomerMember customer,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(infraRepositoryProvider);
    final org = await ref.read(infraWorkspaceProvider.future);
    final projects = await ref.read(projectsProvider.future);
    final assignedIds = await repo.fetchCustomerProjectAssignments(
      organizationId: org.id,
      customerUserId: customer.userId,
    );
    if (!context.mounted) return;

    final selected = assignedIds.toSet();
    var saving = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> save() async {
            setDialogState(() => saving = true);
            try {
              await repo.setCustomerProjectAssignments(
                organizationId: org.id,
                customerUserId: customer.userId,
                projectIds: selected.toList(),
              );
              if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
            } catch (error) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Could not assign projects: ${_clean(error)}',
                    ),
                  ),
                );
              }
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => saving = false);
              }
            }
          }

          return AlertDialog(
            title: const Text('Assign projects'),
            content: SizedBox(
              width: double.maxFinite,
              child: projects.isEmpty
                  ? const Text('No projects available.')
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final project in projects)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: selected.contains(project.id),
                            title: Text(project.name),
                            subtitle: Text(
                              [
                                if ((project.locationCity ?? '').isNotEmpty)
                                  project.locationCity,
                                if ((project.locationState ?? '').isNotEmpty)
                                  project.locationState,
                              ].whereType<String>().join(', '),
                            ),
                            onChanged: saving
                                ? null
                                : (checked) {
                                    setDialogState(() {
                                      if (checked ?? false) {
                                        selected.add(project.id);
                                      } else {
                                        selected.remove(project.id);
                                      }
                                    });
                                  },
                          ),
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.assignment_turned_in_outlined),
                label: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (saved == true && context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Projects assigned to ${customer.fullName ?? customer.email ?? 'customer'}.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteCustomer(
    BuildContext context,
    CustomerMember customer,
  ) async {
    final label = customer.fullName ?? customer.email ?? 'this customer';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text(
          'This will remove $label from this organization and disable their '
          'login. Existing app access will stop when their current session '
          'expires or refreshes.',
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
    if (!context.mounted) return;

    // This list is a ConsumerWidget that can be rebuilt/unmounted while the
    // delete Edge Function call is in flight (e.g. a Supabase token refresh
    // fires onAuthStateChange, which re-runs the router guard), making its
    // `ref` unsafe to touch afterwards. The root container and the messenger
    // both outlive this widget, so capture them up front and drive the
    // post-await refresh through the container.
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final repo = container.read(infraRepositoryProvider);
      final org = await container.read(infraWorkspaceProvider.future);
      await repo.deleteCustomerUser(
        organizationId: org.id,
        userId: customer.userId,
      );
      container.invalidate(customerMembersProvider);
      messenger.showSnackBar(SnackBar(content: Text('$label deleted.')));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete customer: ${_clean(error)}')),
      );
    }
  }

  Widget _dialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    bool obscure = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  String _clean(Object error) {
    final text = error.toString();
    final marker = RegExp(r'error: ([^}]+)');
    final match = marker.firstMatch(text);
    return match?.group(1)?.trim() ?? text;
  }
}

enum _CustomerAction { projects, edit, delete }
