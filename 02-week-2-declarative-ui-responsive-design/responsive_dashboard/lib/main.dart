import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Konstanta breakpoint layar lebar
const double kWideBreakpoint = 700;

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicHomePage(
        isDark: isDark,
        onThemeChanged: (val) => setState(() => isDark = val),
      ),
    );
  }
}

class AcademicHomePage extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const AcademicHomePage({
    required this.isDark,
    required this.onThemeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Semantics(
            label: 'Ubah Tema',
            toggled: isDark,
            child: CupertinoSwitch(
              value: isDark,
              onChanged: onThemeChanged,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Menggunakan konstanta breakpoint tunggal
          final cols = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ProfileHeaderCard(),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
                children: const [
                  InfoCard(title: 'IPK', value: '3.85'),
                  InfoCard(title: 'Presensi', value: '95%'),
                  InfoCard(title: 'Tugas', value: '4 Selesai'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// Widget reusable untuk Header Profil
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Profil Mahasiswa',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yulike Dwi Nurcahyani',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: 244107020146',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reusable untuk Kartu Metrik (InfoCard)
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title: $value',
      readOnly: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}