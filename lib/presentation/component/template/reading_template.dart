import 'package:flutter/material.dart';

import '../../../domain/entity/book_page.dart';
import '../molecule/page_indicator.dart';
import '../organism/illustration_section.dart';
import '../organism/story_section.dart';

class ReadingTemplate extends StatelessWidget {
  const ReadingTemplate({
    super.key,
    required this.page,
    required this.currentIndex,
    required this.totalPages,
    required this.remaining,
  });

  final BookPage page;
  final int currentIndex;
  final int totalPages;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: IllustrationSection(
              imagePath: 'assets/images/${page.image}',
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StorySection(text: page.text),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: PageIndicator(
                    currentIndex: currentIndex,
                    totalPages: totalPages,
                    remaining: remaining,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
