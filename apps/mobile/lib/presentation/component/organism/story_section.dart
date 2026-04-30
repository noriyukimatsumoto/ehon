import 'package:flutter/material.dart';

import '../atom/story_text.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textColor =
        DefaultTextStyle.of(context).style.color ?? Colors.black;
    final bgColor = Color.from(
      alpha: 0.7,
      red: 1.0 - textColor.r,
      green: 1.0 - textColor.g,
      blue: 1.0 - textColor.b,
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: StoryText(key: ValueKey(text), text: text),
      ),
    );
  }
}
