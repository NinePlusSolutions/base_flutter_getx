import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';
import 'package:flutter_getx_boilerplate/models/response/check_in_response/check_in_response.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:get/get.dart';

class HomeRepository extends BaseRepository {
  final ApiServices apiClient;

  HomeRepository({required this.apiClient});

  Future<CheckInResponse> checkIn(String type) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.checkIn,
        data: {'type': type},
      );

      return CheckInResponse.fromJson(
          res.data, (json) => json as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          return CheckInResponse(
            succeeded: false,
            messages: [
              Message(
                messageText: errorData['messages']?[0]['messageText'] ?? "",
              ),
            ],
          );
        }
      }
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }
}
