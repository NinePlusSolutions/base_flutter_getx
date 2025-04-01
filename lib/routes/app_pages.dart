import 'package:flutter_getx_boilerplate/modules/bottom_naviagte/bottom_navigate.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/modules.dart';
import 'package:flutter_getx_boilerplate/modules/notification/notification_binding.dart';
import 'package:flutter_getx_boilerplate/modules/notification/notification_screen.dart';
import 'package:flutter_getx_boilerplate/modules/profile/binding/profile_details_binding.dart';
import 'package:flutter_getx_boilerplate/modules/profile/export/profile.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      children: [
        GetPage(
          name: Routes.onboard,
          page: () => const OnboardScreen(),
        ),
      ],
    ),
    GetPage(
      name: Routes.auth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.navigator,
      page: () => BottomNavScreen(),
      binding: BottomNavigateBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileDetailsScreen(),
      binding: ProfileDetailsBinding(),
    ),
    GetPage(
        name: Routes.notification,
        page: () => const NotificationScreen(),
        binding: NotificationBinding(),
    )
  ];
}
