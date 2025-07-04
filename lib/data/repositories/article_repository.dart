// if exists in DB -> load local else fetch from API and save

import '../api/hacker_news_api.dart';
import '../db/database_helper.dart';
import '../../models/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleRepository {
  final _dbHelper = DatabaseHelper.instance;
  final _api = HackerNewsApi();

  Future<List<Article>> fetchArticles() async {
    // Toujours charger depuis l'API pour avoir les commentIds
    final remote = await _api.fetchTopStories();
    // Sauvegarder en DB pour le cache (sans commentIds)
    for (final article in remote) {
      await _dbHelper.insertArticle(article);
    }
    return remote;
  }

  // Nouvelle méthode avec pagination et tri
  Future<List<Article>> getTopStories({
    int page = 0,
    int pageSize = 20,
    String sortBy = 'score',
  }) async {
    try {
      // Toujours charger depuis l'API pour avoir les commentIds
      final remote = await _api.fetchTopStories();

      // Trier selon le critère
      List<Article> sortedArticles = _sortArticles(remote, sortBy);

      // Paginer
      final startIndex = page * pageSize;
      final paginatedArticles =
          sortedArticles.skip(startIndex).take(pageSize).toList();

      // Sauvegarder en DB pour le cache (sans commentIds)
      for (final article in paginatedArticles) {
        await _dbHelper.insertArticle(article);
      }

      return paginatedArticles;
    } catch (e) {
      print('ArticleRepository: error loading articles: $e');
      throw Exception('Erreur lors du chargement des articles: $e');
    }
  }

  // Méthode de tri
  List<Article> _sortArticles(List<Article> articles, String sortBy) {
    switch (sortBy) {
      case 'score':
        articles.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'time':
        articles.sort((a, b) => b.time.compareTo(a.time));
        break;
      case 'comments':
        articles.sort((a, b) => b.descendants.compareTo(a.descendants));
        break;
      default:
        articles.sort((a, b) => b.score.compareTo(a.score));
    }
    return articles;
  }

  Future<void> addFavori(int id) => _dbHelper.addFavori(id);
  Future<void> removeFavori(int id) => _dbHelper.removeFavori(id);
  Future<List<int>> getFavoris() => _dbHelper.getFavoris();

  Future<void> cleanObsoleteArticles() async {
    await _dbHelper.cleanObsoleteArticles((id) async {
      final article = await _api.fetchArticle(id);
      return article != null;
    });
  }
}

// Provider pour le repository
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});

// Note: Il faut implémenter HackerNewsApi dans api/hacker_news_api.dart
