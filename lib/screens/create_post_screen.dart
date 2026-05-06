// lib/screens/create_post_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  int get _charCount => _controller.text.length;
  static const int _maxChars = 280;
  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && _charCount <= _maxChars;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 400)); // UX pause

    if (!mounted) return;
    final user = context.read<UserProvider>().user;
    context.read<PostProvider>().addPost(
      _controller.text,
      authorName: user?.name ?? 'You',
      authorRole: user?.faculty ?? '',
      avatarUrl: user?.avatarUrl ?? '',
    );

    setState(() => _isSubmitting = false);
    _controller.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = _charCount > _maxChars;
    final Color charColor = isOverLimit
        ? Colors.red
        : _charCount > 240
        ? Colors.orange
        : const Color(0xFF90A4AE);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE3EAF0), height: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSubmitting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF1565C0)),
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      disabledBackgroundColor: const Color(0xFFBBDEFB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Author Row ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Avatar(initials: 'YO', size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B2A),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── Text Field ─────────────────────────────────────────
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0D1B2A),
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Bottom bar ───────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE3EAF0))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_outlined,
                  color: Color(0xFF1565C0),
                  size: 22,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.tag_outlined,
                  color: Color(0xFF1565C0),
                  size: 22,
                ),
                const Spacer(),
                // Character counter
                _CharCounter(
                  current: _charCount,
                  max: _maxChars,
                  color: charColor,
                  isOver: isOverLimit,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ──────────────────────────────────────────────────────

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
            color: const Color(0xFF1565C0).withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _CharCounter extends StatelessWidget {
  final int current;
  final int max;
  final Color color;
  final bool isOver;

  const _CharCounter({
    required this.current,
    required this.max,
    required this.color,
    required this.isOver,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = max - current;
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: (current / max).clamp(0.0, 1.0),
            strokeWidth: 2.5,
            backgroundColor: const Color(0xFFE3EAF0),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        if (isOver || current > 240) ...[
          const SizedBox(width: 8),
          Text(
            '$remaining',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
