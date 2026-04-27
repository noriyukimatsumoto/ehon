import '../entity/remote_book.dart';

abstract interface class CatalogRepository {
  Future<List<RemoteBook>> fetchCatalog();
}
