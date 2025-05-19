import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../models/response/ttlock_response/ttlock_detail_response.dart';
import '../models/response/ttlock_response/ttlock_init_response.dart';
import '../models/response/ttlock_response/ttlock_list_response.dart';
import '../models/response/ttlock_response/ttlock_token_response.dart';
import '../shared/utils/logger.dart';

class TTLockApiEndpoints {
  static const String baseUrl = 'https://euapi.ttlock.com';
  static const String token = '/oauth2/token';
  static const String registerUser = '/v3/user/register';
  static const String resetPassword = '/v3/user/resetPassword';

  static const String initializeLock = '/v3/lock/initialize';
  static const String lockList = '/v3/lock/list';
  static const String lockDetail = '/v3/lock/detail';
  static const String deleteLock = '/v3/lock/delete';
  static const String remoteUnlock = '/v3/lock/unlock';
  static const String remoteLock = '/v3/lock/lock';
  static const String queryLockOpenState = '/v3/lock/queryOpenState';

  static const String getEKey = '/v3/key/get';
  static const String listEKeys = '/v3/lock/listKey';
  static const String accountEKeys = '/v3/key/list';

  static const String gatewayList = '/v3/gateway/list';
  static const String gatewayIsInitSuccess = '/v3/gateway/isInitSuccess';
  static const String gatewayDetail = '/v3/gateway/detail';
  static const String gatewayDelete = '/v3/gateway/delete';
  static const String gatewayRename = '/v3/gateway/rename';
}

class TTLockApiService {
  final Dio _dio;
  final String clientId;
  final String clientSecret;

  TTLockApiService({
    required this.clientId,
    required this.clientSecret,
  }) : _dio = Dio(BaseOptions(
          baseUrl: TTLockApiEndpoints.baseUrl,
          contentType: 'application/x-www-form-urlencoded',
        ));

  String _convertToMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<TTLockTokenResponse> getAccessToken({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        TTLockApiEndpoints.token,
        data: {
          'clientId': clientId,
          'clientSecret': clientSecret,
          'username': username,
          'password': _convertToMd5(password),
        },
      );

      return TTLockTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting token');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<TTLockTokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        TTLockApiEndpoints.token,
        data: {
          'clientId': clientId,
          'clientSecret': clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      return TTLockTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error refreshing token');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<TTLockInitResponse> initializeLock({
    required String accessToken,
    required String lockData,
    required String lockAlias,
    int? groupId,
    int? nbInitSuccess,
  }) async {
    try {
      final response = await _dio.post(
        TTLockApiEndpoints.initializeLock,
        data: {
          'clientId': clientId,
          'accessToken': accessToken,
          'lockData': lockData,
          'lockAlias': lockAlias,
          'date': DateTime.now().millisecondsSinceEpoch,
          if (groupId != null) 'groupId': groupId,
          if (nbInitSuccess != null) 'nbInitSuccess': nbInitSuccess,
        },
      );

      AppLogger.i('Lock initialization response: ${response.data}');
      return TTLockInitResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error initializing lock');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error initializing lock: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<TTLockListResponse> getLockList({
    required String accessToken,
    String? lockAlias,
    int? groupId,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'pageNo': pageNo.toString(),
        'pageSize': pageSize.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (lockAlias != null) {
        queryParameters['lockAlias'] = lockAlias;
      }

      if (groupId != null) {
        queryParameters['groupId'] = groupId.toString();
      }

      final response = await _dio.get(
        TTLockApiEndpoints.lockList,
        queryParameters: queryParameters,
      );

      AppLogger.i('Lock list response: ${response.data}');
      return TTLockListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting lock list');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting lock list: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<TTLockDetailResponse> getLockDetail({
    required String accessToken,
    required int lockId,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.get(
        TTLockApiEndpoints.lockDetail,
        queryParameters: queryParameters,
      );

      AppLogger.i('Lock detail response: ${response.data}');
      return TTLockDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting lock details');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting lock details: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> remoteControlLock({
    required String accessToken,
    required int lockId,
    required String controlAction,
  }) async {
    try {
      final String endpoint =
          controlAction == 'unlock' ? TTLockApiEndpoints.remoteUnlock : TTLockApiEndpoints.remoteLock;

      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Sending remote $controlAction command to lock ID: $lockId');

      final response = await _dio.post(
        endpoint,
        data: data,
      );

      AppLogger.i('Remote $controlAction response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response?.data['errmsg'] ?? 'Error controlling lock remotely';

        if (e.response?.data['errcode'] == -4043) {
          throw ErrorResponse(
              message: 'Remote unlock not enabled for this lock. Please enable it in TTLock APP settings.');
        }

        throw ErrorResponse(message: errorMsg);
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error controlling lock remotely: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> queryLockOpenState({
    required String accessToken,
    required int lockId,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Querying lock open state for ID: $lockId');

      final response = await _dio.get(
        TTLockApiEndpoints.queryLockOpenState,
        queryParameters: queryParameters,
      );

      AppLogger.i('Lock open state response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error querying lock state');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error querying lock state: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> deleteLock({
    required String accessToken,
    required int lockId,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Deleting lock with ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.deleteLock,
        data: data,
      );

      AppLogger.i('Lock delete response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error deleting lock');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error deleting lock: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> getGatewayList({
    required String accessToken,
    int pageNo = 1,
    int pageSize = 20,
    int orderBy = 1,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'pageNo': pageNo.toString(),
        'pageSize': pageSize.toString(),
        'orderBy': orderBy.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.get(
        TTLockApiEndpoints.gatewayList,
        queryParameters: queryParameters,
      );

      AppLogger.i('Gateway list response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting gateway list');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting gateway list: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> checkGatewayInitStatus({
    required String accessToken,
    required String gatewayNetMac,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'gatewayNetMac': gatewayNetMac,
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.post(
        TTLockApiEndpoints.gatewayIsInitSuccess,
        data: data,
      );

      AppLogger.i('Gateway init status response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error checking gateway initialization');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error checking gateway initialization: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> getGatewayDetail({
    required String accessToken,
    required int gatewayId,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'gatewayId': gatewayId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.get(
        TTLockApiEndpoints.gatewayDetail,
        queryParameters: queryParameters,
      );

      AppLogger.i('Gateway detail response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting gateway details');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting gateway details: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> getUserInfo({
    required String accessToken,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.get(
        '/v3/user/getUid',
        queryParameters: queryParameters,
      );

      AppLogger.i('User info response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting user info');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting user info: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> deleteGateway({
    required String accessToken,
    required int gatewayId,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'gatewayId': gatewayId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.post(
        TTLockApiEndpoints.gatewayDelete,
        data: data,
      );

      AppLogger.i('Gateway delete response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error deleting gateway');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error deleting gateway: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> renameGateway({
    required String accessToken,
    required int gatewayId,
    required String gatewayName,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'gatewayId': gatewayId.toString(),
        'gatewayName': gatewayName,
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final response = await _dio.post(
        TTLockApiEndpoints.gatewayRename,
        data: data,
      );

      AppLogger.i('Gateway rename response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error renaming gateway');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error renaming gateway: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> getEKey({
    required String accessToken,
    required int lockId,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Getting eKey for lock ID: $lockId');

      final response = await _dio.get(
        TTLockApiEndpoints.getEKey,
        queryParameters: queryParameters,
      );

      AppLogger.i('eKey response data received');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting eKey');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting eKey: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

// Lấy danh sách eKey cho một khóa
  Future<Map<String, dynamic>> listLockEKeys({
    required String accessToken,
    required int lockId,
    int pageNo = 1,
    int pageSize = 20,
    int? keyRight,
    String? searchStr,
    int orderBy = 1,
  }) async {
    try {
      final queryParameters = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'pageNo': pageNo.toString(),
        'pageSize': pageSize.toString(),
        'orderBy': orderBy.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (keyRight != null) {
        queryParameters['keyRight'] = keyRight.toString();
      }

      if (searchStr != null && searchStr.isNotEmpty) {
        queryParameters['searchStr'] = searchStr;
      }

      final response = await _dio.get(
        TTLockApiEndpoints.listEKeys,
        queryParameters: queryParameters,
      );

      AppLogger.i('Lock eKeys list response: ${response.data["total"]} keys found');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error listing eKeys');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error listing eKeys: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

// Lấy tất cả eKey của tài khoản hiện tại
  Future<Map<String, dynamic>> getAccountEKeys({
    required String accessToken,
    String? lockAlias,
    int? groupId,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'pageNo': pageNo.toString(),
        'pageSize': pageSize.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (lockAlias != null && lockAlias.isNotEmpty) {
        data['lockAlias'] = lockAlias;
      }

      if (groupId != null) {
        data['groupId'] = groupId.toString();
      }

      final response = await _dio.post(
        TTLockApiEndpoints.accountEKeys,
        data: data,
      );

      AppLogger.i('Account eKeys list response: ${response.data["total"]} keys found');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting account eKeys');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting account eKeys: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }
}
