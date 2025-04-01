import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Image.asset(
                    AssetPath.iconNinePlus,
                    width: 90.w,
                    fit: BoxFit.cover,
                  ),
                ),
                const Space(height: kDefaultPadding*2),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLanguageKey.login,
                      style: Typo.h1,
                    ),),
                const Space(height: kDefaultPadding),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLanguageKey.login_with_your_code,
                      style: Typo.actionL,
                    ),),
                const Space(height: kDefaultPadding*3),
                Form(
                  key: controller.formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      InputFieldWidget(
                        label: AppLanguageKey.employee_code,
                        controller: controller.emailController,
                        hint: AppLanguageKey.employee_code,
                      ),
                      const Space(),
                      InputFieldWidget(
                        label: AppLanguageKey.password,
                        controller: controller.passwordController,
                        hint: AppLanguageKey.enter_password.tr,
                        fieldType: InputFieldType.password,
                      ),
                      const Space(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppLanguageKey.forgot_password}?',
                          style: Typo.h4,
                        ),),
                      const Space(height: 40),
                      ButtonWidget(
                        text: AppLanguageKey.login,
                        onPressed: controller.onLogin,
                      ),
                      const Space(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
