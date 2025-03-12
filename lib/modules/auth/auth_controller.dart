import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/models/request/login_request.dart';
import 'package:flutter_getx_boilerplate/models/response/error/error_response.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class AuthController extends BaseController<AuthRepository> {
  AuthController(super.repository);

  final emailController = TextEditingController(text: "emilys");
  final passwordController = TextEditingController(text: "emilyspass");

  final formKey = GlobalKey<FormState>();

  final isDarkMode = false.obs;

  @override
  onInit() {
    super.onInit();
    isDarkMode.value = StorageService.themeMode == 2;
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

  onChangeTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(
      !isDarkMode.value ? ThemeMode.light : ThemeMode.dark,
    );

    StorageService.themeMode = isDarkMode.value ? 2 : 1;
  }

  onChangeLanguage(String lang) {
    Get.updateLocale(Locale(lang));
    StorageService.lang = lang;
  }
}
