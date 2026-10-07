import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
 
/// Satu-satunya tempat konfigurasi Dio (baseUrl + timeout).
/// Repository menerima Dio dari provider ini, sehingga konfigurasi
/// tidak tersebar di tiap method.
const _timeout = Duration(seconds: 10);
 
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: "https://jsonplaceholder.typicode.com",
      connectTimeout: _timeout, // batas waktu membuat koneksi
      sendTimeout: _timeout, // batas waktu mengirim request
      receiveTimeout: _timeout, // batas waktu menerima response
      headers: {"Accept": "application/json"},
    ),
  );
});
 