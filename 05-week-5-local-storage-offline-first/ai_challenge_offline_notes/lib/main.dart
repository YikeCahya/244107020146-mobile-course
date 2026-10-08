import 'package:flutter/material.dart';

import 'data/theme_preferences.dart';
import 'pages/notes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isDarkMode = await ThemePreferences().load();
  runApp(OfflineNotesApp(initialDarkMode: isDarkMode));
}

class OfflineNotesApp extends StatefulWidget {
  const OfflineNotesApp({required this.initialDarkMode, super.key});

  final bool initialDarkMode;

  @override
  State<OfflineNotesApp> createState() => _OfflineNotesAppState();
}

class _OfflineNotesAppState extends State<OfflineNotesApp> {
  late bool _isDarkMode = widget.initialDarkMode;
  final _themePreferences = ThemePreferences();

  Future<void> _setDarkMode(bool value) async {
    await _themePreferences.save(value);
    if (mounted) {
      setState(() => _isDarkMode = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Offline',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF476B5A)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8AB9A0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: NotesPage(
        isDarkMode: _isDarkMode,
        onDarkModeChanged: _setDarkMode,
      ),
    );
  }
}
