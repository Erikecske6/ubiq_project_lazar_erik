import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/plant.dart';

class PlantRepository {
  PlantRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Plant>> getPlants({
    String query = '',
    bool favoritesOnly = false,
  }) async {
    final db = await _database.database;
    final userId = await _requireCurrentUserId(db);

    final whereParts = <String>['user_id = ?'];
    final whereArgs = <Object?>[userId];

    if (query.trim().isNotEmpty) {
      whereParts.add('(name LIKE ? OR species LIKE ? OR notes LIKE ?)');
      final pattern = '%${query.trim()}%';
      whereArgs.addAll([pattern, pattern, pattern]);
    }

    if (favoritesOnly) {
      whereParts.add('is_favorite = ?');
      whereArgs.add(1);
    }

    final maps = await db.query(
      'plants',
      where: whereParts.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'is_favorite DESC, name COLLATE NOCASE ASC',
    );

    return maps.map(Plant.fromMap).toList();
  }

  Future<List<Plant>> getPlantsNeedingCareToday() async {
    final plants = await getPlants();

    return plants.where((plant) => plant.needsWaterToday).toList();
  }

  Future<int> addPlant(Plant plant) async {
    final db = await _database.database;
    final userId = await _requireCurrentUserId(db);
    final now = DateTime.now();

    final plantMap = plant
        .copyWith(
          userId: userId,
          createdAt: now,
          updatedAt: now,
        )
        .toMap();

    plantMap.remove('id');

    return db.insert(
      'plants',
      plantMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await _database.database;
    final userId = await _requireCurrentUserId(db);

    if (plant.id == null) {
      throw ArgumentError('Cannot update a plant without an id.');
    }

    return db.update(
      'plants',
      plant
          .copyWith(
            userId: userId,
            updatedAt: DateTime.now(),
          )
          .toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [plant.id, userId],
    );
  }

  Future<int> deletePlant(int id) async {
    final db = await _database.database;
    final userId = await _requireCurrentUserId(db);

    return db.delete(
      'plants',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<void> toggleFavorite(Plant plant) async {
    await updatePlant(
      plant.copyWith(
        isFavorite: !plant.isFavorite,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> markWatered(Plant plant) async {
    await updatePlant(
      plant.copyWith(
        lastWateredAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteAllPlants() async {
    final db = await _database.database;
    final userId = await _requireCurrentUserId(db);

    await db.delete(
      'plants',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> ensureSeedData() async {
    final db = await _database.database;
    final userId = await _currentUserId(db);

    if (userId == null) {
      return;
    }

    final existingPlants = await getPlants();

    if (existingPlants.isNotEmpty) {
      return;
    }

    await addPlant(
      Plant.demo(
        userId: userId,
        name: 'Monstera',
        species: 'Monstera deliciosa',
        notes: 'Likes bright indirect light and slightly moist soil.',
        wateringIntervalDays: 7,
        isFavorite: true,
      ),
    );

    await addPlant(
      Plant.demo(
        userId: userId,
        name: 'Snake Plant',
        species: 'Dracaena trifasciata',
        notes: 'Very tolerant plant. Avoid overwatering.',
        wateringIntervalDays: 14,
      ),
    );

    await addPlant(
      Plant.demo(
        userId: userId,
        name: 'Peace Lily',
        species: 'Spathiphyllum',
        notes: 'Leaves droop when thirsty. Likes humidity.',
        wateringIntervalDays: 5,
      ),
    );
  }

  Future<int> _requireCurrentUserId(Database db) async {
    final userId = await _currentUserId(db);

    if (userId == null) {
      throw Exception('You must be logged in to manage plants.');
    }

    return userId;
  }

  Future<int?> _currentUserId(Database db) async {
    final rows = await db.query(
      'app_state',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['current_user_id'] as int?;
  }
}