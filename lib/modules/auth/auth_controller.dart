import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/models/request/login_request.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';

class AuthController extends BaseController<AuthRepository> {
  AuthController(super.repository);

  final emailController = TextEditingController(text: "emilys");
  final passwordController = TextEditingController(text: "emilyspass");

  final formKey = GlobalKey<FormState>();

  final themeMode = Rx<AppThemeMode>(AppThemeMode.system);

  @override
  onInit() {
    super.onInit();
    themeMode.value = StorageService.themeModeStorage;
  }

  onLogin() async {
    if (formKey.currentState?.validate() != true) {
      showError("Error", "fill_correct_info".tr);

      return;
    }

    setLoading(true);
    try {
      final request = LoginRequest(
        username: emailController.text,
        password: passwordController.text,
        expiresInMins: 1,
      );
      final res = await repository.login(request);
      if (res.accessToken != null) {
        StorageService.token = res.accessToken!;
        NavigatorHelper.toHome();
      } else {
        // showError("login_failed".tr,res. )
      }
    } on ErrorResponse catch (e) {
      showError("login_failed".tr, e.message);
    } finally {
      setLoading(false);
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
