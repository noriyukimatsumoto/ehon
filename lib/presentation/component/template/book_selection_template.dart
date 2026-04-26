import 'package:flutter/material.dart';

import '../../../domain/entity/book.dart';
import '../../../domain/entity/book_category.dart';
import '../../../l10n/app_localizations.dart';
import '../organism/category_row.dart';

class BookSelectionTemplate extends StatelessWidget {
  const BookSelectionTemplate({
    super.key,
    required this.categories,
    required this.onBookTap,
    required this.onSettingsTap,
  });

  final List<BookCategory> categories;
  final void Function(Book book) onBookTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.bookSelectionTitle,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSettingsTap,
                    icon: const Icon(Icons.settings),
                    color: Colors.brown[600],
                  ),
                ],
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
