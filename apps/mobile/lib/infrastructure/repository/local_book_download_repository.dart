import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../../domain/entity/book.dart';
import '../../domain/entity/remote_book.dart';
import '../../domain/repository/book_download_repository.dart';
import '../database/book_database.dart';

class LocalBookDownloadRepository implements BookDownloadRepository {
  const LocalBookDownloadRepository(this._dio);

  final Dio _dio;
  BookDatabase get _db => BookDatabase.instance;

  Future<Directory> _bookDir(String bookId) async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'ehon_books', bookId));
  }

  @override
  Future<bool> isDownloaded(String bookId) => _db.isDownloaded(bookId);

  @override
  Stream<double> downloadBook(RemoteBook book) async* {
    final dir = await _bookDir(book.id);
    await Directory(p.join(dir.path, 'images')).create(recursive: true);

    // 1. XML をダウンロード
    final xmlPath = p.join(dir.path, 'book.xml');
    await _dio.download(book.xmlUrl, xmlPath);

    // 2. XML をパースして画像ファイル名を取得
    final xmlString = await File(xmlPath).readAsString();
    final document = XmlDocument.parse(xmlString);
    final imageFilenames = document
        .findAllElements('image')
        .map((n) => n.innerText.trim())
        .toSet()
        .toList();

    final total = 1 + imageFilenames.length;
    var done = 0;

    // 3. カバー画像
    final coverPath = p.join(dir.path, 'cover.png');
    await _dio.download(book.coverImageUrl, coverPath);
    done++;
    yield done / total;

    // 4. 挿絵
    for (final filename in imageFilenames) {
      await _dio.download(
        '${book.imageBaseUrl}$filename',
        p.join(dir.path, 'images', filename),
      );
      done++;
      yield done / total;
    }

    // 5. SQLite に保存
    await _db.upsert(book, xmlPath: xmlPath, coverImagePath: coverPath);
  }

  @override
  Future<Book> getLocalBook(String bookId) async {
    final book = await _db.find(bookId);
    if (book == null) throw StateError('Book $bookId not found in database');
    return book;
  }

  @override
  Future<List<Book>> getAllLocalBooks() => _db.getAll();

  @override
  Future<void> deleteBook(String bookId) async {
    final dir = await _bookDir(bookId);
    if (dir.existsSync()) await dir.delete(recursive: true);
    await _db.delete(bookId);
  }
}
