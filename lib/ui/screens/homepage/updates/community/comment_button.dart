// comment_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentButton extends StatelessWidget {
  final String postId;
  final int commentCount;
  
  const CommentButton({
    super.key,
    required this.postId,
    this.commentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.comment,
            color: Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            commentCount.toString(),
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}