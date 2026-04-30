import 'package:flutter/material.dart';

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme();

  static AppTextTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTextTheme>() ?? const AppTextTheme();

  double story(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.03).clamp(16.0, 32.0);

  double bookTitle(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.02).clamp(11.0, 18.0);

  double quizQuestion(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.03).clamp(16.0, 32.0);

  double quizChoice(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.028).clamp(14.0, 28.0);

  @override
  AppTextTheme copyWith() => const AppTextTheme();

  @override
  AppTextTheme lerp(AppTextTheme? other, double t) => const AppTextTheme();
}
