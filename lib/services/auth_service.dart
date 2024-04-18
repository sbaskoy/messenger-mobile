import 'package:planner_messenger/models/api_info_mode.dart';
import 'package:planner_messenger/services/messenger_service.dart';

import '../models/auth/auth_user.dart';

class AuthService {
  final MessengerService service;

  AuthService({required this.service});

  Future<AuthUser?> login(String username, String password, {String? firebaseToken}) async {
    var loginResponse = await service.dio.post(
      "/auth/login",
      data: {
        "email": username,
        "password": password,
        "firebase_token": firebaseToken,
      },
    );
    if (loginResponse.data != null) {
      return AuthUser.fromJson(loginResponse.data);
    }
    return null;
  }

  Future<ApiInfoModel?> logout() async {
    var response = await service.dio.post("/auth/logout");
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }
}
