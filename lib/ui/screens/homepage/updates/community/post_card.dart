import 'dart:async';
import 'package:agapay_users/ui/screens/homepage/updates/community/comment_model.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/comment_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool initialIsLiked;
  final int initialLikeCount;
  final VoidCallback? onLikeChanged;

  const PostCard({
    super.key, 
    required this.post,
    this.initialIsLiked = false,
    this.initialLikeCount = 0,
    this.onLikeChanged,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late PostModel post; // Store local copy of post
  int commentCount = 0;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot>? _postSubscription;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    commentCount = post.comments.length;
    
    // Get current user ID
    final currentUserId = _auth.currentUser?.uid;
    
    // Initialize like state
    isLiked = widget.initialIsLiked || 
              (currentUserId != null && post.likedBy.contains(currentUserId));
    
    // Start listening for post updates
    _startListeningForUpdates();
  }

  void _startListeningForUpdates() {
    print('🎯 Setting up listener for post: ${post.postId}');
    
    // Listen for post updates (likes AND comments)
    _postSubscription = _firestore
        .collection('posts')
        .doc(post.postId)
        .snapshots()
        .listen((snapshot) {
      print('📡 Post snapshot update received');
      
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final currentUserId = _auth.currentUser?.uid;
        
        if (mounted) {
          setState(() {
            // Update likes
            post.likeCount = data['likeCount'] ?? 0;
            post.likedBy = List<String>.from(data['likedBy'] ?? []);
            isLiked = currentUserId != null && post.likedBy.contains(currentUserId);
            
            // Update comments from the post document array
            if (data['comments'] != null && data['comments'] is List) {
              final commentsList = data['comments'] as List<dynamic>;
              commentCount = commentsList.length;
              print('💬 Updated commentCount to: $commentCount');
              
              // Also update the post's comments array
              post.comments.clear();
              for (var commentData in commentsList) {
                try {
                  final commentMap = Map<String, dynamic>.from(commentData);
                  post.comments.add(CommentModel.fromMap(commentMap));
                } catch (e) {
                  debugPrint('Error parsing comment: $e');
                }
              }
            } else {
              // No comments array in document
              commentCount = 0;
              post.comments.clear();
            }
          });
        }
      }
    }, onError: (error) {
      print('❌ Post stream error: $error');
    });
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if post data changes
    if (oldWidget.post.postId != widget.post.postId) {
      final currentUserId = _auth.currentUser?.uid;
      
      setState(() {
        post = widget.post;
        commentCount = post.comments.length;
        isLiked = currentUserId != null && post.likedBy.contains(currentUserId);
      });
      
      // Restart subscription for new post
      _postSubscription?.cancel();
      _startListeningForUpdates();
    }
  }

  @override
  void dispose() {
    _postSubscription?.cancel();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore.collection('posts').doc(post.postId);
    
    // Save previous state for rollback
    final previousIsLiked = isLiked;
    final previousLikeCount = post.likeCount;
    final previousLikedBy = List<String>.from(post.likedBy);

    // Update UI immediately for better UX
    setState(() {
      isLiked = !isLiked;
      
      if (isLiked) {
        // Add like
        if (!post.likedBy.contains(user.uid)) {
          post.likedBy.add(user.uid);
        }
        post.likeCount++;
      } else {
        // Remove like
        post.likedBy.remove(user.uid);
        post.likeCount--;
      }
    });

    try {
      if (isLiked) {
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([user.uid]),
          'likeCount': FieldValue.increment(1),
        });
      } else {
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([user.uid]),
          'likeCount': FieldValue.increment(-1),
        });
      }
      
      // Notify parent widget about like change if callback exists
      widget.onLikeChanged?.call();
      
    } catch (e) {
      debugPrint('Error updating like: $e');
      
      // Rollback on error
      if (mounted) {
        setState(() {
          isLiked = previousIsLiked;
          post.likeCount = previousLikeCount;
          post.likedBy = previousLikedBy;
        });
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update like. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑 User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: post.selfieUrl != null
                      ? NetworkImage(post.selfieUrl!)
                      : null,
                  child: post.selfieUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  post.username,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(post.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                // Debug indicator
                
              ],
            ),

            const SizedBox(height: 8),

            // 📜 Post Text
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),

            // 🖼 Images (if any)
            if (post.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: post.photoUrls.length,
                  itemBuilder: (context, index) {
                    final imageUrl = post.photoUrls[index];
                    return InkWell(
                      onTap: () => _showImageOverlay(imageUrl),
                      borderRadius: BorderRadius.circular(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 10),

            // ❤️ Like and 💬 Comment Buttons
            Row(
              children: [
                _PostButton(
                  icon: isLiked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  color: isLiked ? Colors.blue : Colors.grey.shade700,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.likeCount}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 20),
                _PostButton(
                  icon: Icons.mode_comment_outlined,
                  onTap: () async {
                    print('🎯 Opening CommentSection...');
                    print('🎯 Current commentCount: $commentCount');
                    
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentSection(post: post),
                      ),
                    );
                    
                    print('🎯 Returned from CommentSection');
                    // Force a refresh by fetching the latest data
                    await _refreshPostData();
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '$commentCount',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${date.month}/${date.day}/${date.year}";
  }

  // Helper method to manually refresh post data
  Future<void> _refreshPostData() async {
    print('🔄 Manually refreshing post data');
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(post.postId)
          .get();
      
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        final currentUserId = _auth.currentUser?.uid;
        
        setState(() {
          // Update likes
          post.likeCount = data['likeCount'] ?? 0;
          post.likedBy = List<String>.from(data['likedBy'] ?? []);
          isLiked = currentUserId != null && post.likedBy.contains(currentUserId);
          
          // Update comments
          if (data['comments'] != null && data['comments'] is List) {
            final commentsList = data['comments'] as List<dynamic>;
            commentCount = commentsList.length;
            print('🔄 Manual refresh - commentCount: $commentCount');
            
            // Update post.comments array
            post.comments.clear();
            for (var commentData in commentsList) {
              try {
                final commentMap = Map<String, dynamic>.from(commentData);
                post.comments.add(CommentModel.fromMap(commentMap));
              } catch (e) {
                debugPrint('Error parsing comment: $e');
              }
            }
          }
        });
      }
    } catch (e) {
      print('❌ Manual refresh error: $e');
    }
  }

  void _showImageOverlay(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PostButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _PostButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: color ?? Colors.grey.shade700),
      ),
    );
  }
}