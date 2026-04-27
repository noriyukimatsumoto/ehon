// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'088d5c03610503c2407a8d7429b0e9f3ee76406f';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$catalogRepositoryHash() => r'6b21629c26d6b9a8cea1644f10f7165195ce5334';

/// See also [catalogRepository].
@ProviderFor(catalogRepository)
final catalogRepositoryProvider =
    AutoDisposeProvider<CatalogRepository>.internal(
      catalogRepository,
      name: r'catalogRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$catalogRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CatalogRepositoryRef = AutoDisposeProviderRef<CatalogRepository>;
String _$bookDownloadRepositoryHash() =>
    r'ce072a6304b01d65258c214999755f0a4f0e16c8';

/// See also [bookDownloadRepository].
@ProviderFor(bookDownloadRepository)
final bookDownloadRepositoryProvider =
    AutoDisposeProvider<BookDownloadRepository>.internal(
      bookDownloadRepository,
      name: r'bookDownloadRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookDownloadRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookDownloadRepositoryRef =
    AutoDisposeProviderRef<BookDownloadRepository>;
String _$catalogBooksHash() => r'7b5f7bf7357fd13eafb010beb73dd2d9cf08a9d6';

/// See also [catalogBooks].
@ProviderFor(catalogBooks)
final catalogBooksProvider =
    AutoDisposeFutureProvider<List<RemoteBook>>.internal(
      catalogBooks,
      name: r'catalogBooksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$catalogBooksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CatalogBooksRef = AutoDisposeFutureProviderRef<List<RemoteBook>>;
String _$downloadedBooksHash() => r'bc33c80a5b95e1b24a28488240e9cea79b33f213';

/// See also [downloadedBooks].
@ProviderFor(downloadedBooks)
final downloadedBooksProvider = AutoDisposeFutureProvider<List<Book>>.internal(
  downloadedBooks,
  name: r'downloadedBooksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadedBooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadedBooksRef = AutoDisposeFutureProviderRef<List<Book>>;
String _$downloadedBookCategoriesHash() =>
    r'3577e15e279f6abf97d87a78507834b93abeef3d';

/// See also [downloadedBookCategories].
@ProviderFor(downloadedBookCategories)
final downloadedBookCategoriesProvider =
    AutoDisposeFutureProvider<List<BookCategory>>.internal(
      downloadedBookCategories,
      name: r'downloadedBookCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$downloadedBookCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadedBookCategoriesRef =
    AutoDisposeFutureProviderRef<List<BookCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
