import 'package:flutter/material.dart';
import '../models/post.dart';

/// Displays a 3-column grid of post thumbnails.
///
/// [postIds] comes from [UserModel.postIds] or [UserModel.likedPostIds].
/// [onPostTap] is wired to Team 3's feed so tapping opens the PostDetailScreen.
///
/// NOTE: Replace [_placeholderColor] and the placeholder Container with
/// real post thumbnail widgets once Team 3's PostModel is available.
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
    // Find the post from mock data
    final post = Post.mockPosts.firstWhere(
      (p) => p.id == postId,
      orElse: () => Post(
        id: '',
        authorName: '',
        authorRole: '',
        authorAvatarUrl: '',
        content: 'Unknown post',
        timestamp: DateTime.now(),
      ),
    );

    if (post.id.isEmpty) {
      return Container(color: Colors.grey[300]);
    }

    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return Image.network(
        post.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    }

    // For text-only posts, show a snippet on a subtle background
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          post.content,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
