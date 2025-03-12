import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 50.hp,
                  width: 100.wp,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.image),
                  ),
                ),
                _buildThemeButton(),
                Positioned(
                  top: 48,
                  right: 16,
                  child: PopupMenuButton<String>(
                    onSelected: (String item) {
                      controller.onChangeLanguage(item);
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      const PopupMenuItem(
                        value: 'vi',
                        child: Text('Vietnamese'),
                      ),
                    ],
                    child: const Icon(Icons.language),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Form(
                key: controller.formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    InputFieldWidget(
                      label: "email".tr,
                      controller: controller.emailController,
                      hint: 'email_hint'.tr,
                    ),
                    const Space(),
                    InputFieldWidget(
                      label: "password".tr,
                      controller: controller.passwordController,
                      hint: 'enter_password'.tr,
                      isHideContent: true,
                    ),
                    const Space(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                          text: TextSpan(
                        text: '${'dont_have_account'.tr} ',
                        style: context.bodySmall,
                        children: [
                          TextSpan(
                            text: 'register'.tr,
                            style: context.bodySmall.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      )),
                    ),
                    const Space(height: 40),
                    ButtonWidget(
                      text: "login".tr,
                      onPressed: controller.onLogin,
                    ),
                    const Space(height: 40),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned _buildThemeButton() {
    const darkIcon = Icon(
      Icons.dark_mode,
      color: Colors.black,
    );

    const lightIcon = Icon(
      Icons.light_mode,
      color: Colors.white,
    );

    return Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        onPressed: controller.onChangeTheme,
        icon: Obx(
          () => !controller.isDarkMode.value ? darkIcon : lightIcon,
        ),
      ),
    );
  }
}
