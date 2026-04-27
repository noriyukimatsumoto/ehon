import '../entity/ehon_data.dart';

abstract interface class EhonRepository {
  Future<EhonData> fetchEhon(String xmlPath, String languageCode);
}
