import 'package:flutter/material.dart';
import '../models/issue_report_model.dart';
import 'issue_report_card_widget.dart';

class IssueReportsListWidget extends StatelessWidget {
  final List<IssueReportModel> reports;
  final Function(IssueReportModel) onReportTap;
  final Function(String) onDeleteReport;
  final Function(String, IssueStatus) onStatusChanged;
  final String? emptyMessage;

  const IssueReportsListWidget({
    super.key,
    required this.reports,
    required this.onReportTap,
    required this.onDeleteReport,
    required this.onStatusChanged,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.report_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No issue reports found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: reports
          .map((report) => IssueReportCardWidget(
                issue: report,
                onTap: () => onReportTap(report),
                onDelete: () => onDeleteReport(report.id),
                onStatusChanged: (status) => onStatusChanged(report.id, status),
              ))
          .toList(),
    );
  }
}
