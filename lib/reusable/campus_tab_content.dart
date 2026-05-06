import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
// post.dart used indirectly via PostProvider
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
      currentUserId: currentUser.id,
      isOwner: true,
      onBioSaved: (updated) async {
        await context.read<UserProvider>().updateUser(updated);
      },
      onPostTap: (postId) {},
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

  // ── Attachments ──────────────────────────────────────────────────────────
  Uint8List? _imageBytes;       // raw bytes — works on web & mobile
  String? _attachmentLabel;
  String? _locationText;
  bool _fetchingLocation = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isInfographic}) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _attachmentLabel = isInfographic ? 'Infographic' : 'Photo';
      });
    }
  }

  Future<void> _attachLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { _showSnack('Location services are disabled.'); return; }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) { _showSnack('Location permission denied.'); return; }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied. Enable it in Settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _locationText = 'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _handlePost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final user = context.read<UserProvider>().user;

      if (user == null) {
        _showSnack('User not loaded yet');
        setState(() => _isPosting = false);
        return;
      }

      await context.read<PostProvider>().addPost(
        _contentController.text.trim(),
        authorId: user.id,
        authorName: user.name,
        authorRole: 'Student',
        avatarUrl: user.avatarUrl,
        imageBytes: _imageBytes,
        attachmentType: _attachmentLabel?.toLowerCase(),
        location: _locationText,
      );

      if (mounted) {
        setState(() {
          _isPosting = false;
          _imageBytes = null;
          _attachmentLabel = null;
          _locationText = null;
        });
        _contentController.clear();
        _showSnack('Post published!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        _showSnack('Failed to post: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;

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

          // ── Attachment preview ─────────────────────────────────────────
          if (_imageBytes != null) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _imageBytes!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_attachmentLabel == 'Infographic' ? Icons.bar_chart_rounded : Icons.image_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(_attachmentLabel ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() { _imageBytes = null; _attachmentLabel = null; }),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ── Location tag ───────────────────────────────────────────────
          if (_locationText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_locationText!, style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500))),
                  GestureDetector(
                    onTap: () => setState(() => _locationText = null),
                    child: Icon(Icons.close, color: primaryColor, size: 16),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              // Photo
              IconButton(
                onPressed: _imageBytes == null ? () => _pickImage(isInfographic: false) : null,
                tooltip: 'Attach Photo',
                icon: Icon(Icons.image_outlined, color: primaryColor),
              ),
              // Infographic
              IconButton(
                onPressed: _imageBytes == null ? () => _pickImage(isInfographic: true) : null,
                tooltip: 'Attach Infographic',
                icon: Icon(Icons.bar_chart_rounded, color: primaryColor),
              ),
              // Location
              _fetchingLocation
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(primaryColor))),
                    )
                  : IconButton(
                      onPressed: _locationText == null ? _attachLocation : () => setState(() => _locationText = null),
                      tooltip: _locationText != null ? 'Remove Location' : 'Attach Location',
                      icon: Icon(Icons.location_on_outlined, color: primaryColor),
                    ),
            ],
          ),
          const SizedBox(height: 16),
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
