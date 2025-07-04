// if exists in DB -> load local else fetch from API and save

import '../api/hacker_news_api.dart';
import '../db/database_helper.dart';
import '../../models/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class ArticleRepository {
  final _dbHelper = DatabaseHelper.instance;
  final _api = HackerNewsApi();

  Future<List<Article>> getTopStories({
    int page = 0,
    int pageSize = 20,
    String sortBy = 'score',
  }) async {
    try {
      // Charger depuis l'API
      final remote = await _api.fetchTopStories();

      // Trier selon le critère
      List<Article> sortedArticles = _sortArticles(remote, sortBy);

      // Paginer
      final startIndex = page * pageSize;
      final paginatedArticles =
          sortedArticles.skip(startIndex).take(pageSize).toList();

      // Sauvegarder en DB
      if (paginatedArticles.isNotEmpty) {
        await _dbHelper.insertArticles(paginatedArticles);
      }

      return paginatedArticles;
    } catch (e) {
      debugPrint(
          'ArticleRepository: Erreur lors du chargement des articles: $e');

      // En cas d'erreur, essayer de charger depuis la DB
      try {
        return await _dbHelper.getArticles(
          limit: pageSize,
          offset: page * pageSize,
          sortBy: sortBy,
        );
      } catch (dbError) {
        debugPrint('ArticleRepository: Erreur DB: $dbError');
        return [];
      }
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

  Future<List<Article>> getFavorites() async {
    try {
      return await _dbHelper.getFavorites();
    } catch (e) {
      debugPrint(
          'ArticleRepository: Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  Future<void> toggleFavorite(int articleId, bool isFavorite) async {
    try {
      await _dbHelper.toggleFavorite(articleId, isFavorite);
    } catch (e) {
      debugPrint('ArticleRepository: Erreur lors du toggle favori: $e');
    }
  }
}

// Provider pour le repository
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});

// Note: Il faut implémenter HackerNewsApi dans api/hacker_news_api.dart
