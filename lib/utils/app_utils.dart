import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/progress_indicator/centered_progress_indicator.dart';
import '../widgets/snackbar/custom_snackbar.dart';
import '../widgets/texts/app_text.dart';
import '../widgets/texts/centered_error_text.dart';
import 'hex_color.dart';

class AppUtils {
  AppUtils._();
  static String getErrorText(dynamic error) {
    var text = "";
    if (error is DioException) {
      text = error.error.toString();
    } else if (error is Exception) {
      text = "$error";
    } else if (error is String) {
      text = error;
    } else {
      text = "$error";
    }
    return text;
  }

  static void showErrorSnackBar(dynamic error, {Color? bgColor, Color? textColor}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(CustomSnackBar(
      getErrorText(error),
      bgColor: Get.context!.theme.colorScheme.error,
      textColor: textColor ?? HexColor(AppTheme.secondaryColorString),
    ));
  }

  void showInfoSnackbar(String text, {Color? bgColor, Color? textColor}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(CustomSnackBar(
      text,
      bgColor: bgColor,
      textColor: textColor ?? HexColor(AppTheme.secondaryColorString),
    ));
  }

  static Future<T?> showFlexibleDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext c, ScrollController scrollController, double) builder,
    double? initHeight,
  }) {
    return showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: initHeight ?? 0.5,
      maxHeight: 1,
      context: context,
      duration: const Duration(milliseconds: 500),
      builder: (context, scrollController, bottomSheetOffset) {
        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Container(
                  decoration: AppConstants.popupDecoration(context),
                  child: builder(context, scrollController, bottomSheetOffset),
                ),
              )
            ],
          ),
        );
      },
      anchors: [0, 0.5, 1],
      isSafeArea: true,
      bottomSheetColor: Colors.transparent,
    );
  }

  static Future<bool> buildYesOrNoAlert(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(4),
              actionsPadding: const EdgeInsets.all(4),
              title: BodyLargeText(message, fontSize: 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                )
              ],
            );
          },
        ) ??
        false;
  }

  // static Widget sStateBuilder<T>( bool loading, List<T> item, dynamic error, BuildContext context){
  //   return
  // }
  static Widget Function(bool, T?, dynamic, BuildContext) sStateBuilder<T>(Widget Function(T data) builder) {
    return (bool loading, T? data, dynamic error, BuildContext context) {
      if (error != null) {
        return CenteredErrorText(error.toString());
      }
      if (data != null) {
        return builder(data);
      }
      return const CenteredProgressIndicator();
    };
  }

  static Widget appListView<T>(
      {required List<T> items,
      required Widget Function(BuildContext context, int index, T item) builder,
      bool? shrinkWrap,
      ScrollController? scrollController,
      EdgeInsetsGeometry? padding,
      Axis? axis,
      ScrollPhysics? physics}) {
    return ListView.builder(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.zero,
      scrollDirection: axis ?? Axis.vertical,
      controller: scrollController,
      itemCount: items.length,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      shrinkWrap: shrinkWrap ?? false,
      itemBuilder: (context, index) {
        var item = items[index];
        return builder(context, index, item);
      },
    );
  }

  static Widget buildNotifyBadge() => Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        ),
      );
}
