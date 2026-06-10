import 'dart:async';
import 'dart:io';

import 'package:agapay_users/ui/screens/homepage/sos/groupchat_moder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupChatId; // Firestore document ID of the group
  const GroupChatScreen({super.key, required this.groupChatId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  bool _isSending = false;
  String? _rescuerName;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _groupChatSubscription;
  Set<String> _knownRescuerIds = <String>{};

  @override
  void initState() {
    super.initState();
    _watchRescuerName();
    _watchRescuerAccepted();
  }

  @override
  void dispose() {
    _groupChatSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>> get groupChatRef =>
      FirebaseFirestore.instance.collection('group_chats').doc(widget.groupChatId);

  /// Reference to the chat messages subcollection
  CollectionReference<Map<String, dynamic>> get messagesRef =>
      groupChatRef.collection('messages');

  void _watchRescuerAccepted() {
    _groupChatSubscription = groupChatRef.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data == null) return;

      final rescuerIds = _extractRescuerIds(data['rescuers'])
          .where((id) => id.isNotEmpty && id != currentUser?.uid)
          .toSet();

      if (_knownRescuerIds.isEmpty) {
        _knownRescuerIds = rescuerIds;
        return;
      }

      final newlyJoined = rescuerIds.difference(_knownRescuerIds);
      _knownRescuerIds = rescuerIds;

      for (final rescuerId in newlyJoined) {
        await _postRescuerJoinedMessage(rescuerId);
      }
    });
  }

  List<String> _extractRescuerIds(dynamic raw) {
    if (raw is! List) return const [];

    final ids = <String>[];
    for (final entry in raw) {
      if (entry is String && entry.trim().isNotEmpty) {
        ids.add(entry.trim());
      } else if (entry is Map) {
        final uid = (entry['uid'] ?? entry['id'] ?? '').toString().trim();
        if (uid.isNotEmpty) ids.add(uid);
      }
    }
    return ids;
  }

  Future<void> _postRescuerJoinedMessage(String rescuerId) async {
    final eventKey = 'rescuer_joined_$rescuerId';
    final existing = await messagesRef
        .where('type', isEqualTo: 'system')
        .where('eventKey', isEqualTo: eventKey)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final name = await _getNameByUserId(rescuerId);
    await messagesRef.add({
      ...ChatMessage(
        senderId: rescuerId,
        senderName: name,
        message: '$name joined the chat',
        type: 'system',
      ).toMap(),
      'eventKey': eventKey,
    });
  }

  /// Resolve a user's display name from Users/{uid} as First + Last
  Future<String> _getNameByUserId(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      final data = doc.data() ?? {};
      final first = (data['firstName'] ?? '').toString().trim();
      final last = (data['lastName'] ?? '').toString().trim();
      final full = [first, last].where((s) => s.isNotEmpty).join(' ');
      if (full.isNotEmpty) return full;
      final fallback = (data['displayName'] ?? data['name'] ?? '').toString().trim();
      return fallback.isNotEmpty ? fallback : 'User';
    } catch (_) {
      return 'User';
    }
  }

  /// Watch recent messages to infer rescuer (sender != current user)
  void _watchRescuerName() {
    messagesRef.orderBy('sentAt', descending: true).limit(20).snapshots().listen((snap) async {
      for (final d in snap.docs) {
        final data = d.data();
        final senderId = (data['senderId'] ?? '') as String;
        if (senderId.isNotEmpty && senderId != currentUser?.uid) {
          final name = await _getNameByUserId(senderId);
          if (mounted) setState(() => _rescuerName = name);
          break;
        }
      }
    });
  }

  /// Send a new message
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUser == null) return;

    final senderName = await _getNameByUserId(currentUser!.uid);
    final message = ChatMessage(
      senderId: currentUser!.uid,
      senderName: senderName,
      message: text,
      type: 'text',
    );

    await messagesRef.add(message.toMap());
    _messageController.clear();
  }

  Future<void> _sendImageMessage(ImageSource source) async {
    if (currentUser == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    try {
      setState(() => _isSending = true);
      final file = File(picked.path);
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('group_chats/${widget.groupChatId}/images/$fileName');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      final senderName = await _getNameByUserId(currentUser!.uid);
      final msg = ChatMessage(
        senderId: currentUser!.uid,
        senderName: senderName,
        message: '',
        type: 'image',
        mediaUrl: url,
      );
      await messagesRef.add(msg.toMap());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendVideoMessage(ImageSource source) async {
    if (currentUser == null) return;
    final picked = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked == null) return;

    try {
      setState(() => _isSending = true);
      final file = File(picked.path);
      final fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('group_chats/${widget.groupChatId}/videos/$fileName');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      final senderName = await _getNameByUserId(currentUser!.uid);
      final msg = ChatMessage(
        senderId: currentUser!.uid,
        senderName: senderName,
        message: '',
        type: 'video',
        mediaUrl: url,
      );
      await messagesRef.add(msg.toMap());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handlePickImage() async {
    final source = await _chooseSource(isVideo: false);
    if (source == null) return;
    await _sendImageMessage(source);
  }

  Future<void> _handlePickVideo() async {
    final source = await _chooseSource(isVideo: true);
    if (source == null) return;
    await _sendVideoMessage(source);
  }

  Future<ImageSource?> _chooseSource({required bool isVideo}) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text('Camera', style: GoogleFonts.poppins()),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery', style: GoogleFonts.poppins()),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideo(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(videoUrl: url),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMine) {
    if (msg.type == 'system') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            msg.message,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    Widget content;

    switch (msg.type) {
      case 'image':
        content = GestureDetector(
          onTap: msg.mediaUrl != null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(backgroundColor: Colors.black),
                        body: Center(
                          child: InteractiveViewer(
                            child: Image.network(msg.mediaUrl!),
                          ),
                        ),
                      ),
                    ),
                  )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: msg.mediaUrl != null
                ? Image.network(
                    msg.mediaUrl!,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  )
                : const SizedBox.shrink(),
          ),
        );
        break;
      case 'video':
        content = GestureDetector(
          onTap: msg.mediaUrl != null ? () => _openVideo(msg.mediaUrl!) : null,
          child: Container(
            width: 220,
            height: 150,
            decoration: BoxDecoration(
              color: isMine ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill,
                  size: 48,
                  color: isMine ? Colors.white : Colors.black87,
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(
                    'Video',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMine ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        content = Text(
          msg.message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isMine ? Colors.white : Colors.black87,
          ),
        );
        break;
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMine ? Colors.redAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMine ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                msg.senderName.isNotEmpty ? msg.senderName : (_rescuerName ?? 'Rescuer'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            content,
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.sentAt),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isMine ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _rescuerName == null || _rescuerName!.isEmpty
              ? 'Group Chat'
              : 'Connect with Rescuers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.redAccent,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 🔹 Real-time messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.orderBy('sentAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet.",
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  );
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return ChatMessage.fromSnapshot(doc);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.senderId == currentUser?.uid;
                    return _buildMessageBubble(msg, isMine);
                  },
                );
              },
            ),
          ),

          // 🔹 Message input field
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Attach image',
                    icon: const Icon(Icons.image_outlined),
                    color: Colors.redAccent,
                    onPressed: _isSending ? null : _handlePickImage,
                  ),
                  IconButton(
                    tooltip: 'Attach video',
                    icon: const Icon(Icons.videocam_outlined),
                    color: Colors.redAccent,
                    onPressed: _isSending ? null : _handlePickVideo,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: CircleAvatar(
                      backgroundColor:
                          _isSending ? Colors.grey : Colors.redAccent,
                      radius: 24,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format time to readable short form (e.g., 3:45 PM)
  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Video', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.redAccent,
                        bufferedColor: Colors.white54,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      child: IconButton(
                        iconSize: 48,
                        color: Colors.white,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.redAccent),
      ),
    );
  }
}
