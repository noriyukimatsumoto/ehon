import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
    await dir.create(recursive: true);

    final zipPath = p.join(dir.path, '${book.id}.zip');

    // 1. zip をダウンロード（進捗 0.0〜0.9）
    final progressController = StreamController<double>();
    final downloadFuture = _dio
        .download(
          book.zipUrl,
          zipPath,
          onReceiveProgress: (received, total) {
            if (total > 0 && !progressController.isClosed) {
              progressController.add(received / total * 0.9);
            }
          },
        )
        .whenComplete(progressController.close);

    yield* progressController.stream;
    await downloadFuture;
    yield 0.9;

    // 2. 展開
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final entry in archive) {
      final entryPath = p.join(dir.path, entry.name);
      if (entry.isFile) {
        await File(entryPath).create(recursive: true);
        await File(entryPath).writeAsBytes(entry.content as List<int>);
      } else {
        await Directory(entryPath).create(recursive: true);
      }
    }
    await File(zipPath).delete();
    yield 0.95;

    // 3. SQLite に保存
    final jsonPath = p.join(dir.path, 'book.json');
    final coverPath = p.join(dir.path, 'cover.jpg');
    await _db.upsert(book, jsonPath: jsonPath, coverImagePath: coverPath);
    yield 1.0;
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
