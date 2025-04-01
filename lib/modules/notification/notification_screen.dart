import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/modules/notification/notification_controller.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/enum/loading_state_enum.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.35),
              theme.colorScheme.onPrimary,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.only(left: 10.w),
              height: 7.w,
              width: 7.w,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: theme.colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: theme.colorScheme.onPrimaryContainer, size: 15.w),
                onPressed: () => Get.back(),
              ),
            ),
            title: Text(
              AppLanguageKey.notifications,
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text('Nghỉ phép'),
                    )),
                    Tab(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text('Lịch'),
                    )),
                    Tab(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text('Chung'),
                    )),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildListViewLeave(),
              _buildListViewCalendar(),
              _buildListViewCommon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListViewLeave() {
    return Obx(() => ShimmerLoadingContainer(
        type: LoadingType.list,
        isLoading: !controller.isInitialized.value,
        child: Obx(() => controller.listNotificationLeave.isEmpty
            ? _emptyListData()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.listNotificationLeave.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 10.h,
                ),
                itemBuilder: (context, index) {
                  final notification = controller.listNotificationLeave[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.all(10.w),
                      backgroundColor: ColorConstants.white,
                      collapsedBackgroundColor: ColorConstants.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: SizedBox(
                        height: 80.h,
                        child: Row(
                          children: [
                            Expanded(
                                child: SvgPicture.asset(
                                    AssetPath.iconAvatarDefault)),
                            Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: Typo.h4,
                                    ),
                                    Text(
                                      notification.description,
                                      style: Typo.bodyS,
                                    )
                                  ],
                                )),
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(notification.dateReceiver),
                                style: Typo.bodyS.copyWith(fontSize: 10),
                              ),
                            ),
                            notification.status == 0
                                ? Expanded(
                                    child: Container(
                                      height: 30.h,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(3.w),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Unread",
                                        style: Typo.h5,
                                      ),
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Html(
                            data: notification.content,
                            style: {
                              "body": Style(fontSize: FontSize.medium),
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ))));
  }

  Widget _buildListViewCalendar() {
    return Obx(() => ShimmerLoadingContainer(
        type: LoadingType.list,
        isLoading: !controller.isInitialized.value,
        child: Obx(() => controller.listNotificationCalendar.isEmpty
            ? _emptyListData()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.listNotificationCalendar.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 10.h,
                ),
                itemBuilder: (context, index) {
                  final notification =
                      controller.listNotificationCalendar[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.all(10.w),
                      backgroundColor: ColorConstants.white,
                      collapsedBackgroundColor: ColorConstants.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: SizedBox(
                        height: 80.h,
                        child: Row(
                          children: [
                            Expanded(
                                child: SvgPicture.asset(
                                    AssetPath.iconAvatarDefault)),
                            Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: Typo.h4,
                                    ),
                                    Text(
                                      notification.description,
                                      style: Typo.bodyS,
                                    )
                                  ],
                                )),
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(notification.dateReceiver),
                                style: Typo.bodyS.copyWith(fontSize: 10),
                              ),
                            ),
                            notification.status == 0
                                ? Expanded(
                                    child: Container(
                                      height: 30.h,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(3.w),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Unread",
                                        style: Typo.h5,
                                      ),
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Html(
                            data: notification.content,
                            style: {
                              "body": Style(fontSize: FontSize.medium),
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ))));
  }

  Widget _buildListViewCommon() {
    return Obx(() => ShimmerLoadingContainer(
        type: LoadingType.list,
        isLoading: !controller.isInitialized.value,
        child: Obx(() => controller.listNotificationCommon.isEmpty
            ? _emptyListData()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.listNotificationCommon.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 10.h,
                ),
                itemBuilder: (context, index) {
                  final notification = controller.listNotificationCommon[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.all(10.w),
                      backgroundColor: ColorConstants.white,
                      collapsedBackgroundColor: ColorConstants.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: SizedBox(
                        height: 80.h,
                        child: Row(
                          children: [
                            Expanded(
                                child: SvgPicture.asset(
                                    AssetPath.iconAvatarDefault)),
                            Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: Typo.h4,
                                    ),
                                    Text(
                                      notification.description,
                                      style: Typo.bodyS,
                                    )
                                  ],
                                )),
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(notification.dateReceiver),
                                style: Typo.bodyS.copyWith(fontSize: 8),
                              ),
                            ),
                            notification.status == 0
                                ? Expanded(
                                    child: Container(
                                      height: 30.h,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(3.w),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Unread",
                                        style: Typo.h5,
                                      ),
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Html(
                            data: notification.content,
                            style: {
                              "body": Style(fontSize: FontSize.medium),
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ))));
  }

  Widget _emptyListData() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetPath.emptyData,
              width: 120.w,
              height: 120.h,
            ),
            SizedBox(height: 16.h),
            Text(
              "No data",
              style: Typo.h4.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
}
