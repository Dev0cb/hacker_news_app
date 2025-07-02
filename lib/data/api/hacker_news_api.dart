// Exemple d'endpoint : https://hacker-news.firebaseio.com/v0/item/8863.json

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/article.dart';
import '../../models/comment.dart';

class HackerNewsApi {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0';

  Future<List<Article>> fetchTopStories({int limit = 20}) async {
    final idsResp = await http.get(Uri.parse('$_baseUrl/topstories.json'));
    final List ids = json.decode(idsResp.body);
    final futures = ids.take(limit).map((id) => fetchArticle(id));
    final articles = await Future.wait(futures);
    return articles.whereType<Article>().toList();
  }

  Future<Article?> fetchArticle(int id) async {
    final resp = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data['type'] == 'story') {
        return Article.fromJson(data);
      }
    }
    return null;
  }

  Future<List<Comment>> fetchComments(List<int> ids) async {
    List<Comment> comments = [];
    for (final id in ids) {
      final resp = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['type'] == 'comment') {
          final comment = Comment.fromJson(data);
          // Charger les sous-commentaires récursivement
          final children = data['kids'] != null
              ? await fetchComments(List<int>.from(data['kids']))
              : [];
          comments.add(
            Comment(
              id: comment.id,
              author: comment.author,
              time: comment.time,
              text: comment.text,
              parent: comment.parent,
              childIds: comment.childIds,
              children: List<Comment>.from(children),
            ),
          );
        }
      }
    }
    return comments;
  }
}
