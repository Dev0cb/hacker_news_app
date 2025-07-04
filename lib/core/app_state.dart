import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../main.dart';
import 'package:flutter/foundation.dart';

// Provider pour la persistance d'état
class AppStateNotifier extends StateNotifier<AppState> {
  final SharedPreferences _prefs;

  AppStateNotifier(this._prefs) : super(AppState.initial()) {
    _loadState();
  }

  // Charger l'état depuis SharedPreferences
  Future<void> _loadState() async {
    try {
      final favoritesJson = _prefs.getStringList('favorites') ?? [];
      final favorites = favoritesJson
          .map((json) => Article.fromJson(jsonDecode(json)))
          .toList();

      final lastRefreshTime = _prefs.getInt('lastRefreshTime') ?? 0;
      final currentPage = _prefs.getInt('currentPage') ?? 0;
      final sortBy = _prefs.getString('sortBy') ?? 'score';

      state = state.copyWith(
        favorites: favorites,
        lastRefreshTime: lastRefreshTime,
        currentPage: currentPage,
        sortBy: sortBy,
      );
    } catch (e) {
      // En cas d'erreur, garder l'état initial
      debugPrint('Erreur lors du chargement de l\'état: $e');
    }
  }

  // Sauvegarder l'état dans SharedPreferences
  Future<void> _saveState() async {
    try {
      final favoritesJson = state.favorites
          .map((article) => jsonEncode(article.toJson()))
          .toList();

      await _prefs.setStringList('favorites', favoritesJson);
      await _prefs.setInt('lastRefreshTime', state.lastRefreshTime);
      await _prefs.setInt('currentPage', state.currentPage);
      await _prefs.setString('sortBy', state.sortBy);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'état: $e');
    }
  }

  // Ajouter un favori avec optimistic update
  Future<void> addFavorite(Article article) async {
    try {
      debugPrint('AppState: Ajout de l\'article ${article.id} aux favoris');
      // Optimistic update
      final updatedFavorites = [...state.favorites, article];
      state = state.copyWith(favorites: updatedFavorites);

      // Sauvegarder
      await _saveState();
    } catch (e) {
      // Rollback en cas d'erreur
      state = state.copyWith(
        favorites: state.favorites.where((a) => a.id != article.id).toList(),
      );
      debugPrint('Erreur lors de l\'ajout du favori: $e');
    }
  }

  // Supprimer un favori avec optimistic update
  Future<void> removeFavorite(int articleId) async {
    try {
      debugPrint('AppState: Suppression de l\'article $articleId des favoris');
      final removedArticle =
          state.favorites.firstWhere((a) => a.id == articleId);

      // Optimistic update
      final updatedFavorites =
          state.favorites.where((a) => a.id != articleId).toList();
      state = state.copyWith(favorites: updatedFavorites);

      // Sauvegarder
      await _saveState();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du favori: $e');
    }
  }

  // Mettre à jour la page courante
  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
    _saveState();
  }

  // Mettre à jour le tri
  void setSortBy(String sortBy) {
    debugPrint('AppState: Changement du tri vers $sortBy');
    state = state.copyWith(sortBy: sortBy);
    _saveState();
  }

  // Mettre à jour le temps de dernier refresh
  void setLastRefreshTime(int timestamp) {
    state = state.copyWith(lastRefreshTime: timestamp);
    _saveState();
  }
}

// État global de l'application
class AppState {
  final List<Article> favorites;
  final int lastRefreshTime;
  final int currentPage;
  final String sortBy;
  final bool isLoading;
  final String? error;

  const AppState({
    required this.favorites,
    required this.lastRefreshTime,
    required this.currentPage,
    required this.sortBy,
    this.isLoading = false,
    this.error,
  });

  factory AppState.initial() => const AppState(
        favorites: [],
        lastRefreshTime: 0,
        currentPage: 0,
        sortBy: 'score',
      );

  AppState copyWith({
    List<Article>? favorites,
    int? lastRefreshTime,
    int? currentPage,
    String? sortBy,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      favorites: favorites ?? this.favorites,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      currentPage: currentPage ?? this.currentPage,
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Provider pour l'état global
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppStateNotifier(prefs);
});

// Provider pour les favoris
final favoritesProvider = Provider<List<Article>>((ref) {
  return ref.watch(appStateProvider).favorites;
});

// Provider pour vérifier si un article est favori
final isFavoriteProvider = Provider.family<bool, int>((ref, articleId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((article) => article.id == articleId);
});
