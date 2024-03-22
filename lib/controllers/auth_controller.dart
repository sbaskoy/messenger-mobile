import 'package:get/get.dart';

import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/managers/local_manager.dart';
import 'package:planner_messenger/models/auth/auth_user.dart';
import 'package:planner_messenger/models/auth/user.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/views/home_view.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

class AuthController {
  final authUser = SState<AuthUser>();

  String? get accessToken => authUser.valueOrNull?.accessToken;
  String? get phpToken => authUser.valueOrNull?.phpToken;
  User? get user => authUser.valueOrNull?.user;

  void login(String email, String password) async {
    try {
      AppProgressController.show();
      var response = await AppServices.auth.login(email, password);
      if (response != null) {
        authUser.setState(response);
        AppManagers.local.setString(LocalManagerKey.username, email);
        AppManagers.local.setString(LocalManagerKey.password, password);
        AppManagers.local.setBool(LocalManagerKey.isLogged, true);
        AppManagers.socket.initSocket(accessToken);
        Get.offAll(() => const HomeView());
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
}
