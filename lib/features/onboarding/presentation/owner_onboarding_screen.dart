import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';

class OwnerOnboardingScreen extends StatelessWidget {
  const OwnerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner onboarding')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Set up your internal ledger',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a business, default book, app lock, and INR preferences.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.businessSetup),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Create business'),
          ),
        ],
      ),
    );
  }
}
