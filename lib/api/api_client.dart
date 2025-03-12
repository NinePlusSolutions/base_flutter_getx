import 'package:dio/dio.dart' as dio;
import 'package:flutter_getx_boilerplate/api/interceptor.dart';
import 'package:flutter_getx_boilerplate/flavors.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

class ApiServices extends GetxService {
  late final dio.Dio _dio;

  @override
  void onInit() {
    super.onInit();

    final baseUrl = F.appFlavor?.toBaseurl ?? '';

    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    _dio.interceptors.addAll(
      [
        InterceptorClient(_dio),
      ],
    );
  }

  Future<dio.Response> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<dio.Response> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<dio.Response> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<dio.Response> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future download(
    String path,
    dynamic savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = dio.Headers.contentLengthHeader,
    Object? data,
    dio.Options? options,
  }) {
    return _dio.download(
      path,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

  Future<dio.Response> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
