import 'package:flutter/material.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/models/auth/user.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

class UsersController {
  final users = SState<List<User>>();
  final searchText = SState<String>("");

  final TextEditingController searchTextField = TextEditingController();

  late final SReadOnlyState<List<User>> filteredUsers;

  UsersController() {
    filteredUsers = users.combine(searchText, (current, other) {
      var searchTerm = other.toLowerCase();
      return current.where((element) => (element.fullName ?? "").toLowerCase().contains(searchTerm)).toList();
    });
    searchTextField.addListener(() {
      searchText.setState(searchTextField.text);
    });
  }

  Future<void> listUsers() async {
    try {
      AppProgressController.show();
      var response = await AppServices.users.getUsers();
      if (response != null) {
        users.setState(response);
      }
    } catch (ex) {
      users.setError(AppUtils.getErrorText(ex));
    } finally {
      AppProgressController.hide();
    }
  }
}
