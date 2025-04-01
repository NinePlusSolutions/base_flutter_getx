// import 'dart:async';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart';
//
// class FirebaseCrashlyticsUtil {
//   static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
//
//   /// Initialize Crashlytics
//   static Future<void> initialize() async {
//     FlutterError.onError = (FlutterErrorDetails errorDetails) {
//       _crashlytics.recordFlutterError(errorDetails);
//     };
//
//     PlatformDispatcher.instance.onError = (error, stack) {
//       _crashlytics.recordError(error, stack, fatal: true);
//       return true;
//     };
//   }
//
//   /// Log custom messages
//   static void log(String message) {
//     _crashlytics.log(message);
//   }
//
//   /// Record non-fatal errors
//   static void recordError(dynamic error, StackTrace stackTrace, {String? reason}) {
//     _crashlytics.recordError(error, stackTrace, reason: reason);
//   }
//
//   /// Set user identifier for tracking
//   static Future<void> setUserIdentifier(String? userId) async {
//     await _crashlytics.setUserIdentifier(userId?.toString() ?? '');
//   }
//
//   /// Clear user identifier
//   static Future<void> clearUserIdentifier() async {
//     // '' for userId null -> something wrong
//     // NL for not login
//     await _crashlytics.setUserIdentifier('NL');
//   }
// }
