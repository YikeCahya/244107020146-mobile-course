import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/preferences_service.dart';
import 'providers/app_providers.dart';
import 'ui/notes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesService();
  final previousOpen = await preferences.recordOpenAndGetPrevious();
  runApp(
    ProviderScope(
      overrides: [previousOpenProvider.overrideWithValue(previousOpen)],
      child: const OfflineNotesApp(),
    ),
  );
}

class OfflineNotesApp extends ConsumerWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Catatan Offline',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: theme.asData?.value == true ? ThemeMode.dark : ThemeMode.light,
      home: const NotesPage(),
    );
  }
}
