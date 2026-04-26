import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entity/app_settings.dart';

part 'settings_notifier.g.dart';

const _keyLanguage = 'language_code';
const _keyQuiz = 'quiz_enabled';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      languageCode: prefs.getString(_keyLanguage),
      quizEnabled: prefs.getBool(_keyQuiz) ?? true,
    );
  }

  Future<void> setLanguageCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_keyLanguage);
    } else {
      await prefs.setString(_keyLanguage, code);
    }
    state = AsyncData(
      (state.valueOrNull ?? const AppSettings()).copyWith(languageCode: code),
    );
  }

  Future<void> setQuizEnabled({required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyQuiz, enabled);
    state = AsyncData(
      (state.valueOrNull ?? const AppSettings()).copyWith(quizEnabled: enabled),
    );
  }
}
