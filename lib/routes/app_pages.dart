import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/modules.dart';
import 'package:flutter_getx_boilerplate/modules/checkin/checkin.dart';
import 'package:flutter_getx_boilerplate/modules/issue_report/issue_report.dart';
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
    GetPage(
      name: Routes.checkin,
      page: () => const CheckinScreen(),
      binding: CheckinBinding(),
    ),
    GetPage(
      name: Routes.issueReport,
      page: () => const IssueReportScreen(),
      binding: IssueReportBinding(),
    ),
    GetPage(
      name: Routes.issueHistory,
      page: () => const IssueHistoryScreen(),
      binding: IssueReportBinding(),
    ),
  ];
}
