import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/models/plant.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'plant_care_channel',
    'Plant care reminders',
    channelDescription: 'Notifications for plant watering and care actions.',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const DarwinNotificationDetails _iosDetails =
      DarwinNotificationDetails();

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showTestNotification() async {
    await init();

    await _notifications.show(
      id: 1,
      title: 'PlantApp notification',
      body: 'Local notifications are working.',
      notificationDetails: _notificationDetails,
    );
  }

  Future<void> showPlantWateredNotification(Plant plant) async {
    await init();

    final notificationId = plant.id ?? _safeNotificationId();

    await _notifications.show(
      id: notificationId,
      title: '${plant.name} watered',
      body: 'Great job! Next watering: ${plant.nextWateringLabel}.',
      notificationDetails: _notificationDetails,
    );
  }

  int _safeNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  }
}