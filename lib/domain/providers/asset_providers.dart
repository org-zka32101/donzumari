import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_preloader_service.dart';
import '../../data/fixtures/asset_registry.dart';

/// Asset preloader service provider
final assetPreloaderProvider = Provider<AssetPreloaderService>((ref) {
  return AssetPreloaderService();
});

/// Asset registry provider
final assetRegistryProvider = Provider<AssetRegistry>((ref) {
  return AssetRegistry();
});

/// Asset loading progress provider (StateProvider for real-time updates)
final assetLoadingProgressProvider = StateProvider<double>((ref) {
  return AssetPreloaderService.getProgress();
});

/// Asset loading summary provider
final assetLoadingSummaryProvider = StateProvider<String>((ref) {
  return AssetPreloaderService.getLoadingSummary();
});

/// Critical assets preload provider
final preloadCriticalAssetsProvider = FutureProvider<void>((ref) async {
  return await AssetPreloaderService.preloadCriticalAssets();
});

/// All sprite assets provider
final allSpriteAssetsProvider = Provider<List<String>>((ref) {
  return AssetRegistry.getAllSpriteAssets();
});

/// All audio assets provider
final allAudioAssetsProvider = Provider<List<String>>((ref) {
  return AssetRegistry.getAllAudioAssets();
});

/// Sprite asset by category provider
final spriteAssetsByCategoryProvider =
    Provider.family<List<String>, String>((ref, category) {
  return AssetRegistry.getSpritesByCategory(category);
});

/// Get sprite asset path provider
final getSpriteAssetProvider =
    Provider.family<String?, String>((ref, assetId) {
  return AssetRegistry.getSpriteAsset(assetId);
});

/// Get audio asset path provider
final getAudioAssetProvider =
    Provider.family<String?, String>((ref, assetId) {
  return AssetRegistry.getAudioAsset(assetId);
});

/// Check if sprite asset exists provider
final hasSpriteAssetProvider =
    Provider.family<bool, String>((ref, assetId) {
  return AssetRegistry.hasSpriteAsset(assetId);
});

/// Check if audio asset exists provider
final hasAudioAssetProvider =
    Provider.family<bool, String>((ref, assetId) {
  return AssetRegistry.hasAudioAsset(assetId);
});

/// Asset loading status provider
final assetLoadingStatusProvider =
    Provider.family<AssetLoadingStatus?, String>((ref, assetId) {
  return AssetPreloaderService.getAssetStatus(assetId);
});

/// Check if critical assets are loaded provider
final criticalAssetsLoadedProvider = Provider<bool>((ref) {
  return AssetPreloaderService.areCriticalAssetsLoaded();
});

/// Asset registry summary provider
final assetRegistrySummaryProvider = Provider<String>((ref) {
  return AssetRegistry.getAssetSummary();
});
