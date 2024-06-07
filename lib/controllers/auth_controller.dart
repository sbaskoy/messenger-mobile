import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_state/s_state.dart';

import '../config/push_notifications.dart';
import '../constants/app_managers.dart';
import '../constants/app_services.dart';
import '../managers/local_manager.dart';
import '../models/auth/auth_user.dart';
import '../models/auth/user.dart';
import '../utils/app_utils.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../widgets/progress_indicator/progress_indicator.dart';

class AuthController {
  final authUser = SState<AuthUser>();

  String? accessToken() => authUser.valueOrNull?.accessToken;
  String? refreshToken() => authUser.valueOrNull?.refreshToken;
  String? phpToken() => authUser.valueOrNull?.phpToken;
  User? get user => authUser.valueOrNull?.user;

  void login(String email, String password, {Widget Function()? nextPageBuilder}) async {
    try {
      AppProgressController.show();
      var firebaseToken = await getFirebaseToken();
      log("Firebase Token-> $firebaseToken");
      var response = await AppServices.auth.login(email, password, firebaseToken: firebaseToken);
      if (response != null) {
        authUser.setState(response);
        AppManagers.local.setString(LocalManagerKey.username, email);
        AppManagers.local.setString(LocalManagerKey.password, password);
        AppManagers.local.setBool(LocalManagerKey.isLogged, true);
        saveToPreferences();
        if (response.accessToken != null) {
          AppManagers.local.setString(LocalManagerKey.accessToken, response.accessToken ?? "");
        }

        if (nextPageBuilder == null) {
          Get.offAll(() => const HomeView());
        } else {
          Get.offAll(() => nextPageBuilder());
        }
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  void checkIsLogged(String email, String password) {
    if (AppManagers.local.getBool(LocalManagerKey.isLogged) && email.isNotEmpty && password.isNotEmpty) {
      login(email, password);
    }
  }

  void setAccessToken(String token) {
    var user = authUser.valueOrNull;
    if (user != null) {
      user.accessToken = token;
      authUser.setState(user);
    }
  }

  void setRefreshToken(String token) {
    var user = authUser.valueOrNull;
    if (user != null) {
      user.refreshToken = token;
      authUser.setState(user);
    }
  }

  void saveToPreferences() {
    var user = authUser.valueOrNull;
    if (user == null) return;
    AppManagers.local.setString(LocalManagerKey.user, jsonEncode(user.toJson()));
  }

  void loadFromPreferences() {
    var str = AppManagers.local.getString(LocalManagerKey.user);
    if (str.isNotEmpty) {
      var userStr = jsonDecode(str);
      authUser.setState(AuthUser.fromJson(userStr));
    }
  }

  Future<void> logout() async {
    await AppServices.auth.logout();
    AppManagers.local.setString(LocalManagerKey.user, "");
    AppManagers.local.setBool(LocalManagerKey.isLogged, false);
    AppManagers.socket.client?.disconnect();
    SGlobalState.dispose();
    Get.offAll(() => const LoginView());
  }
}
