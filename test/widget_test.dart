// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_services.dart';

import 'package:planner_messenger/main.dart';

void main() {
  test("Chat api", () async {
    var authController = AppControllers.auth;
    var authResponse = await AppServices.auth.login("salim@ganiotomasyon.com", "123Salim");
    expect(authResponse != null, true);
    authController.authUser.setState(authResponse!);
  });
}
