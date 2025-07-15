import 'package:flutter/material.dart';

class IssueReportStatsWidget extends StatelessWidget {
  final int totalReports;
  final int pendingReports;
  final int inProgressReports;
  final int resolvedReports;

  const IssueReportStatsWidget({
    super.key,
    required this.totalReports,
    required this.pendingReports,
    required this.inProgressReports,
    required this.resolvedReports,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Total',
                totalReports.toString(),
                Colors.blue,
              ),
              _buildStatItem(
                'Pending',
                pendingReports.toString(),
                Colors.orange,
              ),
              _buildStatItem(
                'In Progress',
                inProgressReports.toString(),
                Colors.purple,
              ),
              _buildStatItem(
                'Resolved',
                resolvedReports.toString(),
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
