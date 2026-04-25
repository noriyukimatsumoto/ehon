import 'package:flutter/material.dart';

import '../../../domain/entity/book.dart';
import '../../../domain/entity/book_category.dart';
import '../organism/category_row.dart';

class BookSelectionTemplate extends StatelessWidget {
  const BookSelectionTemplate({
    super.key,
    required this.categories,
    required this.onBookTap,
  });

  final List<BookCategory> categories;
  final void Function(Book book) onBookTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'えほんを えらぼう',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ),
            const Divider(indent: 24, endIndent: 24),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) => CategoryRow(
                  category: categories[index],
                  onBookTap: onBookTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
