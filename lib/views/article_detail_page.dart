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
      appBar: AppBar(title: Text(article.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('par ${article.author}'),
            const SizedBox(height: 8),
            Text('Score : ${article.score}'),
            if (article.url != null) ...[
              const SizedBox(height: 8),
              Text('Lien :', style: Theme.of(context).textTheme.titleMedium),
              InkWell(
                child: Text(
                  article.url!,
                  style: const TextStyle(color: Colors.blue),
                ),
                onTap: () async {
                  final url = Uri.parse(article.url!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
            const Divider(height: 32),
            Text(
              'Commentaires',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: \\${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return CommentTree(comments: snapshot.data!);
                  } else {
                    return const Center(child: Text('Aucun commentaire'));
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
