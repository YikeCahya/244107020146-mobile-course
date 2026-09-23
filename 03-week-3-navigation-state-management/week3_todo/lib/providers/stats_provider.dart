import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatItem {
  final String label;
  final String value;

  const StatItem({required this.label, required this.value});
}

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  final Random _random;
  final Duration _delay;

  // Default delay 2 detik untuk aplikasi, tapi bisa 0 detik saat unit test
  StatsNotifier([Random? random, Duration? delay])
      : _random = random ?? Random(),
        _delay = delay ?? const Duration(seconds: 2);

  @override
  Future<List<StatItem>> build() async {
    return _fetchStats();
  }

  Future<List<StatItem>> _fetchStats() async {
    if (_delay > Duration.zero) {
      await Future.delayed(_delay);
    }

    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat statistik dari server');
    }

    return const [
      StatItem(label: 'Total Pengguna', value: '1.240'),
      StatItem(label: 'Tugas Selesai', value: '856'),
      StatItem(label: 'Tingkat Keaktifan', value: '87%'),
    ];
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);