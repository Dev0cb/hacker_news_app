import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentTree extends StatelessWidget {
  final List<Comment> comments;
  const CommentTree({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: comments.map((c) => _buildComment(context, c, 0)).toList(),
    );
  }

  Widget _buildComment(BuildContext context, Comment comment, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFF6600).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6600).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: const Color(0xFFFF6600),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      comment.author,
                      style: const TextStyle(
                        color: Color(0xFFFF6600),
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
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(comment.time),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (comment.text != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  comment.text!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            if (comment.children.isNotEmpty)
              ...comment.children
                  .map((child) => _buildComment(context, child, depth + 1))
                  ,
          ],
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
