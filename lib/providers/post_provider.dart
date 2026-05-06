// lib/providers/post_provider.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<Post> _posts = [];
  List<Post> get posts => _posts;

  // ── Fetch Posts (realtime) ─────────────────────────────────────────────────
  void fetchPosts() {
    _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _posts.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        _posts.add(
          Post(
            id: doc.id,
            authorId: data['authorId'] ?? '',
            authorName: data['authorName'] ?? '',
            authorRole: data['authorRole'] ?? '',
            authorAvatarUrl: data['avatarUrl'] ?? '',
            content: data['content'] ?? '',
            timestamp:
                (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            likes: List<String>.from(data['likes'] ?? []),
            // ── New attachment fields ──────────────────────────────────────
            imageUrl: data['imageUrl'] as String?,
            attachmentType: data['attachmentType'] as String?,
            location: data['location'] as String?,
          ),
        );
      }

      notifyListeners();
    });
  }

  // ── Add Post ──────────────────────────────────────────────────────────────
  /// [imageBytes] — raw image bytes (null if no attachment).
  /// [attachmentType] — 'photo' or 'infographic'.
  /// [location] — GPS coordinate string from geolocator.
  Future<void> addPost(
    String content, {
    required String authorId,
    required String authorName,
    String authorRole = '',
    String avatarUrl = '',
    Uint8List? imageBytes,
    String? attachmentType,
    String? location,
  }) async {
    // 1. Upload image to Firebase Storage if provided
    String? imageUrl;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final ext = attachmentType == 'infographic' ? 'png' : 'jpg';
      final fileName =
          'posts/${authorId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = _storage.ref().child(fileName);
      final uploadTask = await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/$ext'),
      );
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    // 2. Save post document to Firestore
    await _firestore.collection('posts').add({
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'avatarUrl': avatarUrl,
      'content': content.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'imageUrl': imageUrl,
      'attachmentType': attachmentType,
      'location': location,
    });
  }

  // ── Like / Unlike ─────────────────────────────────────────────────────────
  Future<void> toggleLike(String postId, String userId) async {
    final ref = _firestore.collection('posts').doc(postId);
    final doc = await ref.get();

    final likes = List<String>.from(doc['likes'] ?? []);

    if (likes.contains(userId)) {
      await ref.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // ── Add Comment ───────────────────────────────────────────────────────────
  Future<void> addComment(
    String postId,
    String content, {
    required String userId,
    required String userName,
  }) async {
    if (content.trim().isEmpty) return;

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': userId,
      'userName': userName,
      'content': content.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ── Get Comments (realtime) ───────────────────────────────────────────────
  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Comment(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
          content: data['content'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
              DateTime.now(),
        );
      }).toList();
    });
  }
}