import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/article_repository.dart';
import '../models/article.dart';
import 'dart:developer';

final favoritesProvider =
    StateNotifierProvider<FavoritesVM, AsyncValue<List<Article>>>((ref) {
      return FavoritesVM();
    });

class FavoritesVM extends StateNotifier<AsyncValue<List<Article>>> {
  final ArticleRepository _repository = ArticleRepository();

  FavoritesVM() : super(const AsyncValue.loading()) {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      state = const AsyncValue.loading();
      final allArticles = await _repository.fetchArticles();
      final favIds = await _repository.getFavoris();
      final favs = allArticles.where((a) => favIds.contains(a.id)).toList();
      state = AsyncValue.data(favs);
    } catch (e, st) {
      log('Erreur dans fetchFavorites: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFavorite(int id) async {
    await _repository.addFavori(id);
    await fetchFavorites();
  }

  Future<void> removeFavorite(int id) async {
    await _repository.removeFavori(id);
    await fetchFavorites();
  }

  Future<bool> isFavorite(int id) async {
    final favIds = await _repository.getFavoris();
    return favIds.contains(id);
  }
}
