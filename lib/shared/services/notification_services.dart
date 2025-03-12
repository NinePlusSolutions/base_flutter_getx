//**
// Before using this file, you need to add dependency:
// + local_notification: https://pub.dev/packages/flutter_local_notifications
// + firebase flutter  : https://firebase.flutter.dev/docs/overview/
// */


// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     name: 'your_app_name',
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   showLocalNotification(
//     message.hashCode,
//     "<>",
//     "<>",
//   );
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// class NotificationHandler {
//   final FirebaseMessaging messaging = FirebaseMessaging.instance;

//   final AndroidNotificationChannel androidChannel =
//       const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     '<>', // title
//     importance: Importance.max,
//     showBadge: true,
//     playSound: true,
//     enableVibration: true,
//   );

//   Future init() async {
//     await _createdChannelHandler();
//     await _requestPermissions();
//     await _initLocalNotification();

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }

//   void setListeners() {
//     //kill app
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) async {
//       if (message != null) {
//         log('getInitialMessage: ${message.toMap()}');
//         NotificationResponse response = NotificationResponse(
//           payload: jsonEncode(message.toMap()),
//           notificationResponseType:
//               NotificationResponseType.selectedNotification,
//         );
//         onClickNotification(response);
//       }
//     });

//     // app Foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       AppLogger.i('onMessage: ${message.toMap()}');
//       final data = message.data;
//       final isMessage = data['type'] == 'message.new';

//       if (isMessage) {
//         final channelId = data['channel_id'];
//         final messageId = data['message_id'];
//         // final channel = chatClient.channels[channelId];
//         // final message = await channel.getMessage(messageId);
//         // final user = message.user;
//         // final title = user.name;
//         // final body = message.text;
//         // _showLocalNotification(0, title, body);
//         showLocalNotification(
//           message.hashCode,
//           "<>",
//           "<>",
//           payload: jsonEncode(data),
//         );
//       } else {
//         final title = "<>";
//         final body = "<>";
//         showLocalNotification(
//           0,
//           title,
//           body,
//         );
//       }
//     });

//     // app Background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       AppLogger.i('onMessageOpenedApp: ${message.toMap()}');
//       NotificationResponse response = NotificationResponse(
//         payload: jsonEncode(message.toMap()),
//         notificationResponseType: NotificationResponseType.selectedNotification,
//       );
//       onClickNotification(response);
//     });
//   }

//   _createdChannelHandler() async {
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(androidChannel);
//   }

//   /// -------- FIREBASE HANDLER --------
//   _requestPermissions() async {
//     await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       provisional: false,
//       sound: true,
//     );

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: false,
//       criticalAlert: true,
//       sound: true,
//     );

//     await messaging.setForegroundNotificationPresentationOptions(
//       alert: true, // Required to display a heads up notification
//       badge: true,
//       sound: true,
//     );

//     log('User granted permission: ${settings.authorizationStatus}');
//   }

//   Future<String?> getToken() async {
//     try {
//       final initial = await messaging.isSupported();

//       if (!initial) {
//         await _requestPermissions();
//       }
//       String? apnsToken = await messaging.getAPNSToken();
//       final token = await messaging.getToken();

//       print('APNS Token: $apnsToken');
//       print('fcm Token: $token');

//       return token;
//     } catch (e) {
//       AppLogger.e("Get token got error: ${e.toString()}");
//       return null;
//     }
//   }

//   /// -------- LOCAL NOTIFICATION HANDLER --------
//   static onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) async {
//     final _tag = "NotificationHandler";
//     log('$_tag: onDidReceiveLocalNotification: $id, $title, $body, $payload');
//   }

//   static _initLocalNotification() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     DarwinInitializationSettings initializationSettingsDarwin =
//         const DarwinInitializationSettings(
//       onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//     );

//     InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );

//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: onClickNotification,
//       onDidReceiveBackgroundNotificationResponse: onClickNotification,
//     );
//   }

//   /// -------- NOTIFICATION DEEP LINK HANDLER --------
//   static Future<void> onClickNotification(NotificationResponse? payload) async {
//     final _tag = "NotificationHandler";
//     log('$_tag: onClickNotification: ${payload?.payload}');
//     final data = jsonDecode(payload?.payload ?? '{}');
//     final isMessage = data['type'] == 'message.new';
//     if (isMessage) {
//       final cid = data['cid'];

//       _navigateTo(
//         Routes.CHANNEL_PAGE,
//         parameters: {"cid": cid, "type": "notification"},
//       );
//     } else {
//       // handle notification
//     }
//   }
// }

// showLocalNotification(
//   int? id,
//   String title,
//   String msg, {
//   String? payload,
// }) async {
//   final detail = _getNotificationDetails();

//   await flutterLocalNotificationsPlugin.show(
//     id ?? 0,
//     title,
//     msg,
//     detail,
//     payload: payload,
//   );
// }

// NotificationDetails _getNotificationDetails() {
//   const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//       DarwinNotificationDetails();
//   final AndroidNotificationChannel androidChannel =
//       const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'N Ơi', // title
//     importance: Importance.max,
//     showBadge: true,
//     playSound: true,
//     enableVibration: true,
//   );

//   final AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     androidChannel.id,
//     androidChannel.name,
//     channelDescription: androidChannel.description,
//     icon: "@mipmap/ic_launcher_round",
//     importance: Importance.max,
//     styleInformation: const BigTextStyleInformation(''),
//   );

//   return defaultTargetPlatform == TargetPlatform.iOS
//       ? const NotificationDetails(iOS: iOSPlatformChannelSpecifics)
//       : NotificationDetails(android: androidPlatformChannelSpecifics);
// }

// _navigateTo(String name, {Map<String, String>? parameters}) async {
//   final currentRoute = Get.currentRoute.split("?").first;
//   if (currentRoute == name) {
//     Get.back();
//     Future.delayed(
//       const Duration(milliseconds: 1000),
//       () => Get.toNamed(name, parameters: parameters),
//     );
//     return;
//   }

//   Get.toNamed(name, parameters: parameters);
// }
