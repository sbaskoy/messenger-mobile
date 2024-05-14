import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';
import '../constants/app_constants.dart';
import '../constants/app_controllers.dart';
import '../widgets/progress_indicator/centered_progress_indicator.dart';
import '../widgets/snackbar/custom_snackbar.dart';
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
    return showModalBottomSheet(
      showDragHandle: true,
      useSafeArea: false,
      useRootNavigator: true,
      context: context,
      isScrollControlled: (initHeight ?? 0) > 0.5 ? true : false,
      builder: (context) {
        return builder(context, ScrollController(), 1);
      },
    );
    // return Get.bottomSheet(
    //   SafeArea(
    //     child: Container(
    //       decoration: const BoxDecoration(color: Colors.transparent),
    //       child: Column(
    //         children: [
    //           Container(
    //             height: 5,
    //             width: 50,
    //             decoration: BoxDecoration(
    //               color: Colors.grey.shade100,
    //               borderRadius: BorderRadius.circular(5),
    //             ),
    //           ),
    //           const SizedBox(height: 5),
    //           Expanded(
    //             child: Container(
    //               decoration: AppConstants.popupDecoration(context),
    //               child: builder(context, ScrollController(), 1),
    //             ),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    //   isScrollControlled: (initHeight ?? 0) > 0.5 ? true : false,
    //   ignoreSafeArea: false,
    // );
  }

  static Future<bool> buildYesOrNoAlert(BuildContext context, String message) async {
    // if (!Platform.isIOS) {
    //   return await showDialog<bool>(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             insetPadding: const EdgeInsets.all(4),
    //             actionsPadding: const EdgeInsets.all(4),
    //             title: BodyLargeText(message, fontSize: 12),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context, false),
    //                 child: const Text('No'),
    //               ),
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context, true),
    //                 child: const Text('Yes'),
    //               )
    //             ],
    //           );
    //         },
    //       ) ??
    //       false;
    // }

    return await showCupertinoDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
            title: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: const Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  // static Widget sStateBuilder<T>( bool loading, List<T> item, dynamic error, BuildContext context){
  //   return
  // }
  static Widget Function(bool, T?, dynamic, BuildContext) sStateBuilder<T>(
    Widget Function(T data) builder, {
    String? emptyMessage,
  }) {
    return (bool loading, T? data, dynamic error, BuildContext context) {
      if (error != null) {
        return CenteredErrorText(error.toString());
      }
      if (data != null) {
        if (data is List && data.isEmpty && emptyMessage != null) {
          return Center(
            child: Text(emptyMessage),
          );
        }
        return builder(data);
      }
      return const CenteredProgressIndicator();
    };
  }

  static void clearTempDirectory() {
    var files = Directory.systemTemp.listSync();
    for (var element in files) {
      element.deleteSync(recursive: true);
    }
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
  static String? getImageUrl(String? url) {
    var user = AppControllers.auth.user;
    return url?.replaceAll(("viewFile/user_token"), "viewImage/${user?.id}-${user?.tenantId}");
  }

  static bool isImage(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    // const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'];
    return imageExtensions.any((element) => element == extension);
  }
}
