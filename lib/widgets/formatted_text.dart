import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/html_parser.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool enableLinks;

  const FormattedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.enableLinks = true,
  });

  @override
  Widget build(BuildContext context) {
    final parsedText = HtmlParser.parseCommentHtml(text);
    final cleanedText = HtmlParser.cleanText(parsedText);

    if (!enableLinks) {
      return Text(
        cleanedText,
        style: style,
        textAlign: textAlign,
      );
    }

    return _buildFormattedText(context, cleanedText);
  }

  Widget _buildFormattedText(BuildContext context, String text) {
    final spans = <TextSpan>[];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // Détecter les liens [texte](url)
      final linkMatch = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(word);
      if (linkMatch != null) {
        final linkText = linkMatch.group(1)!;
        final linkUrl = linkMatch.group(2)!;

        spans.add(TextSpan(
          text: linkText,
          style: (style ?? const TextStyle()).copyWith(
            color: const Color(0xFF8B0000),
            decoration: TextDecoration.underline,
          ),
        ));

        // Ajouter un espace après le lien
        if (i < words.length - 1) {
          spans.add(const TextSpan(text: ' '));
        }

        // Créer un widget séparé pour le lien cliquable
        continue;
      }
      // Détecter le gras **texte**
      else if (word.startsWith('**') && word.endsWith('**')) {
        final boldText = word.substring(2, word.length - 2);
        spans.add(TextSpan(
          text: boldText,
          style: (style ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      // Détecter l'italique *texte*
      else if (word.startsWith('*') && word.endsWith('*') && word.length > 2) {
        final italicText = word.substring(1, word.length - 1);
        spans.add(TextSpan(
          text: italicText,
          style: (style ?? const TextStyle()).copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      // Détecter le code `texte`
      else if (word.startsWith('`') && word.endsWith('`')) {
        final codeText = word.substring(1, word.length - 1);
        spans.add(TextSpan(
          text: codeText,
          style: (style ?? const TextStyle()).copyWith(
            fontFamily: 'monospace',
            backgroundColor: const Color(0xFF2A2A2A),
            color: const Color(0xFF8B0000),
          ),
        ));
      }
      // Détecter les URLs directes
      else if (_isUrl(word)) {
        spans.add(TextSpan(
          text: word,
          style: (style ?? const TextStyle()).copyWith(
            color: const Color(0xFF8B0000),
            decoration: TextDecoration.underline,
          ),
        ));
      }
      // Texte normal
      else {
        spans.add(TextSpan(
          text: word,
          style: style,
        ));
      }

      // Ajouter un espace entre les mots (sauf pour le dernier)
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  bool _isUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }
}
