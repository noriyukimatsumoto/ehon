import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

import '../../domain/entity/book_page.dart';
import '../../domain/entity/ehon_data.dart';
import '../../domain/entity/quiz_question.dart';
import '../../domain/repository/ehon_repository.dart';

class XmlEhonRepository implements EhonRepository {
  const XmlEhonRepository();

  @override
  Future<EhonData> fetchEhon(String xmlPath, String languageCode) async {
    final isFilePath = xmlPath.startsWith('/');
    final String xmlString;
    final String imageBasePath;
    final String audioBasePath;

    if (isFilePath) {
      xmlString = await File(xmlPath).readAsString();
      final dir = path.dirname(xmlPath);
      imageBasePath = '$dir/images/';
      audioBasePath = '$dir/audios/';
    } else {
      xmlString = await rootBundle.loadString(xmlPath);
      imageBasePath = 'assets/images/';
      audioBasePath = 'assets/audios/';
    }

    final document = XmlDocument.parse(xmlString);

    final pages = document
        .findAllElements('page')
        .map((n) => _parsePage(n, languageCode, imageBasePath, audioBasePath))
        .toList();
    final questions = document
        .findAllElements('question')
        .map(
          (n) => _parseQuestion(n, languageCode, imageBasePath, audioBasePath),
        )
        .toList();

    return EhonData(pages: pages, questions: questions);
  }

  String _localizedText(XmlElement node, String languageCode) {
    final localized = node.findElements(languageCode).firstOrNull;
    if (localized != null) return localized.innerText.trim();
    final fallback = node.findElements('ja').firstOrNull;
    if (fallback != null) return fallback.innerText.trim();
    return node.innerText.trim();
  }

  String? _audioUrl(
    String? audioBase,
    String audioBasePath,
    String languageCode,
  ) {
    if (audioBase == null) return null;
    return '$audioBasePath${audioBase}_$languageCode.wav';
  }

  BookPage _parsePage(
    XmlElement node,
    String languageCode,
    String imageBasePath,
    String audioBasePath,
  ) {
    final pageDuration = int.tryParse(node.getAttribute('duration') ?? '');
    final textNodes = node.findElements('text').toList();
    final filename = node.findElements('image').first.innerText.trim();

    final List<TextClause> texts;
    if (textNodes.length == 1 && pageDuration != null) {
      final audioBase = textNodes.first.getAttribute('audio');
      texts = [
        TextClause(
          text: _localizedText(textNodes.first, languageCode),
          duration: pageDuration,
          audioUrl: _audioUrl(audioBase, audioBasePath, languageCode),
        ),
      ];
    } else {
      texts = textNodes.map((t) {
        final d = int.tryParse(t.getAttribute('duration') ?? '') ?? 3;
        final audioBase = t.getAttribute('audio');
        return TextClause(
          text: _localizedText(t, languageCode),
          duration: d,
          audioUrl: _audioUrl(audioBase, audioBasePath, languageCode),
        );
      }).toList();
    }

    return BookPage(texts: texts, imagePath: '$imageBasePath$filename');
  }

  QuizQuestion _parseQuestion(
    XmlElement node,
    String languageCode,
    String imageBasePath,
    String audioBasePath,
  ) {
    final questionDuration =
        int.tryParse(node.getAttribute('duration') ?? '') ?? 6;
    final answerDuration =
        int.tryParse(node.getAttribute('answer_duration') ?? '') ?? 3;
    final audioBase = node.getAttribute('audio');
    final textNode = node.findElements('text').first;
    final text = _localizedText(textNode, languageCode);
    final filename = node.findElements('image').first.innerText.trim();
    final choices = node
        .findAllElements('choice')
        .map(
          (c) => QuizChoice(
            text: _localizedText(c, languageCode),
            isCorrect: c.getAttribute('correct') == 'true',
            audioUrl: _audioUrl(
              c.getAttribute('audio'),
              audioBasePath,
              languageCode,
            ),
          ),
        )
        .toList();

    return QuizQuestion(
      questionText: text,
      imagePath: '$imageBasePath$filename',
      choices: choices,
      questionDuration: questionDuration,
      answerDuration: answerDuration,
      audioUrl: _audioUrl(audioBase, audioBasePath, languageCode),
    );
  }
}
