import 'package:flutter/material.dart';
//import 'package:plant_app/core/controllers/app_controller.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/plant.dart';
import '../../data/repositories/plant_repository.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/responsive_page.dart';

class CareTodayScreen extends StatefulWidget {
  const CareTodayScreen({super.key});

  @override
  State<CareTodayScreen> createState() => _CareTodayScreenState();
}

class _CareTodayScreenState extends State<CareTodayScreen> {
  List<Plant> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final plants = await context.read< PlantRepository>().getPlantsNeedingCareToday();

    if (!mounted) return;

    setState(() {
      _plants = plants;
      _isLoading = false;
    });
  }

  Future<void> _markWatered(Plant plant) async {
    await context.read<PlantRepository>().markWatered(plant);

    final updatedPlant = plant.copyWith(
      lastWateredAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await context
        .read<NotificationService>()
        .showPlantWateredNotification(updatedPlant);

    await _loadPlants();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plant.name} marked as watered.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Today'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadPlants,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ResponsivePage(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (_plants.isEmpty) {
      return const EmptyState(
        key: ValueKey('empty'),
        icon: Icons.check_circle_outline,
        title: 'All done',
        message: 'No plants need watering today.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlants,
      child: ListView.separated(
        key: const ValueKey('care-list'),
        itemCount: _plants.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final plant = _plants[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.mint,
                    child: Icon(Icons.water_drop, color: AppColors.water),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Last watered: ${plant.lastWateredLabel}\nInterval: ${plant.wateringIntervalDays} days',
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _markWatered(plant),
                    icon: const Icon(Icons.check),
                    label: const Text('Watered'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}