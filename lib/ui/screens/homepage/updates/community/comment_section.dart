import 'package:agapay_users/ui/screens/homepage/updates/community/comment_button.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/image_preview.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/like_button.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/post_model.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key, required this.post});
  final PostModel post;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // State variables
  bool _isLiked = false;
  int _likeCount = 0;
  List<String> _likedBy = [];
  List<CommentModel> _comments = [];
  String? _currentUserName;
  String? _currentUserPhotoUrl;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// ✅ Initialize all data
  Future<void> _initializeData() async {
    await _fetchCurrentUserData();
    await _loadPostData();
    await _loadComments();
    setState(() => _isLoading = false);
  }

  /// ✅ Fetch current user data
  Future<void> _fetchCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _currentUserId = user.uid;
    });

    try {
      final doc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _currentUserName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
          _currentUserPhotoUrl = data['selfieUrl'];
        });
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching user data: $e");
    }
  }

  /// ✅ Load post data including likes
  Future<void> _loadPostData() async {
    try {
      // Get the latest post data from Firestore
      final postDoc = await _firestore
          .collection('posts')
          .doc(widget.post.postId)
          .get();

      if (postDoc.exists) {
        final data = postDoc.data()!;
        setState(() {
          _likeCount = data['likeCount'] ?? 0;
          _likedBy = List<String>.from(data['likedBy'] ?? []);
          
          // Check if current user has liked this post
          if (_currentUserId != null) {
            _isLiked = _likedBy.contains(_currentUserId!);
          }
        });
      }
    } catch (e) {
      debugPrint("⚠️ Error loading post data: $e");
      // Fallback to widget data
      setState(() {
        _likeCount = widget.post.likeCount;
        _likedBy = widget.post.likedBy;
        if (_currentUserId != null) {
          _isLiked = _likedBy.contains(_currentUserId!);
        }
      });
    }
  }

  /// ✅ Load comments from the post
  Future<void> _loadComments() async {
    try {
      // First check if comments are stored in the post document
      final postDoc = await _firestore
          .collection('posts')
          .doc(widget.post.postId)
          .get();

      if (postDoc.exists) {
        final data = postDoc.data()!;
        
        // Check if comments are stored as an array in the post
        if (data['comments'] != null && data['comments'] is List) {
          final commentsList = data['comments'] as List<dynamic>;
          setState(() {
            _comments = commentsList
                .map((c) => CommentModel.fromMap(Map<String, dynamic>.from(c)))
                .toList();
          });
        } else {
          // If not, try to load from subcollection
          final commentsSnapshot = await _firestore
              .collection('posts')
              .doc(widget.post.postId)
              .collection('Comments')
              .orderBy('createdAt', descending: true)
              .get();

          setState(() {
            _comments = commentsSnapshot.docs
                .map((doc) => CommentModel.fromMap(doc.data()))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error loading comments: $e");
      // Fallback to widget data
      setState(() {
        _comments = widget.post.comments;
      });
    }
  }

  // ✅ Toggle Like with proper Firestore update
  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      _showToast("Please login to like posts");
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
      
      if (_isLiked) {
        // Add user to likedBy if not already there
        if (!_likedBy.contains(_currentUserId!)) {
          _likedBy.add(_currentUserId!);
        }
        _likeCount++;
      } else {
        // Remove user from likedBy
        _likedBy.remove(_currentUserId!);
        _likeCount--;
      }
    });

    try {
      // Update Firestore
      await _firestore
          .collection('posts')
          .doc(widget.post.postId)
          .update({
            'likeCount': _likeCount,
            'likedBy': _likedBy,
          });

      // Show feedback
      if (_isLiked) {
        _showToast("Post liked!");
      }
    } catch (e) {
      debugPrint("⚠️ Error updating like: $e");
      // Revert UI on error
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          _likedBy.remove(_currentUserId!);
          _likeCount--;
        } else {
          _likedBy.add(_currentUserId!);
          _likeCount++;
        }
      });
      _showToast("Failed to update like. Please try again.");
    }
  }

  // ✅ Custom toast overlay method
  void _showToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.20,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: _isLiked ? Colors.blue.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // 💬 Add Comment
  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _currentUserId == null) {
      _showToast("Please write a comment");
      return;
    }

    final newComment = CommentModel(
      commentId: const Uuid().v4(),
      userId: _currentUserId!,
      username: _currentUserName ?? "Unknown User",
      selfieUrl: _currentUserPhotoUrl,
      text: text,
      createdAt: DateTime.now(),
    );

    try {
      // Create a copy of current comments
      List<CommentModel> updatedComments = List.from(_comments);
      updatedComments.insert(0, newComment); // Add new comment at beginning
      
      // Update Firestore - store in post document
      await _firestore
          .collection('posts')
          .doc(widget.post.postId)
          .update({
            'comments': updatedComments.map((c) => c.toMap()).toList(),
          });

      // Update local state
      setState(() {
        _comments = updatedComments;
      });
      
      _commentController.clear();
      _showToast("Comment posted successfully!");
    } catch (e) {
      debugPrint("⚠️ Error adding comment: $e");
      // Try alternative: store in subcollection
      try {
        await _firestore
            .collection('posts')
            .doc(widget.post.postId)
            .collection('Comments')
            .doc(newComment.commentId)
            .set(newComment.toMap());

        // Update local state
        setState(() {
          _comments.insert(0, newComment);
        });
        
        _commentController.clear();
        _showToast("Comment posted successfully!");
      } catch (e2) {
        debugPrint("⚠️ Error adding comment to subcollection: $e2");
        _showToast("Failed to post comment. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(1, 47, 72, 1),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        title: Text(
          "Status Detail",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧑 Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 📜 Post Text
                  Text(
                    post.content,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🖼️ Post Images
                  if (post.photoUrls.isNotEmpty)
                    buildImageGrid(context, post.photoUrls),

                  const SizedBox(height: 15),

                  Text(
                    "${post.createdAt.toLocal()}".split('.')[0],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        // Like button with correct state
                        LikeButton(
                          isLiked: _isLiked,
                          likeCount: _likeCount,
                          onTap: _toggleLike,
                        ),
                        const SizedBox(width: 15),
                        CommentButton(
                          postId: post.postId,
                          commentCount: _comments.length,
                        ),
                      ],
                    ),
                  ),
                  
                  // Show who liked the post
                  if (_likedBy.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Liked by ${_likedBy.length} ${_likedBy.length == 1 ? 'person' : 'people'}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // 🗒️ Comments Section
                  if (_comments.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Comments (${_comments.length})",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF012F48),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._comments.map((comment) => _buildCommentItem(comment)).toList(),
                      ],
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          "No comments yet. Be the first to comment!",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 💬 Input Bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write comment...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF012F48),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: comment.selfieUrl != null
                ? NetworkImage(comment.selfieUrl!)
                : null,
            child: comment.selfieUrl == null
                ? const Icon(Icons.person, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF012F48),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${comment.createdAt.toLocal()}".split('.')[0],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}