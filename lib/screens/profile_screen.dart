import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/profile_post_grid.dart';
import '../widgets/edit_bio_sheet.dart';
import '../widgets/stat_chip.dart';
import 'message_screen.dart';

/// ProfileScreen
///
/// Shows the current user's own profile (isOwner = true) or
/// another student's profile (isOwner = false).
///
/// Integration points for other teams:
///   • Receives [user] — a [UserModel] from your provider / state manager.
///   • [currentUserId] — the logged-in user's UID (needed for follow logic).
///   • [onFollowToggle] — callback so Team 4 (likes/follows) can handle it.
///   • [onPostTap]      — callback so Team 3 (feed) can open the post detail.
class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final String currentUserId;
  final bool isOwner;
  final Future<void> Function(String targetUid)? onFollowToggle;
  final void Function(String postId)? onPostTap;
  final Future<void> Function(UserModel updated)? onBioSaved;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.currentUserId,
    this.isOwner = false,
    this.onFollowToggle,
    this.onPostTap,
    this.onBioSaved,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late UserModel _user;
  bool _isFollowing = false;
  bool _followLoading = false;
  late TabController _tabController;

  // ── Colours (match your global theme) ────────────────────────────────────
  static const Color _primary = Color(0xFF1976D2);
  static const Color _accent = Color(0xFF42A5F5);
  static const Color _surface = Color(0xFFF5F7FA);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textLight = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _isFollowing = _user.followerIds.contains(widget.currentUserId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _handleFollowToggle() async {
    if (_followLoading) return;
    setState(() => _followLoading = true);
    try {
      await widget.onFollowToggle?.call(_user.uid);
      setState(() {
        _isFollowing = !_isFollowing;
        final followers = List<String>.from(_user.followerIds);
        if (_isFollowing) {
          followers.add(widget.currentUserId);
        } else {
          followers.remove(widget.currentUserId);
        }
        _user = _user.copyWith(followerIds: followers);
      });
    } finally {
      setState(() => _followLoading = false);
    }
  }

  Future<void> _openEditBio() async {
    final updated = await showModalBottomSheet<UserModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditBioSheet(user: _user),
    );
    if (updated != null) {
      setState(() => _user = updated);
      await widget.onBioSaved?.call(updated);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildProfileHeader()),
          _buildTabs(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1 — Posts grid
            ProfilePostGrid(
              postIds: _user.postIds,
              onPostTap: widget.onPostTap,
            ),
            // Tab 2 — Liked posts grid
            ProfilePostGrid(
              postIds: _user.likedPostIds,
              onPostTap: widget.onPostTap,
              emptyMessage: 'No liked posts yet',
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: widget.isOwner
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: _textDark),
              onPressed: () => Navigator.pop(context),
            ),
      actions: [
        if (widget.isOwner)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _textDark),
            onPressed: () {
              // TODO: navigate to Settings screen
            },
          ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 20),
              // Stats row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatChip(label: 'Posts', value: _user.postCount),
                    StatChip(label: 'Followers', value: _user.followerCount),
                    StatChip(label: 'Following', value: _user.followingCount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Name + username
          Text(
            _user.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          Text(
            '@${_user.username}',
            style: const TextStyle(fontSize: 14, color: _accent),
          ),
          if (_user.faculty.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.school_outlined, size: 14, color: _textLight),
                const SizedBox(width: 4),
                Text(
                  '${_user.faculty} • Year ${_user.year}',
                  style: const TextStyle(fontSize: 13, color: _textLight),
                ),
              ],
            ),
          ],
          // Bio
          if (_user.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _user.bio,
              style: const TextStyle(
                fontSize: 14,
                color: _textDark,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          // Action buttons
          _buildActionButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: _accent.withOpacity(0.15),
          backgroundImage: _user.avatarUrl.isNotEmpty
              ? NetworkImage(_user.avatarUrl)
              : null,
          child: _user.avatarUrl.isEmpty
              ? Text(
                  _user.name.isNotEmpty ? _user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                )
              : null,
        ),
        if (widget.isOwner)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: pick image from gallery / camera
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (widget.isOwner) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openEditBio,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _followLoading ? null : _handleFollowToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? Colors.white : _primary,
              foregroundColor: _isFollowing ? _primary : Colors.white,
              side: _isFollowing
                  ? const BorderSide(color: _primary)
                  : BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _followLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isFollowing ? 'Following' : 'Follow'),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MessageScreen(recipient: _user),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Message'),
        ),
      ],
    );
  }

  SliverPersistentHeader _buildTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabDelegate(
        TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: _textLight,
          indicatorColor: _primary,
          tabs: const [
            Tab(icon: Icon(Icons.grid_on_outlined), text: 'Posts'),
            Tab(icon: Icon(Icons.favorite_outline), text: 'Liked'),
          ],
        ),
      ),
    );
  }
}

// ── Tab header delegate ────────────────────────────────────────────────────
class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabDelegate old) => false;
}
