import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entity/quiz_question.dart';
import 'ehon_provider.dart';
import 'ehon_reading_state.dart';
import 'settings_notifier.dart';

part 'ehon_notifier.g.dart';

const _quizCount = 3;

@riverpod
class EhonNotifier extends _$EhonNotifier {
  Timer? _timer;

  @override
  Future<EhonReadingState> build(String xmlPath, String languageCode) async {
    ref.onDispose(() => _timer?.cancel());

    final settings = await ref.read(settingsNotifierProvider.future);
    final data = await ref
        .read(loadEhonUseCaseProvider)
        .execute(xmlPath, languageCode);
    final quizQuestions =
        settings.quizEnabled ? _pickQuestions(data.questions) : <QuizQuestion>[];
    final firstDuration = data.pages.first.texts.first.duration;
    _startCountdown(firstDuration);
    return EhonReadingState(
      pages: data.pages,
      currentIndex: 0,
      currentTextIndex: 0,
      phase: ReadingPhase.reading,
      remaining: firstDuration,
      quizQuestions: quizQuestions,
      currentQuizIndex: 0,
    );
  }

  List<QuizQuestion> _pickQuestions(List<QuizQuestion> all) {
    final shuffled = [...all]..shuffle(Random());
    return shuffled.take(_quizCount).toList();
  }

  void _startCountdown(int duration) {
    _timer?.cancel();
    var remaining = duration;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(remaining: remaining));
      }
      if (remaining <= 0) {
        t.cancel();
        _advance();
      }
    });
  }

  void _advance() {
    final current = state.valueOrNull;
    if (current == null) return;

    switch (current.phase) {
      case ReadingPhase.reading:
        _advanceReading(current);
      case ReadingPhase.quizQuestion:
        _showAnswer(current);
      case ReadingPhase.quizAnswer:
        _advanceQuiz(current);
      case ReadingPhase.finished:
        break;
    }
  }

  void _advanceReading(EhonReadingState current) {
    final page = current.currentPage;
    if (current.currentTextIndex < page.texts.length - 1) {
      final nextTextIndex = current.currentTextIndex + 1;
      final nextDuration = page.texts[nextTextIndex].duration;
      state = AsyncData(current.copyWith(
        currentTextIndex: nextTextIndex,
        remaining: nextDuration,
      ));
      _startCountdown(nextDuration);
    } else if (current.currentIndex < current.pages.length - 1) {
      final nextPageIndex = current.currentIndex + 1;
      final nextPage = current.pages[nextPageIndex];
      final firstDuration = nextPage.texts.first.duration;
      state = AsyncData(current.copyWith(
        currentIndex: nextPageIndex,
        currentTextIndex: 0,
        remaining: firstDuration,
      ));
      _startCountdown(firstDuration);
    } else if (current.quizQuestions.isNotEmpty) {
      final duration = current.quizQuestions.first.questionDuration;
      state = AsyncData(current.copyWith(
        phase: ReadingPhase.quizQuestion,
        currentQuizIndex: 0,
        remaining: duration,
      ));
      _startCountdown(duration);
    } else {
      state = AsyncData(current.copyWith(phase: ReadingPhase.finished));
    }
  }

  void _showAnswer(EhonReadingState current) {
    final duration = current.currentQuestion.answerDuration;
    state = AsyncData(current.copyWith(
      phase: ReadingPhase.quizAnswer,
      remaining: duration,
    ));
    _startCountdown(duration);
  }

  void _advanceQuiz(EhonReadingState current) {
    final nextIndex = current.currentQuizIndex + 1;
    if (nextIndex < current.quizQuestions.length) {
      final duration = current.quizQuestions[nextIndex].questionDuration;
      state = AsyncData(current.copyWith(
        phase: ReadingPhase.quizQuestion,
        currentQuizIndex: nextIndex,
        remaining: duration,
      ));
      _startCountdown(duration);
    } else {
      state = AsyncData(current.copyWith(phase: ReadingPhase.finished));
    }
  }

  void nextPage() {
    final current = state.valueOrNull;
    if (current == null || current.phase != ReadingPhase.reading) return;

    if (current.currentIndex < current.pages.length - 1) {
      final nextPageIndex = current.currentIndex + 1;
      final firstDuration = current.pages[nextPageIndex].texts.first.duration;
      state = AsyncData(current.copyWith(
        currentIndex: nextPageIndex,
        currentTextIndex: 0,
        remaining: firstDuration,
      ));
      _startCountdown(firstDuration);
    } else {
      _advanceReading(current.copyWith(
        currentTextIndex: current.currentPage.texts.length - 1,
      ));
    }
  }

  void previousPage() {
    final current = state.valueOrNull;
    if (current == null || current.currentIndex <= 0) return;
    if (current.phase != ReadingPhase.reading) return;

    final prevPageIndex = current.currentIndex - 1;
    final firstDuration = current.pages[prevPageIndex].texts.first.duration;
    state = AsyncData(current.copyWith(
      currentIndex: prevPageIndex,
      currentTextIndex: 0,
      remaining: firstDuration,
    ));
    _startCountdown(firstDuration);
  }

  void restart() {
    final current = state.valueOrNull;
    if (current == null || current.pages.isEmpty) return;

    final shuffled = [...current.quizQuestions]..shuffle(Random());
    final firstDuration = current.pages.first.texts.first.duration;
    state = AsyncData(EhonReadingState(
      pages: current.pages,
      currentIndex: 0,
      currentTextIndex: 0,
      phase: ReadingPhase.reading,
      remaining: firstDuration,
      quizQuestions: shuffled,
      currentQuizIndex: 0,
    ));
    _startCountdown(firstDuration);
  }
}
