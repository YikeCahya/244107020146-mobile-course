import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return 'Server mengembalikan kesalahan (${statusCode ?? 'tidak diketahui'}).';
      default:
        return 'Terjadi kesalahan jaringan. Silakan coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
