// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_getx_boilerplate/models/model/receive_notification.dart';
// import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
// import 'package:flutter_getx_boilerplate/shared/services/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
//
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//     ) async {
//   await NotificationService().setupFlutterNotifications();
//   await NotificationService().showFlutterNotification(message);
// }
//
// class NotificationService {
//   bool isFlutterLocalNotificationsInitialized = false;
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   final AndroidNotificationChannel channel = const AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//   );
//
//   void handleNavigateNotification(RemoteMessage? message) async {
//     if (message == null) return;
//     final result = ReceiveNotification.fromJson(message.data);
//     if (!(StorageService.token != null)) {
//       NavigatorHelper.toAuth();
//     } else {
//       NavigatorHelper.toNotification();
//     }
//     }
//
//   Future<void> setupFlutterNotifications() async {
//     if (isFlutterLocalNotificationsInitialized) {
//       return;
//     }
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   Future<void> initializedLocalNotifications() async {
//     const iOS = DarwinInitializationSettings();
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const setting = InitializationSettings(android: android, iOS: iOS);
//     await flutterLocalNotificationsPlugin.initialize(
//       setting,
//       onDidReceiveNotificationResponse: _onNotificationResponse,
//     );
//   }
//
//   void _onNotificationResponse(NotificationResponse notificationResponse) {
//     if (notificationResponse.payload != null) {
//       final message =
//       RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
//       handleNavigateNotification(message);
//     }
//   }
//
//   Future<void> showFlutterNotification(RemoteMessage message) async {
//     await setupFlutterNotifications();
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     String? payload = jsonEncode(message.toMap());
//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         payload: payload,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             priority: Priority.high,
//             ticker: 'ticker',
//           ),
//         ),
//       );
//     }
//   }
// }
//
// class FirebaseService {
//   /// Foreground message
//   Future<void> firebaseMessagingForegroundHandler() async {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       NotificationService().showFlutterNotification(message);
//     });
//   }
//
//   Future<void> firebaseMessagingBackgroundOpenAppHandler() async {
//     FirebaseMessaging.onMessageOpenedApp
//         .listen(NotificationService().handleNavigateNotification);
//   }
// }
