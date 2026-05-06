import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../base/app_colors.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  static const _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<UserModel> _users = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  String _searchQuery = '';
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchPage(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _searchQuery = val.toLowerCase());
        _fetchPage(reset: true);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore &&
        _searchQuery.isEmpty) {
      _fetchPage(reset: false);
    }
  }

  Future<void> _fetchPage({required bool reset}) async {
    if (!reset && _isFetchingMore) return;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (reset) {
      setState(() {
        _isLoading = true;
        _users = [];
        _lastDoc = null;
        _hasMore = true;
      });
    } else {
      setState(() => _isFetchingMore = true);
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
          .limit(_pageSize);

      if (!reset && _lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }

      final snap = await query.get();

      final newUsers = snap.docs
          .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
          .where((u) => u.uid != currentUid)
          .toList();

      if (mounted) {
        setState(() {
          if (reset) {
            _users = newUsers;
          } else {
            _users.addAll(newUsers);
          }
          if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
          _hasMore = snap.docs.length == _pageSize;
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) {
      return u.name.toLowerCase().contains(_searchQuery) ||
          u.faculty.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;

    return Column(
      children: [
        // ── Search Bar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or major...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // ── List / Skeleton / Empty ───────────────────────────────────
        Expanded(
          child: _isLoading
              ? _buildSkeleton()
              : _filteredUsers.isEmpty
                  ? const Center(
                      child: Text(
                        'No peers found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _fetchPage(reset: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount:
                            _filteredUsers.length + (_isFetchingMore ? 1 : 0),
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == _filteredUsers.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          final peer = _filteredUsers[index];
                          final isConnected =
                              currentUser?.isFollowing(peer.uid) ?? false;
                          return _PeerCard(
                            peer: peer,
                            isConnected: isConnected,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      separatorBuilder: (context, _) => const SizedBox(height: 10),
      itemBuilder: (context, _) => const _SkeletonCard(),
    );
  }
}

// ── Peer card — stateless so only this widget rebuilds on connect ─────────────
class _PeerCard extends StatelessWidget {
  const _PeerCard({required this.peer, required this.isConnected});

  final UserModel peer;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  AppColors.primary.withValues(alpha: 0.15),
              backgroundImage: peer.avatarUrl.isNotEmpty
                  ? NetworkImage(peer.avatarUrl)
                  : null,
              child: peer.avatarUrl.isEmpty
                  ? Text(
                      peer.name.isNotEmpty
                          ? peer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peer.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (peer.faculty.isNotEmpty)
                    Text(
                      peer.faculty,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () =>
                  context.read<UserProvider>().toggleConnection(peer.uid),
              style: OutlinedButton.styleFrom(
                backgroundColor: isConnected ? AppColors.primary : null,
                foregroundColor:
                    isConnected ? Colors.white : AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                isConnected ? 'Connected' : 'Connect',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton placeholder card ────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _ShimmerBox(width: 52, height: 52, radius: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 140, height: 14),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 90, height: 12),
                ],
              ),
            ),
            _ShimmerBox(width: 84, height: 34, radius: 20),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox(
      {required this.width, required this.height, this.radius = 6});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
