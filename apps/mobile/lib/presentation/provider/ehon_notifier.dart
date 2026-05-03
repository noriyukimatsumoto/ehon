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
  Future<EhonReadingState> build(String jsonPath, String languageCode) async {
    ref.onDispose(() {
      _timer?.cancel();
      _playerSub?.cancel();
      _player.dispose();
    });

    final settings = await ref.read(settingsNotifierProvider.future);
    final data = await ref
        .read(loadEhonUseCaseProvider)
        .execute(jsonPath, languageCode);
    final quizQuestions = settings.quizEnabled
        ? _pickQuestions(data.questions)
        : <QuizQuestion>[];
    final firstClause = data.pages.first.texts.first;
    _playOrCountdown(firstClause, delay: const Duration(seconds: 1));
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

  void _playOrCountdown(TextClause clause, {Duration delay = Duration.zero}) {
    _cancelPlayback();
    if (delay == Duration.zero) {
      _startPlayback(clause);
    } else {
      _timer = Timer(delay, () => _startPlayback(clause));
    }
  }

  void _startPlayback(TextClause clause) {
    _playAudioOrCountdown(clause.audioUrl, clause.duration);
  }

  void _playAudioOrCountdown(String? audioUrl, int duration) {
    if (audioUrl != null) {
      _playAudio(audioUrl, duration);
    } else {
      _startCountdown(duration);
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
      _playOrCountdown(nextClause, delay: const Duration(milliseconds: 500));
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
      _playOrCountdown(firstClause, delay: const Duration(seconds: 1));
    } else if (current.quizQuestions.isNotEmpty) {
      final question = current.quizQuestions.first;
      final duration = question.questionDuration;
      state = AsyncData(
        current.copyWith(
          phase: ReadingPhase.quizQuestion,
          currentQuizIndex: 0,
          remaining: duration,
        ),
      );
      _playAudioOrCountdown(question.audioUrl, duration);
    } else {
      state = AsyncData(current.copyWith(phase: ReadingPhase.finished));
    }
  }

  void _showAnswer(EhonReadingState current) {
    _cancelPlayback();
    _timer = Timer(const Duration(seconds: 1), () {
      final question = current.currentQuestion;
      final duration = question.answerDuration;
      state = AsyncData(
        current.copyWith(phase: ReadingPhase.quizAnswer, remaining: duration),
      );
      _startCountdown(duration);
    });
  }

  void _advanceQuiz(EhonReadingState current) {
    final nextIndex = current.currentQuizIndex + 1;
    if (nextIndex < current.quizQuestions.length) {
      final question = current.quizQuestions[nextIndex];
      final duration = question.questionDuration;
      state = AsyncData(
        current.copyWith(
          phase: ReadingPhase.quizQuestion,
          currentQuizIndex: nextIndex,
          remaining: duration,
        ),
      );
      _playAudioOrCountdown(question.audioUrl, duration);
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
      _playOrCountdown(firstClause, delay: const Duration(seconds: 1));
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
    _playOrCountdown(firstClause, delay: const Duration(seconds: 1));
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
    _playOrCountdown(firstClause, delay: const Duration(seconds: 1));
  }
}
