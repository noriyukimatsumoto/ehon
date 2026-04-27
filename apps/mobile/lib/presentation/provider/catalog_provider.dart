import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entity/book.dart';
import '../../domain/entity/book_category.dart';
import '../../domain/entity/remote_book.dart';
import '../../domain/repository/book_download_repository.dart';
import '../../domain/repository/catalog_repository.dart';
import '../../infrastructure/repository/local_book_download_repository.dart';
import '../../infrastructure/repository/remote_catalog_repository.dart';

part 'catalog_provider.g.dart';

@riverpod
Dio dio(Ref ref) => Dio();

@riverpod
CatalogRepository catalogRepository(Ref ref) =>
    RemoteCatalogRepository(ref.watch(dioProvider));

@riverpod
BookDownloadRepository bookDownloadRepository(Ref ref) =>
    LocalBookDownloadRepository(ref.watch(dioProvider));

@riverpod
Future<List<RemoteBook>> catalogBooks(Ref ref) =>
    ref.watch(catalogRepositoryProvider).fetchCatalog();

@riverpod
Future<List<Book>> downloadedBooks(Ref ref) =>
    ref.watch(bookDownloadRepositoryProvider).getAllLocalBooks();

@riverpod
Future<List<BookCategory>> downloadedBookCategories(Ref ref) async {
  final books = await ref.watch(downloadedBooksProvider.future);
  if (books.isEmpty) return [];
  return [
    BookCategory(id: 'downloaded', name: 'downloaded', books: books),
  ];
}
