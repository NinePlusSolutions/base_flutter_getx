import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/modules/profile/controller/profile_controller.dart';
import 'package:flutter_getx_boilerplate/modules/profile/export/profile.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/enum/app_language_enum.dart';
import 'package:flutter_getx_boilerplate/shared/enum/theme_mode_enum.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/common/cached_avatar_image.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
                right: kDefaultPadding,
                left: kDefaultPadding,
                top: kDefaultPadding),
            width: double.infinity,
            child: Column(children: [
              // Card info
              Container(
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),
                height: 90.h,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          border: Border.all(
                              color: ColorConstants.secondaryDarkAppColor,
                              width: 3.w)),
                      child: CachedAvatarImage(
                        imageUrl: controller.user.value?.imageURL,
                        size: 50.w,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.user.value?.fullName ?? "",
                          style: Typo.h4.copyWith(
                              color: ColorConstants.secondaryDarkAppColor),
                        ),
                        Text(
                          controller.user.value?.email ?? "",
                          style: Typo.actionM.copyWith(
                              color: ColorConstants.secondaryDarkAppColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Main menu
              const Space(
                height: kDefaultPadding,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(13),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.tipColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.listMainMenu.length,
                        itemBuilder: (context, index) {
                          final menu = controller.listMainMenu[index];
                          return _buildItemMainMenu(context, menu);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Space(
                height: kDefaultPadding,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppLanguageKey.other, style: Typo.h3,)),
              const Space(
                height: kDefaultPadding,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(13),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.tipColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Obx(
                          () => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.listSecondMenu.length,
                        itemBuilder: (context, index) {
                          final menu = controller.listSecondMenu[index];
                          return _buildSecondMenu(context, menu);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildItemMainMenu(BuildContext context, MainMenu menu) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.w),
      child: ListTile(
        leading: Container(
          height: 40.w,
          width: 40.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withOpacity(0.05)),
          child: SvgPicture.asset(
            menu.iconPath,
            fit: BoxFit.scaleDown,
          ),
        ),
        title: Text(
          menu.title.tr,
          style: Typo.h4.copyWith(color: ColorConstants.black),
        ),
        subtitle: Text(
          menu.subtitle.tr,
          style: Typo.bodyM.copyWith(color: ColorConstants.tipColor),
        ),
        trailing: Container(
            alignment: Alignment.centerRight,
            width: 60.w,
            child: _getTrailingIcon(context, menu.type)),
        onTap: () {
          _navigateToScreen(menu.type);
        },
      ),
    );
  }

  Widget _buildSecondMenu(BuildContext context, SecondMenu menu) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.w),
      child: ListTile(
        leading: Container(
          height: 40.w,
          width: 40.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withOpacity(0.05)),
          child: SvgPicture.asset(
            menu.iconPath,
            fit: BoxFit.scaleDown,
          ),
        ),
        title: Text(
          menu.title.tr,
          style: Typo.h4.copyWith(color: ColorConstants.black),
        ),
        trailing: Container(
            alignment: Alignment.centerRight,
            width: 60.w,
            child: Icon(
          Icons.arrow_forward_ios_outlined,
          color: ColorConstants.darkGray,
          size: 17.w,
        )),
        onTap: () {
          _navigateToScreenSecond(menu.type);
        },
      ),
    );
  }

  Widget _getTrailingIcon(BuildContext context, MainMenuType type) {
    switch (type) {
      case MainMenuType.profile:
        return Icon(
          Icons.arrow_forward_ios_outlined,
          color: ColorConstants.darkGray,
          size: 17.w,
        );
      case MainMenuType.language:
        return Obx(() => PopupMenuButton<AppLanguage>(
              icon: SvgPicture.asset(controller.currentLanguage.value.flagPath,
                  width: 24.w, height: 24.w, fit: BoxFit.contain),
              onSelected: (lang) => controller.onChangeLanguage(lang),
              itemBuilder: (context) => AppLanguage.values.map((lang) {
                return PopupMenuItem(
                  value: lang,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        lang.flagPath,
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      ),
                      Space(width: 8.w),
                      Text(lang.name),
                    ],
                  ),
                );
              }).toList(),
            ));
      case MainMenuType.theme:
        return Obx(() => PopupMenuButton<AppThemeMode>(
              icon: Icon(
                controller.themeMode.value.icon,
                color: context.colors.primary,
              ),
              onSelected: (mode) => controller.onChangeTheme(mode),
              itemBuilder: (context) => AppThemeMode.values.map((mode) {
                return PopupMenuItem(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(mode.icon, color: context.colors.primary),
                      const SizedBox(width: 8),
                      Text(mode.name.capitalizeFirst ?? ""),
                    ],
                  ),
                );
              }).toList(),
            ));
      case MainMenuType.notification:
        return Icon(
          Icons.arrow_forward_ios_outlined,
          color: ColorConstants.darkGray,
          size: 17.w,
        );
      case MainMenuType.logout:
        return Icon(
          Icons.arrow_forward_ios_outlined,
          color: ColorConstants.darkGray,
          size: 17.w,
        );
    }
  }

  void _navigateToScreen(MainMenuType type) {
    switch (type) {
      case MainMenuType.profile:
        NavigatorHelper.toProfileDetail();
        break;
      case MainMenuType.logout:
        _showLogoutDialog();
        break;
      case MainMenuType.language:
        break;
      case MainMenuType.theme:
        break;
      case MainMenuType.notification:
        NavigatorHelper.toNotification();
    }
  }

  void _navigateToScreenSecond(SecondMenuType type) {
    switch (type) {
      case SecondMenuType.aboutApp:
        _launchURL();
        break;
      case SecondMenuType.support:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _showLogoutDialog() {
    CommonDialog.showConfirmation(
      title: "Đăng xuất",
      description: "Đăng xuất khỏi phiên hoạt động",
      confirmText: AppLanguageKey.ok,
      cancelText: AppLanguageKey.cancel,
      onConfirm: () {
        controller.logOut();
      },
    );
  }

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse('https://nineplus.com.vn');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw Exception('Could not launch $uri');
    }
  }

}
