import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planner_messenger/utils/hex_color.dart';

class AppTheme {
  static String primaryColorString = "#0062FF";
  static String secondaryColorString = "#F5F7FE";
  static bool isLightTheme = true;

  static ThemeData getTheme() {
    if (isLightTheme) {
      return lightTheme();
    } else {
      return lightTheme();
    }
  }

  static TextTheme _buildTextTheme(Color color, Color labelColor) {
    const titleWeight = FontWeight.w600;
    const smallSize = 14.0;
    const mediumSize = 16.0;
    const largeSize = 30.0;
    return TextTheme(
      bodySmall: GoogleFonts.urbanist(
        color: color,
        fontSize: smallSize,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.urbanist(
        color: color,
        fontSize: mediumSize,
        fontWeight: FontWeight.normal,
      ),
      bodyLarge: GoogleFonts.urbanist(
        color: color,
        fontSize: largeSize,
        fontWeight: FontWeight.normal,
      ),
      titleSmall: GoogleFonts.urbanist(
        color: color,
        fontSize: smallSize,
        fontWeight: titleWeight,
      ),
      titleMedium: GoogleFonts.urbanist(
        color: color,
        fontSize: mediumSize,
        fontWeight: titleWeight,
      ),
      titleLarge: GoogleFonts.urbanist(
        color: color,
        fontSize: largeSize,
        fontWeight: titleWeight,
      ),
      labelSmall: GoogleFonts.urbanist(
        color: labelColor,
        fontSize: smallSize,
        fontWeight: FontWeight.w400,
      ),
      labelMedium: GoogleFonts.urbanist(
        color: labelColor,
        fontSize: mediumSize,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.urbanist(
        color: labelColor,
        fontSize: largeSize,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static ThemeData lightTheme() {
    var primaryColor = Colors.teal;
    var appBarTextColor = Colors.white;
    var appBarIconColor = Colors.white;
    var textColor = Colors.black;
    var scaffoldColor = Colors.white;
    var disableColor = HexColor("#7E8CA0");
    return ThemeData(
      // primaryColor: Colors.teal,
      scaffoldBackgroundColor: scaffoldColor,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: appBarIconColor,
        ),
      ),
      textTheme: _buildTextTheme(textColor, disableColor),

      tabBarTheme: TabBarTheme(
        labelColor: appBarTextColor,
        unselectedLabelColor: appBarTextColor.withOpacity(0.8),
        labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelStyle: GoogleFonts.urbanist().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: GoogleFonts.urbanist().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      disabledColor: disableColor,
      primaryColor: primaryColor,
      cardTheme: const CardTheme(),
      iconTheme: IconThemeData(
        color: appBarTextColor,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.red,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.black,
      ),
      // disabledColor: const Color(0xff7E8CA0),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme() {
    var primaryColor = Colors.grey.shade700;
    var appBarTextColor = Colors.white;
    var appBarIconColor = Colors.white;
    var textColor = Colors.white;
    var scaffoldColor = Colors.grey.shade600;
    var disableColor = const Color(0xff7E8CA0);
    return ThemeData(
      // primaryColor: Colors.teal,
      scaffoldBackgroundColor: scaffoldColor,

      //brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: appBarIconColor,
        ),
      ),
      textTheme: _buildTextTheme(textColor, disableColor),
      iconTheme: IconThemeData(
        color: appBarTextColor,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: appBarTextColor,
        unselectedLabelColor: appBarTextColor.withOpacity(0.8),
        labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelStyle: GoogleFonts.urbanist().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: GoogleFonts.urbanist().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      disabledColor: disableColor,
      useMaterial3: true,
    );
  }

  static ThemeData expansionTileTheme(BuildContext context) {
    return ThemeData(
      dividerColor: Colors.transparent,
      primaryColor: Theme.of(context).disabledColor,
      primarySwatch: AppTheme.isLightTheme == true
          ? const MaterialColor(
              0xff7E8CA0,
              <int, Color>{
                50: Color(0xff7E8CA0),
                100: Color(0xff7E8CA0),
                200: Color(0xff7E8CA0),
                300: Color(0xff7E8CA0),
                400: Color(0xff7E8CA0),
                500: Color(0xff7E8CA0),
                600: Color(0xff7E8CA0),
                700: Color(0xff7E8CA0),
                800: Color(0xff7E8CA0),
                900: Color(0xff7E8CA0),
              },
            )
          : const MaterialColor(
              0xff808D9E,
              <int, Color>{
                50: Color(0xff808D9E),
                100: Color(0xff808D9E),
                200: Color(0xff808D9E),
                300: Color(0xff808D9E),
                400: Color(0xff808D9E),
                500: Color(0xff808D9E),
                600: Color(0xff808D9E),
                700: Color(0xff808D9E),
                800: Color(0xff808D9E),
                900: Color(0xff808D9E),
              },
            ),
    );
  }
}
