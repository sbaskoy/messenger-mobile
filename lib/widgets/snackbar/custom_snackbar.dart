import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../texts/app_text.dart';

class CustomSnackBar extends SnackBar {
  final String text;
  final Color? bgColor;
  final Color? textColor;
  CustomSnackBar(this.text, {super.key, this.bgColor, this.textColor})
      : super(
          content: BodyLargeText(
            text,
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: bgColor ?? Get.context!.theme.primaryColor,
        );
}
