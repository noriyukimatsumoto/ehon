import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../domain/entity/remote_book.dart';
import '../../domain/repository/catalog_repository.dart';

class RemoteCatalogRepository implements CatalogRepository {
  const RemoteCatalogRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<RemoteBook>> fetchCatalog() async {
    final response = await _dio.get<Map<String, dynamic>>(kCatalogEndpoint);
    final data = response.data!;
    final books = data['books'] as List<dynamic>? ?? [];
    return books.map(_parseBook).toList();
  }

  RemoteBook _parseBook(dynamic json) {
    final map = json as Map<String, dynamic>;
    return RemoteBook(
      id: map['id'] as String,
      version: map['version'] as String? ?? '1.0.0',
      title: Map<String, String>.from(map['title'] as Map),
      categoryId: map['categoryId'] as String,
      categoryName: Map<String, String>.from(map['categoryName'] as Map),
      zipUrl: map['zipUrl'] as String,
      coverImageUrl: map['coverImageUrl'] as String,
    );
  }
}
