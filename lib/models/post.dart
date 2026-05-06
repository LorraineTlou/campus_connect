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
    int? comments, // for backward compatibility in constructor
    this.imageUrl,
  }) : commentList = commentList ?? (comments != null ? List.generate(comments, (_) => Comment(id: '', author: '', text: '', createdAt: DateTime.now())) : []);

  // Convenience getter so PostCard can show a count without breaking old code
  int get commentCount => commentList.length;
  int get comments => commentCount; // Added for compatibility with PostCard

  // Derive initials from authorName for Team 4-style avatars
  String get avatarInitials => authorName.trim().isEmpty
      ? '?'
      : authorName
            .trim()
            .split(' ')
            .map((e) => e[0].toUpperCase())
            .take(2)
            .join();

  static const dummy = null; // Placeholder to avoid empty class body if others were removed
}
