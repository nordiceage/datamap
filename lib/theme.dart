import 'package:flutter/material.dart';

class AppTheme {
  // Defined primary and secondary colors
  static const Color primaryColor = Color(0xFF2B9348);
  static const Color secondaryColor = Color(0xFF000000);
  static const Color textColorPrimary = Color(0xFF000000);
  static const Color textColorSecondary = Color(0xFF757575);

  static const TextStyle bodyText2Green = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: Color(0xFF2B9348),
  );
  // Defined font families
  static const String headerFontFamily = 'Poppins';
  static const String bodyFontFamily = 'OpenSans';

  // Defined text styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: headerFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 32.0,
    color: textColorPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: headerFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: textColorPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: headerFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
    color: textColorPrimary,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: headerFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: textColorPrimary,
  );

  static const TextStyle headline5 = TextStyle(
    fontFamily: headerFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: textColorPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: textColorPrimary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: textColorPrimary,
  );
  static const TextStyle bodyText2white = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: Colors.white,
  );

  static const TextStyle bodyText1Secondary = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: textColorSecondary,
  );

  static const TextStyle bodyText2Secondary = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: textColorSecondary,
  );

  // Defined default padding and margins
  static const EdgeInsets defaultPadding_sides = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets defaultPadding_body_containers = EdgeInsets.symmetric(vertical: 28.0);
  static const EdgeInsets defaultMargin = EdgeInsets.all(16.0);

  // Defined theme data
  static ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: const Color(0xFFEEF1EF),
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        displaySmall: headline3,
        headlineMedium: headline4,
        headlineSmall: headline5,
        bodyLarge: bodyText1,
        bodyMedium: bodyText2,
        bodySmall: bodyText2white,
        titleMedium: bodyText1Secondary,
        titleSmall: bodyText2Secondary,
      ),
    );
  }
}
