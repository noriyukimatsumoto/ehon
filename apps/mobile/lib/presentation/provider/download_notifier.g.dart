// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$downloadNotifierHash() => r'f9312c8b901519b2311fca7db36eff3730875b50';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DownloadNotifier
    extends BuildlessAutoDisposeAsyncNotifier<DownloadState> {
  late final String bookId;

  FutureOr<DownloadState> build(String bookId);
}

/// See also [DownloadNotifier].
@ProviderFor(DownloadNotifier)
const downloadNotifierProvider = DownloadNotifierFamily();

/// See also [DownloadNotifier].
class DownloadNotifierFamily extends Family<AsyncValue<DownloadState>> {
  /// See also [DownloadNotifier].
  const DownloadNotifierFamily();

  /// See also [DownloadNotifier].
  DownloadNotifierProvider call(String bookId) {
    return DownloadNotifierProvider(bookId);
  }

  @override
  DownloadNotifierProvider getProviderOverride(
    covariant DownloadNotifierProvider provider,
  ) {
    return call(provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'downloadNotifierProvider';
}

/// See also [DownloadNotifier].
class DownloadNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<DownloadNotifier, DownloadState> {
  /// See also [DownloadNotifier].
  DownloadNotifierProvider(String bookId)
    : this._internal(
        () => DownloadNotifier()..bookId = bookId,
        from: downloadNotifierProvider,
        name: r'downloadNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$downloadNotifierHash,
        dependencies: DownloadNotifierFamily._dependencies,
        allTransitiveDependencies:
            DownloadNotifierFamily._allTransitiveDependencies,
        bookId: bookId,
      );

  DownloadNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookId,
  }) : super.internal();

  final String bookId;

  @override
  FutureOr<DownloadState> runNotifierBuild(
    covariant DownloadNotifier notifier,
  ) {
    return notifier.build(bookId);
  }

  @override
  Override overrideWith(DownloadNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DownloadNotifierProvider._internal(
        () => create()..bookId = bookId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookId: bookId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DownloadNotifier, DownloadState>
  createElement() {
    return _DownloadNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadNotifierProvider && other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DownloadNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<DownloadState> {
  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _DownloadNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<DownloadNotifier, DownloadState>
    with DownloadNotifierRef {
  _DownloadNotifierProviderElement(super.provider);

  @override
  String get bookId => (origin as DownloadNotifierProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
