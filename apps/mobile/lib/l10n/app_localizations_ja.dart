// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '絵本';

  @override
  String error(Object message) {
    return 'エラー: $message';
  }

  @override
  String get finished => 'おわり';

  @override
  String get readAgain => 'もう一度よむ';

  @override
  String get selectBook => '本をえらぶ';

  @override
  String remainingSeconds(int remaining) {
    return '残り $remaining秒';
  }

  @override
  String get quizQuestion => 'もんだい';

  @override
  String get quizAnswer => 'こたえ';

  @override
  String get bookSelectionTitle => 'えほんを えらぼう';

  @override
  String get settings => 'せってい';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => 'システム';

  @override
  String get settingsLanguageJapanese => '日本語';

  @override
  String get settingsLanguageEnglish => '英語';

  @override
  String get settingsQuizEnabled => '読み終わりにクイズを出題する';

  @override
  String get store => 'ストア';

  @override
  String get download => 'ダウンロード';

  @override
  String get downloading => 'ダウンロード中';

  @override
  String get downloaded => 'ダウンロード済み';

  @override
  String get downloadedBooks => 'ダウンロード済みの本';

  @override
  String get deleteBook => '削除';

  @override
  String get storeEmpty => '利用可能な本はありません';

  @override
  String get downloadError => 'ダウンロードに失敗しました';
}
