import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CUstomIconButton extends StatelessWidget {
  final Color? color;
  final IconData icon;
  final VoidCallback? onPressed;
  const CUstomIconButton({super.key, this.color, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: color ?? context.theme.disabledColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed ?? () {},
        ));
  }
}
