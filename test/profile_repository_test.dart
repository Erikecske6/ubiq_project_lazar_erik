import 'package:flutter_test/flutter_test.dart';
import 'package:plant_app/data/database/app_database.dart';
import 'package:plant_app/data/models/user_profile.dart';
import 'package:plant_app/data/repositories/profile_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late ProfileRepository repository;

  setUp(() async {
    sqfliteFfiInit();

    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await AppDatabase.instance.useDatabaseForTesting(database);

    repository = ProfileRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTesting();
  });

  test('returns default profile', () async {
    final profile = await repository.getProfile();

    expect(profile.id, UserProfile.defaultId);
    expect(profile.displayName, isNotEmpty);
  });

  test('should save profile customization and theme', () async {
    final profile = UserProfile.defaults().copyWith(
      displayName: 'Example',
      email: 'example@example.com',
      bio: 'Plant collector',
      avatarEmoji: '🌵',
      themeMode: 'dark',
    );

    await repository.saveProfile(profile);

    final saved = await repository.getProfile();

    expect(saved.displayName, 'Example');
    expect(saved.email, 'example@example.com');
    expect(saved.bio, 'Plant collector');
    expect(saved.avatarEmoji, '🌵');
    expect(saved.themeMode, 'dark');
  });
}