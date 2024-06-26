import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/views/calls/group_call_screen.dart';
import 'package:planner_messenger/views/chat_message/message_view.dart';
import 'package:planner_messenger/views/login_view.dart';

Timer? _callNotificationTimer;

const AndroidNotificationChannel andChannel =
    AndroidNotificationChannel("id", 'high_importance_channel', description: "Notification");
// ignore: unnecessary_new
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _showCallNotification(RemoteMessage message) async {
  var notificationId = int.tryParse(message.data["chat_id"]);
  var notification = message.notification;
  if (notificationId == null || notification == null) return;
  int currentSecond = 5;

  _callNotificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    currentSecond++;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "call",
      "call",
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
    await _setForegroundNotificationSetting(true);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notification.title,
      "${notification.body}timer içerisinden",
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
    if (currentSecond >= 5) {
      timer.cancel();
      flutterLocalNotificationsPlugin.cancel(notificationId);
      await _setForegroundNotificationSetting(false);
    }
  });
}

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await createNotificationChannel();
  if (message.data["notification_type"] == "NEW_CALL") {
    _showCallNotification(message);
  } else {
    increaseApplicationBadgeCount();
  }
}

Future _onSelectBackgroundNotification(NotificationResponse payload) async {
  log("Notification Select");
  log("Notification Select On  app");
  try {
    if (payload.payload == null) return;
    var messageData = jsonDecode(payload.payload!);
    var chatId = int.tryParse(messageData["chat_id"]?.toString() ?? "");

    if (chatId == null) {
      return;
    }
    if (messageData["notification_type" == "NEW_CALL"]) {
      _callNotificationTimer?.cancel();
      flutterLocalNotificationsPlugin.cancel(chatId);
      Get.offAll(
        () => LoginView(
          nextPageBuilder: () {
            return GroupCallScreen(
              chatId: chatId,
              isOwner: false,
            );
          },
        ),
      );
    } else if (messageData["notification_type" == "NEW_MESSAGE"]) {
      Get.offAll(() => LoginView(nextPageBuilder: () => MessageView(chatId: chatId)));
    }
  } catch (_) {}
}

Future _onSelectNotification(NotificationResponse payload) async {
  log("Notification Select On  app");
  try {
    if (payload.payload == null) return;
    var messageData = jsonDecode(payload.payload!);
    var chatId = int.tryParse(messageData["chat_id"]?.toString() ?? "");
    if (chatId != null) {
      Get.to(() => MessageView(chatId: chatId));
    }
  } catch (_) {}
  //FlutterAppBadger.updateBadgeCount(0);
}

FirebaseOptions _firebaseOptions() {
  if (Platform.isIOS) {
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

Future<void> increaseApplicationBadgeCount() async {
  try {
    int badgeNumber = await FlutterDynamicIcon.getApplicationIconBadgeNumber();
    FlutterDynamicIcon.setApplicationIconBadgeNumber(badgeNumber + 1);
  } catch (_) {}
}

Future<void> _setForegroundNotificationSetting(bool show) async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: show,
    badge: show,
    sound: show,
  );
}

Future<void> _initNotifications() async {
  FirebaseMessaging.instance.subscribeToTopic("all");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    // AndroidNotification? android = message.notification?.android;
    // AndroidNotification? android = message.notification?.android;
    log("Firebase Message ");
    var messageId = int.tryParse(message.data["id"].toString());
    increaseApplicationBadgeCount();
    if (notification != null && messageId != null) {
      log("Data->${message.data}");
      var chatId = message.data["chat_id"]?.toString();

      if (chatId == AppControllers.chatList.activeChatId?.toString()) {
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
      await _setForegroundNotificationSetting(true);
      await flutterLocalNotificationsPlugin.show(
        messageId,
        notification.title,
        "${notification.body}",
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
    await _setForegroundNotificationSetting(false);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log("Clicked Message");
    //FlutterAppBadger.updateBadgeCount(0);
  });
}

Future<void> setFirebaseApp() async {
  await Firebase.initializeApp(
    options: _firebaseOptions(),
  );
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(andChannel);

  await _setForegroundNotificationSetting(false);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> createNotificationChannel() async {
  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings(
      defaultPresentAlert: true, defaultPresentBadge: true, defaultPresentSound: true);
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin.initialize(
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
