class ApiConstants {
  static const baseUrlDev = 'https://euapi.ttlock.com';
  static const baseUrlProd = 'https://reqres.in';

  static const contentTypeDev = 'application/x-www-form-urlencoded';
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = 'auth/login';
  static const String me = 'auth/me';

  // Lock
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
}
