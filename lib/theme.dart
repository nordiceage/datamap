import 'package:flutter/material.dart';

/// `AppTheme` class defines the consistent visual style of the application.
class AppTheme {
  // Color Definitions
  /// `primaryColor` is the main color used across the application.
  static const Color primaryColor = Color(0xFF2B9348);
  /// `secondaryColor` is used for accents and secondary elements.
  static const Color secondaryColor = Color(0xFF000000);
  /// `textColorPrimary` is the default text color for primary content.
  static const Color textColorPrimary = Color(0xFF000000);
  /// `textColorSecondary` is used for secondary or less emphasized text.
  static const Color textColorSecondary = Color(0xFF757575);
  /// `bodyText2Green` is a specific text style for green body text.
  static const TextStyle bodyText2Green = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: Color(0xFF2B9348),
  );
  // Font Family Definitions
  /// `headerFontFamily` is the font family used for headlines and titles.
  static const String headerFontFamily = 'Poppins';
  /// `bodyFontFamily` is the font family used for body text.
  static const String bodyFontFamily = 'OpenSans';

  // Text Style Definitions
  /// `headline1` is the largest headline style.
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

  /// `bodyText1` is a bold style for body text.
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: textColorPrimary,
  );

  /// `bodyText2` is a semi-bold style for body text.
  static const TextStyle bodyText2 = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: textColorPrimary,
  );
  static const TextStyle bodyText2white = TextStyle(
  /// `bodyText2white` is a semi-bold style for body text in white color.

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

  // Padding and Margin Definitions
  /// `defaultPadding_sides` is the default horizontal padding.
  static const EdgeInsets defaultPadding_sides = EdgeInsets.symmetric(horizontal: 20.0);
  /// `defaultPadding_body_containers` is the default vertical padding.
  static const EdgeInsets defaultPadding_body_containers = EdgeInsets.symmetric(vertical: 28.0);
  /// `defaultMargin` is the default margin applied to elements.
  static const EdgeInsets defaultMargin = EdgeInsets.all(16.0);

  // Theme Data
  static ThemeData get themeData {
    /// `themeData` generates the complete ThemeData for the application.
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
