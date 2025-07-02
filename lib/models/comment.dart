class Comment {
  final int id;
  final String author;
  final int time;
  final String? text;
  final int parent;
  final List<int> childIds;
  final List<Comment> children;

  Comment({
    required this.id,
    required this.author,
    required this.time,
    this.text,
    required this.parent,
    required this.childIds,
    this.children = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      author: json['by'] ?? '',
      time: json['time'],
      text: json['text'],
      parent: json['parent'],
      childIds: json['kids'] != null ? List<int>.from(json['kids']) : [],
      children: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'by': author,
      'time': time,
      'text': text,
      'parent': parent,
      'kids': childIds,
    };
  }
}
