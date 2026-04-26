import 'book_page.dart';
import 'quiz_question.dart';

class EhonData {
  const EhonData({required this.pages, required this.questions});

  final List<BookPage> pages;
  final List<QuizQuestion> questions;
}
