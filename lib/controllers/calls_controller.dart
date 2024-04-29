import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/models/call/chat_call_model.dart';
import 'package:s_state/s_state.dart';

class CallsController {
  final calls = SState<List<ChatCallModel>>();

  Future<void> loadCalls() async {
    try {
      var response = await AppServices.call.listCalls();
      if (response != null) {
        calls.setState(response);
      }
    } catch (ex) {
      calls.setError(ex);
    }
  }
}
