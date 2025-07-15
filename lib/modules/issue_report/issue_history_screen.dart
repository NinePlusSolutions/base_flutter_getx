import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/modules/issue_report/issue_report_controller.dart';
import 'package:flutter_getx_boilerplate/modules/issue_report/widgets/widgets.dart';
import 'package:flutter_getx_boilerplate/shared/extension/extension.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/widgets.dart';
import 'package:get/get.dart';

class IssueHistoryScreen extends GetView<IssueReportController> {
  const IssueHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBarWidget(
        title: 'Issue Reports History',
        backgroundColor: context.colors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: context.colors.surface,
            onPressed: () {
              Get.toNamed('/issue-report');
            },
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.getCurrentLocation(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: IssueReportStatsWidget(
                  totalReports: controller.totalReports,
                  pendingReports: controller.pendingReports,
                  inProgressReports: controller.inProgressReports,
                  resolvedReports: controller.resolvedReports,
                ),
              ),
              Expanded(
                child: controller.issueReports.isEmpty ? _buildEmptyState(context) : _buildReportsList(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Issue Reports Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by reporting your first issue\nto help improve workplace safety',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/issue-report'),
            icon: const Icon(Icons.add),
            label: const Text('Report First Issue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IssueReportsListWidget(
        reports: controller.issueReports,
        onReportTap: (report) => controller.viewImageFullScreen(report),
        onDeleteReport: (id) => _showDeleteConfirmation(context, id),
        onStatusChanged: (id, status) => controller.updateIssueStatus(id, status),
        emptyMessage: 'No issue reports found',
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String issueId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Issue Report'),
        content: const Text(
          'Are you sure you want to delete this issue report? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteIssueReport(issueId);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
