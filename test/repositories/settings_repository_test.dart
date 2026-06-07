import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import '../../lib/data/repositories/settings_repository.dart';
import 'package:plant_app/data/repositories/settings_repository.dart';

void main() {
  late SettingsRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = SettingsRepository();
  });

  test('Username can be set and retrieved', () async {
    await repo.setUsername('Erik');
    final username = await repo.getUsername();
    expect(username, 'Erik');
  });

  test('Theme mode can be set and retrieved', () async {
    await repo.setThemeMode(true);
    final isDark = await repo.getThemeMode();
    expect(isDark, true);
  });
}