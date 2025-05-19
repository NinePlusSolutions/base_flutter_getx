import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: context.colors.primary,
        title: 'Home Screen',
        elevation: 2,
        leadingWidth: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: context.colors.surface,
            ),
            onPressed: () {
              NavigatorHelper.toAuth();
            },
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(kDefaultPadding),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          ButtonWidget(
            text: "Lock",
            onPressed: () => Get.toNamed(Routes.lockList),
          ),
          const SizedBox(height: 16),
          ButtonWidget(
            text: "Gateway",
            onPressed: () => Get.toNamed(Routes.gatewayList),
          ),
        ],
      ),
    );
  }
}
