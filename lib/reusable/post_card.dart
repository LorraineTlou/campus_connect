import 'package:flutter/material.dart';
import '../models/post.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../base/app_text_styles.dart';
import 'cc_components.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onAuthorTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onAuthorTap,
  });

  String _timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) return '${duration.inMinutes}m';
    if (duration.inHours < 24) return '${duration.inHours}h';
    return '${duration.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return CCCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onAuthorTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        CCAvatar(
                          imageUrl: post.authorAvatarUrl,
                          initials: post.authorName.contains(' ') 
                              ? post.authorName.split(' ').map((e) => e[0]).take(2).join()
                              : post.authorName.substring(0, 1),
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${post.authorRole} • ${_timeAgo(post.timestamp)}',
                                style: AppTextStyles.labelSm,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: AppColors.grey),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              post.content,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            Image.network(
              post.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
          
          const SizedBox(height: 8),
          
          // Actions
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.favorite_border_rounded,
                  label: post.likes.toString(),
                  onTap: onLike,
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: post.comments.toString(),
                  onTap: onComment,
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.grey),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
