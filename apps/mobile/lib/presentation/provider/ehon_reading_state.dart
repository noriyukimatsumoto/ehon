import '../../domain/entity/book_page.dart';
import '../../domain/entity/quiz_question.dart';

enum ReadingPhase { reading, quizQuestion, quizAnswer, finished }

class EhonReadingState {
  const EhonReadingState({
    required this.pages,
    required this.currentIndex,
    required this.currentTextIndex,
    required this.phase,
    required this.remaining,
    required this.quizQuestions,
    required this.currentQuizIndex,
  });

  final List<BookPage> pages;
  final int currentIndex;
  final int currentTextIndex;
  final ReadingPhase phase;
  final int remaining;
  final List<QuizQuestion> quizQuestions;
  final int currentQuizIndex;

  bool get isFinished => phase == ReadingPhase.finished;
  BookPage get currentPage => pages[currentIndex];
  TextClause get currentText => currentPage.texts[currentTextIndex];
  QuizQuestion get currentQuestion => quizQuestions[currentQuizIndex];

  EhonReadingState copyWith({
    List<BookPage>? pages,
    int? currentIndex,
    int? currentTextIndex,
    ReadingPhase? phase,
    int? remaining,
    List<QuizQuestion>? quizQuestions,
    int? currentQuizIndex,
  }) =>
      EhonReadingState(
        pages: pages ?? this.pages,
        currentIndex: currentIndex ?? this.currentIndex,
        currentTextIndex: currentTextIndex ?? this.currentTextIndex,
        phase: phase ?? this.phase,
        remaining: remaining ?? this.remaining,
        quizQuestions: quizQuestions ?? this.quizQuestions,
        currentQuizIndex: currentQuizIndex ?? this.currentQuizIndex,
      );
}
