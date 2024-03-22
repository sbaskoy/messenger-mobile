import 'package:planner_messenger/models/auth/user.dart';
import 'package:planner_messenger/services/messenger_service.dart';

class UsersService {
  final MessengerService service;

  UsersService({required this.service});
  Future<List<User>?> getUsers() async {
    var response = await service.dio.get("/users");
    var jsonResponse = response.data;
    if (jsonResponse is List) {
      return jsonResponse.map((e) => User.fromJson(e)).toList();
    }
    return null;
  }
}
