import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/providers/stats_provider.dart';

class FakeRandomSuccess implements Random {
  @override
  double nextDouble() => 0.5;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRandomFailure implements Random {
  @override
  double nextDouble() => 0.1;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('StatsNotifier Unit Tests', () {
    test('Mengembalikan 3 item statistik saat proses sukses', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => StatsNotifier(FakeRandomSuccess())),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(statsProvider.future);

      expect(result.length, equals(3));
      expect(result[0].label, equals('Total Pengguna'));
      expect(container.read(statsProvider), isA<AsyncData<List<StatItem>>>());
    });

    test('Mengeluarkan AsyncError saat simulasi gagal 30%', () async {
  final container = ProviderContainer(
    retry: (retryCount, error) => null, // matikan retry otomatis di test
    overrides: [
      statsProvider.overrideWith(() => StatsNotifier(FakeRandomFailure())),
    ],
  );
  addTearDown(container.dispose);

  // expectLater menangkap exception dari .future secara resmi
  await expectLater(
    container.read(statsProvider.future),
    throwsA(isA<Exception>()),
  );

  final state = container.read(statsProvider);
  expect(state, isA<AsyncError<List<StatItem>>>());
  expect(state.hasError, isTrue);
  expect(state.error.toString(), contains('Gagal memuat statistik'));
});
  });
}