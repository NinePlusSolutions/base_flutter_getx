import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/api/ttlock_api_service.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

import '../models/request/request.dart';
import '../models/response/response.dart';

class LockRepository extends BaseRepository {
  final ApiServices apiClient;
  static const String clientId = '1bd4d8e835334c6d87b405df1e0fb7b7';
  static const String clientSecret = '9fcf16d64dc452760f7fc1937e1654e0';
  final accessToken = StorageService.ttlockToken?.accessToken;
  LockRepository({required this.apiClient});

  Future<LockDetailResponse> getLockDetail({required LockBaseRequest request}) async {
    final queryParameters = {
      'clientId': clientId,
      'accessToken': accessToken,
      'lockId': request.lockId,
      'date': request.date,
    };
    final res = await apiClient.get(
      TTLockApiEndpoints.lockDetail,
      queryParameters: queryParameters,
    );

    return LockDetailResponse.fromJson(res.data);
  }

  Future<LockOpenStateResponse> queryLockOpenState({required LockBaseRequest request}) async {
    final queryParameters = {
      'clientId': clientId,
      'accessToken': accessToken,
      'lockId': request.lockId,
      'date': request.date,
    };
    final res = await apiClient.get(
      TTLockApiEndpoints.queryLockOpenState,
      queryParameters: queryParameters,
    );
    return LockOpenStateResponse.fromJson(res.data);
  }

  Future<EkeyDetailResponse> getEKey({
    required LockBaseRequest request,
  }) async {
    final queryParameters = {
      'clientId': clientId,
      'accessToken': accessToken,
      'lockId': request.lockId,
      'date': request.date,
    };

    final response = await apiClient.get(
      TTLockApiEndpoints.getEKey,
      queryParameters: queryParameters,
    );

    return EkeyDetailResponse.fromJson(response.data);
  }

  Future<LockBaseResponse> setAutoLockTime({
    required AutoLockTimeRequest request,
  }) async {
    final data = {
      'clientId': clientId,
      'accessToken': accessToken,
      'lockId': request.lockId,
      'seconds': request.seconds,
      'type': request.type,
      'date': request.date,
    };

    final response = await apiClient.post(
      TTLockApiEndpoints.setAutoLockTime,
      data: data,
    );

    return LockBaseResponse.fromJson(response.data);
  }

  Future<LockBaseResponse> remoteControlLock({
    required LockBaseRequest request,
    required String controlAction,
  }) async {
    final String endpoint = controlAction == 'unlock' ? TTLockApiEndpoints.remoteUnlock : TTLockApiEndpoints.remoteLock;

    final data = {
      'clientId': clientId,
      'accessToken': accessToken,
      'lockId': request.lockId,
      'date': request.date,
    };

    final response = await apiClient.post(
      endpoint,
      data: data,
    );

    return LockBaseResponse.fromJson(response.data);
  }

  Future<LockBaseResponse> renameLock({
    required RenameLockRequest request,
  }) async {
    final data = {
      'clientId': clientId,
      'accessToken': accessToken,
      'lockId': request.lockId,
      'lockAlias': request.lockAlias,
      'date': request.date,
    };

    final response = await apiClient.post(
      TTLockApiEndpoints.renameLock,
      data: data,
    );

    return LockBaseResponse.fromJson(response.data);
  }
}
