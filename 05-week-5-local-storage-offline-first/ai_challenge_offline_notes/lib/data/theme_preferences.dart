import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const _darkModeKey = 'dark_mode';

  Future<bool> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_darkModeKey) ?? false;
  }

  Future<void> save(bool isDarkMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, isDarkMode);
  }
}
