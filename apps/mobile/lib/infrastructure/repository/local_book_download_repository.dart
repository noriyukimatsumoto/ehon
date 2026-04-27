import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../../domain/entity/book.dart';
import '../../domain/entity/remote_book.dart';
import '../../domain/repository/book_download_repository.dart';

class LocalBookDownloadRepository implements BookDownloadRepository {
  const LocalBookDownloadRepository(this._dio);

  final Dio _dio;

  Future<Directory> _bookDir(String bookId) async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'ehon_books', bookId));
  }

  @override
  Future<bool> isDownloaded(String bookId) async {
    final dir = await _bookDir(bookId);
    return Future.value(File(p.join(dir.path, 'book.xml')).existsSync());
  }

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

    // 全ダウンロード数: cover + imageFilenames
    final total = 1 + imageFilenames.length;
    var done = 0;

    // 3. カバー画像
    await _dio.download(
      book.coverImageUrl,
      p.join(dir.path, 'cover.png'),
    );
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

    // 5. メタデータ保存
    await File(p.join(dir.path, 'meta.json')).writeAsString(
      jsonEncode({
        'id': book.id,
        'version': book.version,
        'title': book.title,
        'categoryId': book.categoryId,
        'categoryName': book.categoryName,
      }),
    );
  }

  @override
  Future<Book> getLocalBook(String bookId) async {
    final dir = await _bookDir(bookId);
    final meta = jsonDecode(
      await File(p.join(dir.path, 'meta.json')).readAsString(),
    ) as Map<String, dynamic>;

    return Book(
      id: bookId,
      title: (meta['title'] as Map<String, dynamic>)['ja'] as String? ?? bookId,
      xmlPath: p.join(dir.path, 'book.xml'),
      coverImagePath: p.join(dir.path, 'cover.png'),
    );
  }

  @override
  Future<List<Book>> getAllLocalBooks() async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(docs.path, 'ehon_books'));
    if (!root.existsSync()) return [];

    final books = <Book>[];
    for (final entry in root.listSync().whereType<Directory>()) {
      final metaFile = File(p.join(entry.path, 'meta.json'));
      final xmlFile = File(p.join(entry.path, 'book.xml'));
      if (!metaFile.existsSync() || !xmlFile.existsSync()) continue;

      final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
      books.add(Book(
        id: p.basename(entry.path),
        title: (meta['title'] as Map<String, dynamic>)['ja'] as String? ?? '',
        xmlPath: xmlFile.path,
        coverImagePath: p.join(entry.path, 'cover.png'),
      ));
    }
    return books;
  }

  @override
  Future<void> deleteBook(String bookId) async {
    final dir = await _bookDir(bookId);
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}
