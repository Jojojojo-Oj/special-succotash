class CommentModel {
  final String commentId;
  final String userId;
  final String username;
  final String? selfieUrl;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.username,
    required this.selfieUrl,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'username': username,
      'selfieUrl': selfieUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      selfieUrl: map['selfieUrl'],
      text: map['text'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
