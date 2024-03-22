import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

abstract class IBaseService {
  final String url;
  IBaseService({required this.url});
  late final Dio dio = createDio();
  Dio createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: url,
      receiveTimeout: const Duration(seconds: 2),
      connectTimeout: const Duration(seconds: 2),
      sendTimeout: const Duration(seconds: 2),
    ));
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () => HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    return dio;
  }

  void dispose();
}
