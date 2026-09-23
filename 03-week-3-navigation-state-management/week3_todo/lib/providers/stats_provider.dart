import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';

class StatItem {
  final String label;
  final String value;

  const StatItem({required this.label, required this.value});
}

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  final Random _random;
  final Duration _delay;

  StatsNotifier([Random? random, Duration? delay])
      : _random = random ?? Random(),
        _delay = delay ?? const Duration(seconds: 1);

  @override
  Future<List<StatItem>> build() async {
    return _fetchStats();
  }

  Future<List<StatItem>> _fetchStats() async {
    final todos = ref.watch(todoListProvider);

    if (_delay > Duration.zero) {
      await Future.delayed(_delay);
    }

    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat statistik dari server');
    }

    final totalTugas = todos.length;
    final tugasSelesai = todos.where((t) => t.done).length;
    final persentase = totalTugas == 0
        ? 0
        : ((tugasSelesai / totalTugas) * 100).round();

    return [
      StatItem(label: 'Total Tugas', value: '$totalTugas'),
      StatItem(label: 'Tugas Selesai', value: '$tugasSelesai'),
      StatItem(label: 'Tingkat Penyelesaian', value: '$persentase%'),
    ];
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);