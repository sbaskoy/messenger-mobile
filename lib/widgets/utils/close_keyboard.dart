import 'package:flutter/cupertino.dart';

class CloseKeyboardWidget extends StatelessWidget {
  final Widget child;
  const CloseKeyboardWidget({Key? key, required this.child}) : super(key: key);

  static closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        closeKeyboard(context);
      },
      child: child,
    );
  }
}
