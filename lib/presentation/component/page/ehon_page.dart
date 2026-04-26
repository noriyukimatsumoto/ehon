import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../provider/ehon_notifier.dart';
import '../../provider/ehon_reading_state.dart';
import '../template/finished_template.dart';
import '../template/quiz_template.dart';
import '../template/reading_template.dart';

class EhonPage extends ConsumerWidget {
  const EhonPage({super.key, required this.xmlPath});

  final String xmlPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final ehonAsync = ref.watch(ehonNotifierProvider(xmlPath, languageCode));

    return ehonAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context).error(e))),
      ),
      data: (state) {
        final notifier =
            ref.read(ehonNotifierProvider(xmlPath, languageCode).notifier);

        if (state.phase == ReadingPhase.finished) {
          return FinishedTemplate(
            onRestart: notifier.restart,
            onSelectBook: () => context.pop(),
          );
        }

        if (state.phase == ReadingPhase.quizQuestion ||
            state.phase == ReadingPhase.quizAnswer) {
          return QuizTemplate(
            question: state.currentQuestion,
            showingAnswer: state.phase == ReadingPhase.quizAnswer,
            currentQuizIndex: state.currentQuizIndex,
            totalQuiz: state.quizQuestions.length,
            remaining: state.remaining,
            onBack: () => context.pop(),
          );
        }

        return ReadingTemplate(
          page: state.currentPage,
          text: state.currentText.text,
          currentIndex: state.currentIndex,
          totalPages: state.pages.length,
          remaining: state.remaining,
          onSwipeLeft: notifier.nextPage,
          onSwipeRight: notifier.previousPage,
          onBack: () => context.pop(),
        );
      },
    );
  }
}
