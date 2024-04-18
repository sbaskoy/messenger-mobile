import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:planner_messenger/constants/app_controllers.dart';

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

FirebaseOptions _firebaseOptions(){
  if(Platform.isIOS){
    return const FirebaseOptions(
      apiKey: "AIzaSyAuCBHVo_D3uIbUWOFS2iK-ET4QcjgtdN8",
      appId: "1:570179754457:ios:997a6f8e697d71d7c021c8",
      messagingSenderId: "570179754457",
      projectId: "planner-messenger",
      storageBucket: "planner-messenger.appspot.com",
      
    );
  }
  return const FirebaseOptions(
      apiKey: "AIzaSyApNDjObz8YORbifw_3yrIWoZmaiYZgQcE",
      appId: "1:570179754457:android:d20dd2e3de7859d8c021c8",
      messagingSenderId: "570179754457",
      projectId: "planner-messenger",
      storageBucket: "planner-messenger.appspot.com",
    );
}

Future<void> _initNotifications() async {
  FirebaseMessaging.instance.subscribeToTopic("all");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    // AndroidNotification? android = message.notification?.android;
    log("Firebase Message ");
    if (notification != null) {
      log("Data->${message.data}");
      var chatId=message.data["chat_id"];
        if(chatId == AppControllers.chatList.activeChatId){
          return;
        }
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
          payload: "${notification.title}|${notification.body}",);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log("Clicked Message");
  });
}

Future<void> setFirebaseApp() async {
  await Firebase.initializeApp(
    options: _firebaseOptions(),
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
