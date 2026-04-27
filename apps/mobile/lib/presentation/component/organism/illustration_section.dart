import 'package:flutter/material.dart';

import '../molecule/illustration_image.dart';

class IllustrationSection extends StatelessWidget {
  const IllustrationSection({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: IllustrationImage(
          key: ValueKey(imagePath),
          imagePath: imagePath,
        ),
      ),
    );
  }
}
