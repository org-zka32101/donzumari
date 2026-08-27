import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_service.dart';
import '../../data/models/offline_model.dart';

/// Offline service provider
final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService();
});

/// Initialize offline service
final initializeOfflineProvider = FutureProvider<void>((ref) async {
  await OfflineService.initialize();
});

/// Network connectivity stream
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Network status provider
final networkStatusProvider = StateProvider<NetworkStatus>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);

  return connectivity.when(
    data: (result) {
      if (result == ConnectivityResult.none) {
        return NetworkStatus.offline;
      } else {
        return NetworkStatus.online;
      }
    },
    loading: () => NetworkStatus.online,
    error: (err, stack) => NetworkStatus.online,
  );
});

/// Offline mode toggle
final offlineModeProvider = StateProvider<bool>((ref) {
  return OfflineService.isOfflineMode;
});

/// Pending operations provider
final pendingOperationsProvider = FutureProvider<List<PendingOperation>>((ref) async {
  return OfflineService.getPendingOperations();
});

/// Sync queue statistics provider
final syncQueueStatsProvider = FutureProvider<SyncQueueStats>((ref) async {
  return await OfflineService.getSyncQueueStats();
});

/// Sync pending operations
final syncOperationsProvider = FutureProvider<SyncQueueStats>((ref) async {
  final stats = await OfflineService.syncPendingOperations();
  // Refresh dependent providers after sync
  ref.refresh(pendingOperationsProvider);
  ref.refresh(syncQueueStatsProvider);
  return stats;
});

/// Queue operation provider
final queueOperationProvider =
    FutureProvider.family<bool, (OfflineOperationType, Map<String, dynamic>)>((ref, args) async {
  final (type, data) = args;
  return await OfflineService.queueOperation(type, data);
});

/// Cache data provider
final cacheDataProvider = FutureProvider.family<bool, (String, String, Map<String, dynamic>)>(
    (ref, args) async {
  final (dataType, entityId, data) = args;
  return await OfflineService.cacheData(dataType, entityId, data);
});

/// Get cached data provider
final getCachedDataProvider =
    FutureProvider.family<OfflineCacheEntry?, String>((ref, cacheId) async {
  return OfflineService.getCachedData(cacheId);
});

/// Clear cache provider
final clearCacheProvider = FutureProvider<bool>((ref) async {
  final result = await OfflineService.clearCache();
  ref.refresh(getCachedDataProvider);
  return result;
});

/// Clear failed operations provider
final clearFailedOperationsProvider = FutureProvider<bool>((ref) async {
  final result = await OfflineService.clearFailedOperations();
  ref.refresh(pendingOperationsProvider);
  ref.refresh(syncQueueStatsProvider);
  return result;
});

/// Set offline mode provider
final setOfflineModeProvider =
    FutureProvider.family<void, bool>((ref, enabled) async {
  await OfflineService.setOfflineMode(enabled);
  ref.refresh(offlineModeProvider);
});
