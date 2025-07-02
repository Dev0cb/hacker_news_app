class Article {
  final int id;
  final String title;
  final String author;
  final int time;
  final String? url;
  final int score;
  final int descendants;
  final List<int> commentIds;

  Article({
    required this.id,
    required this.title,
    required this.author,
    required this.time,
    this.url,
    required this.score,
    required this.descendants,
    required this.commentIds,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['by'] ?? json['author'] ?? '',
      time: json['time'],
      url: json['url'],
      score: json['score'] ?? 0,
      descendants: json['descendants'] ?? 0,
      commentIds: json['kids'] != null ? List<int>.from(json['kids']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'time': time,
      'url': url,
      'score': score,
      'descendants': descendants,
      // 'kids': commentIds, // Ne pas inclure dans SQLite
    };
  }
}
