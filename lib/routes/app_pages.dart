import 'package:flutter_getx_boilerplate/modules/gateway_detail/gateway_detail_bindings.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_detail/gateway_detail_screen.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_list/gateway_list_bindings.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_list/gateway_list_screen.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_screen.dart';
import 'package:flutter_getx_boilerplate/modules/modules.dart';
import 'package:get/get.dart';

import '../modules/lock_detail/lock_detail_bindings.dart';
import '../modules/lock_list/lock_list_bindings.dart';
import '../modules/lock_list/lock_list_screen.dart';

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
    GetPage(
      name: Routes.lock,
      page: () => const LockDetailScreen(),
      binding: LockDetailBinding(),
    ),
    GetPage(
      name: Routes.lockList,
      page: () => const LockListScreen(),
      binding: LockListBindings(),
    ),
    GetPage(
      name: Routes.gatewayList,
      page: () => const GatewayListScreen(),
      binding: GatewayListBinding(),
    ),
    GetPage(
      name: Routes.gatewayDetail,
      page: () => const GatewayDetailScreen(),
      binding: GatewayDetailBindings(),
    ),
  ];
}
