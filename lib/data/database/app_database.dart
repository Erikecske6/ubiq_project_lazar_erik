import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String databaseName = 'plant_app_final.db';

  // Increased because plants now belong to users.
  static const int databaseVersion = 4;

  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;

    if (existingDatabase != null && existingDatabase.isOpen) {
      return existingDatabase;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, databaseName);

    _database = await openDatabase(
      path,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _ensureSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _ensureSchema(db);
      },
      onOpen: (db) async {
        await _ensureSchema(db);
      },
    );

    return _database!;
  }

  Future<void> _ensureSchema(Database db) async {
    // Old single-profile table is no longer used.
    await db.execute('DROP TABLE IF EXISTS profile');

    await _repairUsersTableIfNeeded(db);
    await _createUsersTable(db);

    await _repairAppStateTableIfNeeded(db);
    await _createAppStateTable(db);
    await _seedAppState(db);

    await _repairPlantsTableIfNeeded(db);
    await _createPlantsTable(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        display_name TEXT NOT NULL COLLATE NOCASE UNIQUE,
        email TEXT NOT NULL COLLATE NOCASE UNIQUE,
        bio TEXT NOT NULL,
        avatar_emoji TEXT NOT NULL,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        password_hash TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAppStateTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_state(
        id INTEGER PRIMARY KEY CHECK(id = 1),
        current_user_id INTEGER,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(current_user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _createPlantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS plants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        notes TEXT NOT NULL,
        watering_interval_days INTEGER NOT NULL,
        last_watered_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _seedAppState(Database db) async {
    await db.insert(
      'app_state',
      {
        'id': 1,
        'current_user_id': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _repairUsersTableIfNeeded(Database db) async {
    final exists = await _tableExists(db, 'users');

    if (!exists) return;

    final columns = await _columnNames(db, 'users');

    final requiredColumns = <String>{
      'id',
      'display_name',
      'email',
      'bio',
      'avatar_emoji',
      'theme_mode',
      'password_hash',
      'created_at',
      'updated_at',
    };

    final isValid = requiredColumns.every(columns.contains);

    if (!isValid) {
      await db.execute('DROP TABLE IF EXISTS users');
    }
  }

  Future<void> _repairAppStateTableIfNeeded(Database db) async {
    final exists = await _tableExists(db, 'app_state');

    if (!exists) return;

    final columns = await _columnNames(db, 'app_state');

    final requiredColumns = <String>{
      'id',
      'current_user_id',
      'updated_at',
    };

    final isValid = requiredColumns.every(columns.contains);

    if (!isValid) {
      await db.execute('DROP TABLE IF EXISTS app_state');
    }
  }

  Future<void> _repairPlantsTableIfNeeded(Database db) async {
    final exists = await _tableExists(db, 'plants');

    if (!exists) return;

    final columns = await _columnNames(db, 'plants');

    final requiredColumns = <String>{
      'id',
      'user_id',
      'name',
      'species',
      'notes',
      'watering_interval_days',
      'last_watered_at',
      'is_favorite',
      'created_at',
      'updated_at',
    };

    final isValid = requiredColumns.every(columns.contains);

    if (!isValid) {
      await db.execute('DROP TABLE IF EXISTS plants');
    }
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      '''
      SELECT name FROM sqlite_master
      WHERE type = 'table' AND name = ?
      ''',
      [tableName],
    );

    return result.isNotEmpty;
  }

  Future<Set<String>> _columnNames(Database db, String tableName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');

    return result
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();
  }

  Future<void> close() async {
    final existingDatabase = _database;

    if (existingDatabase != null && existingDatabase.isOpen) {
      await existingDatabase.close();
    }

    _database = null;
  }

  Future<void> useDatabaseForTesting(Database database) async {
    await close();
    _database = database;
    await _ensureSchema(database);
  }

  Future<void> resetForTesting() async {
    await close();
  }
}