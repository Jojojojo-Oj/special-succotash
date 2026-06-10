import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/create_a_post.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/post_card.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/post_model.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;
  String? _profileUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      await _getProfileUrl();
    }
  }

  Future<void> _getProfileUrl() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _profileUrl = data?['selfieUrl'] as String?;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile URL: $e");
    }
  }

  // Function to handle like updates
  Future<void> _handleLikeToggle(String postId, bool isCurrentlyLiked, int currentLikeCount, List<String> currentLikedBy) async {
    if (_currentUserId == null) return;

    try {
      if (isCurrentlyLiked) {
        // Unlike: remove user from likedBy and decrement count
        currentLikedBy.remove(_currentUserId!);
        await _firestore.collection('posts').doc(postId).update({
          'likeCount': currentLikeCount - 1,
          'likedBy': currentLikedBy,
        });
      } else {
        // Like: add user to likedBy and increment count
        if (!currentLikedBy.contains(_currentUserId!)) {
          currentLikedBy.add(_currentUserId!);
        }
        await _firestore.collection('posts').doc(postId).update({
          'likeCount': currentLikeCount + 1,
          'likedBy': currentLikedBy,
        });
      }
    } catch (e) {
      debugPrint("Error updating like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CreateAPost(
                  onPostCreated: (_) {},
                  profileUrl: _profileUrl,
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "No posts yet. Be the first to share!",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            );
          }

          final posts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Convert to PostModel with proper parsing
            return PostModel.fromMap(data);
          }).toList();

          return ListView(
  padding: const EdgeInsets.all(16),
  children: [
    CreateAPost(
      onPostCreated: (_) {},
      profileUrl: _profileUrl,
    ),
    const SizedBox(height: 12),
    ...posts.map((post) {
      final currentUserId = _auth.currentUser?.uid;
      final isLiked = currentUserId != null && post.likedBy.contains(currentUserId);
      
      return PostCard(
        post: post,
        initialIsLiked: isLiked,
        initialLikeCount: post.likeCount,
        onLikeChanged: () {
          // Optional: Refresh the posts stream or update local state
          setState(() {});
        },
      );
    }).toList(),
  ],
);
        },
      ),
    );
  }
}