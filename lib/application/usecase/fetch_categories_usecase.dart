import '../../domain/entity/book_category.dart';
import '../../domain/repository/book_repository.dart';

class FetchCategoriesUseCase {
  const FetchCategoriesUseCase(this._repository);

  final BookRepository _repository;

  Future<List<BookCategory>> execute() => _repository.fetchCategories();
}
