import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/user_profile.dart';
import '../../shared/widgets/responsive_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _avatarOptions = [
    '🌱',
    '🌿',
    '🪴',
    '🌵',
    '🌸',
    '🌻',
    '🍃',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  String _selectedAvatar = '🌱';

  @override
  void initState() {
    super.initState();

    final profile = context.read<AppController>().profile;

    _displayNameController = TextEditingController(text: profile.displayName);
    _emailController = TextEditingController(text: profile.email);
    _bioController = TextEditingController(text: profile.bio);
    _selectedAvatar = profile.avatarEmoji;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;

  final currentProfile = context.read<AppController>().profile;

  final updatedProfile = currentProfile.copyWith(
    displayName: _displayNameController.text.trim(),
    email: _emailController.text.trim(),
    bio: _bioController.text.trim(),
    avatarEmoji: _selectedAvatar,
    updatedAt: DateTime.now(),
  );

  try {
    await context.read<AppController>().saveProfile(updatedProfile);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved.')),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}

  void _syncControllersWithProfile(UserProfile profile) {
    if (_displayNameController.text != profile.displayName) {
      _displayNameController.text = profile.displayName;
    }

    if (_emailController.text != profile.email) {
      _emailController.text = profile.email;
    }

    if (_bioController.text != profile.bio) {
      _bioController.text = profile.bio;
    }

    if (_selectedAvatar != profile.avatarEmoji) {
      _selectedAvatar = profile.avatarEmoji;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();

    if (!appController.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ResponsivePage(
          maxWidth: 600,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 56),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'You are logged out',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Please log in to manage your profile.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: () => context.go('/auth'),
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final profile = appController.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsivePage(
        maxWidth: 700,
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _selectedAvatar,
                        key: ValueKey(_selectedAvatar),
                        style: const TextStyle(fontSize: 72),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (profile.email.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(profile.email),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    const Chip(
                      avatar: Icon(Icons.check_circle, size: 18),
                      label: Text('Logged in'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize profile',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Update your local profile information.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _avatarOptions.map((emoji) {
                          return ChoiceChip(
                            label: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            selected: _selectedAvatar == emoji,
                            onSelected: (_) {
                              setState(() {
                                _selectedAvatar = emoji;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Email is required.';
                          }

                          if (!email.contains('@')) {
                            return 'Enter a valid email.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _bioController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.edit_note),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('Save profile'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _syncControllersWithProfile(profile);
                            });
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Reset unsaved changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}