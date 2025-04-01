import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/models/request/login_request.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

class AuthController extends BaseController<AuthRepository> {
  AuthController(super.repository);

  final emailController = TextEditingController(text: "NPLUS0001");
  final passwordController = TextEditingController(text: "Abc123!@#");

  final formKey = GlobalKey<FormState>();
  Future<void> onLogin() async {
    if (formKey.currentState?.validate() != true) {
      showError("Error", "fill_correct_info".tr);

      return;
    }
    setLoading(true);
    try {
      final request = LoginRequest(
        username: emailController.text,
        password: passwordController.text,
        deviceToken: AppServices.to.deviceToken,
      );
      final res = await repository.login(request);
      if (res.succeeded) {
        StorageService.token = res.data?.token!;
        NavigatorHelper.toBottomNav();
      } else {
        showError(
            AppLanguageKey.login_failed, res.messages?[0].messageText ?? "");
      }
    } catch (e) {
      showError("login_failed".tr, e.toString());
    } finally {
      setLoading(false);
    }
  }

  onChangeLanguage(String lang) {
    Get.updateLocale(Locale(lang));
    StorageService.lang = lang;
  }
}
