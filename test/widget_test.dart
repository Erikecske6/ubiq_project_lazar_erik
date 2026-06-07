import 'package:flutter_test/flutter_test.dart';
import 'package:plant_app/core/controllers/app_controller.dart';
import 'package:plant_app/data/database/app_database.dart';
import 'package:plant_app/data/repositories/plant_repository.dart';
import 'package:plant_app/data/repositories/profile_repository.dart';
import 'package:plant_app/main.dart';
import 'package:plant_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlantRepository plantRepository;
  late ProfileRepository profileRepository;
  late NotificationService notificationService;
  late AppController appController;

  setUp(() async {
    sqfliteFfiInit();

    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await AppDatabase.instance.useDatabaseForTesting(database);

    plantRepository = PlantRepository();
    profileRepository = ProfileRepository();
    notificationService = NotificationService();
    appController = AppController(profileRepository);

    await plantRepository.ensureSeedData();
    await appController.load();
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTesting();
  });

  testWidgets('App loads and shows landing page', (tester) async {
    await tester.pumpWidget(
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

    expect(find.text('PlantApp'), findsOneWidget);
  });
}