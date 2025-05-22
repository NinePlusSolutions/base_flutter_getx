import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/api/ttlock_api_service.dart';
import 'package:flutter_getx_boilerplate/repositories/base_repository.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

import '../models/request/request.dart';
import '../models/response/response.dart';

class PasscodeRepository extends BaseRepository {
  final ApiServices apiClient;
  static const String clientId = '1bd4d8e835334c6d87b405df1e0fb7b7';
  static const String clientSecret = '9fcf16d64dc452760f7fc1937e1654e0';
  final accessToken = StorageService.ttlockToken?.accessToken;
  PasscodeRepository({required this.apiClient});
}
