// lib/models/post.dart
import 'comment.dart';

class Post {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;
  int likes;
  bool isLikedByMe;
  List<Comment> commentList; // renamed from 'comments' (was int)
  final String? imageUrl;

  Post({
    required this.id,
    required this.authorName,
    this.authorRole = '',
    this.authorAvatarUrl = '',
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.isLikedByMe = false,
    List<Comment>? commentList,
    this.imageUrl,
  }) : commentList = commentList ?? [];

  // Convenience getter so PostCard can show a count without breaking old code
  int get commentCount => commentList.length;

  // Derive initials from authorName for Team 4-style avatars
  String get avatarInitials => authorName.trim().isEmpty
      ? '?'
      : authorName
            .trim()
            .split(' ')
            .map((e) => e[0].toUpperCase())
            .take(2)
            .join();
}
