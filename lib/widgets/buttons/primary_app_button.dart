import 'package:flutter/material.dart';

class PrimaryAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? bgColor;
  final double? width;
  final double? height;
  const PrimaryAppButton({super.key, required this.text, this.onTap, this.bgColor, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 48,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
