import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/plant_repository.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/responsive_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRegisterMode = true;
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final appController = context.read<AppController>();

    if (_isRegisterMode) {
      await appController.register(
        displayName: _displayNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await appController.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    await context.read<PlantRepository>().ensureSeedData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isRegisterMode
              ? 'Account created successfully.'
              : 'Login successful.',
        ),
      ),
    );

    context.go('/plants');
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _switchMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'Create account' : 'Login'),
      ),
      body: ResponsivePage(
        maxWidth: 520,
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_florist, size: 56),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _isRegisterMode
                            ? 'Create a local PlantApp account'
                            : 'Login to your local account',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _isRegisterMode
                            ? 'You can create multiple accounts using different emails.'
                            : 'Use the email and password you registered with.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (_isRegisterMode) ...[
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (!_isRegisterMode) return null;

                            if (value == null || value.trim().isEmpty) {
                              return 'Display name is required.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

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

                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Enter a valid email.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = value ?? '';

                          if (password.isEmpty) {
                            return 'Password is required.';
                          }

                          if (password.trim().length < 4) {
                            return 'Use at least 4 characters.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _isRegisterMode
                                      ? Icons.person_add
                                      : Icons.login,
                                ),
                          label: Text(_isRegisterMode ? 'Register' : 'Login'),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      TextButton(
                        onPressed: _isLoading ? null : _switchMode,
                        child: Text(
                          _isRegisterMode
                              ? 'Already have an account? Login'
                              : 'No account? Register',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}