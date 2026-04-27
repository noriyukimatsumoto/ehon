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

    if (isFilePath) {
      xmlString = await File(xmlPath).readAsString();
      imageBasePath = '${path.dirname(xmlPath)}/images/';
    } else {
      xmlString = await rootBundle.loadString(xmlPath);
      imageBasePath = 'assets/images/';
    }

    final document = XmlDocument.parse(xmlString);

    final pages = document
        .findAllElements('page')
        .map((n) => _parsePage(n, languageCode, imageBasePath))
        .toList();
    final questions = document
        .findAllElements('question')
        .map((n) => _parseQuestion(n, languageCode, imageBasePath))
        .toList();

    return EhonData(pages: pages, questions: questions);
  }

  /// 言語コードに対応するテキストを取得。なければ 'ja' にフォールバック。
  String _localizedText(XmlElement node, String languageCode) {
    final localized = node.findElements(languageCode).firstOrNull;
    if (localized != null) return localized.innerText.trim();
    final fallback = node.findElements('ja').firstOrNull;
    if (fallback != null) return fallback.innerText.trim();
    return node.innerText.trim();
  }

  BookPage _parsePage(
    XmlElement node,
    String languageCode,
    String imageBasePath,
  ) {
    final pageDuration = int.tryParse(node.getAttribute('duration') ?? '');
    final textNodes = node.findElements('text').toList();
    final filename = node.findElements('image').first.innerText.trim();

    final List<TextClause> texts;
    if (textNodes.length == 1 && pageDuration != null) {
      texts = [
        TextClause(
          text: _localizedText(textNodes.first, languageCode),
          duration: pageDuration,
        ),
      ];
    } else {
      texts = textNodes.map((t) {
        final d = int.tryParse(t.getAttribute('duration') ?? '') ?? 3;
        return TextClause(text: _localizedText(t, languageCode), duration: d);
      }).toList();
    }

    return BookPage(texts: texts, imagePath: '$imageBasePath$filename');
  }

  QuizQuestion _parseQuestion(
    XmlElement node,
    String languageCode,
    String imageBasePath,
  ) {
    final questionDuration =
        int.tryParse(node.getAttribute('duration') ?? '') ?? 6;
    final answerDuration =
        int.tryParse(node.getAttribute('answer_duration') ?? '') ?? 3;
    final textNode = node.findElements('text').first;
    final text = _localizedText(textNode, languageCode);
    final filename = node.findElements('image').first.innerText.trim();
    final choices = node
        .findAllElements('choice')
        .map((c) => QuizChoice(
              text: _localizedText(c, languageCode),
              isCorrect: c.getAttribute('correct') == 'true',
            ))
        .toList();

    return QuizQuestion(
      questionText: text,
      imagePath: '$imageBasePath$filename',
      choices: choices,
      questionDuration: questionDuration,
      answerDuration: answerDuration,
    );
  }
}
