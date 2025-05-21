import 'package:flutter_getx_boilerplate/models/response/ttlock_keyboard_pwd/ttlock_keyboard_pwd_model.dart';

class TTLockKeyboardPwdListResponse {
  final List<TTLockKeyboardPwdModel> list;
  final int pageNo;
  final int pageSize;
  final int pages;
  final int total;

  TTLockKeyboardPwdListResponse({
    required this.list,
    required this.pageNo,
    required this.pageSize,
    required this.pages,
    required this.total,
  });

  factory TTLockKeyboardPwdListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['list'] ?? [];
    final List<TTLockKeyboardPwdModel> passwordList =
        rawList.map((item) => TTLockKeyboardPwdModel.fromJson(item)).toList();

    return TTLockKeyboardPwdListResponse(
      list: passwordList,
      pageNo: json['pageNo'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      pages: json['pages'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

extension TTLockKeyboardPwdModelExtension on TTLockKeyboardPwdModel {
  Map<String, dynamic> toJson() {
    return {
      'keyboardPwdId': keyboardPwdId,
      'lockId': lockId,
      'keyboardPwd': keyboardPwd,
      'keyboardPwdName': keyboardPwdName,
      'keyboardPwdType': keyboardPwdType,
      'startDate': startDate,
      'endDate': endDate,
      'sendDate': sendDate,
      'isCustom': isCustom,
      'senderUsername': senderUsername,
    };
  }
}
