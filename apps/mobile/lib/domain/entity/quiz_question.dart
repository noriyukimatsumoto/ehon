class QuizChoice {
  const QuizChoice({required this.text, required this.isCorrect});

  final String text;
  final bool isCorrect;
}

class QuizQuestion {
  const QuizQuestion({
    required this.questionText,
    required this.imagePath,
    required this.choices,
    required this.questionDuration,
    required this.answerDuration,
  });

  final String questionText;
  final String imagePath;
  final List<QuizChoice> choices;
  final int questionDuration;
  final int answerDuration;

  QuizChoice get correctChoice => choices.firstWhere((c) => c.isCorrect);
}
