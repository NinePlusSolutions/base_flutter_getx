import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/dashboard_models.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_getx_boilerplate/shared/enum/enum.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/common/cached_avatar_image.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/input/search_input.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  final DashboardData data = DashboardData.getSampleData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ShimmerLoadingContainer(
            type: LoadingType.page,
            isLoading: !controller.isInitialized.value,
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                width: double.infinity,
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Image.asset(
                      AssetPath.iconNinePlus,
                      width: 70.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${AppLanguageKey.good_morning}, ${controller.user.value?.fullName ?? ""}',
                      style: Typo.h2,
                    ),
                  ),
                  Space(height: 10.h),
                  SearchInputWidget(
                    screenName: "Home",
                    useSearch: true,
                    onSearch: (p0) =>
                        Future.delayed(const Duration(seconds: 1)),
                  ),
                  Space(height: 10.h),
                  SizedBox(
                    height: 60.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60.h,
                            child: ButtonWidget(
                              text: AppLanguageKey.check_in,
                              onPressed: () async {
                                CommonDialog.showConfirmation(
                                  title: AppLanguageKey
                                      .check_in_and_check_out_confirmation,
                                  description: AppLanguageKey
                                      .check_in_and_check_out_confirmation_desc,
                                  confirmText: AppLanguageKey.ok,
                                  cancelText: AppLanguageKey.cancel,
                                  onConfirm: () {
                                    controller.checkIn();
                                  },
                                );
                              },
                              icon: SvgPicture.asset(
                                AssetPath.iconCheckIn,
                                width: 25.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Space(width: 10.w),
                        Expanded(
                          child: SizedBox(
                            height: 60.h,
                            child: ButtonWidget(
                              text: AppLanguageKey.check_out,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    context.colors.secondary),
                              ),
                              onPressed: () async {
                                CommonDialog.showConfirmation(
                                  title: AppLanguageKey
                                      .check_in_and_check_out_confirmation,
                                  description: AppLanguageKey
                                      .check_in_and_check_out_confirmation_desc,
                                  confirmText: AppLanguageKey.ok,
                                  cancelText: AppLanguageKey.cancel,
                                  onConfirm: () {
                                    controller.checkOut();
                                  },
                                );
                              },
                              icon: SvgPicture.asset(
                                AssetPath.iconCheckOut,
                                width: 25.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Space(height: 10.h),
                  SizedBox(
                    height: 180.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 180.h,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ColorConstants.supportCardBackground,
                                  borderRadius: BorderRadius.circular(14)),
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLanguageKey.leave_days.toUpperCase(),
                                        style: Typo.h3,
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            controller.changeNavToLeave(),
                                        child: Text(
                                          '${AppLanguageKey.more_info}>',
                                          style: Typo.actionS.copyWith(
                                              color: context.colors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Obx(() => Text(
                                                (controller.annualLeave.value
                                                            ?.remainingLeave ??
                                                        "0")
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 55,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.bottomLeft,
                                          height: 40.h,
                                          child: Text(
                                            AppLanguageKey.day_left,
                                            style: Typo.actionM,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Obx(() => Text(
                                        '${AppLanguageKey.leave_used} ${controller.annualLeave.value?.leaveUsed?.toInt() ?? "0"} ${AppLanguageKey.day_left}, ${AppLanguageKey.total_leave_can_use} ${controller.annualLeave.value?.totalLeaveCanUse?.toInt() ?? "0"} ${AppLanguageKey.day_left}',
                                        style: Typo.actionM,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Space(width: 10.w),
                        Expanded(
                          child: SizedBox(
                            height: 180.h,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ColorConstants.supportCardBackground,
                                  borderRadius: BorderRadius.circular(14)),
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLanguageKey.personal.toUpperCase(),
                                        style: Typo.h3,
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            controller.goToProfileDetail(),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: context.colors.primary,
                                          size: 20.w,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CachedAvatarImage(
                                    imageUrl: controller.user.value?.imageURL,
                                    size: 50.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.user.value?.fullName ?? "--",
                                        style: Typo.h4,
                                      ),
                                      Text(
                                        controller.user.value?.email ?? "--",
                                        style: Typo.actionM,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Space(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dasboard',
                        style: Typo.h2,
                      ),
                      InkWell(
                        onTap: () => controller.changeNavToDashboard(),
                        child: Text(
                          '${AppLanguageKey.more_info}>',
                          style: Typo.actionL
                              .copyWith(color: context.colors.primary),
                        ),
                      ),
                    ],
                  ),
                  Space(
                    height: 20.h,
                  ),
                  _buildPersonnelChangesChart(),
                  Space(
                    height: 20.h,
                  ),
                ]),
              ),
            ),
          )),
    );
  }

  Widget _buildPersonnelChangesChart() {
    final barGroups = data.monthlyData.entries.map((entry) {
      final month = int.parse(entry.key);
      final monthData = entry.value;

      final beginHeight = monthData.employeeBegin.toDouble();
      final newHeight = monthData.employeeNewRecruits.toDouble();
      final leaveHeight = monthData.employeeLeave.toDouble();
      final endHeight = monthData.employeeEnd.toDouble();

      return BarChartGroupData(
        x: month - 1,
        barRods: [
          BarChartRodData(
            toY: beginHeight + newHeight + leaveHeight + endHeight,
            width: 22,
            rodStackItems: [
              BarChartRodStackItem(
                0,
                beginHeight,
                Colors.blue,
              ),
              BarChartRodStackItem(
                beginHeight,
                beginHeight + newHeight,
                Colors.green,
              ),
              BarChartRodStackItem(
                beginHeight + newHeight,
                beginHeight + newHeight + leaveHeight,
                Colors.red,
              ),
              BarChartRodStackItem(
                beginHeight + newHeight + leaveHeight,
                beginHeight + newHeight + leaveHeight + endHeight,
                Colors.purple,
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.zero),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 7,
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < data.monthlyData.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('T${(value + 1).toInt()}'),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  groupsSpace: 20,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final monthData =
                            data.monthlyData[(groupIndex + 1).toString()];
                        return BarTooltipItem(
                          'Đầu tháng: ${monthData?.employeeBegin}\n'
                          'Tuyển mới: ${monthData?.employeeNewRecruits}\n'
                          'Nghỉ việc: ${monthData?.employeeLeave}\n'
                          'Cuối tháng: ${monthData?.employeeEnd}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('Đầu tháng', Colors.blue),
                _buildLegendItem('Tuyển mới', Colors.green),
                _buildLegendItem('Nghỉ việc', Colors.red),
                _buildLegendItem('Cuối tháng', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
