// if exists in DB -> load local else fetch from API and save

import '../api/hacker_news_api.dart';
import '../db/database_helper.dart';
import '../../models/article.dart';

class ArticleRepository {
  final _dbHelper = DatabaseHelper.instance;
  final _api = HackerNewsApi();

  Future<List<Article>> fetchArticles() async {
    // Essayer de charger depuis la DB
    final local = await _dbHelper.getArticles();
    if (local.isNotEmpty) return local;
    // Sinon, charger depuis l'API
    final remote = await _api.fetchTopStories();
    for (final article in remote) {
      await _dbHelper.insertArticle(article);
    }
    return remote;
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

// Note: Il faut implémenter HackerNewsApi dans api/hacker_news_api.dart
