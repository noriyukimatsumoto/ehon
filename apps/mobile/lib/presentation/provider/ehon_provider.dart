import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/usecase/load_ehon_usecase.dart';
import '../../domain/repository/ehon_repository.dart';
import '../../infrastructure/repository/xml_ehon_repository.dart';

part 'ehon_provider.g.dart';

@riverpod
EhonRepository ehonRepository(Ref ref) => const XmlEhonRepository();

@riverpod
LoadEhonUseCase loadEhonUseCase(Ref ref) =>
    LoadEhonUseCase(ref.watch(ehonRepositoryProvider));
