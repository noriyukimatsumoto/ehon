import '../entity/book_category.dart';

abstract interface class BookRepository {
  Future<List<BookCategory>> fetchCategories();
}
