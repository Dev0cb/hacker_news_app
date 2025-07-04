import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class ArticleContentService {
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };

  Future<ArticleContent?> fetchArticleContent(String url) async {
    try {
      print('ArticleContentService: Récupération du contenu de $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        return _parseArticleContent(document, url);
      } else {
        print(
            'ArticleContentService: Erreur HTTP ${response.statusCode} pour $url');
        return null;
      }
    } catch (e) {
      print(
          'ArticleContentService: Erreur lors de la récupération du contenu: $e');
      return null;
    }
  }

  ArticleContent? _parseArticleContent(Document document, String url) {
    try {
      // Extraire le titre
      String? title = _extractTitle(document);

      // Extraire la description/meta description
      String? description = _extractDescription(document);

      // Extraire l'image principale
      String? mainImage = _extractMainImage(document, url);

      // Extraire le contenu principal
      String? content = _extractMainContent(document);

      // Extraire les images du contenu
      List<String> images = _extractImages(document, url);

      // Extraire les liens du contenu
      List<String> links = _extractLinks(document, url);

      return ArticleContent(
        title: title,
        description: description,
        mainImage: mainImage,
        content: content,
        images: images,
        links: links,
        url: url,
      );
    } catch (e) {
      print('ArticleContentService: Erreur lors du parsing du contenu: $e');
      return null;
    }
  }

  String? _extractTitle(Document document) {
    // Essayer plusieurs sélecteurs pour le titre
    final selectors = [
      'meta[property="og:title"]',
      'meta[name="twitter:title"]',
      'title',
      'h1',
      '.title',
      '.headline',
      '[class*="title"]',
      '[class*="headline"]',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        String title = element.text.trim();
        if (title.isNotEmpty) {
          return title;
        }
        // Pour les meta tags
        if (element.attributes['content'] != null) {
          title = element.attributes['content']!.trim();
          if (title.isNotEmpty) {
            return title;
          }
        }
      }
    }
    return null;
  }

  String? _extractDescription(Document document) {
    // Essayer plusieurs sélecteurs pour la description
    final selectors = [
      'meta[property="og:description"]',
      'meta[name="description"]',
      'meta[name="twitter:description"]',
      '.description',
      '.summary',
      '.excerpt',
      '[class*="description"]',
      '[class*="summary"]',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        String description = element.text.trim();
        if (description.isNotEmpty) {
          return description;
        }
        // Pour les meta tags
        if (element.attributes['content'] != null) {
          description = element.attributes['content']!.trim();
          if (description.isNotEmpty) {
            return description;
          }
        }
      }
    }
    return null;
  }

  String? _extractMainImage(Document document, String baseUrl) {
    // Essayer plusieurs sélecteurs pour l'image principale
    final selectors = [
      'meta[property="og:image"]',
      'meta[name="twitter:image"]',
      'meta[property="og:image:secure_url"]',
      '.main-image img',
      '.hero-image img',
      '.featured-image img',
      '.article-image img',
      '[class*="hero"] img',
      '[class*="featured"] img',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        String? imageUrl =
            element.attributes['src'] ?? element.attributes['content'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return _makeAbsoluteUrl(imageUrl, baseUrl);
        }
      }
    }
    return null;
  }

  String? _extractMainContent(Document document) {
    // Essayer plusieurs sélecteurs pour le contenu principal
    final selectors = [
      'article',
      '.article-content',
      '.post-content',
      '.entry-content',
      '.content',
      '.main-content',
      '[class*="article"]',
      '[class*="post"]',
      '[class*="content"]',
      'main',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        // Nettoyer le contenu
        _cleanElement(element);
        String content = element.text.trim();
        if (content.length > 100) {
          // Contenu significatif
          return content;
        }
      }
    }

    // Fallback: prendre le body sans les éléments de navigation
    final body = document.body;
    if (body != null) {
      // Supprimer les éléments de navigation, header, footer
      final elementsToRemove = body.querySelectorAll(
          'nav, header, footer, .nav, .header, .footer, .sidebar, .menu');
      for (final element in elementsToRemove) {
        element.remove();
      }

      _cleanElement(body);
      String content = body.text.trim();
      if (content.length > 100) {
        return content;
      }
    }

    return null;
  }

  List<String> _extractImages(Document document, String baseUrl) {
    final images = <String>[];
    final imgElements = document.querySelectorAll('img');

    for (final img in imgElements) {
      final src = img.attributes['src'];
      if (src != null && src.isNotEmpty) {
        final absoluteUrl = _makeAbsoluteUrl(src, baseUrl);
        if (absoluteUrl != null) {
          images.add(absoluteUrl);
        }
      }
    }

    return images;
  }

  List<String> _extractLinks(Document document, String baseUrl) {
    final links = <String>[];
    final linkElements = document.querySelectorAll('a');

    for (final link in linkElements) {
      final href = link.attributes['href'];
      if (href != null && href.isNotEmpty) {
        final absoluteUrl = _makeAbsoluteUrl(href, baseUrl);
        if (absoluteUrl != null) {
          links.add(absoluteUrl);
        }
      }
    }

    return links;
  }

  void _cleanElement(Element element) {
    // Supprimer les scripts et styles
    final scripts = element.querySelectorAll('script, style, noscript');
    for (final script in scripts) {
      script.remove();
    }

    // Supprimer les éléments de navigation
    final navElements =
        element.querySelectorAll('nav, .nav, .navigation, .menu, .breadcrumb');
    for (final nav in navElements) {
      nav.remove();
    }

    // Supprimer les commentaires
    final comments = element.nodes
        .where((node) => node.nodeType == Node.COMMENT_NODE)
        .toList();
    for (final comment in comments) {
      comment.remove();
    }
  }

  String? _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (baseUrl.isNotEmpty) {
      try {
        final baseUri = Uri.parse(baseUrl);
        final resolvedUri = baseUri.resolve(url);
        return resolvedUri.toString();
      } catch (e) {
        print(
            'ArticleContentService: Erreur lors de la résolution de l\'URL $url: $e');
      }
    }

    return null;
  }
}

class ArticleContent {
  final String? title;
  final String? description;
  final String? mainImage;
  final String? content;
  final List<String> images;
  final List<String> links;
  final String url;

  ArticleContent({
    this.title,
    this.description,
    this.mainImage,
    this.content,
    required this.images,
    required this.links,
    required this.url,
  });

  bool get hasContent => content != null && content!.isNotEmpty;
  bool get hasImage => mainImage != null && mainImage!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;

  @override
  String toString() {
    return 'ArticleContent{title: $title, hasContent: $hasContent, hasImage: $hasImage, images: ${images.length}, links: ${links.length}}';
  }
}
