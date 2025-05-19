import 'dart:convert';

import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';

import '../../models/response/ttlock_response/ttlock_token_response.dart';
import '../utils/logger.dart';

class StorageService {
  static SharedPreferences? _sharedPreferences;

  static Future<SharedPreferences> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();

    return _sharedPreferences!;
  }

  /// Theme mode
  ///
  /// 0: System
  /// 1: Light
  /// 2: Dark
  static AppThemeMode get themeModeStorage =>
      AppThemeMode.fromInt(_sharedPreferences?.getInt(StorageConstants.themeMode) ?? AppThemeMode.light.index);

  static set themeModeStorage(AppThemeMode value) =>
      _sharedPreferences?.setInt(StorageConstants.themeMode, value.index);

  static String? get token => _sharedPreferences?.getString(StorageConstants.token);
  static set token(String? value) => _sharedPreferences?.setString(StorageConstants.token, value ?? '');

  static bool get firstInstall => _sharedPreferences?.getBool(StorageConstants.firstInstall) ?? true;
  static set firstInstall(bool value) => _sharedPreferences?.setBool(StorageConstants.firstInstall, value);

  static String? get lang => _sharedPreferences?.getString(StorageConstants.lang);
  static set lang(String? value) => _sharedPreferences?.setString(StorageConstants.lang, value ?? '');

  static const String _ttlockToken = 'ttlock_token';
  static const String _ttlockUsername = 'ttlock_username';

  static TTLockTokenResponse? get ttlockToken {
    final tokenString = _sharedPreferences?.getString(_ttlockToken);
    if (tokenString == null || tokenString.isEmpty) return null;

    try {
      final tokenJson = json.decode(tokenString);
      return TTLockTokenResponse.fromJson(tokenJson);
    } catch (e) {
      print('Error parsing TTLock token: $e');
      return null;
    }
  }

  static set ttlockToken(TTLockTokenResponse? value) {
    if (value == null) {
      _sharedPreferences?.remove(_ttlockToken);
    } else {
      final tokenJson = json.encode(value.toJson());
      _sharedPreferences?.setString(_ttlockToken, tokenJson);
    }
  }

  static String get ttlockUsername => _sharedPreferences?.getString(_ttlockUsername) ?? '';
  static set ttlockUsername(String value) => _sharedPreferences?.setString(_ttlockUsername, value);

  static bool get isTTLockLoggedIn => ttlockToken != null;

  static bool get isTTLockTokenExpired {
    final token = ttlockToken;
    if (token == null) return true;
    return token.isExpired;
  }

  static void clearTTLockAuth() {
    _sharedPreferences?.remove(_ttlockToken);
    _sharedPreferences?.remove(_ttlockUsername);
  }

  static Future<void> saveEKey(int lockId, String lockData) async {
    final String key = 'ekey_$lockId';
    await _sharedPreferences?.setString(key, lockData);
    AppLogger.i('Saved eKey for lock ID: $lockId');
  }

  static String? getEKey(int lockId) {
    final String key = 'ekey_$lockId';
    final data = _sharedPreferences?.getString(key);
    if (data != null) {
      AppLogger.i('Retrieved cached eKey for lock ID: $lockId');
    }
    return data;
  }

  static Future<void> removeEKey(int lockId) async {
    final String key = 'ekey_$lockId';
    await _sharedPreferences?.remove(key);
    AppLogger.i('Removed cached eKey for lock ID: $lockId');
  }

  static void clearAllEKeys() {
    final keys = _sharedPreferences?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith('ekey_')) {
        _sharedPreferences?.remove(key);
      }
    }
    AppLogger.i('Cleared all cached eKeys');
  }

  static void clear() {
    _sharedPreferences?.remove(StorageConstants.token);
    clearTTLockAuth();
    clearAllEKeys();

    /// more code
  }

  /// Soft clean cache
  ///
  /// Call when logout
}
