// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookRepositoryHash() => r'0cf226588cb351000245b26b035e4295782717a1';

/// See also [bookRepository].
@ProviderFor(bookRepository)
final bookRepositoryProvider = AutoDisposeProvider<BookRepository>.internal(
  bookRepository,
  name: r'bookRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookRepositoryRef = AutoDisposeProviderRef<BookRepository>;
String _$fetchCategoriesUseCaseHash() =>
    r'7e7aa3b0f30cb676573ddebafefb61c127800713';

/// See also [fetchCategoriesUseCase].
@ProviderFor(fetchCategoriesUseCase)
final fetchCategoriesUseCaseProvider =
    AutoDisposeProvider<FetchCategoriesUseCase>.internal(
      fetchCategoriesUseCase,
      name: r'fetchCategoriesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fetchCategoriesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchCategoriesUseCaseRef =
    AutoDisposeProviderRef<FetchCategoriesUseCase>;
String _$bookCategoriesHash() => r'0e138815c628830580c4ab3f8289fb54e3f80de3';

/// See also [bookCategories].
@ProviderFor(bookCategories)
final bookCategoriesProvider =
    AutoDisposeFutureProvider<List<BookCategory>>.internal(
      bookCategories,
      name: r'bookCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookCategoriesRef = AutoDisposeFutureProviderRef<List<BookCategory>>;
String _$combinedCategoriesHash() =>
    r'2b3accb51873cea1f2460a834225a2cef02856b8';

/// アセット本 + ダウンロード済み本を結合したカテゴリ一覧
///
/// Copied from [combinedCategories].
@ProviderFor(combinedCategories)
final combinedCategoriesProvider =
    AutoDisposeFutureProvider<List<BookCategory>>.internal(
      combinedCategories,
      name: r'combinedCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$combinedCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CombinedCategoriesRef =
    AutoDisposeFutureProviderRef<List<BookCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
