import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entity/book_page.dart';
import '../molecule/page_indicator.dart';
import '../organism/illustration_section.dart';
import '../organism/story_section.dart';

class ReadingTemplate extends StatefulWidget {
  const ReadingTemplate({
    super.key,
    required this.page,
    required this.text,
    required this.currentIndex,
    required this.totalPages,
    required this.remaining,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onBack,
  });

  final BookPage page;
  final String text;
  final int currentIndex;
  final int totalPages;
  final int remaining;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onBack;

  @override
  State<ReadingTemplate> createState() => _ReadingTemplateState();
}

class _ReadingTemplateState extends State<ReadingTemplate> {
  bool _textVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleTextAppear();
  }

  @override
  void didUpdateWidget(ReadingTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _timer?.cancel();
      setState(() => _textVisible = false);
      _scheduleTextAppear();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleTextAppear() {
    _timer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _textVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final dx = details.primaryVelocity ?? 0;
          if (dx < -200) {
            widget.onSwipeLeft?.call();
          } else if (dx > 200) {
            widget.onSwipeRight?.call();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: IllustrationSection(
                imagePath: widget.page.imagePath,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.home, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black38,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: AnimatedOpacity(
                  opacity: _textVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StorySection(text: widget.text),
                        const SizedBox(height: 4),
                        PageIndicator(
                          currentIndex: widget.currentIndex,
                          totalPages: widget.totalPages,
                          remaining: widget.remaining,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
