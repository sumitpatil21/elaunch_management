
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Function(Map<String, dynamic>)? onNotificationTap;

  Future<void> initialize() async {
    try {
      // Skip Firebase Messaging initialization for web platform
      if (kIsWeb) {
        debugPrint('Firebase Messaging skipped for web platform');
        return;
      }

      // Request permission for mobile platforms
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
        return;
      }

      // Get token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification}');
          _showForegroundNotification(message);
        }
      });

      // Handle when app is in background but opened
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened from background: ${message.data}');
        if (onNotificationTap != null) {
          onNotificationTap!(message.data);
        }
      });

      // Handle initial message when app is launched from terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Initial message: ${initialMessage.data}');
        if (onNotificationTap != null) {
          onNotificationTap!(initialMessage.data);
        }
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    // You can implement local notifications here if needed
    // For now, just print the notification
    debugPrint('Foreground notification: ${message.notification?.title}');
    debugPrint('Foreground notification body: ${message.notification?.body}');
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) return;

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) return;

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) return null;

    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) return;

    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Background message data: ${message.data}");
}
