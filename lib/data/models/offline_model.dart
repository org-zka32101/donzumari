import 'package:freezed_annotation/freezed_annotation.dart';

part 'offline_model.freezed.dart';
part 'offline_model.g.dart';

/// Sync status for offline operations
enum SyncStatus {
  pending,    // Waiting to sync
  syncing,    // Currently syncing
  synced,     // Successfully synced
  failed,     // Failed to sync
  cancelled,  // Cancelled by user
}

/// Offline operation type
enum OfflineOperationType {
  gameStart,
  gameEnd,
  scoreUpdate,
  purchase,
  achievementProgress,
  profileUpdate,
}

/// Pending offline operation
@freezed
class PendingOperation with _$PendingOperation {
  const factory PendingOperation({
    required String operationId,
    required OfflineOperationType type,
    required Map<String, dynamic> data,
    required SyncStatus status,
    required DateTime createdAt,
    required DateTime? lastSyncAttempt,
    required int syncAttempts,
    String? errorMessage,
  }) = _PendingOperation;

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      _$PendingOperationFromJson(json);
}

/// Offline cache entry for game session
@freezed
class OfflineCacheEntry with _$OfflineCacheEntry {
  const factory OfflineCacheEntry({
    required String cacheId,
    required String dataType,      // 'match', 'achievements', 'userStats'
    required String entityId,      // ID of the entity being cached
    required Map<String, dynamic> data,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime expiresAt,
  }) = _OfflineCacheEntry;

  factory OfflineCacheEntry.fromJson(Map<String, dynamic> json) =>
      _$OfflineCacheEntryFromJson(json);
}

/// Network status
enum NetworkStatus {
  online,
  offline,
  lowConnection,
}

/// Sync queue statistics
@freezed
class SyncQueueStats with _$SyncQueueStats {
  const factory SyncQueueStats({
    required int totalPending,
    required int totalSyncing,
    required int totalFailed,
    required int successfulSyncs,
    required DateTime lastSyncTime,
    required double successRate,  // 0-100 percentage
  }) = _SyncQueueStats;

  factory SyncQueueStats.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueStatsFromJson(json);
}

/// Offline session data
@freezed
class OfflineSessionData with _$OfflineSessionData {
  const factory OfflineSessionData({
    required String sessionId,
    required String userId,
    required bool isOfflineMode,
    required NetworkStatus networkStatus,
    required List<String> pendingOperationIds,
    required Map<String, dynamic> cachedData,
    required DateTime sessionStartTime,
    required DateTime lastActivity,
  }) = _OfflineSessionData;

  factory OfflineSessionData.fromJson(Map<String, dynamic> json) =>
      _$OfflineSessionDataFromJson(json);
}

/// Batch sync request
@freezed
class BatchSyncRequest with _$BatchSyncRequest {
  const factory BatchSyncRequest({
    required String batchId,
    required List<String> operationIds,
    required DateTime createdAt,
    required DateTime? syncedAt,
  }) = _BatchSyncRequest;

  factory BatchSyncRequest.fromJson(Map<String, dynamic> json) =>
      _$BatchSyncRequestFromJson(json);
}
