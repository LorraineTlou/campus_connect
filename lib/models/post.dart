// lib/models/post.dart

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;
  final List<String> likes;

  // ── Attachment fields ──────────────────────────────────────────────────────
  /// Firebase Storage download URL for an attached image or infographic.
  final String? imageUrl;

  /// 'photo', 'infographic', or null if no image is attached.
  final String? attachmentType;

  /// Human-readable coordinates string, e.g. "Lat: -17.82931, Lng: 31.05334"
  final String? location;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
    required this.likes,
    this.imageUrl,
    this.attachmentType,
    this.location,
  });
}