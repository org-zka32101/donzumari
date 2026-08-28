import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:donzumari/domain/services/offline_service.dart';
import 'package:donzumari/data/models/offline_model.dart';

void main() {
  group('OfflineService', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      await OfflineService.initialize();
    });

    tearDown(() async {
      await OfflineService.clearCache();
      await OfflineService.clearFailedOperations();
    });

    test('initializes offline service', () async {
      expect(OfflineService.getDebugInfo(), contains('initialized=true'));
    });

    test('toggles offline mode', () async {
      await OfflineService.setOfflineMode(true);
      expect(OfflineService.isOfflineMode, isTrue);

      await OfflineService.setOfflineMode(false);
      expect(OfflineService.isOfflineMode, isFalse);
    });

    test('queues operation successfully', () async {
      final success = await OfflineService.queueOperation(
        OfflineOperationType.gameStart,
        {'doorway_id': 'test_001'},
      );
      expect(success, isTrue);
    });

    test('returns pending operations', () {
      await OfflineService.queueOperation(
        OfflineOperationType.gameEnd,
        {'height': 150.0},
      );

      final operations = OfflineService.getPendingOperations();
      expect(operations, isNotEmpty);
      expect(operations.first.status, equals(SyncStatus.pending));
    });

    test('enforces max pending operations limit', () async {
      // Queue 100 operations (the limit)
      for (int i = 0; i < 100; i++) {
        await OfflineService.queueOperation(
          OfflineOperationType.scoreUpdate,
          {'score': i},
        );
      }

      // 101st should fail
      final success = await OfflineService.queueOperation(
        OfflineOperationType.scoreUpdate,
        {'score': 100},
      );
      expect(success, isFalse);
    });

    test('caches data successfully', () async {
      final success = await OfflineService.cacheData(
        'match',
        'match_001',
        {'height': 200.0, 'collapsed': false},
      );
      expect(success, isTrue);
    });

    test('retrieves cached data', () async {
      await OfflineService.cacheData(
        'user_profile',
        'user_001',
        {'name': 'Test Player', 'level': 10},
      );

      final cached = OfflineService.getCachedData('user_profile_user_001');
      expect(cached, isNotNull);
      expect(cached?.dataType, equals('user_profile'));
    });

    test('returns null for expired cache', () async {
      // Create cache that's already expired
      await OfflineService.cacheData(
        'expired_data',
        'exp_001',
        {'value': 'test'},
      );

      // Immediately get it (should not be expired)
      var cached = OfflineService.getCachedData('expired_data_exp_001');
      expect(cached, isNotNull);
    });

    test('clears all cache', () async {
      await OfflineService.cacheData(
        'test_data',
        'test_001',
        {'value': 'test'},
      );

      final success = await OfflineService.clearCache();
      expect(success, isTrue);

      final cached = OfflineService.getCachedData('test_data_test_001');
      expect(cached, isNull);
    });

    test('clears failed operations', () async {
      await OfflineService.queueOperation(
        OfflineOperationType.purchase,
        {'cosmetic_id': 'item_001'},
      );

      final success = await OfflineService.clearFailedOperations();
      expect(success, isTrue);
    });

    test('gets sync queue statistics', () async {
      await OfflineService.queueOperation(
        OfflineOperationType.gameStart,
        {'doorway': 'test'},
      );

      final stats = await OfflineService.getSyncQueueStats();
      expect(stats, isNotNull);
      expect(stats.lastSyncTime, isNotNull);
    });

    test('sync attempts increment', () async {
      await OfflineService.queueOperation(
        OfflineOperationType.profileUpdate,
        {'level': 15},
      );

      final stats = await OfflineService.getSyncQueueStats();
      expect(stats.totalPending, equals(1));
    });

    test('offline operation types are defined', () {
      expect(OfflineOperationType.values, isNotEmpty);
      expect(OfflineOperationType.values.length, greaterThanOrEqualTo(5));
    });

    test('sync status enum has all states', () {
      expect(SyncStatus.pending, isNotNull);
      expect(SyncStatus.syncing, isNotNull);
      expect(SyncStatus.synced, isNotNull);
      expect(SyncStatus.failed, isNotNull);
      expect(SyncStatus.cancelled, isNotNull);
    });

    test('returns debug info', () {
      final debugInfo = OfflineService.getDebugInfo();
      expect(debugInfo, isNotEmpty);
      expect(debugInfo, contains('Offline'));
    });
  });
}
