import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  Future<bool> getDarkMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, value);
  }

  Future<String?> recordOpenAndGetPrevious() async {
    final preferences = await SharedPreferences.getInstance();
    final previous = preferences.getString(_lastOpenedKey);
    await preferences.setString(
      _lastOpenedKey,
      DateTime.now().toIso8601String(),
    );
    return previous;
  }
}
