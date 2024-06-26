import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/config/push_notifications.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/views/call_ring_view.dart';

import 'package:planner_messenger/views/login_view.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:planner_messenger/widgets/utils/close_keyboard.dart';

import 'constants/app_managers.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // com.bilsas.planner_messenger
  await AppManagers.local.load();

  await setFirebaseApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppControllers.auth.loadFromPreferences();
    var accessToken = AppControllers.auth.accessToken();
    createNotificationChannel();
    return GetMaterialApp(
      title: 'Planner Messenger',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.dark(scheme: FlexScheme.bahamaBlue),
      builder: (context, child) {
        return CallRingView(
          child: CloseKeyboardWidget(
            child: AppProgressIndicator(child: child!),
          ),
        );
      },
      home: accessToken != null ? const HomeView() : const LoginView(),
    );
  }
}
