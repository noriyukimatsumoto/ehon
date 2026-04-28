import 'dart:async';
import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entity/book_page.dart';
import '../../domain/entity/quiz_question.dart';
import 'ehon_provider.dart';
import 'ehon_reading_state.dart';
import 'settings_notifier.dart';

part 'ehon_notifier.g.dart';

const _quizCount = 3;

@riverpod
class EhonNotifier extends _$EhonNotifier {
  Timer? _timer;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<ProcessingState>? _playerSub;

  @override
  Future<EhonReadingState> build(String xmlPath, String languageCode) async {
    ref.onDispose(() {
      _timer?.cancel();
      _playerSub?.cancel();
      _player.dispose();
    });

    final settings = await ref.read(settingsNotifierProvider.future);
    final data = await ref
        .read(loadEhonUseCaseProvider)
        .execute(xmlPath, languageCode);
    final quizQuestions = settings.quizEnabled
        ? _pickQuestions(data.questions)
        : <QuizQuestion>[];
    final firstClause = data.pages.first.texts.first;
    _playOrCountdown(firstClause);
    return EhonReadingState(
      pages: data.pages,
      currentIndex: 0,
      currentTextIndex: 0,
      phase: ReadingPhase.reading,
      remaining: firstClause.duration,
      quizQuestions: quizQuestions,
      currentQuizIndex: 0,
    );
  }

  List<QuizQuestion> _pickQuestions(List<QuizQuestion> all) {
    final shuffled = [...all]..shuffle(Random());
    return shuffled.take(_quizCount).toList();
  }

  void _playOrCountdown(TextClause clause) {
    _cancelPlayback();
    if (clause.audioUrl != null) {
      _playAudio(clause.audioUrl!, clause.duration);
    } else {
      _startCountdown(clause.duration);
    }
  }

  Future<void> _playAudio(String audioUrl, int fallbackDuration) async {
    try {
      await _player.stop();
      if (audioUrl.startsWith('/')) {
        await _player.setFilePath(audioUrl);
      } else {
        await _player.setUrl(audioUrl);
      }
      _playerSub = _player.processingStateStream.listen((s) {
        if (s == ProcessingState.completed) {
          _cancelPlayback();
          _advance();
        }
      });
      await _player.play();
    } catch (error, stack) {
      // ignore: avoid_print
      print('[EhonNotifier] _playAudio failed: $error\n$stack\naudioUrl: $audioUrl');
      _startCountdown(fallbackDuration);
    }
  }

  void _cancelPlayback() {
    _timer?.cancel();
    _timer = null;
    _playerSub?.cancel();
    _playerSub = null;
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
      final nextClause = page.texts[nextTextIndex];
      state = AsyncData(
        current.copyWith(
          currentTextIndex: nextTextIndex,
          remaining: nextClause.duration,
        ),
      );
      _playOrCountdown(nextClause);
    } else if (current.currentIndex < current.pages.length - 1) {
      final nextPageIndex = current.currentIndex + 1;
      final firstClause = current.pages[nextPageIndex].texts.first;
      state = AsyncData(
        current.copyWith(
          currentIndex: nextPageIndex,
          currentTextIndex: 0,
          remaining: firstClause.duration,
        ),
      );
      _playOrCountdown(firstClause);
    } else if (current.quizQuestions.isNotEmpty) {
      final duration = current.quizQuestions.first.questionDuration;
      state = AsyncData(
        current.copyWith(
          phase: ReadingPhase.quizQuestion,
          currentQuizIndex: 0,
          remaining: duration,
        ),
      );
      _startCountdown(duration);
    } else {
      state = AsyncData(current.copyWith(phase: ReadingPhase.finished));
    }
  }

  void _showAnswer(EhonReadingState current) {
    final duration = current.currentQuestion.answerDuration;
    state = AsyncData(
      current.copyWith(phase: ReadingPhase.quizAnswer, remaining: duration),
    );
    _startCountdown(duration);
  }

  void _advanceQuiz(EhonReadingState current) {
    final nextIndex = current.currentQuizIndex + 1;
    if (nextIndex < current.quizQuestions.length) {
      final duration = current.quizQuestions[nextIndex].questionDuration;
      state = AsyncData(
        current.copyWith(
          phase: ReadingPhase.quizQuestion,
          currentQuizIndex: nextIndex,
          remaining: duration,
        ),
      );
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
      final firstClause = current.pages[nextPageIndex].texts.first;
      state = AsyncData(
        current.copyWith(
          currentIndex: nextPageIndex,
          currentTextIndex: 0,
          remaining: firstClause.duration,
        ),
      );
      _playOrCountdown(firstClause);
    } else {
      _advanceReading(
        current.copyWith(
          currentTextIndex: current.currentPage.texts.length - 1,
        ),
      );
    }
  }

  void previousPage() {
    final current = state.valueOrNull;
    if (current == null || current.currentIndex <= 0) return;
    if (current.phase != ReadingPhase.reading) return;

    final prevPageIndex = current.currentIndex - 1;
    final firstClause = current.pages[prevPageIndex].texts.first;
    state = AsyncData(
      current.copyWith(
        currentIndex: prevPageIndex,
        currentTextIndex: 0,
        remaining: firstClause.duration,
      ),
    );
    _playOrCountdown(firstClause);
  }

  void restart() {
    final current = state.valueOrNull;
    if (current == null || current.pages.isEmpty) return;

    final shuffled = [...current.quizQuestions]..shuffle(Random());
    final firstClause = current.pages.first.texts.first;
    state = AsyncData(
      EhonReadingState(
        pages: current.pages,
        currentIndex: 0,
        currentTextIndex: 0,
        phase: ReadingPhase.reading,
        remaining: firstClause.duration,
        quizQuestions: shuffled,
        currentQuizIndex: 0,
      ),
    );
    _playOrCountdown(firstClause);
  }
}
