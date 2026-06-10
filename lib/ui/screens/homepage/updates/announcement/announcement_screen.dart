import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agapay_users/ui/screens/homepage/updates/News/news_card.dart';
import 'package:agapay_users/ui/screens/homepage/updates/News/news_model.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading announcements"));
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No announcements available"));
          }

          // Parse Firestore documents into NewsModel objects
          final announcementList = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return NewsModel.fromMap(data);
          }).toList();

          // Display announcement list
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemCount: announcementList.length,
              itemBuilder: (context, index) {
                return NewsCard(news: announcementList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
