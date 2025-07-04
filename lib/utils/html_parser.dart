import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class HtmlParser {
  /// Parse le HTML d'un commentaire et retourne le texte formaté
  static String parseCommentHtml(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return '';
    }

    try {
      final document = html_parser.parse(htmlText);
      return _parseElement(document.body ?? document.documentElement!);
    } catch (e) {
      debugPrint('HtmlParser: Erreur lors du parsing HTML: $e');
      return htmlText; // Retourner le texte original en cas d'erreur
    }
  }

  /// Parse récursivement un élément HTML
  static String _parseElement(Element element) {
    String result = '';

    for (final node in element.nodes) {
      if (node.nodeType == Node.TEXT_NODE) {
        result += node.text ?? '';
      } else if (node.nodeType == Node.ELEMENT_NODE) {
        final element = node as Element;
        result += _parseHtmlElement(element);
      }
    }

    return result;
  }

  /// Parse un élément HTML spécifique
  static String _parseHtmlElement(Element element) {
    final tagName = element.localName?.toLowerCase() ?? '';
    final text = _parseElement(element);

    switch (tagName) {
      case 'p':
        return '$text\n\n';
      case 'br':
        return '\n';
      case 'div':
        return '$text\n';
      case 'span':
        return text;
      case 'strong':
      case 'b':
        return '**$text**';
      case 'em':
      case 'i':
        return '*$text*';
      case 'code':
        return '`$text`';
      case 'pre':
        return '\n```\n$text\n```\n';
      case 'a':
        final href = element.attributes['href'];
        if (href != null && href.isNotEmpty) {
          return '[$text]($href)';
        }
        return text;
      case 'ul':
      case 'ol':
        return _parseList(element);
      case 'li':
        return '• $text\n';
      case 'blockquote':
        return '\n> $text\n';
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final level = int.parse(tagName.substring(1));
        final prefix = '#' * level;
        return '\n$prefix $text\n';
      default:
        return text;
    }
  }

  /// Parse une liste (ul/ol)
  static String _parseList(Element listElement) {
    String result = '\n';
    final items = listElement.querySelectorAll('li');

    for (final item in items) {
      result += '• ${_parseElement(item).trim()}\n';
    }

    return result;
  }

  /// Nettoie le texte en supprimant les espaces en trop
  static String cleanText(String text) {
    // Remplacer les espaces multiples par un seul espace
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Supprimer les espaces au début et à la fin
    text = text.trim();

    // Supprimer les lignes vides multiples
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    return text;
  }

  /// Extrait les liens d'un texte HTML
  static List<String> extractLinks(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return [];
    }

    try {
      final document = html_parser.parse(htmlText);
      final links = <String>[];

      for (final link in document.querySelectorAll('a')) {
        final href = link.attributes['href'];
        if (href != null && href.isNotEmpty) {
          links.add(href);
        }
      }

      return links;
    } catch (e) {
      debugPrint('HtmlParser: Erreur lors de l\'extraction des liens: $e');
      return [];
    }
  }

  /// Extrait les images d'un texte HTML
  static List<String> extractImages(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return [];
    }

    try {
      final document = html_parser.parse(htmlText);
      final images = <String>[];

      for (final img in document.querySelectorAll('img')) {
        final src = img.attributes['src'];
        if (src != null && src.isNotEmpty) {
          images.add(src);
        }
      }

      return images;
    } catch (e) {
      debugPrint('HtmlParser: Erreur lors de l\'extraction des images: $e');
      return [];
    }
  }
}
