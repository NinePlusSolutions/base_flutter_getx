class TTLockKeyboardPwdModel {
  final int keyboardPwdId;
  final int lockId;
  final String keyboardPwd;
  final String keyboardPwdName;
  final int keyboardPwdType;
  final int startDate;
  final int endDate;
  final int sendDate;
  final int isCustom;
  final String senderUsername;

  TTLockKeyboardPwdModel({
    required this.keyboardPwdId,
    required this.lockId,
    required this.keyboardPwd,
    required this.keyboardPwdName,
    required this.keyboardPwdType,
    required this.startDate,
    required this.endDate,
    required this.sendDate,
    required this.isCustom,
    required this.senderUsername,
  });

  factory TTLockKeyboardPwdModel.fromJson(Map<String, dynamic> json) {
    return TTLockKeyboardPwdModel(
      keyboardPwdId: json['keyboardPwdId'] ?? 0,
      lockId: json['lockId'] ?? 0,
      keyboardPwd: json['keyboardPwd'] ?? '',
      keyboardPwdName: json['keyboardPwdName'] ?? '',
      keyboardPwdType: int.tryParse(json['keyboardPwdType']?.toString() ?? '0') ?? 0,
      startDate: json['startDate'] ?? 0,
      endDate: json['endDate'] ?? 0,
      sendDate: json['sendDate'] ?? 0,
      isCustom: json['isCustom'] ?? 0,
      senderUsername: json['senderUsername'] ?? '',
    );
  }

  // Helper method to format passcode type text
  String get passcodeTypeText {
    switch (keyboardPwdType) {
      case 1:
        return 'One-time';
      case 2:
        return 'Permanent';
      case 3:
        return 'Period';
      case 4:
        return 'Delete';
      case 5:
        return 'Weekend';
      case 6:
        return 'Daily';
      case 7:
        return 'Workday';
      case 8:
        return 'Monday';
      case 9:
        return 'Tuesday';
      case 10:
        return 'Wednesday';
      case 11:
        return 'Thursday';
      case 12:
        return 'Friday';
      case 13:
        return 'Saturday';
      case 14:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  // Method to format date for display
  String formatDate(int timestamp) {
    if (timestamp <= 0) return 'N/A';
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get formattedStartDate => formatDate(startDate);
  String get formattedEndDate => formatDate(endDate);
}
