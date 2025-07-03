import 'package:flutter/material.dart';
import '../models/article.dart';
import '../data/api/hacker_news_api.dart';
import '../widgets/comment_tree.dart';
import '../models/comment.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _loadComments();
  }

  Future<List<Comment>> _loadComments() async {
    Article article = widget.article;
    if (article.commentIds.isEmpty) {
      // Recharge l'article depuis l'API pour avoir les commentIds
      final apiArticle = await HackerNewsApi().fetchArticle(article.id);
      if (apiArticle != null && apiArticle.commentIds.isNotEmpty) {
        article = apiArticle;
      }
    }
    if (article.commentIds.isEmpty) {
      return [];
    }
    return await HackerNewsApi().fetchComments(article.commentIds);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title.length > 30
              ? '${article.title.substring(0, 30)}...'
              : article.title,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article content card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            article.author,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Icon(
                          Icons.trending_up,
                          color: Colors.white.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: ${article.score}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (article.url != null) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: const Color(0xFFFF6600),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Lien de l\'article:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final url = Uri.parse(article.url!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6600).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFF6600),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  article.url!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6600),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.open_in_new,
                                color: Color(0xFFFF6600),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Comments section
            Row(
              children: [
                Icon(Icons.comment, color: const Color(0xFFFF6600), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Commentaires (${article.descendants})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400, // Fixed height for comments
              child: FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6600),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            color: Color(0xFFFF6600),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return CommentTree(comments: snapshot.data!);
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            color: Colors.white.withOpacity(0.5),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun commentaire',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
