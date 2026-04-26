// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/cover_akazukin.png
  AssetGenImage get coverAkazukin =>
      const AssetGenImage('assets/images/cover_akazukin.png');

  /// File path: assets/images/cover_cinderella.png
  AssetGenImage get coverCinderella =>
      const AssetGenImage('assets/images/cover_cinderella.png');

  /// File path: assets/images/cover_issun.png
  AssetGenImage get coverIssun =>
      const AssetGenImage('assets/images/cover_issun.png');

  /// File path: assets/images/cover_momotaro.png
  AssetGenImage get coverMomotaro =>
      const AssetGenImage('assets/images/cover_momotaro.png');

  /// File path: assets/images/cover_urashima.png
  AssetGenImage get coverUrashima =>
      const AssetGenImage('assets/images/cover_urashima.png');

  /// File path: assets/images/scene1.png
  AssetGenImage get scene1 => const AssetGenImage('assets/images/scene1.png');

  /// File path: assets/images/scene2.png
  AssetGenImage get scene2 => const AssetGenImage('assets/images/scene2.png');

  /// File path: assets/images/scene3.png
  AssetGenImage get scene3 => const AssetGenImage('assets/images/scene3.png');

  /// File path: assets/images/scene4.png
  AssetGenImage get scene4 => const AssetGenImage('assets/images/scene4.png');

  /// File path: assets/images/scene5.png
  AssetGenImage get scene5 => const AssetGenImage('assets/images/scene5.png');

  /// File path: assets/images/scene6.png
  AssetGenImage get scene6 => const AssetGenImage('assets/images/scene6.png');

  /// File path: assets/images/title.png
  AssetGenImage get title => const AssetGenImage('assets/images/title.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    coverAkazukin,
    coverCinderella,
    coverIssun,
    coverMomotaro,
    coverUrashima,
    scene1,
    scene2,
    scene3,
    scene4,
    scene5,
    scene6,
    title,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const String momotaro = 'assets/momotaro.xml';

  /// List of all assets
  static List<String> get values => [momotaro];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
