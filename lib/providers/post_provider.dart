// lib/providers/post_provider.dart
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [
    Post(
      id: 'p1',
      authorName: 'Dr. Sarah Smith',
      authorRole: 'Faculty of Engineering',
      authorAvatarUrl: '',
      content: 'Welcome back to campus, students! Remember that the library is now open 24/7 during the exam period. Good luck with your studies!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 24,
    ),
    Post(
      id: 'p2',
      authorName: 'Alex Johnson',
      authorRole: 'Computer Science, Year 3',
      authorAvatarUrl: '',
      content: 'Does anyone have the notes for the mobile app development lecture from yesterday? I missed it due to a doctor\'s appointment.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 5,
    ),
    Post(
      id: 'p3',
      authorName: 'NUST Sports Club',
      authorRole: 'Official Organization',
      authorAvatarUrl: '',
      content: 'Soccer tryouts are happening this Friday at 4 PM on the main field. All skill levels are welcome! ⚽️',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 42,
    ),
  ];

  List<Post> get posts => List.unmodifiable(_posts);

  void addPost(
    String content, {
    required String authorName,
    String authorRole = '',
    String avatarUrl = '',
    String? imagePath,
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
        imagePath: imagePath,
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
