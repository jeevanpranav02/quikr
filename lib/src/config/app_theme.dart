import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    primaryColor: AppColors.primaryColor,
    useMaterial3: true,
    fontFamily: AppText.fontName,
    cardColor: AppColors.transparent,
    focusColor: AppColors.primaryAccentColorLight,
    highlightColor: AppColors.transparent,
    splashColor: AppColors.transparent,
    dividerColor: AppColors.dividerColor,
    scaffoldBackgroundColor: AppColors.white,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColorDark),
    primaryColor: AppColors.primaryColorDark,
    useMaterial3: true,
    fontFamily: AppText.fontName,
    cardColor: AppColors.transparent,
    focusColor: AppColors.primaryAccentColorDark,
    highlightColor: AppColors.transparent,
    splashColor: AppColors.transparent,
    dividerColor: AppColors.dividerColor,
    scaffoldBackgroundColor: AppColors.white,
  );
}
