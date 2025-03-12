import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/image/image_widget.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/input/search_input.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        isCenter: false,
        title: 'HomeScreen',
        elevation: 2,
        leadingWidth: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
    return Obx(() {
      return ShimmerLoadingContainer(
        type: LoadingType.page,
        isLoading: !controller.isInitialized.value,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    ImageWidget(
                      controller.user.value?.image ?? '',
                      width: 80.sp,
                      height: 80.sp,
                      shape: BoxShape.circle,
                    ),
                    const SizedBox(height: kDefaultPadding),
                    Text(controller.user.value?.fullName ?? ''),
                    Text(controller.user.value?.email ?? ''),
                  ],
                ),
              ),
              const SizedBox(height: kDefaultPadding),
              InputFieldWidget(
                controller: controller.searchController,
                hint: 'Search...',
              ),
              const SizedBox(height: 8),
              SearchInputWidget(
                screenName: "Home",
                useSearch: true,
                onSearch: (p0) => Future.delayed(const Duration(seconds: 1)),
              ),
              const SizedBox(height: 8),
              ButtonWidget(text: "Inline button", onPressed: () {}),
              const SizedBox(height: 8),
              ButtonWidget(
                text: "Out button",
                type: ButtonType.outline,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              ButtonWidget(
                text: "Icon button primary",
                onPressed: () async {
                  SnackbarHelper.snackBarWithAction().then((value) {
                    controller.showSuccess(
                        "Success", "Success message: ${value.toString()}");
                  });
                },
                icon: const Icon(Icons.ad_units),
              ),
              const SizedBox(height: 8),
              ButtonWidget(
                type: ButtonType.outline,
                text: "Icon button outline",
                onPressed: () {
                  controller.showError("Error", "Error message");
                },
                icon: const Icon(Icons.ad_units),
              ),
              const SizedBox(height: 8),
              ButtonWidget(
                type: ButtonType.text,
                text: "Text button",
                onPressed: () {
                  controller.showSuccess("Success", "Success message");
                },
              ),
              ButtonWidget(
                text: "Disabled button",
                onPressed: () {},
                icon: const Icon(Icons.ad_units),
                enabled: false,
              ),
            ],
          ),
        ),
      );
    });
  }
}
