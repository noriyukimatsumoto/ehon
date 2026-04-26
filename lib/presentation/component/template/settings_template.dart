import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entity/app_settings.dart';
import '../../../l10n/app_localizations.dart';
import '../../provider/settings_notifier.dart';

class SettingsTemplate extends ConsumerWidget {
  const SettingsTemplate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings =
        ref.watch(settingsNotifierProvider).valueOrNull ?? const AppSettings();
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        backgroundColor: Colors.amber[50],
        elevation: 0,
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.brown[800]),
      ),
      body: ListView(
        children: [
          _SectionHeader(label: l10n.settingsLanguage),
          RadioGroup<String?>(
            groupValue: settings.languageCode,
            onChanged: notifier.setLanguageCode,
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.settingsLanguageSystem),
                ),
                RadioListTile<String?>(
                  value: 'ja',
                  title: Text(l10n.settingsLanguageJapanese),
                ),
                RadioListTile<String?>(
                  value: 'en',
                  title: Text(l10n.settingsLanguageEnglish),
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(
              l10n.settingsQuizEnabled,
              style: const TextStyle(fontSize: 16),
            ),
            value: settings.quizEnabled,
            activeThumbColor: Colors.orange,
            onChanged: (v) => notifier.setQuizEnabled(enabled: v),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.brown[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
