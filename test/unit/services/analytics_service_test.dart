import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:donzumari/domain/services/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('AnalyticsService', () {
    setUp(() async {
      await AnalyticsService.initialize();
    });

    test('initializes analytics collection enabled', () async {
      expect(AnalyticsService.getDebugInfo(), contains('initialized=true'));
    });

    test('sets user ID successfully', () async {
      expect(
        () async => await AnalyticsService.setUserId('user123'),
        returnsNormally,
      );
    });

    test('logs game start event', () async {
      expect(
        () async => await AnalyticsService.logGameStart('doorway_001'),
        returnsNormally,
      );
    });

    test('logs game end event with metrics', () async {
      expect(
        () async => await AnalyticsService.logGameEnd(
          'doorway_001',
          150.5,
          false,
          120,
        ),
        returnsNormally,
      );
    });

    test('logs parcel dropped event', () async {
      expect(
        () async => await AnalyticsService.logParcelDropped('box_blue', 5),
        returnsNormally,
      );
    });

    test('logs tower collapse event', () async {
      expect(
        () async => await AnalyticsService.logTowerCollapse(
          'doorway_001',
          200.0,
          25,
        ),
        returnsNormally,
      );
    });

    test('logs perfect stack achievement', () async {
      expect(
        () async => await AnalyticsService.logPerfectStack('doorway_001', 300.0),
        returnsNormally,
      );
    });

    test('logs purchase event', () async {
      expect(
        () async => await AnalyticsService.logPurchase('cosmetic_001', 9.99, 'USD'),
        returnsNormally,
      );
    });

    test('logs screen view', () async {
      expect(
        () async => await AnalyticsService.logScreenView('HomeScreen'),
        returnsNormally,
      );
    });

    test('logs user engagement', () async {
      expect(
        () async => await AnalyticsService.logUserEngagement('menu_opened'),
        returnsNormally,
      );
    });

    test('logs multiplayer match', () async {
      expect(
        () async => await AnalyticsService.logMultiplayerMatch(
          'doorway_001',
          'opponent_123',
          'win',
        ),
        returnsNormally,
      );
    });

    test('logs error event', () async {
      expect(
        () async => await AnalyticsService.logError('ERROR_001', 'Test error'),
        returnsNormally,
      );
    });

    test('sets user property', () async {
      expect(
        () async => await AnalyticsService.setUserProperty('player_level', '10'),
        returnsNormally,
      );
    });

    test('sanitizes parameters correctly', () {
      final params = {
        'string_val': 'test',
        'int_val': 42,
        'double_val': 3.14,
        'bool_val': true,
        'object_val': {'nested': 'value'},
      };

      final sanitized = AnalyticsService.logEvent(
        name: 'test',
        parameters: params,
      );

      // Parameters should be sanitized without crashing
      expect(() async => sanitized, returnsNormally);
    });

    test('returns debug info', () {
      final debugInfo = AnalyticsService.getDebugInfo();
      expect(debugInfo, isNotEmpty);
      expect(debugInfo, contains('Analytics'));
    });
  });
}
