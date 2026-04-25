import 'package:flutter/material.dart';

class PageCounterText extends StatelessWidget {
  const PageCounterText({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$current / $total',
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
  }
}
