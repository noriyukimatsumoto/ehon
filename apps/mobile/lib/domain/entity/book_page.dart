class TextClause {
  const TextClause({
    required this.text,
    required this.duration,
    this.audioUrl,
  });

  final String text;
  final int duration;
  final String? audioUrl;
}

class BookPage {
  const BookPage({required this.texts, required this.imagePath});

  final List<TextClause> texts;
  final String imagePath;
}
