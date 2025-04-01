import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/notification_response/get_notification_response.dart';
import 'package:flutter_getx_boilerplate/models/response/profile_response/get_profile_response.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/models/model/user_model.dart';
import 'package:flutter_getx_boilerplate/models/request/identity_request.dart';
import 'package:flutter_getx_boilerplate/models/response/base_response.dart';

class ProfileRepository extends BaseRepository {
  final ApiServices apiClient;

  ProfileRepository({required this.apiClient});

  Future<GetProfileResponse> getProfile() async {
    try {
      final res = await apiClient.get(ApiEndpoints.profile);
      return GetProfileResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<BaseResponse> updateIdentity(IdentityRequest request) async {
    try {
      final res = await apiClient.put(
        ApiEndpoints.updateIdentity,
        data: request.toJson(),
      );
      return BaseResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<BaseResponse> updateProfile(UserModel user) async {
    try {
      final res = await apiClient.put(
        ApiEndpoints.updateProfile,
        data: user.toJson(),
      );
      return BaseResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<NotificationResponse> getNotification({required String type, int pageSize = 10, int pageNumber = 1}) async {
    try {
      final res = await apiClient.get(
        '${ApiEndpoints.notificationList}?PageNumber=$pageNumber&PageSize=$pageSize&Type=$type',
      );
      return NotificationResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

}
