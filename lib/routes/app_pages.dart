import 'package:flutter_getx_boilerplate/modules/create_passcode/create_passcode_bindings.dart';
import 'package:flutter_getx_boilerplate/modules/create_passcode/create_passcode_screen.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_detail/gateway_detail_bindings.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_detail/gateway_detail_screen.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_list/gateway_list_bindings.dart';
import 'package:flutter_getx_boilerplate/modules/gateway_list/gateway_list_screen.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/lock_detail/lock_detail_screen.dart';
import 'package:flutter_getx_boilerplate/modules/modules.dart';
import 'package:flutter_getx_boilerplate/modules/passcode_manager/passcode_manager_bindings.dart';
import 'package:flutter_getx_boilerplate/modules/passcode_manager/passcode_manager_screen.dart';
import 'package:get/get.dart';

import '../modules/lock_detail/lock_detail_bindings.dart';
import '../modules/lock/lock_bindings.dart';
import '../modules/lock/lock_screen.dart';

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
      page: () => const LockScreen(),
      binding: LockBindings(),
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
    GetPage(
      name: Routes.createPasscode,
      page: () => const CreatePasscodeScreen(),
      binding: CreatePasscodeBindings(),
    ),
    GetPage(
      name: Routes.passcodeManager,
      page: () => const PasscodeManagerScreen(),
      binding: PasscodeManagerBindings(),
    ),
  ];
}
