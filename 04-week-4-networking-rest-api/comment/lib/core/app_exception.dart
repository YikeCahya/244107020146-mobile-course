import "package:dio/dio.dart";
 
/// Exception aplikasi yang membawa pesan ramah pengguna.
/// Repository melempar ini sehingga UI/provider tidak perlu tahu soal Dio.
class AppException implements Exception {
  final String message;
  final Object? cause;
  const AppException(this.message, [this.cause]);
 
  @override
  String toString() => message;
}
 
/// Memetakan error apa pun menjadi pesan ramah pengguna.
/// Dipakai di UI: `friendlyErrorMessage(asyncError.error)`.
String friendlyErrorMessage(Object error) {
  if (error is AppException) return error.message;
  if (error is DioException) return _fromDio(error);
  return "Terjadi kesalahan tak terduga. Silakan coba lagi.";
}
 
String _fromDio(DioException e) {
  switch (e.type) {
    // Semua jenis timeout dijadikan satu pesan.
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return "Koneksi terlalu lama merespons. Silakan coba lagi.";
 
    // Tidak ada internet / server tidak terjangkau.
    case DioExceptionType.connectionError:
      return "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
 
    // Server menjawab dengan status error: bedakan 404, 5xx, dan lainnya.
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode ?? 0;
      if (code == 404) return "Data yang dicari tidak ditemukan.";
      if (code >= 500) {
        return "Server sedang bermasalah. Silakan coba beberapa saat lagi.";
      }
      return "Permintaan gagal (kode $code).";
 
    case DioExceptionType.badCertificate:
      return "Koneksi tidak aman. Sertifikat server tidak valid.";
 
    case DioExceptionType.cancel:
      return "Permintaan dibatalkan.";
 
    default:
      return "Terjadi kesalahan jaringan. Silakan coba lagi.";
  }
}