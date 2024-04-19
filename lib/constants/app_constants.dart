import 'package:flutter/material.dart';

import '../utils/hex_color.dart';

class AppConstants {
  AppConstants._();
  // static String get baseUrl => "http://ganimuhendislik.com:1885";
  static String get baseUrl => "http://192.168.2.5:1881";
  static String get baseApiUrl => baseUrl;
  static String get tagGroupId => "1";
  static Color get progressGreenColor => HexColor("#4ADE80").withOpacity(0.8); // green-400
  static Color get progressYellowColor => HexColor("#FACC15").withOpacity(0.8);

  static Color get dailyExceptedGreenColor => HexColor('#4ADE80'); // green-400
  static Color get dailyExceptedYellowColor => HexColor('#FACC15'); // yellow-400
  static Color get dailyExceptedRedColor => HexColor('#FB7185'); // red -400
  static Color get dailyExceptedPurpleColor => HexColor('#C084FC'); // purple-400

  /// yellow-400
  static Color get progressRedColor => HexColor("#F43F5E").withOpacity(0.8); // rose-500

  static Color get dateTodayColor => HexColor("#FACC15");
  static Color get dateAfterColor => HexColor("#4ADE80");
  static Color get dateBeforeColor => HexColor("#FB7185");

  //
  static Color get exceptedStartDateAfterColor => HexColor("4ADE80"); // green-400
  static Color get exceptedStartDateBeforeColor => HexColor("FB7185"); // red-400

  static Color get exceptedEndDateAfterColor => HexColor("4ADE80");

  static Color get exceptedEndDateBeforeColor => HexColor("FB7185");

  /// ORDER STATUS
  static Color get orderStatusCompletedColor => HexColor("FB7185");
  static Color get orderStatusCanceledColor => HexColor("FB7185");
  static Color get orderStatusPreparingColor => HexColor("FB7185");
  static Color get orderStatusDefaultColor => HexColor("FB7185");

  static BoxDecoration popupDecoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      );
}
