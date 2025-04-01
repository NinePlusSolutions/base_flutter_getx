import 'package:flutter_getx_boilerplate/lang/generate/app_language_key.dart';
import 'package:flutter_getx_boilerplate/models/model/notification_model.dart';
import 'package:flutter_getx_boilerplate/modules/base/base_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/profile_repository.dart';
import 'package:get/get.dart';

class NotificationController extends BaseController<ProfileRepository> {
  NotificationController(super.repository);

  int pageNumberLeave = 1;
  int pageNumberCalendar = 1;
  int pageNumberCommon = 1;

  final RxList<NotificationModel> listNotificationLeave = <NotificationModel>[].obs;
  final RxList<NotificationModel> listNotificationCalendar = <NotificationModel>[].obs;
  final RxList<NotificationModel> listNotificationCommon = <NotificationModel>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
  }
  @override
  Future<void> getData() async {
    await getNotifications('EmployeeAlert', pageNumberCommon);
    await getNotifications('MyLeave', pageNumberLeave);
    await getNotifications('MyCalendar', pageNumberCalendar);
  }

  Future<void> getNotifications(String type, int pageNumber) async {
    try {
      final res = await repository.getNotification(type: type, pageNumber: pageNumber);
      if (res.succeeded) {
        _assignListNotification(type, res.data ?? []);
      }
    } catch (e) {
      showError(AppLanguageKey.connect_error,e.toString());
    }
  }

  void _assignListNotification(String type, List<NotificationModel> list) {
    switch (type) {
      case 'MyLeave':
        listNotificationLeave(list);
      case 'MyCalendar':
        listNotificationCalendar(list);
      case 'EmployeeAlert':
        listNotificationCommon(list);
    }
  }

}