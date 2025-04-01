import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/modules/home/home_screen.dart';
import 'package:flutter_getx_boilerplate/modules/leave/leave_screen.dart';
import 'package:flutter_getx_boilerplate/modules/profile/screen/profile_screen.dart';
import 'package:flutter_getx_boilerplate/modules/dashboard/dashboard_page.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'bottom_navigate_controller.dart';

class BottomNavScreen extends GetView<BottomNavController> {
  final List<Widget> _screens = [
    HomeScreen(),
    DashboardPage(),
    const LeaveScreen(),
    const ProfileScreen(),
  ];

  final List<String> _icons = [
    AssetPath.iconHomeNav,
    AssetPath.iconDashboardNav,
    AssetPath.iconLeaveNav,
    AssetPath.iconProfileNav,
  ];

  final List<String> _labels = [
    AppLanguageKey.home,
    AppLanguageKey.dashboard,
    AppLanguageKey.leave_days,
    AppLanguageKey.personal,
  ];

  BottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          height: 60.h,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorConstants.tipColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: (index) => controller.selectedIndex.value = index,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: ColorConstants.darkGray,
              items: List.generate(
                _icons.length,
                (index) => BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _icons[index],
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == index
                          ? Theme.of(context).primaryColor
                          : ColorConstants.darkGray,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: _labels[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
