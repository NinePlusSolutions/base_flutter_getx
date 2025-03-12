import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PatternConstants {
  static const String ddMMyyyy = 'dd-MM-yyyy';
  static const String ddMMYYYY = 'dd/MM/yyyy';
  static const String ddMMYYYYHmm = 'dd/MM/yyyy HH:mm';
  static const String hhMmDDYYYY = 'HH:mm dd/MM/yyyy';
  static const String HHmm = 'HH:mm';

  static const String UTC = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
}

extension DateTimeExt on DateTime {
  bool isBefore(String utc) {
    final now = DateTime.now();
    final date = DateTime.parse(utc);
    return date.isBefore(now);
  }

  String get toUtc {
    final utc = DateFormat(PatternConstants.UTC).format(this.toUtc());
    return utc;
  }

  String format(String? pattern) {
    final pat = pattern ?? PatternConstants.ddMMYYYY;
    final utcDate = DateTime.parse(toLocal);

    return DateFormat(pattern).format(utcDate);
  }

  /// Compare date with current date is after now
  /// @[example]
  /// current date is 2021/10/10;
  /// DateTimeUtils.isDateAfter(DateTime(2021, 10, 17), 6); // true
  /// DateTimeUtils.isDateAfter(DateTime(2021, 10, 17), 8); // false
  bool isDateBeforeDay(int count) {
    final now = DateTime.now();
    final diff = this.difference(now).inDays;

    return diff < count;
  }

  // get time sent message
  // return: Yesterday, Today or dd/MM/yyyy
  String sentTimeChat() {
    final day2Date = DateTime.now().difference(this).inDays;

    if (day2Date == 0) {
      return 'today'.tr;
    } else if (day2Date == 1) {
      return 'yesterday'.tr;
    } else {
      return format(PatternConstants.ddMMYYYY);
    }
  }

  String get toLocal {
    final local =
        DateFormat(PatternConstants.UTC).format(this.toUtc().toLocal());
    return local;
  }

  String getLastTime() {
    try {
      final now = DateTime.now();
      final difference = now.difference(this);

      if (difference.inSeconds < 60) {
        return 'just_now'.tr;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${'minutes_ago'.tr}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${'hours_ago'.tr}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${'days_ago'.tr}';
      } else {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${'weeks_ago'.tr}';
      }
    } catch (e) {
      return 'undefined_time'.tr;
    }
  }
}
