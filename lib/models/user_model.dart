class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String bio;
  final String avatarUrl;
  final String faculty;
  final String year;
  final List<String> postIds;
  final List<String> likedPostIds;
  final List<String> followerIds;
  final List<String> followingIds;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.bio = '',
    this.avatarUrl = '',
    this.faculty = '',
    this.year = '',
    this.postIds = const [],
    this.likedPostIds = const [],
    this.followerIds = const [],
    this.followingIds = const [],
    required this.createdAt,
  });

  // ── Computed ─────────────────────────────────────────────────────────────
  int get postCount => postIds.length;
  int get followerCount => followerIds.length;
  int get followingCount => followingIds.length;

  bool isFollowing(String otherUid) => followingIds.contains(otherUid);

  // ── Serialisation ─────────────────────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      bio: map['bio'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      faculty: map['faculty'] as String? ?? '',
      year: map['year'] as String? ?? '',
      postIds: List<String>.from(map['postIds'] as List? ?? []),
      likedPostIds: List<String>.from(map['likedPostIds'] as List? ?? []),
      followerIds: List<String>.from(map['followerIds'] as List? ?? []),
      followingIds: List<String>.from(map['followingIds'] as List? ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'faculty': faculty,
      'year': year,
      'postIds': postIds,
      'likedPostIds': likedPostIds,
      'followerIds': followerIds,
      'followingIds': followingIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
    String? faculty,
    String? year,
    List<String>? postIds,
    List<String>? likedPostIds,
    List<String>? followerIds,
    List<String>? followingIds,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      faculty: faculty ?? this.faculty,
      year: year ?? this.year,
      postIds: postIds ?? this.postIds,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      followerIds: followerIds ?? this.followerIds,
      followingIds: followingIds ?? this.followingIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, username: @$username)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
