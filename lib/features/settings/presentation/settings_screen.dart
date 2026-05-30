import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/ledger_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _upiController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                Text('Could not load business profile: $error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(businessProfileProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (!_initialized) {
            _nameController.text = profile.name;
            _ownerController.text = profile.ownerName ?? '';
            _phoneController.text = profile.phone ?? '';
            _upiController.text = profile.upiId ?? '';
            _gstinController.text = profile.gstin ?? '';
            _addressController.text = profile.address ?? '';
            _initialized = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Business profile',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _field(_nameController, 'Business name', Icons.store_outlined),
              const SizedBox(height: 12),
              _field(_ownerController, 'Owner name', Icons.person_outline),
              const SizedBox(height: 12),
              _field(_phoneController, 'Phone', Icons.phone_outlined,
                  keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_upiController, 'UPI ID (for payment QR)',
                  Icons.qr_code_2_outlined),
              const SizedBox(height: 12),
              _field(_gstinController, 'GSTIN', Icons.receipt_long_outlined),
              const SizedBox(height: 12),
              _field(_addressController, 'Address', Icons.location_on_outlined,
                  maxLines: 3),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving ? null : () => _save(profile.id),
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save settings'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _save(String businessId) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_nameController.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Business name is required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(ledgerRepositoryProvider).updateBusinessProfile(
            businessId: businessId,
            name: _nameController.text,
            ownerName: _ownerController.text,
            phone: _phoneController.text,
            upiId: _upiController.text,
            gstin: _gstinController.text,
            address: _addressController.text,
          );
      ref.invalidate(businessProfileProvider);
      ref.invalidate(businessNameProvider);
      ref.invalidate(ledgerWorkspaceProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
