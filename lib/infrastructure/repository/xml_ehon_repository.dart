import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../../domain/entity/book_page.dart';
import '../../domain/repository/ehon_repository.dart';

class XmlEhonRepository implements EhonRepository {
  const XmlEhonRepository();

  @override
  Future<List<BookPage>> fetchPages(String xmlPath) async {
    final xmlString = await rootBundle.loadString(xmlPath);
    final document = XmlDocument.parse(xmlString);
    return document
        .findAllElements('page')
        .map(
          (node) => BookPage(
            text: node.findElements('text').first.innerText.trim(),
            image: node.findElements('image').first.innerText.trim(),
            duration: int.parse(node.getAttribute('duration') ?? '5'),
          ),
        )
        .toList();
  }
}
