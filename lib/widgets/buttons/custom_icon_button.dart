import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomIconButton extends StatelessWidget {
  final Color? color;
  final IconData icon;
  final VoidCallback? onPressed;
  const CustomIconButton({super.key, this.color, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: color ?? context.theme.disabledColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed ?? () {},
        ));
  }
}
