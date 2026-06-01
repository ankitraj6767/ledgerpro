import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/navdream_logo.dart';

/// Real organization setup. Saves org name/owner/phone/address before
/// continuing. If a workspace already exists, this still updates the details.
class OrganizationSetupScreen extends ConsumerStatefulWidget {
  const OrganizationSetupScreen({super.key});

  @override
  ConsumerState<OrganizationSetupScreen> createState() =>
      _OrganizationSetupScreenState();
}

class _OrganizationSetupScreenState
    extends ConsumerState<OrganizationSetupScreen> {
  final _orgName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _orgName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your organization')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const NavdreamLogo(
                size: 58,
                borderRadius: BorderRadius.all(Radius.circular(17)),
                showBorder: true,
                showShadow: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Welcome to ${AppConstants.appName}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Create your organization to start managing projects.'),
          const SizedBox(height: 20),
          TextField(
            controller: _orgName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Organization name',
              prefixIcon: Icon(Icons.apartment),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ownerName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Owner name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward),
            label: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_orgName.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Organization name is required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(infraRepositoryProvider);
      final org = await repo.ensureWorkspace(orgName: _orgName.text.trim());
      await repo.updateOrganization(
        organizationId: org.id,
        name: _orgName.text.trim(),
        ownerName: _ownerName.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
      );
      ref.invalidate(infraWorkspaceProvider);
      ref.invalidate(organizationProfileProvider);
      if (mounted) context.go(AppRoutes.home);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save organization: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
