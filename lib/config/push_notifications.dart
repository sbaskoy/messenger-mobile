import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel andChannel =
    AndroidNotificationChannel("id", 'high_importance_channel', description: "Notification");
// ignore: unnecessary_new
final FlutterLocalNotificationsPlugin plugins = FlutterLocalNotificationsPlugin();

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future _onSelectBackgroundNotification(NotificationResponse payload) async {
  log("Notification Select");
}

Future _onSelectNotification(NotificationResponse payload) async {
  log("Notification Select");
}

Future<void> _initNotifications() async {
  FirebaseMessaging.instance.subscribeToTopic("all");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    // AndroidNotification? android = message.notification?.android;
    log("Firebase Message ");
    if (notification != null) {
      log("Data->${message.data}");

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        andChannel.id,
        andChannel.name,
        channelDescription: andChannel.description,
        importance: Importance.max,
        playSound: true,
        color: const Color(0xffC47AFF),
        showProgress: true,
        priority: Priority.high,
        ticker: 'Planner Messenger',
      );

      var iOSChannelSpecifics = const DarwinNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSChannelSpecifics,
      );
      plugins.show(notification.hashCode, notification.title, notification.body, platformChannelSpecifics,
          payload: "${notification.title}|${notification.body}");
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log("Clicked Message");
  });
}

Future<void> setFirebaseApp() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyApNDjObz8YORbifw_3yrIWoZmaiYZgQcE",
      appId: "1:570179754457:android:d20dd2e3de7859d8c021c8",
      messagingSenderId: "570179754457",
      projectId: "planner-messenger",
      storageBucket: "planner-messenger.appspot.com",
    ),
  );
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
  await plugins
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(andChannel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> createNotificationChannel() async {
  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  plugins.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: _onSelectBackgroundNotification,
    onDidReceiveNotificationResponse: _onSelectNotification,
  );
  await _initNotifications();
}

Future<String?> getFirebaseToken() async {
  try {
    return await FirebaseMessaging.instance.getToken();
  } catch (ex) {}
  return null;
}
