import 'package:flutter/material.dart';

class IllustrationImage extends StatelessWidget {
  const IllustrationImage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
