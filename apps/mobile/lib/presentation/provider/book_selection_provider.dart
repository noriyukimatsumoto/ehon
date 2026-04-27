import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/usecase/fetch_categories_usecase.dart';
import '../../domain/entity/book_category.dart';
import '../../domain/repository/book_repository.dart';
import '../../infrastructure/repository/static_book_repository.dart';
import 'catalog_provider.dart';

part 'book_selection_provider.g.dart';

@riverpod
BookRepository bookRepository(Ref ref) => const StaticBookRepository();

@riverpod
FetchCategoriesUseCase fetchCategoriesUseCase(Ref ref) =>
    FetchCategoriesUseCase(ref.watch(bookRepositoryProvider));

@riverpod
Future<List<BookCategory>> bookCategories(Ref ref) =>
    ref.watch(fetchCategoriesUseCaseProvider).execute();

/// アセット本 + ダウンロード済み本を結合したカテゴリ一覧
@riverpod
Future<List<BookCategory>> combinedCategories(Ref ref) async {
  final asset = await ref.watch(bookCategoriesProvider.future);
  final downloaded = await ref.watch(downloadedBookCategoriesProvider.future);
  return [...asset, ...downloaded];
}
