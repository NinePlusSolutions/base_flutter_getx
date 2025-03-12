import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

class InterceptorClient extends Interceptor {
  final Dio dio;

  InterceptorClient(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.token;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    log(
      """
        url(${options.method}): ${options.uri},
        headers:${jsonEncode(options.headers)},
        data: ${jsonEncode(options.data)},
      """,
      name: 'API_REQUEST',
    );

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      """
        url(${response.requestOptions.method}): ${response.requestOptions.uri},
        headers:${jsonEncode(response.requestOptions.headers)},
        data: ${jsonEncode(response.data)},
      """,
      name: 'API_RESPONSE',
    );
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);

    log(
      """
        url(${err.requestOptions.method}): ${err.requestOptions.uri},
        headers:${jsonEncode(err.requestOptions.headers)},
        data: ${jsonEncode(err.response?.data)},
        error: ${err.message},
      """,
      name: 'API_ERROR',
    );
  }
}
