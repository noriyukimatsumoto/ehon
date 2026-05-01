import 'dart:io';

import 'package:flutter/material.dart';

class IllustrationImage extends StatelessWidget {
  const IllustrationImage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (screenWidth * dpr).toInt();

    return Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth,
    );
  }
}
