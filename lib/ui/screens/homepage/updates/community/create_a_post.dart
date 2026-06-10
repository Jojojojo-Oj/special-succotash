import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_dialog.dart';
import 'post_model.dart';

class CreateAPost extends StatelessWidget {
  final void Function(PostModel) onPostCreated;
  final String? profileUrl;

  const CreateAPost({
    super.key,
    required this.onPostCreated,
    this.profileUrl,
  });

  void _openPostDialog(BuildContext context) async {
    final newPost = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CustomPostDialog(),
    );

    if (newPost != null) {
      onPostCreated(newPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPostDialog(context),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: profileUrl != null
                        ? NetworkImage(profileUrl!)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        "Share status...",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openPostDialog(context),
                    icon: const Icon(Icons.image_outlined, color: Colors.white),
                    label: Text(
                      "Post a Photo",
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
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 130,
                    child: ElevatedButton.icon(
                      onPressed: () => _openPostDialog(context),
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        "Post",
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
