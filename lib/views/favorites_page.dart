import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import 'article_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(appStateProvider).favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun favori',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des articles à vos favoris pour les retrouver ici',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final article = favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFF1A1A1A),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.author,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(article.time),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              size: 16,
                              color: Color(0xFF8B0000),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.score}',
                              style: const TextStyle(
                                color: Color(0xFF8B0000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.comment,
                              size: 16,
                              color: Color(0xFF8B0000),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.descendants}',
                              style: const TextStyle(
                                color: Color(0xFF8B0000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.star,
                        color: Color(0xFF8B0000),
                        size: 24,
                      ),
                      onPressed: () {
                        ref
                            .read(appStateProvider.notifier)
                            .removeFavorite(article.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArticleDetailPage(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(int timestamp) {
    final now = DateTime.now();
    final articleTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final difference = now.difference(articleTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'maintenant';
    }
  }
}
