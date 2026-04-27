class Book {
  const Book({
    required this.id,
    required this.titles,
    required this.xmlPath,
    required this.coverImagePath,
  });

  final String id;
  final Map<String, String> titles;
  final String xmlPath;
  final String coverImagePath;

  String localizedTitle(String languageCode) =>
      titles[languageCode] ?? titles['ja'] ?? '';
}
