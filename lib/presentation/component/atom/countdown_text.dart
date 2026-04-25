import 'package:flutter/material.dart';

class CountdownText extends StatelessWidget {
  const CountdownText({super.key, required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Text(
      '残り $remaining秒',
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
  }
}
