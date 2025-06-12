// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const String primaryColorString = "#4263EB";
  static const String secondaryColorString = "#F5F7FE";
  static const String disabledColorString = "#D5D7D8";
  
  // Theme state
  static bool isLightTheme = true;

  // Font sizes
  static const double fontSizeSmall = 10.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 34.0;
  static const double fontSizeDisplaySmall = 48.0;
  static const double fontSizeDisplayMedium = 60.0;
  static const double fontSizeDisplayLarge = 96.0;

  static ThemeData getTheme() {
    return isLightTheme ? lightTheme() : darkTheme();
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      titleLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.titleLarge!.color,
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.w500,
        ),
      ),
      titleMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.titleMedium!.color,
          fontSize: fontSizeLarge,
        ),
      ),
      titleSmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.titleSmall!.color,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w500,
        ),
      ),
      bodyMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodyMedium!.color,
          fontSize: fontSizeLarge,
        ),
      ),
      bodyLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodyLarge!.color,
          fontSize: fontSizeMedium,
        ),
      ),
      labelLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.labelLarge!.color,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
      bodySmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.bodySmall!.color,
          fontSize: fontSizeSmall,
        ),
      ),
      headlineMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headlineMedium!.color,
          fontSize: fontSizeXXXLarge,
        ),
      ),
      displaySmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.displaySmall!.color,
          fontSize: fontSizeDisplaySmall,
        ),
      ),
      displayMedium: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.displayMedium!.color,
          fontSize: fontSizeDisplayMedium,
        ),
      ),
      displayLarge: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.displayLarge!.color,
          fontSize: fontSizeDisplayLarge,
        ),
      ),
      headlineSmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.headlineSmall!.color,
          fontSize: fontSizeXXLarge,
        ),
      ),
      labelSmall: GoogleFonts.ubuntu(
        textStyle: TextStyle(
          color: base.labelSmall!.color,
          fontSize: fontSizeSmall,
        ),
      ),
    );
  }

  static ThemeData lightTheme() {
    final Color primaryColor = HexColor(primaryColorString);
    final Color secondaryColor = HexColor(secondaryColorString);
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );

    final ThemeData base = ThemeData.light();
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        elevation: 0,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
      ),
      primaryColor: primaryColor,
      splashColor: Colors.white.withOpacity(0.1),
      hoverColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.textTheme),
      platform: TargetPlatform.iOS,
      indicatorColor: primaryColor,
      disabledColor: HexColor(disabledColorString),
      colorScheme: colorScheme.copyWith(
        error: Colors.red,
        background: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    final Color primaryColor = HexColor(primaryColorString);
    final Color secondaryColor = HexColor(secondaryColorString);
    final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );

    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        elevation: 0,
      ),
      primaryColor: primaryColor,
      indicatorColor: Colors.white,
      splashColor: Colors.white24,
      splashFactory: InkRipple.splashFactory,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: Colors.grey[850],
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      platform: TargetPlatform.iOS,
      colorScheme: colorScheme.copyWith(
        background: Colors.grey[850],
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
