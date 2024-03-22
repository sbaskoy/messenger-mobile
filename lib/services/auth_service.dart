import 'package:planner_messenger/services/messenger_service.dart';

import '../models/auth/auth_user.dart';

class AuthService {
  final MessengerService service;

  AuthService({required this.service});

  Future<AuthUser?> login(String username, String password) async {
    var loginResponse = await service.dio.post(
      "/auth/login",
      data: {
        "email": username,
        "password": password,
      },
    );
    if (loginResponse.data != null) {
      return AuthUser.fromJson(loginResponse.data);
    }
    return null;
  }
}
