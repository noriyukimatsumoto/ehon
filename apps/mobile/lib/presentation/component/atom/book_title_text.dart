import 'package:flutter/material.dart';

class BookTitleText extends StatelessWidget {
  const BookTitleText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
