import 'package:flutter/material.dart';

import '../../theme/app_text_theme.dart';

class StoryText extends StatelessWidget {
  const StoryText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final fontSize = AppTextTheme.of(context).story(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.9,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}
