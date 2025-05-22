import 'package:flutter_getx_boilerplate/shared/utils/logger.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';

import '../../repositories/ttlock_repository.dart';

class AuthController extends BaseController<AuthRepository> {
  final TTLockRepository ttlockRepository = Get.find<TTLockRepository>();
  AuthController(super.repository);

  final emailController = TextEditingController(text: "phuc.dcv@nineplus.vn");
  final passwordController = TextEditingController(text: "Abc123!@#");

  final formKey = GlobalKey<FormState>();

  final themeMode = Rx<AppThemeMode>(AppThemeMode.system);

  @override
  onInit() {
    super.onInit();
    themeMode.value = StorageService.themeModeStorage;
  }

  void checkTTLockAuthentication() async {
    try {
      final isAuthenticated = await ttlockRepository.isAuthenticated();
      if (isAuthenticated) {
        NavigatorHelper.toHome();
      }
    } catch (e) {
      // Not authenticated - stay on login screen
    }
  }

  onLogin() async {
    if (formKey.currentState?.validate() != true) {
      showError("Error", "fill_correct_info".tr);
      return;
    }

    setLoading(true);

    try {
      await loginWithTTLock();
      NavigatorHelper.toHome();
    } on ErrorResponse catch (e) {
      AppLogger.e('Login failed with ErrorResponse: ${e.message}');
      showError("login_failed".tr, e.message);
    } catch (e) {
      AppLogger.e('Login failed with unexpected error: ${e.toString()}');
      final errorMessage = e.toString().contains('SocketException')
          ? 'Network connection error. Please check your internet connection.'
          : e.toString();
      showError("login_failed".tr, errorMessage);
    } finally {
      setLoading(false);
    }
  }

  Future<void> loginWithTTLock() async {
    final username = emailController.text;
    final password = passwordController.text;

    final response = await ttlockRepository.login(username, password);
    if (response.accessToken.isNotEmpty) {
      AppLogger.i('TTLock login successful with token length: ${response.accessToken.length}');
    } else {
      throw ErrorResponse(message: 'ttlock_login_failed'.tr);
    }
  }

  void onChangeTheme(AppThemeMode mode) {
    themeMode.value = mode;
    StorageService.themeModeStorage = mode;
    Get.changeThemeMode(mode.themeMode);
  }

  onChangeLanguage(String lang) {
    Get.updateLocale(Locale(lang));
    StorageService.lang = lang;
  }
}
