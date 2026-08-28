import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/offline_model.dart';

/// Service for handling offline functionality and data synchronization
class OfflineService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static late SharedPreferences _prefs;
  static bool _initialized = false;
  static bool _isOfflineMode = false;
  static NetworkStatus _networkStatus = NetworkStatus.online;

  // Constants
  static const String _pendingOpsKey = 'pending_operations';
  static const String _cacheKey = 'offline_cache';
  static const String _offlineModeKey = 'offline_mode';
  static const int _maxPendingOps = 100;
  static const int _cacheExpiryMinutes = 60;

  /// Initialize offline service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isOfflineMode = _prefs.getBool(_offlineModeKey) ?? false;
      _initialized = true;
      print('✅ Offline service initialized');
    } catch (e) {
      print('⚠️ Offline service initialization warning: $e');
    }
  }

  /// Check if device is in offline mode
  static bool get isOfflineMode => _isOfflineMode;

  /// Get current network status
  static NetworkStatus get networkStatus => _networkStatus;

  /// Set offline mode
  static Future<void> setOfflineMode(bool enabled) async {
    _ensureInitialized();
    try {
      _isOfflineMode = enabled;
      await _prefs.setBool(_offlineModeKey, enabled);
      print('🔌 Offline mode: ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('⚠️ Failed to set offline mode: $e');
    }
  }

  /// Update network status
  static void updateNetworkStatus(NetworkStatus status) {
    _networkStatus = status;
    print('📡 Network status: $status');
  }

  /// Queue an operation for offline sync
  static Future<bool> queueOperation(
    OfflineOperationType type,
    Map<String, dynamic> data,
  ) async {
    _ensureInitialized();

    try {
      final operations = _getPendingOperations();

      if (operations.length >= _maxPendingOps) {
        print('⚠️ Pending operations limit reached');
        return false;
      }

      final operation = PendingOperation(
        operationId: 'op_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        data: data,
        status: SyncStatus.pending,
        createdAt: DateTime.now(),
        lastSyncAttempt: null,
        syncAttempts: 0,
      );

      operations.add(operation);
      await _savePendingOperations(operations);

      print('📝 Operation queued: ${operation.operationId}');
      return true;
    } catch (e) {
      print('⚠️ Failed to queue operation: $e');
      return false;
    }
  }

  /// Get all pending operations
  static List<PendingOperation> getPendingOperations() {
    _ensureInitialized();
    return _getPendingOperations();
  }

  /// Sync all pending operations
  static Future<SyncQueueStats> syncPendingOperations() async {
    _ensureInitialized();

    try {
      final operations = _getPendingOperations();
      final updatedOperations = <PendingOperation>[];
      int successCount = 0;
      int failCount = 0;
      final now = DateTime.now();

      for (final operation in operations) {
        if (operation.status == SyncStatus.pending) {
          final success = await _syncOperation(operation);

          if (success) {
            successCount++;
            updatedOperations.add(operation.copyWith(
              status: SyncStatus.synced,
              lastSyncAttempt: now,
              syncAttempts: operation.syncAttempts + 1,
            ));
          } else {
            failCount++;
            updatedOperations.add(operation.copyWith(
              status: SyncStatus.failed,
              lastSyncAttempt: now,
              syncAttempts: operation.syncAttempts + 1,
              errorMessage: 'Sync failed',
            ));
          }
        } else {
          updatedOperations.add(operation);
        }
      }

      // Save updated operations
      await _savePendingOperations(updatedOperations);

      final stats = SyncQueueStats(
        totalPending: updatedOperations.where((op) => op.status == SyncStatus.pending).length,
        totalSyncing: 0,
        totalFailed: updatedOperations.where((op) => op.status == SyncStatus.failed).length,
        successfulSyncs: successCount,
        lastSyncTime: now,
        successRate:
            (successCount + failCount) > 0
                ? (successCount / (successCount + failCount) * 100).clamp(0.0, 100.0)
                : 0.0,
      );

      print('🔄 Sync complete: $successCount synced, $failCount failed');
      return stats;
    } catch (e) {
      print('⚠️ Failed to sync operations: $e');
      return SyncQueueStats(
        totalPending: 0,
        totalSyncing: 0,
        totalFailed: 0,
        successfulSyncs: 0,
        lastSyncTime: DateTime.now(),
        successRate: 0.0,
      );
    }
  }

  /// Cache data for offline access
  static Future<bool> cacheData(
    String dataType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    _ensureInitialized();

    try {
      final cacheId = '${dataType}_$entityId';
      final entry = OfflineCacheEntry(
        cacheId: cacheId,
        dataType: dataType,
        entityId: entityId,
        data: data,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: _cacheExpiryMinutes)),
      );

      final cacheKeyForId = '${_cacheKey}_$cacheId';
      final cacheJson = jsonEncode(entry.toJson());
      await _prefs.setString(cacheKeyForId, cacheJson);

      print('💾 Data cached: ${entry.cacheId}');
      return true;
    } catch (e) {
      print('⚠️ Failed to cache data: $e');
      return false;
    }
  }

  /// Retrieve cached data
  static OfflineCacheEntry? getCachedData(String cacheId) {
    _ensureInitialized();
    try {
      final cacheKeyForId = '${_cacheKey}_$cacheId';
      final cachedJson = _prefs.getString(cacheKeyForId);
      if (cachedJson == null) return null;

      final entry = OfflineCacheEntry.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);

      // Check if cache has expired
      if (entry.expiresAt.isBefore(DateTime.now())) {
        _prefs.remove(cacheKeyForId);
        print('🗑️ Cache expired: $cacheId');
        return null;
      }

      print('📂 Cache retrieved: $cacheId');
      return entry;
    } catch (e) {
      print('⚠️ Failed to retrieve cached data: $e');
      return null;
    }
  }

  // Private helpers

  /// Clear all cache
  static Future<bool> clearCache() async {
    _ensureInitialized();

    try {
      final allKeys = _prefs.getKeys();
      final cacheKeys = allKeys.where((key) => key.startsWith(_cacheKey)).toList();

      for (final key in cacheKeys) {
        await _prefs.remove(key);
      }

      print('🗑️ Cache cleared');
      return true;
    } catch (e) {
      print('⚠️ Failed to clear cache: $e');
      return false;
    }
  }

  /// Clear failed operations
  static Future<bool> clearFailedOperations() async {
    _ensureInitialized();

    try {
      final operations = _getPendingOperations();
      final remaining = operations
          .where((op) => op.status != SyncStatus.failed)
          .toList();

      await _savePendingOperations(remaining);
      print('🗑️ Failed operations cleared');
      return true;
    } catch (e) {
      print('⚠️ Failed to clear failed operations: $e');
      return false;
    }
  }

  /// Get sync queue statistics
  static Future<SyncQueueStats> getSyncQueueStats() async {
    _ensureInitialized();

    try {
      final operations = _getPendingOperations();
      final synced = operations.where((op) => op.status == SyncStatus.synced).length;
      final failed = operations.where((op) => op.status == SyncStatus.failed).length;
      final pending = operations.where((op) => op.status == SyncStatus.pending).length;

      final successRate = (synced + failed) > 0
          ? (synced / (synced + failed) * 100).clamp(0.0, 100.0)
          : 0.0;

      return SyncQueueStats(
        totalPending: pending,
        totalSyncing: 0,
        totalFailed: failed,
        successfulSyncs: synced,
        lastSyncTime: DateTime.now(),
        successRate: successRate,
      );
    } catch (e) {
      print('⚠️ Failed to get sync stats: $e');
      return SyncQueueStats(
        totalPending: 0,
        totalSyncing: 0,
        totalFailed: 0,
        successfulSyncs: 0,
        lastSyncTime: DateTime.now(),
        successRate: 0.0,
      );
    }
  }

  // Private helper methods

  /// Sync a single operation to Firestore
  static Future<bool> _syncOperation(PendingOperation operation) async {
    try {
      switch (operation.type) {
        case OfflineOperationType.gameStart:
          await _firestore.collection('gameEvents').add(operation.data);
          break;
        case OfflineOperationType.gameEnd:
          await _firestore.collection('gameResults').add(operation.data);
          break;
        case OfflineOperationType.scoreUpdate:
          await _firestore.collection('scoreUpdates').add(operation.data);
          break;
        case OfflineOperationType.purchase:
          await _firestore.collection('purchases').add(operation.data);
          break;
        case OfflineOperationType.achievementProgress:
          await _firestore.collection('achievements').add(operation.data);
          break;
        case OfflineOperationType.profileUpdate:
          await _firestore.collection('profileUpdates').add(operation.data);
          break;
      }
      return true;
    } catch (e) {
      print('⚠️ Operation sync failed: $e');
      return false;
    }
  }

  /// Get pending operations from local storage
  static List<PendingOperation> _getPendingOperations() {
    try {
      final opsJson = _prefs.getString(_pendingOpsKey);
      if (opsJson == null) return [];

      final data = jsonDecode(opsJson);
      return (data as List)
          .map((item) => PendingOperation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('⚠️ Failed to get pending operations: $e');
      return [];
    }
  }

  /// Save pending operations to local storage
  static Future<bool> _savePendingOperations(
      List<PendingOperation> operations) async {
    try {
      final json = jsonEncode(operations.map((op) => op.toJson()).toList());
      return await _prefs.setString(_pendingOpsKey, json);
    } catch (e) {
      print('⚠️ Failed to save pending operations: $e');
      return false;
    }
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'OfflineService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    final ops = _getPendingOperations();
    return 'Offline: initialized=$_initialized, mode=$_isOfflineMode, '
        'pending=${ops.where((op) => op.status == SyncStatus.pending).length}';
  }
}
