import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static int get themeMode =>
      _sharedPreferences?.getInt(StorageConstants.themeMode) ?? 0;
  static set themeMode(int value) =>
      _sharedPreferences?.setInt(StorageConstants.themeMode, value);

  static String? get token =>
      _sharedPreferences?.getString(StorageConstants.token);
  static set token(String? value) =>
      _sharedPreferences?.setString(StorageConstants.token, value ?? '');

  static bool get firstInstall =>
      _sharedPreferences?.getBool(StorageConstants.firstInstall) ?? true;
  static set firstInstall(bool value) =>
      _sharedPreferences?.setBool(StorageConstants.firstInstall, value);

  static String? get lang =>
      _sharedPreferences?.getString(StorageConstants.lang);
  static set lang(String? value) =>
      _sharedPreferences?.setString(StorageConstants.lang, value ?? '');

  /// more code
  /// --------- ------------ -------------

  /// Soft clean cache
  ///
  /// Call when logout
  static void clear() {
    _sharedPreferences?.remove(StorageConstants.token);

    /// more code
  }
}
