import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entity/quiz_question.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/app_text_theme.dart';
import '../atom/countdown_text.dart';
import '../organism/illustration_section.dart';

class QuizTemplate extends StatefulWidget {
  const QuizTemplate({
    super.key,
    required this.question,
    required this.showingAnswer,
    required this.currentQuizIndex,
    required this.totalQuiz,
    required this.remaining,
    this.onBack,
  });

  final QuizQuestion question;
  final bool showingAnswer;
  final int currentQuizIndex;
  final int totalQuiz;
  final int remaining;
  final VoidCallback? onBack;

  @override
  State<QuizTemplate> createState() => _QuizTemplateState();
}

class _QuizTemplateState extends State<QuizTemplate> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleAppear();
  }

  @override
  void didUpdateWidget(QuizTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentQuizIndex != widget.currentQuizIndex) {
      _timer?.cancel();
      setState(() => _visible = false);
      _scheduleAppear();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleAppear() {
    _timer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: IllustrationSection(
              imagePath: q.imagePath,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.home, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black38),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _QuizHeader(
                        label: widget.showingAnswer
                            ? AppLocalizations.of(context).quizAnswer
                            : AppLocalizations.of(context).quizQuestion,
                        currentIndex: widget.currentQuizIndex,
                        total: widget.totalQuiz,
                        remaining: widget.remaining,
                      ),
                      const SizedBox(height: 8),
                      _QuestionBox(text: q.questionText),
                      const SizedBox(height: 8),
                      ...q.choices.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _ChoiceTile(
                            choice: c,
                            revealAnswer: widget.showingAnswer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.label,
    required this.currentIndex,
    required this.total,
    required this.remaining,
  });

  final String label;
  final int currentIndex;
  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$label ${currentIndex + 1} / $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        CountdownText(remaining: remaining),
      ],
    );
  }
}

class _QuestionBox extends StatelessWidget {
  const _QuestionBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final fontSize = AppTextTheme.of(context).quizQuestion(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.choice, required this.revealAnswer});

  final QuizChoice choice;
  final bool revealAnswer;

  @override
  Widget build(BuildContext context) {
    final fontSize = AppTextTheme.of(context).quizChoice(context);

    Color bgColor;
    Color textColor;

    if (!revealAnswer) {
      bgColor = Colors.white70;
      textColor = Colors.black87;
    } else if (choice.isCorrect) {
      bgColor = Colors.green;
      textColor = Colors.white;
    } else {
      bgColor = Colors.white30;
      textColor = Colors.white60;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (revealAnswer && choice.isCorrect)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
          Text(
            choice.text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: choice.isCorrect && revealAnswer
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
