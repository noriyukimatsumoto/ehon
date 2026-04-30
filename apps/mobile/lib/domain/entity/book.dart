class Book {
  const Book({
    required this.id,
    required this.version,
    required this.titles,
    required this.jsonPath,
    required this.coverImagePath,
  });

  final String id;
  final String version;
  final Map<String, String> titles;
  final String jsonPath;
  final String coverImagePath;

  String localizedTitle(String languageCode) =>
      titles[languageCode] ?? titles['ja'] ?? '';
}
