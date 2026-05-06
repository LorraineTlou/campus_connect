// lib/screens/create_post_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
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

  // ── Attachments ──────────────────────────────────────────────────────────
  Uint8List? _imageBytes;       // raw bytes — works on web & mobile
  String? _attachmentLabel;     // 'Photo' or 'Infographic'
  String? _locationText;        // "Lat: x.xxxxx, Lng: y.yyyyy"
  bool _fetchingLocation = false;

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

  // ── Pick image (photo or infographic) ────────────────────────────────────
  Future<void> _pickImage({required bool isInfographic}) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _attachmentLabel = isInfographic ? 'Infographic' : 'Photo';
      });
    }
  }

  void _removeImage() => setState(() {
        _imageBytes = null;
        _attachmentLabel = null;
      });

  // ── Get device location ───────────────────────────────────────────────────
  Future<void> _attachLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied. Enable it in Settings.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _locationText =
            'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _removeLocation() => setState(() => _locationText = null);

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    if (!mounted) return;
    final user = context.read<UserProvider>().user;

    try {
      await context.read<PostProvider>().addPost(
            _controller.text,
            authorId: user?.id ?? '',
            authorName: user?.name ?? 'You',
            authorRole: user?.faculty ?? '',
            avatarUrl: user?.avatarUrl ?? '',
            imageBytes: _imageBytes,
            attachmentType: _attachmentLabel?.toLowerCase(),
            location: _locationText,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _controller.clear();
        Navigator.pop(context);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0F1117) : Colors.white;
    final Color surfaceColor = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final Color dividerColor = isDark ? const Color(0xFF2D3148) : const Color(0xFFE3EAF0);
    final Color primaryColor = const Color(0xFF5EC4F2);
    final Color textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0D1B2A);
    final Color hintColor = isDark ? const Color(0xFF64748B) : const Color(0xFFB0BEC5);
    final Color charColor = _charCount > _maxChars
        ? Colors.red
        : _charCount > 240
            ? Colors.orange
            : isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF90A4AE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          'New Post',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: dividerColor, height: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSubmitting
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(primaryColor),
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.3),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Author + text area ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(initials: 'YO', size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _controller,
                                autofocus: true,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                                decoration: InputDecoration(
                                  hintText: "What's on your mind?",
                                  hintStyle: TextStyle(color: hintColor, fontSize: 16),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Image Preview ──────────────────────────────────────────
                  if (_imageBytes != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imageBytes!,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Label badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _attachmentLabel == 'Infographic'
                                        ? Icons.bar_chart_rounded
                                        : Icons.image_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _attachmentLabel ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Remove button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Location Tag ───────────────────────────────────────────
                  if (_locationText != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: primaryColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationText!,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _removeLocation,
                              child: Icon(Icons.close, color: primaryColor, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Bottom toolbar ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: dividerColor)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Photo icon
                _ToolbarButton(
                  icon: Icons.photo_outlined,
                  color: primaryColor,
                  tooltip: 'Attach Photo',
                  active: _imageBytes != null && _attachmentLabel == 'Photo',
                  onTap: _imageBytes == null ? () => _pickImage(isInfographic: false) : null,
                ),
                const SizedBox(width: 4),
                // Infographic icon
                _ToolbarButton(
                  icon: Icons.bar_chart_rounded,
                  color: primaryColor,
                  tooltip: 'Attach Infographic',
                  active: _imageBytes != null && _attachmentLabel == 'Infographic',
                  onTap: _imageBytes == null ? () => _pickImage(isInfographic: true) : null,
                ),
                const SizedBox(width: 4),
                // Location icon
                _fetchingLocation
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(primaryColor),
                          ),
                        ),
                      )
                    : _ToolbarButton(
                        icon: Icons.location_on_outlined,
                        color: primaryColor,
                        tooltip: _locationText != null ? 'Remove Location' : 'Attach Location',
                        active: _locationText != null,
                        onTap: _locationText == null ? _attachLocation : _removeLocation,
                      ),

                const Spacer(),
                // Character counter
                _CharCounter(
                  current: _charCount,
                  max: _maxChars,
                  color: charColor,
                  isOver: _charCount > _maxChars,
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

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final bool active;
  final VoidCallback? onTap;

  const _ToolbarButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: onTap == null && !active ? color.withValues(alpha: 0.4) : color,
            size: 22,
          ),
        ),
      ),
    );
  }
}

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
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
