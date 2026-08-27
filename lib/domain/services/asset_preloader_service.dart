import '../../data/fixtures/asset_registry.dart';

/// Service for preloading and tracking asset loading progress
class AssetPreloaderService {
  static final Map<String, AssetLoadingStatus> _loadingStatus = {};
  static int _totalAssetsToLoad = 0;
  static int _assetsLoaded = 0;
  static bool _isPreloading = false;

  // Callback for progress updates
  static Function(double progress)? onProgressUpdate;
  static Function(String assetId, String type)? onAssetLoaded;
  static Function(String assetId, String type, String error)? onAssetFailed;

  /// Start preloading all critical assets
  static Future<void> preloadCriticalAssets() async {
    if (_isPreloading) return;

    _isPreloading = true;
    _assetsLoaded = 0;
    _loadingStatus.clear();

    try {
      // Preload stable parcel sprites (high priority)
      final stableSprites = AssetRegistry.getSpritesByCategory('stable');
      _totalAssetsToLoad = stableSprites.length;

      print('📦 Starting asset preload: $_totalAssetsToLoad assets');

      for (final spriteId in stableSprites) {
        await _preloadSprite(spriteId);
      }

      print('✅ Asset preload complete: $_assetsLoaded/$_totalAssetsToLoad');
    } catch (e) {
      print('⚠️ Asset preload warning: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Preload sprite asset
  static Future<void> _preloadSprite(String spriteId) async {
    try {
      _loadingStatus[spriteId] = AssetLoadingStatus.pending(spriteId, 'sprite');

      // Simulate asset loading (real implementation would load from Flame)
      await Future.delayed(const Duration(milliseconds: 50));

      _loadingStatus[spriteId] = AssetLoadingStatus.loaded(spriteId, 'sprite');
      _assetsLoaded++;

      onAssetLoaded?.call(spriteId, 'sprite');
      _updateProgress();

      print('  ✓ Loaded: $spriteId');
    } catch (e) {
      _loadingStatus[spriteId] = AssetLoadingStatus.failed(spriteId, 'sprite', e.toString());
      onAssetFailed?.call(spriteId, 'sprite', e.toString());
      print('  ✗ Failed: $spriteId - $e');
    }
  }

  /// Preload audio asset
  static Future<void> _preloadAudio(String audioId) async {
    try {
      _loadingStatus[audioId] = AssetLoadingStatus.pending(audioId, 'audio');

      // Simulate audio loading
      await Future.delayed(const Duration(milliseconds: 100));

      _loadingStatus[audioId] = AssetLoadingStatus.loaded(audioId, 'audio');
      _assetsLoaded++;

      onAssetLoaded?.call(audioId, 'audio');
      _updateProgress();

      print('  ✓ Loaded: $audioId');
    } catch (e) {
      _loadingStatus[audioId] = AssetLoadingStatus.failed(audioId, 'audio', e.toString());
      onAssetFailed?.call(audioId, 'audio', e.toString());
      print('  ✗ Failed: $audioId - $e');
    }
  }

  /// Update progress callback
  static void _updateProgress() {
    final progress = _totalAssetsToLoad > 0 ? _assetsLoaded / _totalAssetsToLoad : 0.0;
    onProgressUpdate?.call(progress);
  }

  /// Get loading status for asset
  static AssetLoadingStatus? getAssetStatus(String assetId) {
    return _loadingStatus[assetId];
  }

  /// Check if all critical assets are loaded
  static bool areCriticalAssetsLoaded() {
    final stableSprites = AssetRegistry.getSpritesByCategory('stable');
    return stableSprites.every((id) =>
        _loadingStatus[id]?.isLoaded == true);
  }

  /// Get current progress (0.0 to 1.0)
  static double getProgress() {
    if (_totalAssetsToLoad == 0) return 0.0;
    return (_assetsLoaded / _totalAssetsToLoad).clamp(0.0, 1.0);
  }

  /// Get loading summary
  static String getLoadingSummary() {
    return 'Assets: $_assetsLoaded/$_totalAssetsToLoad loaded '
        '(${(getProgress() * 100).toStringAsFixed(0)}%)';
  }

  /// Get all asset loading status
  static Map<String, AssetLoadingStatus> getAllStatus() {
    return Map.from(_loadingStatus);
  }

  /// Clear all cached assets
  static void clearCache() {
    _loadingStatus.clear();
    _assetsLoaded = 0;
    _totalAssetsToLoad = 0;
    print('🗑️ Asset cache cleared');
  }

  /// Preload single asset on demand
  static Future<void> preloadAsset(String assetId, String type) async {
    if (type == 'sprite') {
      await _preloadSprite(assetId);
    } else if (type == 'audio') {
      await _preloadAudio(assetId);
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'AssetPreloader: ${_loadingStatus.length} tracked, '
        '$_assetsLoaded loaded, preloading=$_isPreloading';
  }
}
