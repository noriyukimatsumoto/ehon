import '../entity/book.dart';
import '../entity/remote_book.dart';

abstract interface class BookDownloadRepository {
  Future<bool> isDownloaded(String bookId);
  Stream<double> downloadBook(RemoteBook book);
  Future<Book> getLocalBook(String bookId);
  Future<List<Book>> getAllLocalBooks();
  Future<void> deleteBook(String bookId);
}
