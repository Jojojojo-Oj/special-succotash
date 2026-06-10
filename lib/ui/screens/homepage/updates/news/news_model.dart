import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String title;
  final Timestamp date; // ✅ changed from String → Timestamp
  final String content;
  final String imagePath;

  NewsModel({
    required this.title,
    required this.date,
    required this.content,
    required this.imagePath,
  });

  factory NewsModel.fromMap(Map<String, dynamic> data) {
    return NewsModel(
      title: data['title'] ?? '',
      date: data['date'] is Timestamp
          ? data['date']
          : Timestamp.now(), // ✅ fallback if missing or wrong type
      content: data['content'] ?? '',
      imagePath: data['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'content': content,
      'imagePath': imagePath,
    };
  }
}
