class Post {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String? imageUrl;

  const Post({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.imageUrl,
  });
}
