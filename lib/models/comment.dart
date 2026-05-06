// lib/models/comment.dart

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.replies = const [],
  });
}
