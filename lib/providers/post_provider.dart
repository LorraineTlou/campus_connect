// lib/providers/post_provider.dart
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [
    Post(
      id: '1',
      authorName: 'Lorraine Tlou',
      authorRole: 'CS Student',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=lorraine',
      content:
          'Just finished the final project for Mobile Dev! Campus Connect is looking great. 🚀',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      likes: 24,
    ),
    Post(
      id: '2',
      authorName: 'Alice Monroe',
      authorRole: 'CS Student',
      content:
          'Does anyone have the syllabus for CS301? The portal is down again.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 5,
      commentList: [
        Comment(
          id: 'c1',
          author: 'Bob',
          text: "Yeah, I have it. I'll DM it to you!",
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          replies: [
            Comment(
              id: 'r1',
              author: 'Alice Monroe',
              text: 'Thanks so much! 🙏',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ],
        ),
      ],
    ),
    Post(
      id: '3',
      authorName: 'James Okafor',
      content:
          'Free pizza at the student union right now! Come by the main hall. 🍕',
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      likes: 38,
    ),
  ];

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
