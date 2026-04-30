import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../../domain/entity/book_page.dart';
import '../../domain/entity/ehon_data.dart';
import '../../domain/entity/quiz_question.dart';
import '../../domain/repository/ehon_repository.dart';

class JsonEhonRepository implements EhonRepository {
  const JsonEhonRepository();

  @override
  Future<EhonData> fetchEhon(String jsonPath, String languageCode) async {
    final isFilePath = jsonPath.startsWith('/');
    final String jsonString;
    final String imageBasePath;
    final String audioBasePath;

    if (isFilePath) {
      jsonString = await File(jsonPath).readAsString();
      final dir = path.dirname(jsonPath);
      imageBasePath = '$dir/images/';
      audioBasePath = '$dir/audios/';
    } else {
      jsonString = await rootBundle.loadString(jsonPath);
      imageBasePath = 'assets/images/';
      audioBasePath = 'assets/audios/';
    }

    final book = jsonDecode(jsonString) as Map<String, dynamic>;

    final pages = (book['pages'] as List<dynamic>)
        .map((p) => _parsePage(p as Map<String, dynamic>, languageCode, imageBasePath, audioBasePath))
        .toList();
    final questions = (book['questions'] as List<dynamic>)
        .map((q) => _parseQuestion(q as Map<String, dynamic>, languageCode, imageBasePath, audioBasePath))
        .toList();

    return EhonData(pages: pages, questions: questions);
  }

  String _localizedText(Map<String, dynamic> node, String languageCode) {
    return (node[languageCode] ?? node['ja'] ?? '') as String;
  }

  String? _audioUrl(String? audioBase, String audioBasePath, String languageCode) {
    if (audioBase == null || audioBase.isEmpty) return null;
    return '$audioBasePath${audioBase}_$languageCode.wav';
  }

  BookPage _parsePage(
    Map<String, dynamic> node,
    String languageCode,
    String imageBasePath,
    String audioBasePath,
  ) {
    final texts = (node['texts'] as List<dynamic>).map((t) {
      final text = t as Map<String, dynamic>;
      final audioBase = text['audio'] as String?;
      return TextClause(
        text: _localizedText(text, languageCode),
        duration: (text['duration'] as num).toInt(),
        audioUrl: _audioUrl(audioBase, audioBasePath, languageCode),
      );
    }).toList();

    return BookPage(
      texts: texts,
      imagePath: '$imageBasePath${node['image']}',
    );
  }

  QuizQuestion _parseQuestion(
    Map<String, dynamic> node,
    String languageCode,
    String imageBasePath,
    String audioBasePath,
  ) {
    final audioBase = node['audio'] as String?;
    final choices = (node['choices'] as List<dynamic>).map((c) {
      final choice = c as Map<String, dynamic>;
      return QuizChoice(
        text: _localizedText(choice, languageCode),
        isCorrect: (choice['correct'] as bool?) ?? false,
        audioUrl: _audioUrl(choice['audio'] as String?, audioBasePath, languageCode),
      );
    }).toList();

    return QuizQuestion(
      questionText: _localizedText(node, languageCode),
      imagePath: '$imageBasePath${node['image']}',
      choices: choices,
      questionDuration: (node['duration'] as num).toInt(),
      answerDuration: (node['answerDuration'] as num).toInt(),
      audioUrl: _audioUrl(audioBase, audioBasePath, languageCode),
    );
  }
}
