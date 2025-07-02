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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (articles) => favoritesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur favoris: $e')),
          data: (favorites) => ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final Article article = articles[index];
              final isFav = favorites.any((a) => a.id == article.id);
              return ListTile(
                title: Text(article.title),
                subtitle: Text(
                  'par ${article.author} • ${article.descendants} commentaires',
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : null,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
