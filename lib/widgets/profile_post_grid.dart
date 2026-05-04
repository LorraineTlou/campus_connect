import 'package:flutter/material.dart';

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

  // Deterministic placeholder colours (replace with real thumbnails later)
  static const List<Color> _palette = [
    Color(0xFFBBDEFB),
    Color(0xFFE3F2FD),
    Color(0xFF90CAF9),
    Color(0xFF64B5F6),
    Color(0xFF42A5F5),
  ];

  Color _colorFor(String id) => _palette[id.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: swap with CachedNetworkImage / PostThumbnail once Team 3 is ready
      color: _colorFor(postId),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.white.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }
}
