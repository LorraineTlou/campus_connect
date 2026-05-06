// lib/providers/post_provider.dart
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [];

  List<Post> get posts => List.unmodifiable(_posts);

  void addPost(
    String content, {
    required String authorName,
    String authorRole = '',
    String avatarUrl = '',
  }) {
    _posts.insert(
      0,
      Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: authorName,
        authorRole: authorRole,
        authorAvatarUrl: avatarUrl,
        content: content.trim(),
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void toggleLike(String postId) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('not found'),
    );
    post.isLikedByMe ? post.likes-- : post.likes++;
    post.isLikedByMe = !post.isLikedByMe;
    notifyListeners();
  }

  void addComment(String postId, String text) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('not found'),
    );
    post.commentList.add(
      Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'You',
        text: text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addReply(String postId, String commentId, String text) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('not found'),
    );
    final comment = post.commentList.firstWhere(
      (c) => c.id == commentId,
      orElse: () => throw StateError('not found'),
    );
    comment.replies.add(
      Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: 'You',
        text: text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
