import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/location_service.dart';
import '../../services/weather_services.dart';
import '../../shared/widgets/responsive_page.dart';

class WeatherAdviceScreen extends StatefulWidget {
  const WeatherAdviceScreen({super.key});

  @override
  State<WeatherAdviceScreen> createState() => _WeatherAdviceScreenState();
}

class _WeatherAdviceScreenState extends State<WeatherAdviceScreen> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  WeatherReading? _reading;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherAdvice();
  }

  @override
  void dispose() {
    _weatherService.close();
    super.dispose();
  }

  Future<void> _loadWeatherAdvice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final reading = await _weatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _reading = reading;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await _locationService.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Advice'),
        actions: [
          IconButton(
            tooltip: 'Refresh weather',
            onPressed: _loadWeatherAdvice,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ResponsivePage(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        key: ValueKey('weather-loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        key: const ValueKey('weather-error'),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 56, color: AppColors.danger),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Could not load weather',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openLocationSettings,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Location settings'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openAppSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('App settings'),
                    ),
                    FilledButton.icon(
                      onPressed: _loadWeatherAdvice,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final reading = _reading!;

    return ListView(
      key: const ValueKey('weather-success'),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.wb_sunny,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '${reading.temperature.toStringAsFixed(1)} °C',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  reading.conditionLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.water_drop),
                      label: Text('Humidity ${reading.humidity}%'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.umbrella),
                      label: Text(
                        'Rain ${reading.precipitation.toStringAsFixed(1)} mm',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plant care advice', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(reading.plantAdvice),
              ],
            ),
          ),
        ),
      ],
    );
  }
}