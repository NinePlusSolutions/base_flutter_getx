import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api_client.dart';
import 'package:flutter_getx_boilerplate/models/request/checkin/checkin_request.dart';
import 'package:flutter_getx_boilerplate/models/response/checkin/checkin_response.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';

class CheckinRepository extends BaseRepository {
  final ApiServices apiClient;

  CheckinRepository({required this.apiClient});

  Future<CheckinResponse> createCheckin(CheckinRequest request) async {
    try {
      final response = await apiClient.post(
        '/checkin',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckinResponse.fromJson(response.data['data']);
      } else {
        throw errorHandler(response);
      }
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<List<CheckinResponse>> getCheckinHistory({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      };

      final response = await apiClient.get(
        '/checkin/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => CheckinResponse.fromJson(json)).toList();
      } else {
        throw errorHandler(response);
      }
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<CheckinResponse> getLastCheckin() async {
    try {
      final response = await apiClient.get('/checkin/last');

      if (response.statusCode == 200) {
        return CheckinResponse.fromJson(response.data['data']);
      } else {
        throw errorHandler(response);
      }
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
