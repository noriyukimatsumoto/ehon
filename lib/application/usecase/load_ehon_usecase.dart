import '../../domain/entity/ehon_data.dart';
import '../../domain/repository/ehon_repository.dart';

class LoadEhonUseCase {
  const LoadEhonUseCase(this._repository);

  final EhonRepository _repository;

  Future<EhonData> execute(String xmlPath, String languageCode) =>
      _repository.fetchEhon(xmlPath, languageCode);
}
