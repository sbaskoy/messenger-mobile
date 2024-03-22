import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/views/login_view.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:planner_messenger/widgets/utils/close_keyboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppManagers.local.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Planner Messenger',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.dark(scheme: FlexScheme.aquaBlue),
      builder: (context, child) {
        return CloseKeyboardWidget(
          child: AppProgressIndicator(child: child!),
        );
      },
      home: const LoginView(),
    );
  }
}
