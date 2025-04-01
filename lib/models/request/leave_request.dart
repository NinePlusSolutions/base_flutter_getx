class LeaveRequest {
  final String leaveType;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final DateTime requestDate;
  final String reason;

  LeaveRequest({
    required this.leaveType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.requestDate,
    required this.reason,
  });
}
