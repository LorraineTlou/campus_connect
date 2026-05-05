class Post {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String? imageUrl;

  const Post({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.imageUrl,
  });

  static final List<Post> mockPosts = [
    Post(
      id: '1',
      authorName: 'Lorraine Tlou',
      authorRole: 'CS Student',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=lorraine',
      content: 'Just finished the final project for Mobile Dev! Campus Connect is looking great. 🚀',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      likes: 24,
      comments: 5,
    ),
    Post(
      id: '2',
      authorName: 'John Doe',
      authorRole: 'Applied Science',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=john',
      content: 'Anyone wanting to form a study group for the Physics exam? Meet at the library at 4 PM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      comments: 8,
    ),
    Post(
      id: '3',
      authorName: 'Sarah Smith',
      authorRole: 'Engineering',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=sarah',
      content: 'The new cafeteria menu is actually pretty good today! Highly recommend the pasta.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 45,
      comments: 12,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format',
    ),
  ];
}
