import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/issue_report/issue_report_controller.dart';
import 'package:flutter_getx_boilerplate/modules/issue_report/widgets/widgets.dart';
import 'package:flutter_getx_boilerplate/shared/extension/extension.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/widgets.dart';
import 'package:get/get.dart';

class IssueReportScreen extends GetView<IssueReportController> {
  const IssueReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBarWidget(
        title: 'Report Issue',
        backgroundColor: context.colors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: context.colors.surface,
            onPressed: () {
              Get.toNamed('/issue-history');
            },
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.getCurrentLocation(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocationCardWidget(
                  position: controller.currentPosition.value,
                  address: controller.currentAddress.value,
                  isLoading: controller.isLoading.value,
                  onRefresh: controller.getCurrentLocation,
                ),
                const SizedBox(height: 16),
                IssueTypeSelectionWidget(
                  selectedType: controller.issueType.value,
                  onTypeChanged: (type) => controller.issueType.value = type,
                ),
                const SizedBox(height: 16),
                PrioritySelectionWidget(
                  selectedPriority: controller.issuePriority.value,
                  onPriorityChanged: (priority) => controller.issuePriority.value = priority,
                ),
                const SizedBox(height: 16),
                DescriptionInputWidget(
                  controller: controller.issueDescription,
                  hintText: 'Describe the issue in detail...',
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(context),
                const SizedBox(height: 16),
                _buildRecentReportsSection(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : controller.submitIssueReport,
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.camera_alt),
          label: Text(
            controller.isLoading.value ? 'Submitting...' : 'Take Photo & Submit Report',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRecentReportsSection(BuildContext context) {
    return Obx(() {
      if (controller.issueReports.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/issue-history'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IssueReportsListWidget(
            reports: controller.issueReports.take(3).toList(),
            onReportTap: (report) => controller.viewImageFullScreen(report),
            onDeleteReport: (id) => controller.deleteIssueReport(id),
            onStatusChanged: (id, status) => controller.updateIssueStatus(id, status),
            emptyMessage: 'No recent reports',
          ),
        ],
      );
    });
  }
}
