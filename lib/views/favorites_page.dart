import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/favorites_vm.dart';
import '../models/article.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: favoritesAsync.when(
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
        data: (favorites) => favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: Colors.white.withOpacity(0.5),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun favori',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoutez des articles à vos favoris depuis la page d\'accueil',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final Article article = favorites[index];
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
                        icon: const Icon(
                          Icons.star,
                          color: Color(0xFFFF6600),
                          size: 28,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .removeFavorite(article.id);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
