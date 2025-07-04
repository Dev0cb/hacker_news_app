import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/article_repository.dart';
import '../models/article.dart';
import '../core/app_state.dart';

class ArticleListViewModel extends StateNotifier<ArticleListState> {
  final ArticleRepository _repository;
  final Ref _ref;

  static const int _pageSize = 20; // Articles par page

  ArticleListViewModel(this._repository, this._ref)
      : super(ArticleListState.initial()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await loadArticles(page: 0, refresh: false);
  }

  Future<void> loadArticles({int page = 0, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      // Pull-to-refresh : remettre à zéro
      state = state.copyWith(isLoading: true, error: null);
      page = 0;
    } else if (page == 0) {
      // Premier chargement
      state = state.copyWith(isLoading: true, error: null);
    } else {
      // Pagination : ajouter à la liste existante
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final sortBy = _ref.read(appStateProvider).sortBy;
      final articles = await _repository.getTopStories(
        page: page,
        pageSize: _pageSize,
        sortBy: sortBy,
      );

      if (refresh || page == 0) {
        // Remplacer la liste
        state = state.copyWith(
          articles: articles,
          currentPage: page,
          isLoading: false,
          isLoadingMore: false,
          hasMore: articles.length == _pageSize,
        );
      } else {
        // Ajouter à la liste existante
        final newArticles = [...state.articles, ...articles];
        state = state.copyWith(
          articles: newArticles,
          currentPage: page,
          isLoading: false,
          isLoadingMore: false,
          hasMore: articles.length == _pageSize,
        );
      }
    } catch (e) {
      debugPrint('ArticleListViewModel: Erreur lors du chargement: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadArticles(page: 0, refresh: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    await loadArticles(page: state.currentPage + 1);
  }

  Future<void> toggleFavorite(Article article) async {
    final isFavorite = _ref.read(isFavoriteProvider(article.id));

    if (isFavorite) {
      await _ref.read(appStateProvider.notifier).removeFavorite(article.id);
    } else {
      await _ref.read(appStateProvider.notifier).addFavorite(article);
    }
  }

  void setSortBy(String sortBy) {
    if (state.sortBy != sortBy) {
      state = state.copyWith(
        sortBy: sortBy,
        articles: [],
        currentPage: 0,
        hasMore: true,
      );
      loadArticles();
    }
  }
}

class ArticleListState {
  final List<Article> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final String sortBy;

  const ArticleListState({
    required this.articles,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    required this.currentPage,
    required this.sortBy,
  });

  factory ArticleListState.initial() => const ArticleListState(
        articles: [],
        isLoading: false,
        isLoadingMore: false,
        hasMore: true,
        currentPage: 0,
        sortBy: 'score',
      );

  ArticleListState copyWith({
    List<Article>? articles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
    String? sortBy,
  }) {
    return ArticleListState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

// Provider pour le ViewModel
final articleListViewModelProvider =
    StateNotifierProvider<ArticleListViewModel, ArticleListState>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return ArticleListViewModel(repository, ref);
});
