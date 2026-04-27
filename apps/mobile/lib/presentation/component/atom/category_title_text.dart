import 'package:flutter/material.dart';

class CategoryTitleText extends StatelessWidget {
  const CategoryTitleText({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown[700],
      ),
    );
  }
}
