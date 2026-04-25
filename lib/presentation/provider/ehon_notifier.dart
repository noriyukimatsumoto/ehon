import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ehon_provider.dart';
import 'ehon_reading_state.dart';

part 'ehon_notifier.g.dart';

@riverpod
class EhonNotifier extends _$EhonNotifier {
  Timer? _timer;

  @override
  Future<EhonReadingState> build(String xmlPath) async {
    ref.onDispose(() => _timer?.cancel());

    final useCase = ref.read(loadEhonUseCaseProvider);
    final pages = await useCase.execute(xmlPath);
    _startCountdown(pages.first.duration);
    return EhonReadingState(
      pages: pages,
      currentIndex: 0,
      isFinished: false,
      remaining: pages.first.duration,
    );
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

    if (current.currentIndex < current.pages.length - 1) {
      final nextIndex = current.currentIndex + 1;
      final nextDuration = current.pages[nextIndex].duration;
      state = AsyncData(current.copyWith(
        currentIndex: nextIndex,
        remaining: nextDuration,
      ));
      _startCountdown(nextDuration);
    } else {
      state = AsyncData(current.copyWith(isFinished: true));
    }
  }

  void restart() {
    final current = state.valueOrNull;
    if (current == null || current.pages.isEmpty) return;

    state = AsyncData(EhonReadingState(
      pages: current.pages,
      currentIndex: 0,
      isFinished: false,
      remaining: current.pages.first.duration,
    ));
    _startCountdown(current.pages.first.duration);
  }
}
