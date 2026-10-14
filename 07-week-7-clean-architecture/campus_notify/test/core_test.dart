import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/2'}), '/pengumuman/2');
    expect(routeFromMessage({'route': '/pengumuman/2'}), '/pengumuman/2');
  });

  test('formatDate memakai bulan Indonesia', () {
    expect(formatDate(DateTime(2026, 10, 10)), '10 Okt 2026');
    expect(formatDate(DateTime(2026, 8, 17)), '17 Agu 2026');
  });

  test('FailureException hanya menampilkan pesan ramah', () {
    const e = FailureException(LocalFailure('Gagal login. Coba lagi.'));
    expect('$e', 'Gagal login. Coba lagi.');
  });
}