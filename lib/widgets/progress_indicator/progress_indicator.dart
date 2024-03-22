import 'package:flutter/material.dart';
import 'package:s_state/s_state.dart';

import 'centered_progress_indicator.dart';

class AppProgressController {
  static AppProgressController? _instance;
  static AppProgressController get _this {
    _instance ??= AppProgressController._init();
    return _instance!;
  }

  AppProgressController._init();

  final _loading = SState(false);
  //static Stream<bool> get loadingStream => _this._loading.stream;

  static void hide() {
    _this._loading.setState(false);
  }

  static void show() {
    _this._loading.setState(true);
  }

  static void toggle() {
    _this._loading.setState(!(_this._loading.valueOrNull ?? false));
  }
}

class AppProgressIndicator extends StatelessWidget {
  final Widget child;
  const AppProgressIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppProgressController._this._loading.builder(
        (loading, data, error, context) {
          var isProgress = data ?? false;
          return Stack(
            children: [
              AnimatedOpacity(
                opacity: isProgress ? 0.1 : 1,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: isProgress,
                  child: child,
                ),
              ),
              if (isProgress)
                const Align(
                  alignment: Alignment.center,
                  child: CenteredProgressIndicator(),
                )
            ],
          );
        },
      ),
    );
  }
}
