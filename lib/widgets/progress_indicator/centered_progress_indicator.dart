import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class CenteredProgressIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  const CenteredProgressIndicator({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: color ?? context.theme.primaryColor,
        size: size ?? 25.0,
      ),
    );
  }
}
