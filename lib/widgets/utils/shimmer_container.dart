import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  final double? height;
  final double? width;
  const ShimmerContainer({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.disabledColor.withOpacity(0.1),
      highlightColor: context.theme.disabledColor.withOpacity(0.2),
      child: Container(
        color: context.theme.disabledColor,
        height: height,
        width: width,
      ),
    );
  }
}
