import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

/// Displays a 3-column grid of post thumbnails.
///

class ProfilePostGrid extends StatelessWidget {
  final List<String> postIds;
  final void Function(String postId)? onPostTap;
  final String emptyMessage;

  const ProfilePostGrid({
    super.key,
    required this.postIds,
    this.onPostTap,
    this.emptyMessage = 'No posts yet',
  });

  @override
  Widget build(BuildContext context) {
    if (postIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: postIds.length,
      itemBuilder: (context, index) {
        final postId = postIds[index];
        return GestureDetector(
          onTap: () => onPostTap?.call(postId),
          child: _PostTile(postId: postId),
        );
      },
    );
  }
}

class _PostTile extends StatelessWidget {
  final String postId;
  const _PostTile({required this.postId});

  @override
  Widget build(BuildContext context) {
    final posts = context.read<PostProvider>().posts;

    final post = posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => Post(
        id: '',
        authorId: '', // ✅ required
        authorName: '',
        authorRole: '',
        authorAvatarUrl: '',
        content: 'Unknown post',
        timestamp: DateTime.now(),
        likes: [], // ✅ required
      ),
    );

    if (post.id.isEmpty) {
      return Container(color: Colors.grey[300]);
    }

    // ❌ REMOVE imageUrl logic completely (no longer exists)

    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(8.0),
      child: Text(post.content, style: const TextStyle(fontSize: 16)),
    );
  }
}
