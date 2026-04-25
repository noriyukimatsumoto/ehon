import '../../domain/entity/book_page.dart';

class EhonReadingState {
  const EhonReadingState({
    required this.pages,
    required this.currentIndex,
    required this.isFinished,
    required this.remaining,
  });

  final List<BookPage> pages;
  final int currentIndex;
  final bool isFinished;
  final int remaining;

  BookPage get currentPage => pages[currentIndex];

  EhonReadingState copyWith({
    List<BookPage>? pages,
    int? currentIndex,
    bool? isFinished,
    int? remaining,
  }) =>
      EhonReadingState(
        pages: pages ?? this.pages,
        currentIndex: currentIndex ?? this.currentIndex,
        isFinished: isFinished ?? this.isFinished,
        remaining: remaining ?? this.remaining,
      );
}
