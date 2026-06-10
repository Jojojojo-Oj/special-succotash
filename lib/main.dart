import 'package:agapay_users/firebase_options.dart';
import 'package:agapay_users/ui/screens/HOMEPAGE/control_page.dart';
import 'package:agapay_users/ui/screens/auth/login/Login.dart';
import 'package:agapay_users/ui/screens/onboarding/Onboarding.dart';
import 'package:agapay_users/ui/screens/auth/verification/verification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Register background handler
  FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler); // Top-level function

  // ✅ SharedPreferences for onboarding
  final prefs = await SharedPreferences.getInstance();
  final bool? seenOnboarding = prefs.getBool('seenOnboarding');

  runApp(MainApp(seenOnboarding: seenOnboarding ?? false));

  NotificationService.init()
      .timeout(const Duration(seconds: 8))
      .catchError((error) {
    debugPrint('Notification initialization skipped: $error');
  });
}

/// 🔹 Main app
class MainApp extends StatelessWidget {
  final bool seenOnboarding;
  const MainApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    // NotificationService already initialized in main

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: seenOnboarding ? const AuthStateWrapper() : const Onboarding(),
    );
  }
}

/// 🔹 Auth + Firestore wrapper
class AuthStateWrapper extends StatelessWidget {
  const AuthStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // ❌ No Firestore document
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const LoginScreen();
              }

              // ✅ Check status
              final data =
                  userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              final status = data['status'] ?? 'pending';

              if (status == 'approved') {
                return Homepage();
              } else if (status == 'pending') {
                return const VerificationPage();
              } else {
                return const LoginScreen();
              }
            },
          );
        }

        // 🔐 Not logged in
        return const LoginScreen();
      },
    );
  }
}
