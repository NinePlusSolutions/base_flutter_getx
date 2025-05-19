class InitLockRequest {
  final String lockData;
  final String lockAlias;
  final int? groupId;
  final int? nbInitSuccess;
  final int date;

  InitLockRequest({
    required this.lockData,
    required this.lockAlias,
    this.groupId,
    this.nbInitSuccess,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'lockData': lockData,
      'lockAlias': lockAlias,
      'date': date,
    };

    if (groupId != null) {
      data['groupId'] = groupId;
    }

    if (nbInitSuccess != null) {
      data['nbInitSuccess'] = nbInitSuccess;
    }

    return data;
  }
}