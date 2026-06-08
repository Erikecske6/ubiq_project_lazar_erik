import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/controllers/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/repositories/plant_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'navigation/app_router.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final plantRepository = PlantRepository();
  final profileRepository = ProfileRepository();
  final notificationService = NotificationService();
  final appController = AppController(profileRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<PlantRepository>.value(value: plantRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider<AppController>.value(value: appController),
      ],
      child: const PlantApp(),
    ),
  );

  unawaited(
    _initializeApp(
      plantRepository: plantRepository,
      notificationService: notificationService,
      appController: appController,
    ),
  );
}

Future <void> _initializeApp({
  required PlantRepository plantRepository,
  required NotificationService notificationService,
  required AppController appController,
}) async {
  try {
    await AppDatabase.instance.database;
    await plantRepository.ensureSeedData();
    await appController.load();


    //await notificationService.init();
  } catch (error, stackTrace) {
    debugPrint('App initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class PlantApp extends StatelessWidget {
  const PlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PlantApp',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appController.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}