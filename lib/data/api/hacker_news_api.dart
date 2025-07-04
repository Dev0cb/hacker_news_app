// Exemple d'endpoint : https://hacker-news.firebaseio.com/v0/item/8863.json

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/article.dart';
import '../../models/comment.dart';

class HackerNewsApi {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0';

  Future<List<Article>> fetchTopStories({int limit = 20}) async {
    try {
      final idsResp = await http.get(Uri.parse('$_baseUrl/topstories.json'));
      if (idsResp.statusCode != 200) {
        throw Exception('Erreur HTTP: ${idsResp.statusCode}');
      }
      final List ids = json.decode(idsResp.body);

      final futures = ids.take(limit).map((id) => fetchArticle(id));
      final articles = await Future.wait(futures);
      final validArticles = articles.whereType<Article>().toList();

      return validArticles;
    } catch (e) {
      print('HackerNewsApi: error in fetchTopStories: $e');
      throw Exception('Erreur lors du chargement des articles: $e');
    }
  }

  Future<Article?> fetchArticle(int id) async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data != null && data['type'] == 'story') {
          // Si les kids ne sont pas présents, faire un appel séparé
          if (data['kids'] == null) {
            final kidsResp =
                await http.get(Uri.parse('$_baseUrl/item/$id.json'));
            if (kidsResp.statusCode == 200) {
              final kidsData = json.decode(kidsResp.body);
              data['kids'] = kidsData['kids'];
            }
          }

          final article = Article.fromJson(data);
          return article;
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors du chargement de l\'article $id: $e');
      return null;
    }
  }

  Future<List<Comment>> fetchComments(List<int> ids) async {
    try {
      print('HackerNewsApi: Chargement de ${ids.length} commentaires');
      List<Comment> comments = [];

      // Utiliser Future.wait pour charger les commentaires en parallèle
      final futures = ids.map((id) async {
        try {
          final resp = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body);
            if (data != null &&
                data['type'] == 'comment' &&
                data['deleted'] != true &&
                data['dead'] != true) {
              final comment = Comment.fromJson(data);
              print(
                  'HackerNewsApi: Commentaire chargé: ${comment.id} par ${comment.author}');
              return comment;
            } else {
              print(
                  'HackerNewsApi: Commentaire $id ignoré (type: ${data?['type']}, deleted: ${data?['deleted']}, dead: ${data?['dead']})');
            }
          } else {
            print(
                'HackerNewsApi: Erreur HTTP ${resp.statusCode} pour le commentaire $id');
          }
        } catch (e) {
          print(
              'HackerNewsApi: Erreur lors du chargement du commentaire $id: $e');
        }
        return null;
      });

      final results = await Future.wait(futures);
      comments = results.whereType<Comment>().toList();

      print(
          'HackerNewsApi: ${comments.length} commentaires chargés avec succès');
      return comments;
    } catch (e) {
      print('HackerNewsApi: Erreur lors du chargement des commentaires: $e');
      return [];
    }
  }

  Future<List<Comment>> fetchCommentReplies(List<int> ids) async {
    try {
      List<Comment> comments = [];
      for (final id in ids) {
        try {
          final resp = await http.get(Uri.parse('$_baseUrl/item/$id.json'));
          if (resp.statusCode == 200) {
            final data = json.decode(resp.body);
            if (data != null &&
                data['type'] == 'comment' &&
                data['deleted'] != true &&
                data['dead'] != true) {
              final comment = Comment.fromJson(data);
              // Charger les sous-commentaires récursivement pour les réponses
              final children = data['kids'] != null
                  ? await fetchCommentReplies(List<int>.from(data['kids']))
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
        } catch (e) {
          print('Erreur lors du chargement de la réponse $id: $e');
          // Continuer avec les autres réponses
        }
      }
      return comments;
    } catch (e) {
      print('Erreur lors du chargement des réponses: $e');
      return [];
    }
  }
}
