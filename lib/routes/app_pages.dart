import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/modules.dart';
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
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}
