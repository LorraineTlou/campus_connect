import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel updated) async {
    _user = updated;
    notifyListeners();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(updated.uid)
        .update(updated.toMap());
  }

  Future<void> toggleConnection(String targetUid) async {
    if (_user == null) return;

    final updatedFollowing = List<String>.from(_user!.followingIds);
    if (updatedFollowing.contains(targetUid)) {
      updatedFollowing.remove(targetUid);
    } else {
      updatedFollowing.add(targetUid);
    }

    _user = _user!.copyWith(followingIds: updatedFollowing);
    notifyListeners();

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .update({'followingIds': updatedFollowing});

    // Also update the other user's follower list (simplified)
    final targetDoc = await FirebaseFirestore.instance.collection('users').doc(targetUid).get();
    if (targetDoc.exists) {
      final targetData = targetDoc.data()!;
      final followers = List<String>.from(targetData['followerIds'] ?? []);
      if (followers.contains(_user!.uid)) {
        followers.remove(_user!.uid);
      } else {
        followers.add(_user!.uid);
      }
      await FirebaseFirestore.instance.collection('users').doc(targetUid).update({'followerIds': followers});
    }
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
