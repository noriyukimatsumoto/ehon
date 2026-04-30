import 'package:flutter/material.dart';

import '../../theme/app_text_theme.dart';

class BookTitleText extends StatelessWidget {
  const BookTitleText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final fontSize = AppTextTheme.of(context).bookTitle(context);

    return Text(
      title,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
