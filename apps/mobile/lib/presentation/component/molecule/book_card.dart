import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/entity/book.dart';
import '../atom/book_title_text.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _coverImage(book.coverImagePath),
              ),
            ),
            const SizedBox(height: 6),
            BookTitleText(title: book.localizedTitle(languageCode)),
          ],
        ),
      ),
    );
  }

  Widget _coverImage(String path) {
    if (path.startsWith('/')) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return Image.asset(path, fit: BoxFit.cover);
  }
}
