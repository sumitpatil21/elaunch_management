
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../Service/firebase_database.dart';

// Global function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
  log('Background message data: ${message.data}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
  FirebaseMessagingService._internal();

  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Navigation callback for handling notification taps
  Function(Map<String, dynamic>)? onNotificationTap;

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get and save FCM token
    // await _updateFCMToken();
    //
    // // Listen for token refresh
    // _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

    // Subscribe to general topic
    await _firebaseMessaging.subscribeToTopic('all_users');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'elaunch_chat_channel',
      'Chat Notifications',
      description: 'Notifications for chat messages',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');


    if (message.notification != null) {
    log('Message also contained a notification: ${message.notification}');

    // Only show local notification if it's a chat message
    if (message.data['type'] == 'chat') {
    await _showChatNotification(message);
    }
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('Notification tapped: ${message.data}');

    if (onNotificationTap != null) {
      onNotificationTap!(message.data);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    log('Notification clicked with payload: ${response.payload}');

    if (response.payload != null && onNotificationTap != null) {
      try {
        // Parse the payload if it's JSON
        final Map<String, dynamic> data = {};
        // Add your payload parsing logic here if needed
        onNotificationTap!(data);
      } catch (e) {
        log('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _showChatNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'elaunch_chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Colors.blue,
      playSound: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  // Future<void> _updateFCMToken() async {
  //   try {
  //     String? token = await getToken();
  //     if (token != null) {
  //       log('FCM Token: $token');
  //
  //       // Save token to Firestore if user is authenticated
  //       final currentUser = FirebaseAuth.instance.currentUser;
  //       if (currentUser != null) {
  //         await FirebaseDbHelper.firebase.updateEmployeeFCMToken(currentUser.uid, token);
  //       }
  //     }
  //   } catch (e) {
  //     log('Error updating FCM token: $e');
  //   }
  // }

  // Future<void> _onTokenRefresh(String token) async {
  //   log('FCM Token refreshed: $token');
  //
  //   try {
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       await FirebaseDbHelper.firebase.updateEmployeeFCMToken(currentUser.uid, token);
  //     }
  //   } catch (e) {
  //     log('Error updating refreshed FCM token: $e');
  //   }
  // }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  // Initialize chat-specific notifications
  Future<void> initializeChatNotifications(String userId) async {
    try {
      // Subscribe to user's personal topic for chat notifications
      await subscribeToTopic('chat_$userId');
      log('Initialized chat notifications for user: $userId');
    } catch (e) {
      log('Error initializing chat notifications: $e');
    }
  }

// Clean up chat notifications when user logs out
  Future<void> cleanupChatNotifications(String userId) async {
    try {
      await unsubscribeFromTopic('chat_$userId');
      log('Cleaned up chat notifications for user: $userId');
    } catch (e) {
      log('Error cleaning up chat notifications: $e');
    }
  }
}

// Notification handler utility class
class NotificationHandler {
  static void handleChatNotification(
      BuildContext context,
      Map<String, dynamic> data,
      ) {
    final String? senderId = data['senderId'];
    final String? senderName = data['senderName'];

    if (senderId != null && senderName != null) {
      // Navigate to chat screen
      // You'll need to implement this based on your navigation structure
      _navigateToChat(context, senderId, senderName);
    }
  }

  static void _navigateToChat(
      BuildContext context,
      String senderId,
      String senderName,
      ) {
    // Implementation depends on your navigation structure
    // This is a placeholder - customize based on your app's navigation
    log('Should navigate to chat with $senderName ($senderId)');


     Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'otherUserId': senderId,
        'otherUserName': senderName,
      },
    );
  }
}
