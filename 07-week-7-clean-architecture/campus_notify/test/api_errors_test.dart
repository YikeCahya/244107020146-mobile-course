import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/api_errors.dart';

DioException _err(DioExceptionType type, {int? status}) {
  final req = RequestOptions(path: '/');
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: req, statusCode: status),
  );
}

void main() {
  test('401 -> sesi berakhir', () {
    final e = _err(DioExceptionType.badResponse, status: 401);
    expect(friendlyMessage(e), 'Sesi berakhir. Silakan login ulang.');
  });

  test('timeout -> koneksi terlalu lama', () {
    final e = _err(DioExceptionType.receiveTimeout);
    expect(friendlyMessage(e), 'Koneksi terlalu lama. Coba lagi.');
  });

  test('offline -> tidak ada koneksi', () {
    final e = _err(DioExceptionType.connectionError);
    expect(friendlyMessage(e), 'Tidak ada koneksi internet.');
  });

  test('error non-Dio -> pesan umum', () {
    expect(friendlyMessage(Exception('x')), 'Terjadi kesalahan. Coba lagi.');
  });
}