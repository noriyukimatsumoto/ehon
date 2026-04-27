import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class FinishedTemplate extends StatelessWidget {
  const FinishedTemplate({
    super.key,
    required this.onRestart,
    required this.onSelectBook,
  });

  final VoidCallback onRestart;
  final VoidCallback onSelectBook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.finished,
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: Text(l10n.readAgain, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 24),
                OutlinedButton(
                  onPressed: onSelectBook,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: Text(l10n.selectBook, style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
