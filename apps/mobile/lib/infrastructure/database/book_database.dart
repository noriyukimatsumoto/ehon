import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entity/book.dart';
import '../../domain/entity/remote_book.dart';

class BookDatabase {
  BookDatabase._();
  static final BookDatabase instance = BookDatabase._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = p.join(docs.path, 'ehon_books.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE books (
          id TEXT PRIMARY KEY,
          version TEXT NOT NULL,
          title_ja TEXT NOT NULL,
          title_en TEXT NOT NULL,
          category_id TEXT NOT NULL,
          category_name_ja TEXT NOT NULL,
          category_name_en TEXT NOT NULL,
          json_path TEXT NOT NULL,
          cover_image_path TEXT NOT NULL,
          downloaded_at INTEGER NOT NULL
        )
      '''),
    );
  }

  Future<void> upsert(
    RemoteBook remote, {
    required String jsonPath,
    required String coverImagePath,
  }) async {
    final db = await _database;
    await db.insert('books', {
      'id': remote.id,
      'version': remote.version,
      'title_ja': remote.title['ja'] ?? '',
      'title_en': remote.title['en'] ?? '',
      'category_id': remote.categoryId,
      'category_name_ja': remote.categoryName['ja'] ?? '',
      'category_name_en': remote.categoryName['en'] ?? '',
      'json_path': jsonPath,
      'cover_image_path': coverImagePath,
      'downloaded_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isDownloaded(String bookId) async {
    final db = await _database;
    final rows = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Book?> find(String bookId) async {
    final db = await _database;
    final rows = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<List<Book>> getAll() async {
    final db = await _database;
    final rows = await db.query('books', orderBy: 'downloaded_at DESC');
    return rows.map(_fromRow).toList();
  }

  Future<void> delete(String bookId) async {
    final db = await _database;
    await db.delete('books', where: 'id = ?', whereArgs: [bookId]);
  }

  Future<void> removeStaleRecords() async {
    final db = await _database;
    final rows = await db.query('books', columns: ['id', 'json_path']);
    for (final row in rows) {
      final jsonPath = row['json_path']! as String;
      if (!File(jsonPath).existsSync()) {
        await db.delete('books', where: 'id = ?', whereArgs: [row['id']]);
      }
    }
  }

  Book _fromRow(Map<String, Object?> row) => Book(
    id: row['id']! as String,
    version: row['version']! as String,
    titles: {
      'ja': row['title_ja']! as String,
      'en': row['title_en']! as String,
    },
    jsonPath: row['json_path']! as String,
    coverImagePath: row['cover_image_path']! as String,
  );
}
