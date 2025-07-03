import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/article_list_vm.dart';
import '../models/article.dart';
import '../viewmodels/favorites_vm.dart';
import 'favorites_page.dart';
import 'article_detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articleListProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacker News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FavoritesPage()));
            },
          ),
        ],
      ),
      body: articlesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6600)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Color(0xFFFF6600), size: 64),
              const SizedBox(height: 16),
              Text('Erreur: $e', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        data: (articles) => favoritesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6600)),
          ),
          error: (e, _) => Center(
            child: Text(
              'Erreur favoris: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (favorites) => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final Article article = articles[index];
              final isFav = favorites.any((a) => a.id == article.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  article.author,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.comment,
                                size: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${article.descendants}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${article.score}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav
                          ? const Color(0xFFFF6600)
                          : Colors.white.withOpacity(0.7),
                      size: 28,
                    ),
                    onPressed: () {
                      final favVM = ref.read(favoritesProvider.notifier);
                      if (isFav) {
                        favVM.removeFavorite(article.id);
                      } else {
                        favVM.addFavorite(article.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailPage(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
