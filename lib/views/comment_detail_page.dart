import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../data/api/hacker_news_api.dart';
import '../widgets/comment_tree.dart';
import '../widgets/formatted_text.dart';

class CommentDetailPage extends StatefulWidget {
  final Comment comment;
  final String articleTitle;
  final List<Comment> breadcrumb;

  const CommentDetailPage({
    super.key,
    required this.comment,
    required this.articleTitle,
    this.breadcrumb = const [],
  });

  @override
  State<CommentDetailPage> createState() => _CommentDetailPageState();
}

class _CommentDetailPageState extends State<CommentDetailPage> {
  late Future<List<Comment>> _repliesFuture;

  @override
  void initState() {
    super.initState();
    _repliesFuture = _loadReplies();
  }

  Future<List<Comment>> _loadReplies() async {
    if (widget.comment.childIds.isEmpty) {
      return [];
    }
    return await HackerNewsApi().fetchCommentReplies(widget.comment.childIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaire'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb navigation
            if (widget.breadcrumb.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF8B0000).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.article,
                          color: const Color(0xFF8B0000),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.articleTitle,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.breadcrumb.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...widget.breadcrumb.asMap().entries.map((entry) {
                        final index = entry.key;
                        final comment = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(left: index * 16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                color: Colors.white.withOpacity(0.5),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${comment.author}: ${comment.text?.substring(0, comment.text!.length > 50 ? 50 : comment.text!.length)}${comment.text!.length > 50 ? '...' : ''}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Main comment
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8B0000), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000).withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: const Color(0xFF8B0000),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.comment.author,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.schedule,
                          color: Colors.white.withOpacity(0.5),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(widget.comment.time),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.comment.text != null &&
                      widget.comment.text!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FormattedText(
                        text: widget.comment.text!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        enableLinks: true,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '[Commentaire supprimé]',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Replies section
            Row(
              children: [
                Icon(Icons.reply, color: const Color(0xFF8B0000), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Réponses (${widget.comment.childIds.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Replies list
            SizedBox(
              height: 400,
              child: FutureBuilder<List<Comment>>(
                future: _repliesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B0000),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            color: Color(0xFF8B0000),
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
                    return ListView(
                      children: snapshot.data!
                          .map((reply) => _buildReplyTile(reply))
                          .toList(),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.reply_outlined,
                            color: Colors.white.withOpacity(0.5),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune réponse',
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

  Widget _buildReplyTile(Comment reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Row(
          children: [
            Icon(Icons.person, color: const Color(0xFF8B0000), size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                reply.author,
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
              color: Colors.white.withOpacity(0.5),
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              _formatTime(reply.time),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (reply.text != null && reply.text!.isNotEmpty)
              Text(
                reply.text!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                '[Commentaire supprimé]',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (reply.childIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.reply,
                    color: Colors.white.withOpacity(0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reply.childIds.length} réponses',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        onTap: () {
          if (reply.childIds.isNotEmpty) {
            final newBreadcrumb = [...widget.breadcrumb, widget.comment];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CommentDetailPage(
                  comment: reply,
                  articleTitle: widget.articleTitle,
                  breadcrumb: newBreadcrumb,
                ),
              ),
            );
          }
        },
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
