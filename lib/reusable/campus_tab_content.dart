import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../screens/profile_screen.dart';
import 'post_card.dart';
import '../screens/profile_screen.dart';
import '../models/user_model.dart';

/// Placeholder bodies per tab; swap for real feature screens later.
Widget campusTabContent(BuildContext context, int index, {Key? key}) {
  switch (index) {
    case 0:
      return _HomeFeed(key: key);
    case 1:
      return _PlaceholderContent(
        key: key,
        title: 'Connect',
        subtitle: 'Clubs, groups, and people.',
      );
    case 2:
      return _PlaceholderContent(
        key: key,
        title: 'Events',
        subtitle: 'Campus events and calendar.',
      );
    case 3:
      return _PlaceholderContent(
        key: key,
        title: 'Chat',
        subtitle: 'Messages and announcements.',
      );
    case 4:
      return _PlaceholderContent(
        key: key,
        title: 'Profile',
        subtitle: 'Account and settings.',
      );
    default:
      return _HomeFeed(key: key);
  }
}

/// Stateless wrapper that reads UserProvider and builds ProfileScreen.
class _ProfileTab extends StatefulWidget {
  const _ProfileTab({super.key});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  @override
  void initState() {
    super.initState();
    // Load user data when the profile tab is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Failed to load profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<UserProvider>().loadUser(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ProfileScreen(
      user: currentUser,
      currentUserId: currentUser.uid,
      isOwner: true,
      onBioSaved: (updated) async {
        await context.read<UserProvider>().updateUser(updated);
      },
      onPostTap: (postId) {
        // TODO: navigate to post detail screen
      },
    );
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
      content:
          'Just finished the final project for Mobile Dev! Campus Connect is looking great. 🚀',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      likes: 24,
      comments: 5,
    ),
    Post(
      id: '2',
      authorName: 'John Doe',
      authorRole: 'Applied Science',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=john',
      content:
          'Anyone wanting to form a study group for the Physics exam? Meet at the library at 4 PM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      comments: 8,
    ),
    Post(
      id: '3',
      authorName: 'Sarah Smith',
      authorRole: 'Engineering',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=sarah',
      content:
          'The new cafeteria menu is actually pretty good today! Highly recommend the pasta.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 45,
      comments: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format',
    ),
  ];

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
                    postIds: Post.mockPosts
                        .where((p) => p.authorName == post.authorName)
                        .map((p) => p.id)
                        .toList(),
                    followerIds: [
                      'user1',
                      'user2',
                      'user3',
                    ].take((post.authorName.length % 3) + 1).toList(),
                    followingIds: [
                      'user4',
                      'user5',
                    ].take((post.authorName.length % 2) + 1).toList(),
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
