import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../models/response/lock_response/lock_detail_response.dart';
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
  static const String listEKeys = '/v3/lock/listKey';

  static const String renameLock = '/v3/lock/rename';
  static const String changeAdminPasscode = '/v3/lock/changeAdminKeyboardPwd';
  static const String configurePassageMode = '/v3/lock/configurePassageMode';
  static const String getPassageModeConfiguration = '/v3/lock/getPassageModeConfiguration';
  static const String setAutoLockTime = '/v3/lock/setAutoLockTime';

  static const String getRandomPasscode = '/v3/keyboardPwd/get';
  static const String addCustomPasscode = '/v3/keyboardPwd/add';
  static const String listKeyboardPwd = '/v3/lock/listKeyboardPwd';
  static const String deleteKeyboardPwd = '/v3/keyboardPwd/delete';
  static const String changeKeyboardPwd = '/v3/keyboardPwd/change';

  static const String getEKey = '/v3/key/get';
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

  Future<LockDetailResponse> getLockDetail({
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
      return LockDetailResponse.fromJson(response.data);
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

  Future<Map<String, dynamic>> changeAdminPasscode({
    required String accessToken,
    required int lockId,
    required String password,
    required int changeType,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'password': password,
        'changeType': changeType.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Changing admin passcode for lock ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.changeAdminPasscode,
        data: data,
      );

      AppLogger.i('Change admin passcode response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error changing admin passcode');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error changing admin passcode: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> configurePassageMode({
    required String accessToken,
    required int lockId,
    required int passageMode,
    required String cyclicConfig,
    required int type,
    int? autoUnlock,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'passageMode': passageMode.toString(),
        'cyclicConfig': cyclicConfig,
        'type': type.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (autoUnlock != null) {
        data['autoUnlock'] = autoUnlock.toString();
      }

      AppLogger.i('Configuring passage mode for lock ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.configurePassageMode,
        data: data,
      );

      AppLogger.i('Configure passage mode response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error configuring passage mode');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error configuring passage mode: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> getPassageModeConfiguration({
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

      AppLogger.i('Getting passage mode configuration for lock ID: $lockId');

      final response = await _dio.get(
        TTLockApiEndpoints.getPassageModeConfiguration,
        queryParameters: queryParameters,
      );

      AppLogger.i('Get passage mode configuration response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting passage mode configuration');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting passage mode configuration: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> renameLock({
    required String accessToken,
    required int lockId,
    required String lockAlias,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'lockAlias': lockAlias,
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Renaming lock with ID: $lockId to "$lockAlias"');

      final response = await _dio.post(
        TTLockApiEndpoints.renameLock,
        data: data,
      );

      AppLogger.i('Lock rename response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error renaming lock');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error renaming lock: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> setAutoLockTime({
    required String accessToken,
    required int lockId,
    required int seconds,
    int type = 2, // Mặc định là qua gateway hoặc WiFi lock
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'seconds': seconds.toString(),
        'type': type.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Setting auto lock time for lock ID: $lockId to $seconds seconds');

      final response = await _dio.post(
        TTLockApiEndpoints.setAutoLockTime,
        data: data,
      );

      AppLogger.i('Set auto lock time response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error setting auto lock time');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error setting auto lock time: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<Map<String, dynamic>> getRandomPasscode({
    required String accessToken,
    required int lockId,
    required int keyboardPwdType,
    String? keyboardPwdName,
    required int startDate,
    int? endDate,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'keyboardPwdType': keyboardPwdType.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
        'startDate': startDate.toString(),
      };

      if (keyboardPwdName != null) {
        data['keyboardPwdName'] = keyboardPwdName;
      }

      if (endDate != null) {
        data['endDate'] = endDate.toString();
      }

      AppLogger.i('Getting random passcode for lock ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.getRandomPasscode,
        data: data,
      );

      AppLogger.i('Random passcode response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error getting random passcode');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error getting random passcode: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  // Add custom passcode
  Future<Map<String, dynamic>> addCustomPasscode({
    required String accessToken,
    required int lockId,
    required String keyboardPwd,
    String? keyboardPwdName,
    int? keyboardPwdType,
    int? startDate,
    int? endDate,
    required int addType,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'keyboardPwd': keyboardPwd,
        'addType': addType.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (keyboardPwdName != null) {
        data['keyboardPwdName'] = keyboardPwdName;
      }

      if (keyboardPwdType != null) {
        data['keyboardPwdType'] = keyboardPwdType.toString();
      }

      if (startDate != null) {
        data['startDate'] = startDate.toString();
      }

      if (endDate != null) {
        data['endDate'] = endDate.toString();
      }

      AppLogger.i('Adding custom passcode for lock ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.addCustomPasscode,
        data: data,
      );

      AppLogger.i('Custom passcode response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error adding custom passcode');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error adding custom passcode: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  // Get all passcodes of a lock
  Future<Map<String, dynamic>> listKeyboardPwd({
    required String accessToken,
    required int lockId,
    String? searchStr,
    int pageNo = 1,
    int pageSize = 20,
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

      if (searchStr != null && searchStr.isNotEmpty) {
        queryParameters['searchStr'] = searchStr;
      }

      AppLogger.i('Listing passcodes for lock ID: $lockId');

      final response = await _dio.get(
        TTLockApiEndpoints.listKeyboardPwd,
        queryParameters: queryParameters,
      );

      AppLogger.i('List passcode response: ${response.data["total"]} passcodes found');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error listing passcodes');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error listing passcodes: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  // Delete passcode
  Future<Map<String, dynamic>> deleteKeyboardPwd({
    required String accessToken,
    required int lockId,
    required int keyboardPwdId,
    required int deleteType,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'keyboardPwdId': keyboardPwdId.toString(),
        'deleteType': deleteType.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      AppLogger.i('Deleting passcode ID: $keyboardPwdId from lock ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.deleteKeyboardPwd,
        data: data,
      );

      AppLogger.i('Delete passcode response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error deleting passcode');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error deleting passcode: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  // Change passcode
  Future<Map<String, dynamic>> changeKeyboardPwd({
    required String accessToken,
    required int lockId,
    required int keyboardPwdId,
    String? keyboardPwdName,
    String? newKeyboardPwd,
    int? startDate,
    int? endDate,
    int? changeType,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'accessToken': accessToken,
        'lockId': lockId.toString(),
        'keyboardPwdId': keyboardPwdId.toString(),
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (keyboardPwdName != null) {
        data['keyboardPwdName'] = keyboardPwdName;
      }

      if (newKeyboardPwd != null) {
        data['newKeyboardPwd'] = newKeyboardPwd;
      }

      if (startDate != null) {
        data['startDate'] = startDate.toString();
      }

      if (endDate != null) {
        data['endDate'] = endDate.toString();
      }

      if (changeType != null) {
        data['changeType'] = changeType.toString();
      }

      AppLogger.i('Changing passcode ID: $keyboardPwdId for lock ID: $lockId');

      final response = await _dio.post(
        TTLockApiEndpoints.changeKeyboardPwd,
        data: data,
      );

      AppLogger.i('Change passcode response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ErrorResponse(message: e.response?.data['errmsg'] ?? 'Error changing passcode');
      }
      throw ErrorResponse(message: 'network_error'.tr);
    } catch (e) {
      AppLogger.e('Error changing passcode: $e');
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }
}
