import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/model/leave_model.dart';
import 'package:flutter_getx_boilerplate/modules/leave/leave_controller.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/common/cached_avatar_image.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends GetView<LeaveController> {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => ShimmerLoadingContainer(
            type: LoadingType.page,
            isLoading: !controller.isInitialized.value,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(
                    right: kDefaultPadding,
                    left: kDefaultPadding,
                    top: kDefaultPadding),
                width: double.infinity,
                child: Column(children: [
                  // Card info
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              border: Border.all(
                                  color: ColorConstants.secondaryDarkAppColor,
                                  width: 3.w)),
                          child: CachedAvatarImage(
                              imageUrl: controller.user.value?.imageURL,
                              size: 50.w),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInformationRow(
                                '${AppLanguageKey.full_name}:',
                                controller.user.value?.fullName ?? "--",
                              ),
                              _buildInformationRow(
                                  '${AppLanguageKey.position}:',
                                  _getPositionName()),
                              _buildInformationRow(
                                  'Ngày bắt đầu:',
                                  DateFormat('dd/MM/yyyy').format(
                                      controller.user.value?.workingDateFrom ??
                                          DateTime.now())),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Main menu
                  const Space(
                    height: kDefaultPadding,
                  ),
                  Row(
                    children: [
                      _buildMainCard(
                          'Nghỉ Thường Niên:',
                          (controller.annualLeave.value?.totalLeaveCanUse ??
                                  "--")
                              .toString()),
                      Space(
                        width: 10.w,
                      ),
                      _buildMainCard(
                          'Ngày Phép Đã Dùng:',
                          (controller.annualLeave.value?.leaveUsed ?? "--")
                              .toString()),
                    ],
                  ),
                  const Space(
                    height: kDefaultPadding,
                  ),
                  Row(
                    children: [
                      _buildMainCard(
                          'Nghỉ Không Phép:',
                          (controller.annualLeave.value?.unpaidLeave ?? "--")
                              .toString()),
                      Space(
                        width: 10.w,
                      ),
                      _buildMainCard(
                          'Ngày Phép Còn Lại:',
                          (controller.annualLeave.value?.remainingLeave ?? "--")
                              .toString()),
                    ],
                  ),
                  const Space(
                    height: kDefaultPadding,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Danh sách ngày phép", style: Typo.h3,),
                      InkWell(onTap: () => controller.showAddLeaveDialog(context), child: Icon(Icons.add, color: context.colors.primary, size: 20.w,),)
                    ],
                  ),
                  const Space(
                    height: kDefaultPadding,
                  ),
                  SizedBox(
                      height: 400.h,
                      child: Obx(
                        () => ShimmerLoadingContainer(
                            type: LoadingType.list,
                            isLoading: controller.isLoadingList.value,
                            child: Obx(() => controller.listLeaveCurrent.isEmpty
                                ? _emptyListData()
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        controller.listLeaveCurrent.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                    itemBuilder: (context, index) {
                                      return _buildItemLeave(
                                          controller.listLeaveCurrent[index]);
                                    }))),
                      )),
                  const Space(
                    height: kDefaultPadding,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationRow(String label, String value) {
    return SizedBox(
      height: 30.h,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                label,
                style: Typo.h5
                    .copyWith(color: ColorConstants.secondaryDarkAppColor),
              )),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Typo.actionM
                  .copyWith(color: ColorConstants.secondaryDarkAppColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(String title, String value) {
    return Expanded(
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(100),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
          color: ColorConstants.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Typo.h5,
            ),
            Text(
              value,
              style: Typo.actionM,
            ),
          ],
        ),
      ),
    );
  }

  String _getPositionName() {
    final currentLocale = Get.locale?.languageCode ?? 'vi';
    final position = controller.user.value?.positionResponse;

    if (position == null) return '--';

    switch (currentLocale) {
      case 'en':
        return position.nameEn ?? '--';
      case 'ja':
        return position.nameJa ?? '--';
      case 'vi':
      default:
        return position.nameVi ?? '--';
    }
  }

  Widget _buildItemLeave(LeaveModel leave) {
    return Container(
      height: 100.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.darkGray),
          color: ColorConstants.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              controller.getLeaveTypeName(leave.leaveTypeId),
              style: Typo.h4,
            ),
          ),
          Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDateRange(leave.fromTime, leave.toTime),
                    style: Typo.bodyM,
                  ),
                  Text(
                    leave.reason ?? "--",
                    style: Typo.bodyM,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  String formattedDateRange(DateTime? fromTime, DateTime? toTime) {
    if (fromTime == null || toTime == null) return '';

    String formatDateTime(DateTime dateTime) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} '
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }

    return '${formatDateTime(fromTime)} - ${formatDateTime(toTime)}';
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
