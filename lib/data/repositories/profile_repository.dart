import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<UserProfile?> getCurrentUser() async {
    final db = await _database.database;
    final currentUserId = await _getCurrentUserId(db);

    if (currentUserId == null) {
      return null;
    }

    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [currentUserId],
      limit: 1,
    );

    if (maps.isEmpty) {
      await _setCurrentUserId(db, null);
      return null;
    }

    return UserProfile.fromMap(
      maps.first,
      isLoggedIn: true,
    );
  }

  Future<List<UserProfile>> getAllUsers() async {
    final db = await _database.database;

    final maps = await db.query(
      'users',
      orderBy: 'display_name COLLATE NOCASE ASC',
    );

    return maps.map(UserProfile.fromMap).toList();
  }

  Future<UserProfile> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final db = await _database.database;

    final normalizedName = displayName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final passwordHash = _hashPassword(password);

    if (normalizedName.isEmpty) {
      throw Exception('Username is required.');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Enter a valid email address.');
    }

    if (password.trim().length < 4) {
      throw Exception('Password must contain at least 4 characters.');
    }

    final existingEmail = await _findUserByEmail(db, normalizedEmail);

    if (existingEmail != null) {
      throw Exception('An account with this email already exists. Please login.');
    }

    final existingName = await _findUserByDisplayName(db, normalizedName);

    if (existingName != null) {
      throw Exception('An account with this username already exists.');
    }

    final existingPassword = await _findUserByPasswordHash(db, passwordHash);

    if (existingPassword != null) {
      throw Exception('This password is already used by another account.');
    }

    final now = DateTime.now();

    final user = UserProfile(
      id: null,
      displayName: normalizedName,
      email: normalizedEmail,
      bio: 'I am growing a healthy plant collection.',
      avatarEmoji: '🌱',
      themeMode: UserProfile.defaultThemeMode,
      passwordHash: passwordHash,
      isLoggedIn: true,
      createdAt: now,
      updatedAt: now,
    );

    final userMap = user.toMap();
    userMap.remove('id');

    final id = await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    await _setCurrentUserId(db, id);

    return user.copyWith(
      id: id,
      isLoggedIn: true,
    );
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final db = await _database.database;

    final normalizedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Enter a valid email address.');
    }

    final userMap = await _findUserByEmail(db, normalizedEmail);

    if (userMap == null) {
      throw Exception('No account found with this email. Please register first.');
    }

    final user = UserProfile.fromMap(userMap);
    final enteredPasswordHash = _hashPassword(password);

    if (user.passwordHash != enteredPasswordHash) {
      throw Exception('Invalid password.');
    }

    await _setCurrentUserId(db, user.id);

    return user.copyWith(isLoggedIn: true);
  }

  Future<void> logout() async {
    final db = await _database.database;
    await _setCurrentUserId(db, null);
  }

  Future<UserProfile> saveProfile(UserProfile profile) async {
    final db = await _database.database;

    if (profile.id == null) {
      throw Exception('Cannot save a profile while logged out.');
    }

    final normalizedName = profile.displayName.trim();
    final normalizedEmail = profile.email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      throw Exception('Display name is required.');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Enter a valid email address.');
    }

    final duplicateEmail = await db.query(
      'users',
      where: 'LOWER(email) = ? AND id != ?',
      whereArgs: [normalizedEmail, profile.id],
      limit: 1,
    );

    if (duplicateEmail.isNotEmpty) {
      throw Exception('Another account already uses this email.');
    }

    final duplicateName = await db.query(
      'users',
      where: 'LOWER(display_name) = ? AND id != ?',
      whereArgs: [normalizedName.toLowerCase(), profile.id],
      limit: 1,
    );

    if (duplicateName.isNotEmpty) {
      throw Exception('Another account already uses this username.');
    }

    final updatedProfile = profile.copyWith(
      displayName: normalizedName,
      email: normalizedEmail,
      updatedAt: DateTime.now(),
    );

    final userMap = updatedProfile.toMap();
    userMap.remove('id');

    await db.update(
      'users',
      userMap,
      where: 'id = ?',
      whereArgs: [profile.id],
    );

    return updatedProfile.copyWith(isLoggedIn: true);
  }

  Future<Map<String, Object?>?> _findUserByEmail(
    Database db,
    String normalizedEmail,
  ) async {
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, Object?>?> _findUserByDisplayName(
    Database db,
    String displayName,
  ) async {
    final result = await db.query(
      'users',
      where: 'LOWER(display_name) = ?',
      whereArgs: [displayName.trim().toLowerCase()],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, Object?>?> _findUserByPasswordHash(
    Database db,
    String passwordHash,
  ) async {
    final result = await db.query(
      'users',
      where: 'password_hash = ?',
      whereArgs: [passwordHash],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int?> _getCurrentUserId(Database db) async {
    final rows = await db.query(
      'app_state',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      await _setCurrentUserId(db, null);
      return null;
    }

    return rows.first['current_user_id'] as int?;
  }

  Future<void> _setCurrentUserId(Database db, int? userId) async {
    await db.insert(
      'app_state',
      {
        'id': 1,
        'current_user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('plant_app_local_auth:${password.trim()}');
    return sha256.convert(bytes).toString();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}