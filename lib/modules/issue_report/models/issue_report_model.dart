import 'package:flutter/material.dart';

enum IssueType {
  safety,
  equipment,
  quality,
  environment,
  other,
}

enum IssuePriority {
  low,
  medium,
  high,
  critical,
}

enum IssueStatus {
  pending,
  inProgress,
  resolved,
}

class IssueReportModel {
  final String id;
  final IssueType issueType;
  final IssuePriority priority;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String imageBase64;
  final DateTime timestamp;
  final IssueStatus status;
  final DateTime? lastUpdated;

  IssueReportModel({
    required this.id,
    required this.issueType,
    required this.priority,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageBase64,
    required this.timestamp,
    required this.status,
    this.lastUpdated,
  });

  factory IssueReportModel.fromJson(Map<String, dynamic> json) {
    return IssueReportModel(
      id: json['id'],
      issueType: IssueType.values.firstWhere(
        (e) => e.name == json['issueType'],
        orElse: () => IssueType.other,
      ),
      priority: IssuePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => IssuePriority.medium,
      ),
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      imageBase64: json['imageBase64'],
      timestamp: DateTime.parse(json['timestamp']),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == json['status'] || e.name.replaceAll('_', '') == json['status'],
        orElse: () => IssueStatus.pending,
      ),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'issue_report',
      'issueType': issueType.name,
      'priority': priority.name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'imageBase64': imageBase64,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name.replaceAll('Progress', '_progress').toLowerCase(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  IssueReportModel copyWith({
    String? id,
    IssueType? issueType,
    IssuePriority? priority,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? imageBase64,
    DateTime? timestamp,
    IssueStatus? status,
    DateTime? lastUpdated,
  }) {
    return IssueReportModel(
      id: id ?? this.id,
      issueType: issueType ?? this.issueType,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      imageBase64: imageBase64 ?? this.imageBase64,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

extension IssueTypeExtension on IssueType {
  String get displayName {
    switch (this) {
      case IssueType.safety:
        return 'Safety Issue';
      case IssueType.equipment:
        return 'Equipment Issue';
      case IssueType.quality:
        return 'Quality Issue';
      case IssueType.environment:
        return 'Environment Issue';
      case IssueType.other:
        return 'Other Issue';
    }
  }

  IconData get icon {
    switch (this) {
      case IssueType.safety:
        return Icons.security;
      case IssueType.equipment:
        return Icons.build;
      case IssueType.quality:
        return Icons.verified;
      case IssueType.environment:
        return Icons.eco;
      case IssueType.other:
        return Icons.info;
    }
  }

  Color get color {
    switch (this) {
      case IssueType.safety:
        return Colors.red;
      case IssueType.equipment:
        return Colors.blue;
      case IssueType.quality:
        return Colors.green;
      case IssueType.environment:
        return Colors.teal;
      case IssueType.other:
        return Colors.grey;
    }
  }
}

extension IssuePriorityExtension on IssuePriority {
  String get displayName {
    switch (this) {
      case IssuePriority.low:
        return 'Low';
      case IssuePriority.medium:
        return 'Medium';
      case IssuePriority.high:
        return 'High';
      case IssuePriority.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case IssuePriority.low:
        return Colors.green;
      case IssuePriority.medium:
        return Colors.orange;
      case IssuePriority.high:
        return Colors.red;
      case IssuePriority.critical:
        return Colors.red.shade900;
    }
  }
}

extension IssueStatusExtension on IssueStatus {
  String get displayName {
    switch (this) {
      case IssueStatus.pending:
        return 'Pending';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case IssueStatus.pending:
        return Colors.orange;
      case IssueStatus.inProgress:
        return Colors.blue;
      case IssueStatus.resolved:
        return Colors.green;
    }
  }
}
