import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../data/api/hacker_news_api.dart';
import '../views/comment_detail_page.dart';
import '../widgets/formatted_text.dart';

class CommentTree extends ConsumerWidget {
  final List<int> commentIds;
  final Function(Comment)? onCommentTap;
  final String? articleTitle;
  final List<Comment> breadcrumb;

  const CommentTree({
    super.key,
    required this.commentIds,
    this.onCommentTap,
    this.articleTitle,
    this.breadcrumb = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (commentIds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              color: Color(0xFF8B0000),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun commentaire',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Comment>>(
      future: HackerNewsApi().fetchComments(commentIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF8B0000)),
                SizedBox(height: 16),
                Text(
                  'Chargement des commentaires...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Color(0xFF8B0000), size: 64),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Recharger les commentaires
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentTree(
                          commentIds: commentIds,
                          onCommentTap: onCommentTap,
                          articleTitle: articleTitle,
                          breadcrumb: breadcrumb,
                        ),
                      ),
                    );
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: Color(0xFF8B0000),
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Aucun commentaire disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Commentaires (${comments.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...comments.map((comment) => _buildComment(context, comment, 0)),
          ],
        );
      },
    );
  }

  Widget _buildComment(BuildContext context, Comment comment, int depth) {
    // Vérifier si le commentaire a du contenu à afficher
    final hasContent = comment.text != null && comment.text!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
      child: GestureDetector(
        onTap: comment.childIds.isNotEmpty
            ? () {
                if (onCommentTap != null) {
                  onCommentTap!(comment);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommentDetailPage(
                        comment: comment,
                        articleTitle: articleTitle ?? 'Article',
                        breadcrumb: breadcrumb,
                      ),
                    ),
                  );
                }
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF8B0000).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFF8B0000),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        comment.author,
                        style: const TextStyle(
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.schedule,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(comment.time),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    if (comment.childIds.isNotEmpty) ...[
                      const Spacer(),
                      Icon(
                        Icons.reply,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.childIds.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ),
              if (hasContent)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FormattedText(
                    text: comment.text!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    enableLinks: true,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '[Commentaire supprimé]',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final now = DateTime.now();
    final commentTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final difference = now.difference(commentTime);

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
