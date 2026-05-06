// lib/models/comment.dart

class Comment {
  final String id;
  final String author;
  final String text;
  final DateTime createdAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    List<Comment>? replies,
  }) : replies = replies ?? [];
}
