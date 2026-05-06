// lib/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../models/comment.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(
                  initials: post.authorName.substring(0, 1).toUpperCase(),
                  size: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      Text(
                        _timeAgo(post.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF90A4AE),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Color(0xFFB0BEC5),
                    size: 20,
                  ),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Text(
              post.content,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF263238),
                height: 1.55,
              ),
            ),
          ),

          // ── Attached Image / Infographic ──────────────────────────────────
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 220,
                        color: const Color(0xFFF0F4F8),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF5EC4F2)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: const Color(0xFFF0F4F8),
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Color(0xFFB0BEC5)),
                      ),
                    ),
                  ),
                ),
                // Infographic badge
                if (post.attachmentType == 'infographic')
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5EC4F2).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded,
                              color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Infographic',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // ── Location Chip ─────────────────────────────────────────────────
          if (post.location != null && post.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFF5EC4F2), size: 15),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.location!,
                      style: const TextStyle(
                        color: Color(0xFF5EC4F2),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── Divider ───────────────────────────────────────────────────────
          const Divider(
            height: 1,
            color: Color(0xFFF0F4F8),
            indent: 16,
            endIndent: 16,
          ),


          // ── Action Bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _LikeButton(post: post),
                const SizedBox(width: 4),
                _CommentButton(post: post),
                const Spacer(),
                if ((post.likes.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF90A4AE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Comments Section ──────────────────────────────────────────────
          StreamBuilder<List<Comment>>(
            stream: context.read<PostProvider>().getComments(post.id),
            builder: (context, snapshot) {
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) return const SizedBox.shrink();
              return _CommentsSection(comments: comments);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Like Button ─────────────────────────────────────────────────────────────

class _LikeButton extends StatefulWidget {
  final Post post;
  const _LikeButton({required this.post});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    final userId = context.read<UserProvider>().user?.id ?? '';
    context.read<PostProvider>().toggleLike(widget.post.id, userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().user?.id ?? '';
    final isLiked = widget.post.likes.contains(userId);
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Icon(
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: isLiked
                    ? const Color(0xFFE53935)
                    : const Color(0xFF90A4AE),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Like',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isLiked
                    ? const Color(0xFFE53935)
                    : const Color(0xFF90A4AE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Comment Button & Sheet ───────────────────────────────────────────────────

class _CommentButton extends StatelessWidget {
  final Post post;
  const _CommentButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openCommentSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mode_comment_outlined,
              size: 20,
              color: Color(0xFF90A4AE),
            ),
            const SizedBox(width: 5),
            StreamBuilder<List<Comment>>(
  stream: context.read<PostProvider>().getComments(post.id),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Text(
        'Comment',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF90A4AE),
        ),
      );
    }

    final count = snapshot.data!.length;

    return Text(
      count == 0
          ? 'Comment'
          : '$count Comment${count == 1 ? '' : 's'}',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF90A4AE),
      ),
    );
  },
            ),
          ],
        ),
      ),
    );
  }

  void _openCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(post: post),
    );
  }
}

// ─── Comment Sheet ────────────────────────────────────────────────────────────

class _CommentSheet extends StatefulWidget {
  final Post post;
  const _CommentSheet({required this.post});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _ctrl = TextEditingController();
  bool _canSend = false;
  Comment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _canSend = _ctrl.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void send() {
  if (!_canSend) return;

  final user = context.read<UserProvider>().user!;

  if (_replyingTo != null) {
    context.read<PostProvider>().addComment(
      widget.post.id,
      _ctrl.text,
      userId: user.id,
      userName: user.name,
    );

    setState(() => _replyingTo = null);
  } else {
    context.read<PostProvider>().addComment(
      widget.post.id,
      _ctrl.text,
      userId: user.id,
      userName: user.name,
    );
  }

  _ctrl.clear();
}
  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (ctx, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFD8DC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFF0F4F8)),

                Expanded(
                  child: StreamBuilder<List<Comment>>(
                    stream: context.read<PostProvider>().getComments(widget.post.id),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 36,
                                color: Color(0xFFB0BEC5),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No comments yet.\nBe the first!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF90A4AE),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => _CommentTile(
                          comment: comments[i],
                          onReply: (comment) =>
                              setState(() => _replyingTo = comment),
                        ),
                      );
                    },
                  ),
                ),

                // Input Row
                const Divider(height: 1, color: Color(0xFFF0F4F8)),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 10,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                    ),
                    child: Row(
                      children: [
                        const _Avatar(initials: 'YO', size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_replyingTo != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    bottom: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Replying to ${_replyingTo!.userName}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1565C0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () =>
                                            setState(() => _replyingTo = null),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              TextField(
                                controller: _ctrl,
                                autofocus: true,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: _replyingTo != null
                                      ? 'Write a reply…'
                                      : 'Write a comment…',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFFB0BEC5),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            onPressed: _canSend ? send : null,
                            icon: Icon(
                              Icons.send_rounded,
                              color: _canSend
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFFB0BEC5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Comment Tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final ValueChanged<Comment>? onReply;
  const _CommentTile({required this.comment, this.onReply});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          initials: comment.userName.substring(0, 1).toUpperCase(),
          size: 32,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timeAgo(comment.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF263238),
                        height: 1.4,
                      ),
                    ),
                    if (onReply != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: GestureDetector(
                          onTap: () => onReply!(comment),
                          child: const Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (comment.replies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: comment.replies
                        .map(
                          (reply) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Avatar(
                                  initials: reply.userName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F7FB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              reply.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Color(0xFF0D1B2A),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _timeAgo(reply.timestamp),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF90A4AE),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          reply.content,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF263238),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared Avatar widget ─────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;
  const _Avatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.33,
          ),
        ),
      ),
    );
  }
}

// ─── Comments inline preview ──────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  final List<Comment> comments;
  const _CommentsSection({required this.comments});

  @override
  Widget build(BuildContext context) {
    final preview = comments.take(2).toList();
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          for (final comment in preview)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(
                    initials: comment.userName.substring(0, 1).toUpperCase(),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${comment.userName} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          TextSpan(
                            text: comment.content,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF546E7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (comments.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'View all ${comments.length} comments',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
