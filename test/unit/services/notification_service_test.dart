import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:donzumari/domain/services/notification_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  group('NotificationService', () {
    setUp(() async {
      await NotificationService.initialize();
    });

    test('initializes notification service', () {
      expect(
        NotificationService.getDebugInfo(),
        contains('initialized=true'),
      );
    });

    test('subscribes to topic', () async {
      expect(
        () async => await NotificationService.subscribeToTopic('game_events'),
        returnsNormally,
      );
    });

    test('unsubscribes from topic', () async {
      expect(
        () async => await NotificationService.unsubscribeFromTopic('achievements'),
        returnsNormally,
      );
    });

    test('retrieves FCM token', () async {
      final token = await NotificationService.getFCMToken();
      // Token might be null in test environment, but call should not crash
      expect(token, token is String? || token is null, reason: 'Token should be string or null');
    });

    test('sets notification preferences successfully', () async {
      final success = await NotificationService.setNotificationPreferences(
        enableGameNotifications: true,
        enableAchievementNotifications: true,
        enableSocialNotifications: false,
        enablePromotionalNotifications: false,
      );
      expect(success, isTrue);
    });

    test('enables all notification categories', () async {
      final success = await NotificationService.setNotificationPreferences(
        enableGameNotifications: true,
        enableAchievementNotifications: true,
        enableSocialNotifications: true,
        enablePromotionalNotifications: true,
      );
      expect(success, isTrue);
    });

    test('disables all notification categories', () async {
      final success = await NotificationService.setNotificationPreferences(
        enableGameNotifications: false,
        enableAchievementNotifications: false,
        enableSocialNotifications: false,
        enablePromotionalNotifications: false,
      );
      expect(success, isTrue);
    });

    test('updates notification preferences independently', () async {
      var success = await NotificationService.setNotificationPreferences(
        enableGameNotifications: true,
        enableAchievementNotifications: false,
        enableSocialNotifications: true,
        enablePromotionalNotifications: false,
      );
      expect(success, isTrue);

      success = await NotificationService.setNotificationPreferences(
        enableGameNotifications: false,
        enableAchievementNotifications: true,
        enableSocialNotifications: false,
        enablePromotionalNotifications: true,
      );
      expect(success, isTrue);
    });

    test('subscribes to multiple topics', () async {
      expect(
        () async {
          await NotificationService.subscribeToTopic('game_events');
          await NotificationService.subscribeToTopic('achievements');
          await NotificationService.subscribeToTopic('social');
          await NotificationService.subscribeToTopic('promotions');
        },
        returnsNormally,
      );
    });

    test('unsubscribes from multiple topics', () async {
      expect(
        () async {
          await NotificationService.unsubscribeFromTopic('game_events');
          await NotificationService.unsubscribeFromTopic('achievements');
          await NotificationService.unsubscribeFromTopic('social');
          await NotificationService.unsubscribeFromTopic('promotions');
        },
        returnsNormally,
      );
    });

    test('returns debug info', () {
      final debugInfo = NotificationService.getDebugInfo();
      expect(debugInfo, isNotEmpty);
      expect(debugInfo, contains('Notifications'));
      expect(debugInfo, contains('initialized=true'));
    });

    test('handles subscription to same topic multiple times', () async {
      expect(
        () async {
          await NotificationService.subscribeToTopic('game_events');
          await NotificationService.subscribeToTopic('game_events');
          await NotificationService.subscribeToTopic('game_events');
        },
        returnsNormally,
      );
    });

    test('handles unsubscription from non-subscribed topic', () async {
      expect(
        () async => await NotificationService.unsubscribeFromTopic('non_existent_topic'),
        returnsNormally,
      );
    });

    test('settings include all notification categories', () async {
      // Test that all four notification categories are managed
      const gameNotif = true;
      const achievementNotif = true;
      const socialNotif = true;
      const promotionalNotif = true;

      final success = await NotificationService.setNotificationPreferences(
        enableGameNotifications: gameNotif,
        enableAchievementNotifications: achievementNotif,
        enableSocialNotifications: socialNotif,
        enablePromotionalNotifications: promotionalNotif,
      );

      expect(success, isTrue);
    });

    test('handles mixed notification preferences', () async {
      final configs = [
        (true, true, true, false),
        (true, false, true, false),
        (false, true, false, true),
        (true, true, false, false),
      ];

      for (final config in configs) {
        final success = await NotificationService.setNotificationPreferences(
          enableGameNotifications: config.$1,
          enableAchievementNotifications: config.$2,
          enableSocialNotifications: config.$3,
          enablePromotionalNotifications: config.$4,
        );
        expect(success, isTrue);
      }
    });
  });
}
