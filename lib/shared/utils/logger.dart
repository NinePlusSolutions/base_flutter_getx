import 'dart:developer' as developer;

class AppLogger {
  static e(String msg, {String? name}) {
    developer.log('\x1B[31m$msg\x1B[0m', name: name ?? "ERROR_LOG");
  }

  static void s(String msg, {String? name}) {
    developer.log('\x1B[32m$msg\x1B[0m', name: name ?? "SUCCESS_LOG");
  }

  static void i(String msg, {String? name}) {
    developer.log('\x1B[37m$msg\x1B[0m', name: name ?? "INFO_LOG");
  }

  static void w(String msg, {String? name}) {
    developer.log('\x1B[33m$msg\x1B[0m', name: name ?? "WARNING_LOG");
  }
}
