import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/models/notification_model.dart';

/// Service for managing push notifications
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;
  static StreamSubscription<RemoteMessage>? _messageSubscription;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryForward: true,
        critical: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
      } else {
        print('⚠️ Notification permissions denied');
      }

      // Get FCM token
      final token = await _messaging.getToken();
      print('🔔 FCM Token: ${token?.substring(0, 20)}...');

      // Handle foreground messages - store subscription to prevent memory leak
      _messageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 Foreground notification: ${message.notification?.title}');
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      _initialized = true;
      print('✅ Notification service initialized');
    } catch (e) {
      print('⚠️ Notification service initialization warning: $e');
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    _ensureInitialized();
    try {
      await _messaging.subscribeToTopic(topic);
      print('📬 Subscribed to topic: $topic');
    } catch (e) {
      print('⚠️ Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    _ensureInitialized();
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('📬 Unsubscribed from topic: $topic');
    } catch (e) {
      print('⚠️ Failed to unsubscribe from topic: $e');
    }
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    _ensureInitialized();
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('⚠️ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Set user notification preferences
  static Future<bool> setNotificationPreferences({
    required bool enableGameNotifications,
    required bool enableAchievementNotifications,
    required bool enableSocialNotifications,
    required bool enablePromotionalNotifications,
  }) async {
    _ensureInitialized();
    try {
      // Subscribe/unsubscribe based on preferences
      if (enableGameNotifications) {
        await subscribeToTopic('game_events');
      } else {
        await unsubscribeFromTopic('game_events');
      }

      if (enableAchievementNotifications) {
        await subscribeToTopic('achievements');
      } else {
        await unsubscribeFromTopic('achievements');
      }

      if (enableSocialNotifications) {
        await subscribeToTopic('social');
      } else {
        await unsubscribeFromTopic('social');
      }

      if (enablePromotionalNotifications) {
        await subscribeToTopic('promotions');
      } else {
        await unsubscribeFromTopic('promotions');
      }

      print('📬 Notification preferences updated');
      return true;
    } catch (e) {
      print('⚠️ Failed to set notification preferences: $e');
      return false;
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Notifications: initialized=$_initialized';
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'NotificationService not initialized. Call initialize() first.',
      );
    }
  }

  /// Dispose notification service and clean up subscriptions
  static void dispose() {
    _messageSubscription?.cancel();
    print('🔔 Notification service disposed');
  }
}

/// Handle background messages
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('🔔 Background notification: ${message.notification?.title}');
}
