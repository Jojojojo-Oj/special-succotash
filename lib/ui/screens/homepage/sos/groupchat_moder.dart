import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  final String? id;                   // Firestore document ID (subcollection)
  final String senderId;
  final List<String> rescuers;
  final List<ChatMessage> messages;
  final Timestamp createdAt;

  GroupChat({
    this.id,
    required this.senderId,
    required this.rescuers,
    this.messages = const [],
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'rescuers': rescuers,
      'createdAt': createdAt,
    };
  }

  factory GroupChat.fromMap(Map<String, dynamic> map, {String? id}) {
    return GroupChat(
      id: id,
      senderId: map['senderId'] ?? '',
      rescuers: List<String>.from(map['rescuers'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  factory GroupChat.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupChat.fromMap(data, id: doc.id);
  }
}

class ChatMessage {
  final String? id;
  final String senderId;
  final String senderName;
  final String message; // For text messages; empty for media/audio
  final String type; // text | image | audio
  final String? mediaUrl; // Image or audio URL
  final int? audioDurationSec; // Optional audio duration
  final Timestamp sentAt;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.type = 'text',
    this.mediaUrl,
    this.audioDurationSec,
    Timestamp? sentAt,
  }) : sentAt = sentAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'type': type,
      'mediaUrl': mediaUrl,
      'audioDurationSec': audioDurationSec,
      'sentAt': sentAt,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'text',
      mediaUrl: map['mediaUrl'] as String?,
      audioDurationSec: map['audioDurationSec'] as int?,
      sentAt: map['sentAt'] ?? Timestamp.now(),
    );
  }

  factory ChatMessage.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromMap(data, id: doc.id);
  }
}
