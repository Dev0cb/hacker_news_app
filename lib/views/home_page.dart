import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../viewmodels/article_list_vm.dart';
import '../core/app_state.dart';
import '../widgets/skeleton_loading.dart';
import 'article_detail_page.dart';
import 'favorites_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(articleListViewModelProvider.notifier).loadMore();
    }
  }

  void _toggleFavorite(Article article) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    await ref
        .read(articleListViewModelProvider.notifier)
        .toggleFavorite(article);
  }

  void _showSortDialog() {
    final currentSort = ref.read(appStateProvider).sortBy;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Trier par', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('score', 'Score', currentSort),
            _buildSortOption('time', 'Plus récents', currentSort),
            _buildSortOption('comments', 'Plus commentés', currentSort),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, String currentSort) {
    final isSelected = currentSort == value;
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? const Color(0xFF8B0000) : Colors.white70,
      ),
      onTap: () {
        Navigator.pop(context);
        ref.read(articleListViewModelProvider.notifier).setSortBy(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleListViewModelProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacker News'),
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(articleListViewModelProvider.notifier).refresh(),
        color: const Color(0xFF8B0000),
        child: _buildBody(state, favorites),
      ),
    );
  }

  Widget _buildBody(ArticleListState state, List<Article> favorites) {
    if (state.isLoading && state.articles.isEmpty) {
      return _buildSkeletonList();
    }

    if (state.error != null && state.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Color(0xFF8B0000), size: 64),
            const SizedBox(height: 16),
            Text(
              'Erreur: ${state.error}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(articleListViewModelProvider.notifier).refresh(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return _buildLoadMoreIndicator(state);
        }

        final article = state.articles[index];
        final isFav = favorites.any((fav) => fav.id == article.id);

        return _buildArticleCard(article, isFav);
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => const ArticleSkeleton(),
    );
  }

  Widget _buildLoadMoreIndicator(ArticleListState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B0000)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildArticleCard(Article article, bool isFav) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailPage(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_outline,
                      color: isFav
                          ? const Color(0xFF8B0000)
                          : Colors.white.withValues(alpha: 0.7),
                      size: 32,
                    ),
                    onPressed: () => _toggleFavorite(article),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    'par ${article.author}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Score: ${article.score}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${article.descendants} commentaires',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
