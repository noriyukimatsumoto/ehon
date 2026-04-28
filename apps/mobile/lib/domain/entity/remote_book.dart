class RemoteBook {
  const RemoteBook({
    required this.id,
    required this.version,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.xmlUrl,
    required this.coverImageUrl,
    required this.imageBaseUrl,
    required this.audioBaseUrl,
  });

  final String id;
  final String version;
  final Map<String, String> title;
  final String categoryId;
  final Map<String, String> categoryName;
  final String xmlUrl;
  final String coverImageUrl;
  final String imageBaseUrl;
  final String audioBaseUrl;

  String localizedTitle(String languageCode) =>
      title[languageCode] ?? title['ja'] ?? '';

  String localizedCategoryName(String languageCode) =>
      categoryName[languageCode] ?? categoryName['ja'] ?? '';
}
