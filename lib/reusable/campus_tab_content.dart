import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../providers/user_provider.dart';
import '../screens/profile_screen.dart';
import 'post_card.dart';
import '../providers/post_provider.dart';

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
      return _ProfileTab(key: key);
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
      onPostTap: (postId) {},
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        final posts = provider.posts;
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet. Be the first!'));
        }
        return ListView.separated(
          key: const ValueKey('home-feed'),
          padding: AppSpacing.screenInsets.copyWith(top: 16, bottom: 80),
          itemCount: posts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, i) => PostCard(post: posts[i]),
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
