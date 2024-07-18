import 'package:flutter/material.dart';
import 'package:tadbirio/utils/app_color.dart';

class AppThemeMode {
  static ThemeData night = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColor.nightGrey,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColor.nightGrey,
    ),
    
    dialogTheme: const DialogTheme(backgroundColor: AppColor.nightGrey),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      onSecondaryContainer: AppColor.titleColor2,
      onPrimaryContainer: AppColor.nightGrey,
      primaryContainer: AppColor.nightGrey,
      secondaryContainer: Color(0xff101210),
      primaryFixedDim: AppColor.bgUnTapColor,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xff727782),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      labelMedium: TextStyle(
        color: AppColor.whiteColor,
      ),
      titleLarge: TextStyle(
        color: AppColor.whiteColor,
      ),
      labelSmall: TextStyle(
        color: AppColor.titleColor,
      ),
      titleSmall: TextStyle(
        color: AppColor.whiteColor,
      ),
    ),
  );

  static ThemeData light = ThemeData(
    dialogTheme: const DialogTheme(backgroundColor: AppColor.whiteColor),
    dividerTheme: const DividerThemeData(
      color: AppColor.textFieldBackgroundColor,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColor.whiteColor,
    bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColor.whiteColor,
    ),
    fontFamily: "gilroy",
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      onSecondaryContainer: AppColor.whiteColor,
      primaryContainer: AppColor.whiteColor,
      secondaryContainer: AppColor.whiteColor,
      onPrimaryContainer: AppColor.bgUnTapColor,
      primaryFixedDim: AppColor.nightGrey.withOpacity(0.2),
    ),
    textTheme: TextTheme(
      labelMedium: const TextStyle(
        color: AppColor.titleColor2,
      ),
      titleLarge: const TextStyle(
        color: AppColor.splashScreenTitleFontColor,
      ),
      labelSmall: const TextStyle(
        color: AppColor.splashScreenTitleFontColor,
      ),
      titleSmall: TextStyle(
        color: AppColor.primaryColor.withOpacity(0.2),
      ),
    ),
  );
}
