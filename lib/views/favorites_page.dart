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
      appBar: AppBar(title: const Text('Favoris')),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (favorites) => favorites.isEmpty
            ? const Center(child: Text('Aucun favori'))
            : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final Article article = favorites[index];
                  return ListTile(
                    title: Text(article.title),
                    subtitle: Text(
                      'par ${article.author} • ${article.descendants} commentaires',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      onPressed: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .removeFavorite(article.id);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
