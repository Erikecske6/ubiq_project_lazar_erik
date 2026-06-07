import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _openNextPage();
  }

  Future<void> _openNextPage() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final appController = context.read<AppController>();

    if (!appController.isLoaded) {
      await appController.load();
    }

    if (!mounted) return;

    if (appController.isLoggedIn) {
      context.go('/plants');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.local_florist,
                  size: 64,
                  color: AppColors.leafGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'PlantApp',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Smart care for your plants',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}