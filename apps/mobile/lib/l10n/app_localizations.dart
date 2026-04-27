import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'絵本'**
  String get appTitle;

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラー: {message}'**
  String error(Object message);

  /// No description provided for @finished.
  ///
  /// In ja, this message translates to:
  /// **'おわり'**
  String get finished;

  /// No description provided for @readAgain.
  ///
  /// In ja, this message translates to:
  /// **'もう一度よむ'**
  String get readAgain;

  /// No description provided for @selectBook.
  ///
  /// In ja, this message translates to:
  /// **'本をえらぶ'**
  String get selectBook;

  /// No description provided for @remainingSeconds.
  ///
  /// In ja, this message translates to:
  /// **'残り {remaining}秒'**
  String remainingSeconds(int remaining);

  /// No description provided for @quizQuestion.
  ///
  /// In ja, this message translates to:
  /// **'もんだい'**
  String get quizQuestion;

  /// No description provided for @quizAnswer.
  ///
  /// In ja, this message translates to:
  /// **'こたえ'**
  String get quizAnswer;

  /// No description provided for @bookSelectionTitle.
  ///
  /// In ja, this message translates to:
  /// **'えほんを えらぼう'**
  String get bookSelectionTitle;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'せってい'**
  String get settings;

  /// No description provided for @settingsLanguage.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ja, this message translates to:
  /// **'システム'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageJapanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get settingsLanguageJapanese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In ja, this message translates to:
  /// **'英語'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsQuizEnabled.
  ///
  /// In ja, this message translates to:
  /// **'読み終わりにクイズを出題する'**
  String get settingsQuizEnabled;

  /// No description provided for @store.
  ///
  /// In ja, this message translates to:
  /// **'ストア'**
  String get store;

  /// No description provided for @download.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード中'**
  String get downloading;

  /// No description provided for @downloaded.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード済み'**
  String get downloaded;

  /// No description provided for @downloadedBooks.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード済みの本'**
  String get downloadedBooks;

  /// No description provided for @deleteBook.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get deleteBook;

  /// No description provided for @storeEmpty.
  ///
  /// In ja, this message translates to:
  /// **'利用可能な本はありません'**
  String get storeEmpty;

  /// No description provided for @downloadError.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロードに失敗しました'**
  String get downloadError;

  /// No description provided for @library.
  ///
  /// In ja, this message translates to:
  /// **'本棚'**
  String get library;

  /// No description provided for @noDownloadedBooks.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロードした本がありません'**
  String get noDownloadedBooks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
