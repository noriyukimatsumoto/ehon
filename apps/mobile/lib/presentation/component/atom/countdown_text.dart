import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class CountdownText extends StatelessWidget {
  const CountdownText({super.key, required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).remainingSeconds(remaining),
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
  }
}
