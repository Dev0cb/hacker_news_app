import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../core/app_state.dart';
import '../widgets/comment_tree.dart';
import '../widgets/article_content_view.dart';
import 'comment_detail_page.dart';

class ArticleDetailPage extends ConsumerWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(article.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_outline,
              color: isFav
                  ? const Color(0xFF8B0000)
                  : Colors.white.withValues(alpha: 0.7),
              size: 32,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (isFav) {
                ref.read(appStateProvider.notifier).removeFavorite(article.id);
              } else {
                ref.read(appStateProvider.notifier).addFavorite(article);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de l'article
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Métadonnées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person,
                            color: Color(0xFF8B0000), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'par ${article.author}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.trending_up,
                            color: Color(0xFF8B0000), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Score: ${article.score}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment,
                            color: Color(0xFF8B0000), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${article.descendants} commentaires',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton pour ouvrir le lien
            if (article.url != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final url = Uri.parse(article.url!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ouvrir l\'article'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Contenu de l'article
            if (article.url != null) ...[
              const Text(
                'Contenu de l\'article',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ArticleContentView(
                url: article.url!,
                articleTitle: article.title,
              ),
              const SizedBox(height: 24),
            ],

            // Section commentaires
            const Text(
              'Commentaires',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Arbre de commentaires
            CommentTree(
              commentIds: article.commentIds,
              onCommentTap: (comment) {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentDetailPage(
                      comment: comment,
                      articleTitle: article.title,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
