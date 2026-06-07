import 'package:flutter_test/flutter_test.dart';
import 'package:plant_app/data/database/app_database.dart';
import 'package:plant_app/data/models/plant.dart';
import 'package:plant_app/data/repositories/plant_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late PlantRepository repository;

  setUp(() async {
    sqfliteFfiInit();

    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await AppDatabase.instance.useDatabaseForTesting(database);

    repository =PlantRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTesting();
  });

  test('creates and reads a plant', () async {
    final now = DateTime.now();

    await repository.addPlant(
      Plant(
        name: 'Test Plant',
        species: 'Test Species',
        notes: 'Test Notes',
        wateringIntervalDays: 7,
        lastWateredAt: now,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final plants = await repository.getPlants();

    expect(plants.length, 1);
    expect(plants.first.name, 'Test Plant');
  });

  test('updates a plant', () async {
    final now = DateTime.now();

    await repository.addPlant(
      Plant(
        name: 'Old Name',
        species: 'Species',
        notes: 'Notes',
        wateringIntervalDays: 7,
        lastWateredAt: now,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final plant = (await repository.getPlants()).first;

    await repository.updatePlant(
      plant.copyWith(name: 'New Name'),
    );

    final updatedPlant = (await repository.getPlants()).first;

    expect(updatedPlant.name, 'New Name');
  });

  test('deletes a plant', () async {
    final now = DateTime.now();

    await repository.addPlant(
      Plant(
        name: 'Delete Me',
        species: 'Species',
        notes: 'Notes',
        wateringIntervalDays: 7,
        lastWateredAt: now,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final plant = (await repository.getPlants()).first;

    await repository.deletePlant(plant.id!);

    final plants = await repository.getPlants();

    expect(plants, isEmpty);
  });

  test('marks favorite', () async {
    final now = DateTime.now();

    await repository.addPlant(
      Plant(
        name: 'Favorite Test',
        species: 'Species',
        notes: 'Notes',
        wateringIntervalDays: 7,
        lastWateredAt: now,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final plant = (await repository.getPlants()).first;

    await repository.toggleFavorite(plant);

    final updatedPlant = (await repository.getPlants()).first;

    expect(updatedPlant.isFavorite, true);
  });
}