import 'dart:io';

import 'package:flutter/material.dart';

class IllustrationImage extends StatelessWidget {
  const IllustrationImage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('/')) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
