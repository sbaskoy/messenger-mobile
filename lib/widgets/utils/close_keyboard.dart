import 'package:flutter/cupertino.dart';

class CloseKeyboardWidget extends StatelessWidget {
  final Widget child;
  const CloseKeyboardWidget({super.key, required this.child});

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
