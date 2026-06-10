import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔹 Global key for snackbar
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'agapay_channel',
    'Agapay Notifications',
    description: 'Channel for Agapay notifications',
    importance: Importance.max,
    playSound: true,
  );

  /// 🔔 Initialize notifications
  static Future<void> init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1️⃣ Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');

    // 2️⃣ Init local notifications
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // 3️⃣ Create Android channel
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 4️⃣ Save token immediately if user is already logged in
    await _saveTokenToUsers();

    // 5️⃣ Listen for token refresh (CRITICAL)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed');
      await _saveTokenToUsers(token: newToken);
    });

    // 6️⃣ Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notif = message.notification;
      if (notif == null) return;

      final title = notif.title ?? '';
      final body = notif.body ?? '';

      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      await _localNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
          ),
        ),
      );
    });

    // 7️⃣ Notification tap (background / terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened: ${message.data}');
    });
  }

  /// 🔹 SAVE TOKEN INTO Users/{uid}.fcmToken  (THIS FIXES YOUR ISSUE)
  static Future<void> _saveTokenToUsers({String? token}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('No logged-in user, skipping token save');
        return;
      }

      final String? tokenToSave =
          token ?? await FirebaseMessaging.instance.getToken();

      if (tokenToSave == null) {
        debugPrint('FCM token is null');
        return;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .set(
        {
          'fcmToken': tokenToSave,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      debugPrint('FCM token saved to Users/${user.uid}');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  static Future<void> syncFcmToken() async {}
}

/// 🔹 Background handler (required)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
}
