class ApiConstants {
  static const baseUrlDev = 'http://103.98.152.50:5019/api/';
  static const baseUrlProd = 'https://reqres.in';
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = 'identity/token';
  static const String me = 'auth/me';
  static const String profile = 'v1/my-info/employee-profile';

  // Check in and check out
  static const String checkIn = 'v1/employee-log-time';

  // Leave
  static const String annualLeave = '/v1/annual-leave/annual-my-leave';
  static const String leavesList = 'v1/annual-leave/employee-my-leave';
  static const String commonLeaveType = 'v1/commons/data-kbn-leave-type';

  // Profile
  static const String updateIdentity = 'v1/employees/employee-identity';
  static const String updateProfile = 'v1/my-info/employee-information';

  // Notification
  static const String notificationList = 'v1/notifications/notification-by-employeeNo';

}
