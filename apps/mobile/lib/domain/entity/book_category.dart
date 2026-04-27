import 'book.dart';

class BookCategory {
  const BookCategory({
    required this.id,
    required this.name,
    required this.books,
  });

  final String id;
  final String name;
  final List<Book> books;
}
