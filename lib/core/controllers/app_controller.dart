import 'package:flutter/material.dart';

import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

class AppController extends ChangeNotifier {
  AppController(this._profileRepository);

  final ProfileRepository _profileRepository;

  UserProfile? _profile;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;

  UserProfile get profile => _profile ?? UserProfile.guest();
  bool get isLoaded => _isLoaded;
  bool get isLoggedIn => _profile?.isLoggedIn ?? false;
  bool get isRegistered => _profile?.isRegistered ?? false;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    try {
      _profile = await _profileRepository.getCurrentUser();
      _themeMode = _themeModeFromString(profile.themeMode);
      _isLoaded = true;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Failed to load current user: $error');
      debugPrintStack(stackTrace: stackTrace);

      _profile = null;
      _themeMode = ThemeMode.system;
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _profile = await _profileRepository.register(
      displayName: displayName,
      email: email,
      password: password,
    );

    _themeMode = _themeModeFromString(profile.themeMode);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _profile = await _profileRepository.login(
      email: email,
      password: password,
    );

    _themeMode = _themeModeFromString(profile.themeMode);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _profileRepository.logout();

    _profile = null;
    _themeMode = ThemeMode.system;
    _isLoaded = true;

    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final savedProfile = await _profileRepository.saveProfile(profile);

    _profile = savedProfile.copyWith(isLoggedIn: true);
    _themeMode = _themeModeFromString(_profile!.themeMode);

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    if (_profile == null) {
      notifyListeners();
      return;
    }

    final updatedProfile = _profile!.copyWith(
      themeMode: _themeModeToString(mode),
      updatedAt: DateTime.now(),
    );

    _profile = updatedProfile;
    notifyListeners();

    try {
      _profile = await _profileRepository.saveProfile(updatedProfile);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Failed to save theme mode: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  ThemeMode _themeModeFromString(String value) {
    final normalized = value.toLowerCase().trim();

    if (normalized == 'dark' || normalized == 'thememode.dark') {
      return ThemeMode.dark;
    }

    if (normalized == 'light' || normalized == 'thememode.light') {
      return ThemeMode.light;
    }

    return ThemeMode.system;
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}