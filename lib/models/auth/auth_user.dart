import 'package:planner_messenger/models/auth/user.dart';

class AuthUser {
  String? accessToken;
  String? refreshToken;
  String? phpToken;
  User? user;

  AuthUser({this.accessToken, this.refreshToken, this.user});

  AuthUser.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    phpToken = json['php_token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
