import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/model/user_model.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/enum/app_language_enum.dart';
import 'package:flutter_getx_boilerplate/shared/enum/theme_mode_enum.dart';
import 'package:flutter_getx_boilerplate/shared/services/storage_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/user_service.dart';
import 'package:get/get.dart';

enum MainMenuType { profile, language, theme, notification, logout }
enum SecondMenuType {
  aboutApp, support
}

class MainMenu {
  final String iconPath;
  final String title;
  final String subtitle;
  final MainMenuType type;

  MainMenu(this.iconPath, this.title, this.subtitle, this.type);
}

class SecondMenu {
  final String iconPath;
  final String title;
  final SecondMenuType type;

  SecondMenu(this.iconPath, this.title, this.type);
}

class ProfileController extends BaseController<AuthRepository> {
  ProfileController(super.repository);

  final themeMode = Rx<AppThemeMode>(AppThemeMode.system);
  final currentLanguage = Rx<AppLanguage>(AppLanguage.vietnamese);

  final RxList<MainMenu> listMainMenu = <MainMenu>[].obs;

  final RxList<SecondMenu> listSecondMenu = <SecondMenu>[].obs;

  // Add reactive user variable
  final user = Rx<UserModel?>(null);

  @override
  onInit() {
    super.onInit();
    _initializeMainMenu();
    _initializeSecondMenu();
    themeMode.value = StorageService.themeModeStorage;
    currentLanguage.value = AppLanguage.fromCode(StorageService.lang ?? '');
    getProfile();
  }

  void _initializeMainMenu() {
    listMainMenu.value = [
      MainMenu(AssetPath.iconProfileMenu, AppLanguageKey.profile_info,
          AppLanguageKey.profile_info_desc, MainMenuType.profile),
      MainMenu(AssetPath.iconProfileMenu, AppLanguageKey.language,
          AppLanguageKey.language_desc, MainMenuType.language),
      MainMenu(AssetPath.iconProfileMenu, AppLanguageKey.theme,
          AppLanguageKey.language_desc, MainMenuType.theme),
      MainMenu(AssetPath.iconNotificationMenu, AppLanguageKey.notifications,
          AppLanguageKey.notifications_desc, MainMenuType.notification),
      MainMenu(AssetPath.iconLogoutMenu, AppLanguageKey.logout,
          AppLanguageKey.logout_desc, MainMenuType.logout),
    ];
  }

  void _initializeSecondMenu() {
    listSecondMenu.value = [
      SecondMenu(AssetPath.iconAboutUs, AppLanguageKey.help_center,SecondMenuType.aboutApp),
      SecondMenu(AssetPath.iconAboutUs, AppLanguageKey.about_us, SecondMenuType.support),
    ];
  }

  void onChangeTheme(AppThemeMode mode) {
    themeMode.value = mode;
    StorageService.themeModeStorage = mode;
    Get.changeThemeMode(mode.themeMode);
  }

  onChangeLanguage(AppLanguage language) {
    Get.updateLocale(language.locale);
    currentLanguage.value = language;
    StorageService.lang = language.languageCode;
    _initializeMainMenu();
    _initializeSecondMenu();
  }

  Future<void> getProfile() async {
    user.value = UserService.to.user;
  }

  Future<void> logOut() async {
    NavigatorHelper.toAuth();
  }
}
