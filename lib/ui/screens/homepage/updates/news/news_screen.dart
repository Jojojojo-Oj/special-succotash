import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'news_card.dart';
import 'news_model.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('news')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading news"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No news available"));
          }

          final newsList = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return NewsModel.fromMap(data);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return NewsCard(news: newsList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
