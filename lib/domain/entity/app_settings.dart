const _unset = Object();

class AppSettings {
  const AppSettings({
    this.languageCode,
    this.quizEnabled = true,
  });

  /// null = システムデフォルト
  final String? languageCode;
  final bool quizEnabled;

  AppSettings copyWith({
    Object? languageCode = _unset,
    bool? quizEnabled,
  }) =>
      AppSettings(
        languageCode: identical(languageCode, _unset)
            ? this.languageCode
            : languageCode as String?,
        quizEnabled: quizEnabled ?? this.quizEnabled,
      );
}
