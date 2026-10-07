import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio createDio() {
  const timeout = Duration(seconds: 10);
  return Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: timeout,
      sendTimeout: timeout,
      receiveTimeout: timeout,
      headers: const {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (message) => debugPrint(message.toString()),
      ),
    );
}
