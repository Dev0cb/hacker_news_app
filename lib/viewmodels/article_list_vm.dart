import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/article_repository.dart';
import '../models/article.dart';
import 'dart:developer';

final articleListProvider =
    StateNotifierProvider<ArticleListVM, AsyncValue<List<Article>>>((ref) {
      return ArticleListVM();
    });

class ArticleListVM extends StateNotifier<AsyncValue<List<Article>>> {
  final ArticleRepository _repository = ArticleRepository();

  ArticleListVM() : super(const AsyncValue.loading()) {
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      state = const AsyncValue.loading();
      final articles = await _repository.fetchArticles();
      state = AsyncValue.data(articles);
    } catch (e, st) {
      log('Erreur dans fetchArticles: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}
