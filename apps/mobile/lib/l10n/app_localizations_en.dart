// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Picture Book';

  @override
  String error(Object message) {
    return 'Error: $message';
  }

  @override
  String get finished => 'The End';

  @override
  String get readAgain => 'Read Again';

  @override
  String get selectBook => 'Choose a Book';

  @override
  String remainingSeconds(int remaining) {
    return '${remaining}s left';
  }

  @override
  String get quizQuestion => 'Question';

  @override
  String get quizAnswer => 'Answer';

  @override
  String get bookSelectionTitle => 'Choose a Book';

  @override
  String get settings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageJapanese => 'Japanese';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsQuizEnabled => 'Show quiz after reading';

  @override
  String get store => 'Store';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloadedBooks => 'Downloaded Books';

  @override
  String get deleteBook => 'Delete';

  @override
  String get storeEmpty => 'No books available';

  @override
  String get downloadError => 'Download failed';

  @override
  String get library => 'Library';

  @override
  String get noDownloadedBooks => 'No downloaded books yet';
}
