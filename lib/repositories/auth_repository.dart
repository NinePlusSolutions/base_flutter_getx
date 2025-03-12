import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/models/models.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/login_response/login_response.dart';
import 'package:flutter_getx_boilerplate/models/response/user/user.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:get/get.dart';

class AuthRepository extends BaseRepository {
  final ApiServices apiClient;

  AuthRepository({required this.apiClient});

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final res = await apiClient.post(
        'auth/login',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<User?> me() async {
    try {
      final res = await apiClient.get(
        'auth/me',
      );

      return User.fromJson(res.data);
    } on DioException catch (e) {
      throw handleError(e);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }
}
