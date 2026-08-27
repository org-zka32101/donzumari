import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification type
enum NotificationType {
  gameEvent,
  achievement,
  social,
  promotion,
  system,
}

/// App notification
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String notificationId,
    required String title,
    required String body,
    required NotificationType type,
    required DateTime sentAt,
    required DateTime? readAt,
    required Map<String, dynamic>? data,
    required bool isRead,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

/// Notification preferences
@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    required bool enableGameNotifications,
    required bool enableAchievementNotifications,
    required bool enableSocialNotifications,
    required bool enablePromotionalNotifications,
    required bool soundEnabled,
    required bool vibrationEnabled,
    required String? quietHoursStart,    // HH:mm format
    required String? quietHoursEnd,      // HH:mm format
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}
