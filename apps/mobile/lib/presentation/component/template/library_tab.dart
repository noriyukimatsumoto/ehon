import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entity/book.dart';
import '../../../l10n/app_localizations.dart';
import '../../provider/catalog_provider.dart';
import '../../provider/download_notifier.dart';
import '../atom/book_title_text.dart';

class LibraryTab extends ConsumerWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final booksAsync = ref.watch(downloadedBooksProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: Colors.amber[50],
          elevation: 0,
          title: Text(
            l10n.library,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
        ),
        booksAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text(l10n.error(e))),
          ),
          data: (books) {
            if (books.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book, size: 64, color: Colors.brown[200]),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noDownloadedBooks,
                        style:
                            TextStyle(color: Colors.brown[400], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.83,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _LibraryBookCard(book: books[index]),
                  childCount: books.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LibraryBookCard extends ConsumerWidget {
  const _LibraryBookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final notifier = ref.read(downloadNotifierProvider(book.id).notifier);

    return GestureDetector(
      onTap: () => context.push('/read', extra: book.jsonPath),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(book.coverImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.brown[100],
                      child: const Icon(
                        Icons.book,
                        size: 32,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => notifier.delete(book.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          BookTitleText(title: book.localizedTitle(languageCode)),
        ],
      ),
    );
  }
}
