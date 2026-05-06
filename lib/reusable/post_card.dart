// lib/widgets/post_card.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF263238);
    final subtitleColor = isDark ? const Color(0xFF90A4AE) : const Color(0xFF90A4AE);
    final dividerColor = isDark ? const Color(0xFF333333) : const Color(0xFFF0F4F8);

    final currentUser = context.watch<UserProvider>().user;
    final isMe = currentUser?.name == post.authorName; // Simple check for demo purposes
    final isFollowing = currentUser?.followingIds.contains(post.id) ?? false; // Simplified logic

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF1565C0).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                _Avatar(initials: post.avatarInitials, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0D1B2A))),
                      Text(_timeAgo(post.timestamp), style: TextStyle(fontSize: 12, color: subtitleColor)),
                    ],
                  ),
                ),
                if (!isMe)
                  TextButton(
                    onPressed: () {
                      // Logic to follow user (placeholder target UID)
                      context.read<UserProvider>().toggleConnection(post.id);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: subtitleColor, size: 20),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // ── Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(post.content, style: TextStyle(fontSize: 15, color: textColor, height: 1.55)),
          ),

          // ── Image (if attached)
          if (post.hasImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.imagePath != null && post.imagePath!.isNotEmpty
                    ? (kIsWeb
                        ? Image.network(post.imagePath!, width: double.infinity, height: 220, fit: BoxFit.cover)
                        : Image.file(File(post.imagePath!), width: double.infinity, height: 220, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image, size: 40)))))
                    : Image.network(post.imageUrl!, width: double.infinity, height: 220, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image, size: 40)))),
              ),
            ),

          // ── Divider
          Divider(height: 1, color: dividerColor, indent: 16, endIndent: 16),

          // ── Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _LikeButton(post: post),
                const SizedBox(width: 4),
                _CommentButton(post: post),
                const SizedBox(width: 4),
                _ReshareButton(post: post),
                const SizedBox(width: 4),
                _ShareButton(post: post),
                const Spacer(),
                if (post.likes > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('${post.likes} ${post.likes == 1 ? 'like' : 'likes'}', style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),

          // ── Comments Section
          if (post.commentList.isNotEmpty) _CommentsSection(post: post),
        ],
      ),
    );
  }
}

// ─── Reshare Button ───────────────────────────────────────────────────────────

class _ReshareButton extends StatelessWidget {
  final Post post;
  const _ReshareButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post reshared to your profile!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat_rounded, size: 20, color: Color(0xFF90A4AE)),
            SizedBox(width: 5),
            Text('Reshare', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF90A4AE))),
          ],
        ),
      ),
    );
  }
}

// ─── Share Button ─────────────────────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  final Post post;
  const _ShareButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showShareSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.share_outlined, size: 20, color: Color(0xFF90A4AE)),
            SizedBox(width: 5),
            Text('Share', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF90A4AE))),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Share Post', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0D1B2A))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(icon: Icons.copy_rounded, label: 'Copy Link', color: const Color(0xFF1976D2), onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!'))); }),
                _ShareOption(icon: Icons.message_rounded, label: 'Message', color: const Color(0xFF43A047), onTap: () => Navigator.pop(context)),
                _ShareOption(icon: Icons.bookmark_add_outlined, label: 'Save', color: const Color(0xFFF57C00), onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post saved!'))); }),
                _ShareOption(icon: Icons.flag_outlined, label: 'Report', color: const Color(0xFFE53935), onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reported.'))); }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : const Color(0xFF546E7A))),
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

class _LikeButtonState extends State<_LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _handleTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    context.read<PostProvider>().toggleLike(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.isLikedByMe;
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(scale: _scale, child: Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20, color: isLiked ? const Color(0xFFE53935) : const Color(0xFF90A4AE))),
            const SizedBox(width: 5),
            Text('Like', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isLiked ? const Color(0xFFE53935) : const Color(0xFF90A4AE))),
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
            const Icon(Icons.mode_comment_outlined, size: 20, color: Color(0xFF90A4AE)),
            const SizedBox(width: 5),
            Text(
              post.commentList.isEmpty ? 'Comment' : '${post.commentList.length} Comment${post.commentList.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF90A4AE)),
            ),
          ],
        ),
      ),
    );
  }

  void _openCommentSheet(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _CommentSheet(post: post));
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
    _ctrl.addListener(() { setState(() => _canSend = _ctrl.text.trim().isNotEmpty); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    if (!_canSend) return;
    if (_replyingTo != null) {
      context.read<PostProvider>().addReply(widget.post.id, _replyingTo!.id, _ctrl.text);
      setState(() => _replyingTo = null);
    } else {
      context.read<PostProvider>().addComment(widget.post.id, _ctrl.text);
    }
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F7FB);

    return Consumer<PostProvider>(
      builder: (ctx, provider, _) {
        final livePost = provider.posts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);
        return DraggableScrollableSheet(
          initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(color: sheetBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                Container(margin: const EdgeInsets.only(top: 10, bottom: 4), width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFCFD8DC), borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(children: [Text('Comments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0D1B2A)))]),
                ),
                Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFF0F4F8)),
                Expanded(
                  child: livePost.commentList.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.chat_bubble_outline, size: 36, color: isDark ? Colors.grey[600] : const Color(0xFFB0BEC5)),
                          const SizedBox(height: 10),
                          Text('No comments yet.\nBe the first!', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF90A4AE), fontSize: 14)),
                        ]))
                      : ListView.separated(
                          controller: scrollCtrl, padding: const EdgeInsets.all(16),
                          itemCount: livePost.commentList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (_, i) => _CommentTile(comment: livePost.commentList[i], onReply: (c) => setState(() => _replyingTo = c)),
                        ),
                ),
                Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFF0F4F8)),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                    child: Row(
                      children: [
                        const _Avatar(initials: 'YO', size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_replyingTo != null)
                                Padding(padding: const EdgeInsets.only(left: 12, bottom: 4), child: Row(children: [
                                  Text('Replying to ${_replyingTo!.author}', style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 4),
                                  GestureDetector(onTap: () => setState(() => _replyingTo = null), child: const Icon(Icons.close, size: 14, color: Color(0xFF1565C0))),
                                ])),
                              TextField(
                                controller: _ctrl, autofocus: true, style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: _replyingTo != null ? 'Write a reply…' : 'Write a comment…',
                                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : const Color(0xFFB0BEC5)),
                                  filled: true, fillColor: inputBg,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(onPressed: _canSend ? _send : null, icon: Icon(Icons.send_rounded, color: _canSend ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5))),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F7FB);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(initials: comment.author.substring(0, 1).toUpperCase(), size: 32),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: tileBg, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(comment.author, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0D1B2A))),
                const SizedBox(width: 6),
                Text(_timeAgo(comment.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE))),
              ]),
              const SizedBox(height: 3),
              Text(comment.text, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF263238), height: 1.4)),
              if (onReply != null)
                Padding(padding: const EdgeInsets.only(top: 4), child: GestureDetector(
                  onTap: () => onReply!(comment),
                  child: const Text('Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF90A4AE))),
                )),
            ]),
          ),
          if (comment.replies.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 8), child: Column(
              children: comment.replies.map((reply) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Avatar(initials: reply.author.substring(0, 1).toUpperCase(), size: 24),
                  const SizedBox(width: 8),
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: tileBg, borderRadius: BorderRadius.circular(10)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(reply.author, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: isDark ? Colors.white : const Color(0xFF0D1B2A))),
                        const SizedBox(width: 6),
                        Text(_timeAgo(reply.createdAt), style: const TextStyle(fontSize: 10, color: Color(0xFF90A4AE))),
                      ]),
                      const SizedBox(height: 2),
                      Text(reply.text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF263238), height: 1.3)),
                    ]),
                  )),
                ]),
              )).toList(),
            )),
        ])),
      ],
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;
  const _Avatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Center(child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.33))),
    );
  }
}

// ─── Comments inline preview ──────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  final Post post;
  const _CommentsSection({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = post.commentList.take(2).toList();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(children: [
        for (final comment in preview)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Avatar(initials: comment.author.substring(0, 1).toUpperCase(), size: 26),
            const SizedBox(width: 8),
            Expanded(child: RichText(text: TextSpan(children: [
              TextSpan(text: '${comment.author} ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0D1B2A))),
              TextSpan(text: comment.text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF546E7A))),
            ]))),
          ])),
        if (post.commentList.length > 2)
          Padding(padding: const EdgeInsets.only(top: 2), child: Text('View all ${post.commentList.length} comments', style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0), fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
