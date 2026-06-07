import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/repositories/plant_repository.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/responsive_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setThemeMode(BuildContext context, ThemeMode mode) async {
    await context.read<AppController>().updateThemeMode(mode);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme changed to ${mode.name}.')),
    );
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    await context.read<NotificationService>().showTestNotification();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification sent.')),
    );
  }

  Future<void> _resetDemoPlants(BuildContext context) async {
  final repository = context.read<PlantRepository>();

  await repository.deleteAllPlants();
  await repository.ensureSeedData();

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Demo plants restored.')),
  );
}

  Future<void> _logout(BuildContext context) async {
    await context.read<AppController>().logout();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out.')),
    );

    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppController>().themeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ResponsivePage(
        maxWidth: 760,
        child: ListView(
          children: [
            _AccountCard(
              onLogout: () => _logout(context),
            ),
            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme customization',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Choose how the app should look.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RadioListTile<ThemeMode>(
                      title: const Text('Use system theme'),
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      onChanged: (mode) {
                        if (mode != null) {
                          _setThemeMode(context, mode);
                        }
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light mode'),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: (mode) {
                        if (mode != null) {
                          _setThemeMode(context, mode);
                        }
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark mode'),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: (mode) {
                        if (mode != null) {
                          _setThemeMode(context, mode);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'This app uses local notifications.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () => _sendTestNotification(context),
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Send test notification'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Restore the default sample plants for testing.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => _resetDemoPlants(context),
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore demo plants'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About PlantApp',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'PlantApp is a SQLite-only plant care app with local authentication, '
                      'plant CRUD, weather advice, profile customization, and local notifications.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, appController, child) {
        final profile = appController.profile;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),

                if (!appController.isLoggedIn) ...[
                  const Text(
                    'You are currently logged out. Log in to manage your profile.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => context.go('/auth'),
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(profile.avatarEmoji),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.displayName),
                            if (profile.email.isNotEmpty) Text(profile.email),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person),
                        label: const Text('Manage profile'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}