import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../provider/book_selection_provider.dart';
import '../template/book_selection_template.dart';

class BookSelectionPage extends ConsumerWidget {
  const BookSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(bookCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('エラー: $e')),
      ),
      data: (categories) => BookSelectionTemplate(
        categories: categories,
        onBookTap: (book) => context.push('/read', extra: book.xmlPath),
      ),
    );
  }
}
