import 'package:flutter/material.dart';

import '../../../domain/entity/book.dart';
import '../../../domain/entity/book_category.dart';
import '../atom/category_title_text.dart';
import '../molecule/book_card.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.category,
    required this.onBookTap,
  });

  final BookCategory category;
  final void Function(Book book) onBookTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CategoryTitleText(name: category.name),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: category.books.length,
              itemBuilder: (context, index) => BookCard(
                book: category.books[index],
                onTap: () => onBookTap(category.books[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
