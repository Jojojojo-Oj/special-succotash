import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post_model.dart';

class CustomPostDialog extends StatefulWidget {
  const CustomPostDialog({super.key});

  @override
  State<CustomPostDialog> createState() => _CustomPostDialogState();
}

class _CustomPostDialogState extends State<CustomPostDialog> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedImages = [];

  String? _userName;
  String? _selfieUrl;
  bool _isLoadingUser = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        final firstName = doc.data()?['firstName'] ?? '';
        final lastName = doc.data()?['lastName'] ?? '';
        final selfieUrl = doc.data()?['selfieUrl'] ?? user.photoURL;

        setState(() {
          _userName = "$firstName $lastName".trim().isEmpty
              ? (user.displayName ?? 'Anonymous')
              : "$firstName $lastName";
          _selfieUrl = selfieUrl;
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _userName = 'Guest';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() {
        _userName = 'Unknown';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    final content = _textController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something or add a photo.")),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final postId = FirebaseFirestore.instance.collection('posts').doc().id;
      final storageRef =
          FirebaseStorage.instance.ref().child('posts/${user.uid}/$postId');

      // Upload photos to Firebase Storage
      List<String> photoUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final photoRef = storageRef.child('photo_$i.jpg');
        await photoRef.putFile(_selectedImages[i]);
        final downloadUrl = await photoRef.getDownloadURL();
        photoUrls.add(downloadUrl);
      }

      // Create post model
      final newPost = PostModel(
        postId: postId,
        userId: user.uid,
        username: _userName ?? "Unknown",
        selfieUrl: _selfieUrl,
        content: content,
        likeCount: 0, 
        likedBy: [],
        comments: [],
        photoUrls: photoUrls,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .set(newPost.toMap());

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error posting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to post. Please try again.")),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoadingUser
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Profile Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              _selfieUrl != null ? NetworkImage(_selfieUrl!) : null,
                          child: _selfieUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            _userName ?? "Unknown User",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Text Input
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Image Grid
                    if (_selectedImages.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedImages.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 16),

                    // 🔹 Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPosting ? null : _pickMultipleImages,
                            icon: const Icon(Icons.image_outlined,
                                color: Colors.white),
                            label: Text(
                              "Photos",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF022B3A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPosting ? null : _submitPost,
                            icon: _isPosting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            label: Text(
                              _isPosting ? "Posting..." : "Post",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F7A8C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
