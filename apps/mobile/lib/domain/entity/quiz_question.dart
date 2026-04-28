class QuizChoice {
  const QuizChoice({
    required this.text,
    required this.isCorrect,
    this.audioUrl,
  });

  final String text;
  final bool isCorrect;
  final String? audioUrl;
}

class QuizQuestion {
  const QuizQuestion({
    required this.questionText,
    required this.imagePath,
    required this.choices,
    required this.questionDuration,
    required this.answerDuration,
    this.audioUrl,
  });

  final String questionText;
  final String imagePath;
  final List<QuizChoice> choices;
  final int questionDuration;
  final int answerDuration;
  final String? audioUrl;

  QuizChoice get correctChoice => choices.firstWhere((c) => c.isCorrect);
}
