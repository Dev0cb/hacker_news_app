import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentTree extends StatelessWidget {
  final List<Comment> comments;
  const CommentTree({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return _buildComment(context, comments[index], 0);
      },
    );
  }

  Widget _buildComment(BuildContext context, Comment comment, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (comment.text != null) Text(comment.text!),
              ],
            ),
          ),
          if (comment.children.isNotEmpty)
            CommentTree(comments: comment.children),
        ],
      ),
    );
  }
}
