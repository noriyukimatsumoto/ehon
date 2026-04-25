import '../../domain/entity/book_page.dart';
import '../../domain/repository/ehon_repository.dart';

class LoadEhonUseCase {
  const LoadEhonUseCase(this._repository);

  final EhonRepository _repository;

  Future<List<BookPage>> execute(String xmlPath) =>
      _repository.fetchPages(xmlPath);
}
