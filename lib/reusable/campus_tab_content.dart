import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../models/post.dart';
import 'post_card.dart';
import '../screens/profile_screen.dart';
import '../models/user_model.dart';

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
      return _ProfileTabWrapper(key: key);
    default:
      return _HomeFeed(key: key);
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('home-feed'),
      padding: AppSpacing.screenInsets.copyWith(top: 16, bottom: 80),
      itemCount: Post.mockPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = Post.mockPosts[index];
        return PostCard(
          post: post,
          onAuthorTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  user: UserModel(
                    uid: 'mock_${post.authorName}',
                    name: post.authorName,
                    username: post.authorName.toLowerCase().replaceAll(' ', ''),
                    email: 'mock@example.com',
                    avatarUrl: post.authorAvatarUrl,
                    faculty: post.authorRole,
                    createdAt: DateTime.now(),
                    postIds: Post.mockPosts.where((p) => p.authorName == post.authorName).map((p) => p.id).toList(),
                    followerIds: ['user1', 'user2', 'user3'].take((post.authorName.length % 3) + 1).toList(),
                    followingIds: ['user4', 'user5'].take((post.authorName.length % 2) + 1).toList(),
                  ),
                  currentUserId: 'mock_current_user',
                  isOwner: false,
                  onPostTap: (postId) {
                    final p = Post.mockPosts.firstWhere((p) => p.id == postId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Post')),
                          body: ListView(
                            padding: const EdgeInsets.only(top: 16),
                            children: [PostCard(post: p)],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
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

class _ProfileTabWrapper extends StatefulWidget {
  const _ProfileTabWrapper({super.key});

  @override
  State<_ProfileTabWrapper> createState() => _ProfileTabWrapperState();
}

class _ProfileTabWrapperState extends State<_ProfileTabWrapper> {
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = UserModel(
      uid: 'mock_current_user',
      name: 'Lorraine Tlou',
      username: 'lorrainet',
      email: 'lorraine@campus.edu',
      bio: 'CS Student passionate about mobile development and UI design.',
      avatarUrl: 'https://i.pravatar.cc/150?u=lorraine',
      faculty: 'Computer Science',
      year: '3',
      postIds: ['1'],
      followerIds: ['user1', 'user2', 'user3', 'user4', 'user5'],
      followingIds: ['user2', 'user4'],
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      user: _currentUser,
      currentUserId: _currentUser.uid,
      isOwner: true,
      onPostTap: (postId) {
        final p = Post.mockPosts.firstWhere((p) => p.id == postId);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Post')),
              body: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [PostCard(post: p)],
              ),
            ),
          ),
        );
      },
      onBioSaved: (updatedUser) async {
        setState(() {
          _currentUser = updatedUser;
        });
      },
    );
  }
}
