import 'package:agapay_users/ui/screens/homepage/updates/community/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String? selfieUrl;
  final String content;
  final List<String> photoUrls;
  int likeCount;
  List<String> likedBy;
  final List<CommentModel> comments;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    this.selfieUrl,
    required this.content,
    this.photoUrls = const [],
    this.likeCount = 0,
    this.likedBy = const [],
    this.comments = const [],
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt == null) return DateTime.now();
      
      if (createdAt is Timestamp) {
        return createdAt.toDate();
      }
      
      if (createdAt is String) {
        return DateTime.tryParse(createdAt) ?? DateTime.now();
      }
      
      if (createdAt is int) {
        return DateTime.fromMillisecondsSinceEpoch(createdAt);
      }
      
      return DateTime.now();
    }

    return PostModel(
      postId: map['postId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      selfieUrl: map['selfieUrl']?.toString(),
      content: map['content']?.toString() ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      likeCount: (map['likeCount'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>?)
              ?.map((c) {
                if (c is Map<String, dynamic>) {
                  return CommentModel.fromMap(c);
                } else if (c is Map) {
                  return CommentModel.fromMap(Map<String, dynamic>.from(c));
                }
                return CommentModel.fromMap({});
              })
              .toList() ??
          [],
      createdAt: parseCreatedAt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'selfieUrl': selfieUrl,
      'content': content,
      'photoUrls': photoUrls,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'comments': comments.map((c) => c.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt), // Always use Timestamp for Firestore
    };
  }

  // Helper method for debugging
  @override
  String toString() {
    return 'PostModel(postId: $postId, likeCount: $likeCount, likedBy: $likedBy, createdAt: $createdAt)';
  }
}