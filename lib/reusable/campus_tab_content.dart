import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../screens/profile_screen.dart';
import 'cc_buttons.dart';
import 'cc_text_fields.dart';
import 'post_card.dart';

/// Placeholder bodies per tab; swap for real feature screens later.
Widget campusTabContent(BuildContext context, int index, {Key? key}) {
  switch (index) {
    case 0:
      return _HomeFeed(key: key);
    case 1:
      return _CreatePostTab(key: key);
    case 2:
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

class _CreatePostTab extends StatefulWidget {
  const _CreatePostTab({super.key});

  @override
  State<_CreatePostTab> createState() => _CreatePostTabState();
}

class _CreatePostTabState extends State<_CreatePostTab> {
  final _contentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _handlePost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final user = context.read<UserProvider>().user;
      context.read<PostProvider>().addPost(
        _contentController.text.trim(),
        authorName: user?.name ?? 'Anonymous Student',
        authorRole: 'Student',
        avatarUrl: user?.avatarUrl ?? '',
      );

      if (mounted) {
        setState(() => _isPosting = false);
        _contentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenInsets.copyWith(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What's happening on campus?",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          CCTextField(
            controller: _contentController,
            hint: "Share your thoughts, updates, or questions...",
            maxLines: 8,
            minLines: 5,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.image_outlined, color: AppColors.primary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.poll_outlined, color: AppColors.primary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          CCPrimaryButton(
            label: 'Post to Feed',
            onPressed: _handlePost,
            isLoading: _isPosting,
          ),
        ],
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey('home-feed'),
      padding: AppSpacing.screenInsets.copyWith(top: 16, bottom: 80),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return PostCard(post: posts[index]);
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