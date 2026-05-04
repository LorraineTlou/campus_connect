import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../models/post.dart';
import 'post_card.dart';

/// Placeholder bodies per tab; swap for real feature screens later.
Widget campusTabContent(int index, {Key? key}) {
  switch (index) {
    case 0:
      return _HomeFeed(key: key);
    case 1:
      return _PlaceholderContent(key: key, title: 'Connect', subtitle: 'Clubs, groups, and people.');
    case 2:
      return _PlaceholderContent(key: key, title: 'Events', subtitle: 'Campus events and calendar.');
    case 3:
      return _PlaceholderContent(key: key, title: 'Chat', subtitle: 'Messages and announcements.');
    case 4:
      return _PlaceholderContent(key: key, title: 'Profile', subtitle: 'Account and settings.');
    default:
      return _HomeFeed(key: key);
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({super.key});

  static final List<Post> _mockPosts = [
    Post(
      id: '1',
      authorName: 'Lorraine Tlou',
      authorRole: 'CS Student',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=lorraine',
      content: 'Just finished the final project for Mobile Dev! Campus Connect is looking great. 🚀',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      likes: 24,
      comments: 5,
    ),
    Post(
      id: '2',
      authorName: 'John Doe',
      authorRole: 'Applied Science',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=john',
      content: 'Anyone wanting to form a study group for the Physics exam? Meet at the library at 4 PM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      comments: 8,
    ),
    Post(
      id: '3',
      authorName: 'Sarah Smith',
      authorRole: 'Engineering',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=sarah',
      content: 'The new cafeteria menu is actually pretty good today! Highly recommend the pasta.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 45,
      comments: 12,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('home-feed'),
      padding: AppSpacing.screenInsets.copyWith(top: 16, bottom: 80),
      itemCount: _mockPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return PostCard(post: _mockPosts[index]);
      },
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: ValueKey('placeholder-$title'),
      child: Padding(
        padding: AppSpacing.screenInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
