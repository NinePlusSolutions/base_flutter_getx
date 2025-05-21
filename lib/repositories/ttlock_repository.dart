import 'package:flutter_getx_boilerplate/api/ttlock_api_service.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_base_response.dart';
import 'package:flutter_getx_boilerplate/models/response/ttlock_response/ttlock_token_response.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:flutter_getx_boilerplate/shared/services/storage_service.dart';
import 'package:get/get.dart';

import '../models/response/ttlock_response/ttlock_detail_response.dart';
import '../models/response/ttlock_response/ttlock_init_response.dart';
import '../models/response/ttlock_response/ttlock_list_response.dart';
import '../shared/utils/logger.dart';

class TTLockRepository extends BaseRepository {
  final TTLockApiService apiService;

  TTLockRepository({required this.apiService});

  Future<TTLockTokenResponse> login(String username, String password) async {
    try {
      final response = await apiService.getAccessToken(
        username: username,
        password: password,
      );

      StorageService.ttlockToken = response;
      StorageService.ttlockUsername = username;

      return response;
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'unknown_error'.tr);
    }
  }

  Future<TTLockTokenResponse> refreshTokenIfNeeded() async {
    final currentToken = StorageService.ttlockToken;
    if (currentToken == null) {
      throw ErrorResponse(message: 'not_logged_in'.tr);
    }

    if (!currentToken.isExpired) {
      return currentToken;
    }

    try {
      final newToken = await apiService.refreshToken(currentToken.refreshToken);
      StorageService.ttlockToken = newToken;
      return newToken;
    } catch (e) {
      StorageService.clearTTLockAuth();
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'session_expired'.tr);
    }
  }

  Future<bool> isAuthenticated() async {
    final tokenExists = StorageService.isTTLockLoggedIn;
    if (!tokenExists) return false;

    if (StorageService.isTTLockTokenExpired) {
      try {
        await refreshTokenIfNeeded();
        return true;
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  void logout() {
    StorageService.clearTTLockAuth();
  }

  Future<String> getCurrentToken() async {
    await refreshTokenIfNeeded();
    return StorageService.ttlockToken?.accessToken ?? '';
  }

  Future<TTLockInitResponse> initializeLock({
    required String lockData,
    required String lockAlias,
    int? groupId,
    int? nbInitSuccess,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.initializeLock(
        accessToken: accessToken,
        lockData: lockData,
        lockAlias: lockAlias,
        groupId: groupId,
        nbInitSuccess: nbInitSuccess,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_initialize_lock'.tr);
    }
  }

  Future<TTLockListResponse> getLockList({
    String? lockAlias,
    int? groupId,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getLockList(
        accessToken: accessToken,
        lockAlias: lockAlias,
        groupId: groupId,
        pageNo: pageNo,
        pageSize: pageSize,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_lock_list'.tr);
    }
  }

  Future<dynamic> remoteControlLock({
    required int lockId,
    required String controlAction,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.remoteControlLock(
        accessToken: accessToken,
        lockId: lockId,
        controlAction: controlAction,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_control_lock_remotely'.tr);
    }
  }

  Future<Map<String, dynamic>> queryLockOpenState(int lockId) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.queryLockOpenState(
        accessToken: accessToken,
        lockId: lockId,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_query_lock_state'.tr);
    }
  }

  Future<TTLockDetailResponse> getLockDetail(int lockId) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getLockDetail(
        accessToken: accessToken,
        lockId: lockId,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_lock_details'.tr);
    }
  }

  Future<Map<String, dynamic>> deleteLock(int lockId) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      final response = await apiService.deleteLock(
        accessToken: accessToken,
        lockId: lockId,
      );

      if (response['errcode'] == 0) {
        await StorageService.removeEKey(lockId);
      }

      return response;
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_delete_lock'.tr);
    }
  }

  Future<dynamic> getGatewayList({
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getGatewayList(
        accessToken: accessToken,
        pageNo: pageNo,
        pageSize: pageSize,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_gateway_list'.tr);
    }
  }

  Future<dynamic> checkGatewayInitStatus({
    required String gatewayNetMac,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.checkGatewayInitStatus(
        accessToken: accessToken,
        gatewayNetMac: gatewayNetMac,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_check_gateway_init_status'.tr);
    }
  }

  Future<dynamic> getGatewayDetail(int gatewayId) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getGatewayDetail(
        accessToken: accessToken,
        gatewayId: gatewayId,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_gateway_details'.tr);
    }
  }

  Future<dynamic> getUserInfo() async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getUserInfo(
        accessToken: accessToken,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_user_info'.tr);
    }
  }

  Future<dynamic> deleteGateway(int gatewayId) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.deleteGateway(
        accessToken: accessToken,
        gatewayId: gatewayId,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_delete_gateway'.tr);
    }
  }

  Future<dynamic> renameGateway(int gatewayId, String gatewayName) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.renameGateway(
        accessToken: accessToken,
        gatewayId: gatewayId,
        gatewayName: gatewayName,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_rename_gateway'.tr);
    }
  }

  Future<Map<String, dynamic>> getEKey(int lockId) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      final cachedEKey = StorageService.getEKey(lockId);
      if (cachedEKey != null) {
        return {'lockData': cachedEKey};
      }

      final response = await apiService.getEKey(
        accessToken: accessToken,
        lockId: lockId,
      );

      if (response.containsKey('lockData') && response['lockData'] != null) {
        StorageService.saveEKey(lockId, response['lockData']);
      }

      return response;
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_ekey'.tr);
    }
  }

  Future<Map<String, dynamic>> getEKeysForLock(int lockId, {int? keyRight}) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.listLockEKeys(
        accessToken: accessToken,
        lockId: lockId,
        keyRight: keyRight,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_ekeys'.tr);
    }
  }

// Lấy tất cả eKey của tài khoản hiện tại
  Future<Map<String, dynamic>> getAccountEKeys({String? lockAlias, int? groupId}) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getAccountEKeys(
        accessToken: accessToken,
        lockAlias: lockAlias,
        groupId: groupId,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_account_ekeys'.tr);
    }
  }

  Future<Map<String, dynamic>> changeAdminPasscode({
    required int lockId,
    required String password,
    required int changeType,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.changeAdminPasscode(
        accessToken: accessToken,
        lockId: lockId,
        password: password,
        changeType: changeType,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_change_admin_passcode'.tr);
    }
  }

  Future<Map<String, dynamic>> configurePassageMode({
    required int lockId,
    required int passageMode,
    required String cyclicConfig,
    required int type,
    int? autoUnlock,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.configurePassageMode(
        accessToken: accessToken,
        lockId: lockId,
        passageMode: passageMode,
        cyclicConfig: cyclicConfig,
        type: type,
        autoUnlock: autoUnlock,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_configure_passage_mode'.tr);
    }
  }

  Future<Map<String, dynamic>> getPassageModeConfiguration({
    required int lockId,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      return await apiService.getPassageModeConfiguration(
        accessToken: accessToken,
        lockId: lockId,
      );
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_get_passage_mode_configuration'.tr);
    }
  }

  Future<TTLockBaseResponse> renameLock({
    required int lockId,
    required String newName,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      final response = await apiService.renameLock(
        accessToken: accessToken,
        lockId: lockId,
        lockAlias: newName,
      );

      return TTLockBaseResponse.fromJson(response);
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_rename_lock'.tr);
    }
  }

  Future<TTLockBaseResponse> setAutoLockTime({
    required int lockId,
    required int seconds,
    int type = 2,
  }) async {
    try {
      await refreshTokenIfNeeded();
      final accessToken = StorageService.ttlockToken?.accessToken;

      if (accessToken == null) {
        throw ErrorResponse(message: 'not_logged_in'.tr);
      }

      final response = await apiService.setAutoLockTime(
        accessToken: accessToken,
        lockId: lockId,
        seconds: seconds,
        type: type,
      );

      return TTLockBaseResponse.fromJson(response);
    } catch (e) {
      if (e is ErrorResponse) {
        rethrow;
      }
      throw ErrorResponse(message: 'failed_to_set_auto_lock_time'.tr);
    }
  }
}
