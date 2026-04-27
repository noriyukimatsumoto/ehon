class TextClause {
  const TextClause({required this.text, required this.duration});

  final String text;
  final int duration;
}

class BookPage {
  const BookPage({required this.texts, required this.imagePath});

  final List<TextClause> texts;
  final String imagePath;
}
