import '../entity/book_page.dart';

abstract interface class EhonRepository {
  Future<List<BookPage>> fetchPages(String xmlPath);
}
