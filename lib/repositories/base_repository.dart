import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/services/storage_service.dart';
import 'package:get/get.dart' as g;

abstract class BaseRepository {
  ErrorResponse errorHandler(Response res) {
    switch (res.statusCode) {
      case 401:
        StorageService.clear();
        NavigatorHelper.toAuth();
        return ErrorResponse(
          message: res.data["message"] ?? 'Unauthorized',
          statusCode: res.statusCode ?? 500,
        );

      default:
        return ErrorResponse(
          message: res.data["message"] ?? 'Unknown Error',
          statusCode: res.statusCode ?? 500,
        );
    }
  }

  ErrorResponse handleError(DioException e) {
    final type = e.type;

    switch (type) {
      case DioExceptionType.connectionError:
        return ErrorResponse(
          message: 'connect_error'.tr,
        );
      case DioExceptionType.sendTimeout:
        return ErrorResponse(
          message: 'send_timeout'.tr,
        );

      case DioExceptionType.receiveTimeout:
        return ErrorResponse(
          message: 'receive_timeout'.tr,
        );

      case DioExceptionType.badResponse:
        return errorHandler(e.response!);

      case DioExceptionType.cancel:
        return ErrorResponse(
          message: 'request_cancelled'.tr,
        );

      case DioExceptionType.badCertificate:
        return ErrorResponse(
          message: 'bad_certificate'.tr,
        );

      default:
        return ErrorResponse(
          message: 'unknown_error'.tr,
        );
    }
  }
}
