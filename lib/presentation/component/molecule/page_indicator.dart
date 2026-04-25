import 'package:flutter/material.dart';

import '../atom/countdown_text.dart';
import '../atom/page_counter_text.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    required this.remaining,
  });

  final int currentIndex;
  final int totalPages;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PageCounterText(current: currentIndex + 1, total: totalPages),
        const SizedBox(width: 16),
        CountdownText(remaining: remaining),
      ],
    );
  }
}
