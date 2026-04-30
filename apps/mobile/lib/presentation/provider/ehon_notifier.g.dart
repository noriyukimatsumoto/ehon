// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ehon_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ehonNotifierHash() => r'08b813dc3cf029accc37adbd1a8e165dc84797f7';

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

abstract class _$EhonNotifier
    extends BuildlessAutoDisposeAsyncNotifier<EhonReadingState> {
  late final String jsonPath;
  late final String languageCode;

  FutureOr<EhonReadingState> build(String jsonPath, String languageCode);
}

/// See also [EhonNotifier].
@ProviderFor(EhonNotifier)
const ehonNotifierProvider = EhonNotifierFamily();

/// See also [EhonNotifier].
class EhonNotifierFamily extends Family<AsyncValue<EhonReadingState>> {
  /// See also [EhonNotifier].
  const EhonNotifierFamily();

  /// See also [EhonNotifier].
  EhonNotifierProvider call(String jsonPath, String languageCode) {
    return EhonNotifierProvider(jsonPath, languageCode);
  }

  @override
  EhonNotifierProvider getProviderOverride(
    covariant EhonNotifierProvider provider,
  ) {
    return call(provider.jsonPath, provider.languageCode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ehonNotifierProvider';
}

/// See also [EhonNotifier].
class EhonNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<EhonNotifier, EhonReadingState> {
  /// See also [EhonNotifier].
  EhonNotifierProvider(String jsonPath, String languageCode)
    : this._internal(
        () => EhonNotifier()
          ..jsonPath = jsonPath
          ..languageCode = languageCode,
        from: ehonNotifierProvider,
        name: r'ehonNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ehonNotifierHash,
        dependencies: EhonNotifierFamily._dependencies,
        allTransitiveDependencies:
            EhonNotifierFamily._allTransitiveDependencies,
        jsonPath: jsonPath,
        languageCode: languageCode,
      );

  EhonNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jsonPath,
    required this.languageCode,
  }) : super.internal();

  final String jsonPath;
  final String languageCode;

  @override
  FutureOr<EhonReadingState> runNotifierBuild(covariant EhonNotifier notifier) {
    return notifier.build(jsonPath, languageCode);
  }

  @override
  Override overrideWith(EhonNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EhonNotifierProvider._internal(
        () => create()
          ..jsonPath = jsonPath
          ..languageCode = languageCode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jsonPath: jsonPath,
        languageCode: languageCode,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<EhonNotifier, EhonReadingState>
  createElement() {
    return _EhonNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EhonNotifierProvider &&
        other.jsonPath == jsonPath &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jsonPath.hashCode);
    hash = _SystemHash.combine(hash, languageCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EhonNotifierRef on AutoDisposeAsyncNotifierProviderRef<EhonReadingState> {
  /// The parameter `jsonPath` of this provider.
  String get jsonPath;

  /// The parameter `languageCode` of this provider.
  String get languageCode;
}

class _EhonNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<EhonNotifier, EhonReadingState>
    with EhonNotifierRef {
  _EhonNotifierProviderElement(super.provider);

  @override
  String get jsonPath => (origin as EhonNotifierProvider).jsonPath;
  @override
  String get languageCode => (origin as EhonNotifierProvider).languageCode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
