import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/widgets/access_denied_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _name = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _owner.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canEditSettings) {
      return const AccessDeniedScreen();
    }

    final orgAsync = ref.watch(organizationProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: orgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                Text(
                  'Could not load organization: $e',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(organizationProfileProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (org) {
          if (!_initialized) {
            _name.text = org.name;
            _owner.text = org.ownerName ?? '';
            _phone.text = org.phone ?? '';
            _address.text = org.address ?? '';
            _initialized = true;
          }
          return ResponsiveFormArea(
            maxWidth: 760,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Organization profile',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _field(_name, 'Organization name', Icons.apartment),
                const SizedBox(height: 12),
                _field(_owner, 'Owner name', Icons.person_outline),
                const SizedBox(height: 12),
                _field(
                  _phone,
                  'Phone',
                  Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _field(
                  _address,
                  'Address',
                  Icons.location_on_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _save(org.id),
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Future<void> _save(String orgId) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Organization name is required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(infraRepositoryProvider)
          .updateOrganization(
            organizationId: orgId,
            name: _name.text.trim(),
            ownerName: _owner.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
          );
      ref.invalidate(infraWorkspaceProvider);
      ref.invalidate(organizationProfileProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Settings saved.')));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
