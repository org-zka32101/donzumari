/// Central registry for all game assets
/// Maintains a mapping of asset IDs to their file paths
class AssetRegistry {
  // Sprite asset registry
  static const Map<String, String> spriteAssets = {
    // Stable parcels
    'small_box': 'assets/sprites/parcels/stable/small_box.png',
    'medium_box': 'assets/sprites/parcels/stable/medium_box.png',
    'letter_mail': 'assets/sprites/parcels/stable/letter_mail.png',
    'tube_mail': 'assets/sprites/parcels/stable/tube_mail.png',
    'books': 'assets/sprites/parcels/stable/books.png',

    // Moderate parcels
    'triangle_box': 'assets/sprites/parcels/moderate/triangle_box.png',
    'tall_box': 'assets/sprites/parcels/moderate/tall_box.png',
    'wide_box': 'assets/sprites/parcels/moderate/wide_box.png',
    'round_items': 'assets/sprites/parcels/moderate/round_items.png',
    'slanted_box': 'assets/sprites/parcels/moderate/slanted_box.png',

    // Unstable parcels
    'narrow_tower': 'assets/sprites/parcels/unstable/narrow_tower.png',
    'wobble_cone': 'assets/sprites/parcels/unstable/wobble_cone.png',
    'tilted_cube': 'assets/sprites/parcels/unstable/tilted_cube.png',
    'asymmetric_box': 'assets/sprites/parcels/unstable/asymmetric_box.png',
    'top_heavy_item': 'assets/sprites/parcels/unstable/top_heavy_item.png',

    // Rare parcels
    'pizza_box': 'assets/sprites/parcels/rare/pizza_box.png',
    'dumbbell': 'assets/sprites/parcels/rare/dumbbell.png',
    'tire': 'assets/sprites/parcels/rare/tire.png',
    'crown': 'assets/sprites/parcels/rare/crown.png',
    'potted_plant': 'assets/sprites/parcels/rare/potted_plant.png',
  };

  // Audio asset registry
  static const Map<String, String> audioAssets = {
    // SFX
    'parcel_drop': 'assets/sounds/effects/parcel_drop.wav',
    'parcel_land': 'assets/sounds/effects/parcel_land.wav',
    'parcel_collision': 'assets/sounds/effects/parcel_collision.wav',
    'tower_collapse': 'assets/sounds/effects/tower_collapse.wav',
    'tower_perfect': 'assets/sounds/effects/tower_perfect.wav',
    'score_increase': 'assets/sounds/effects/score_increase.wav',

    // UI sounds
    'button_tap': 'assets/sounds/ui/button_tap.wav',
    'screen_transition': 'assets/sounds/ui/screen_transition.wav',
    'notification': 'assets/sounds/ui/notification.wav',
    'achievement_unlock': 'assets/sounds/ui/achievement_unlock.wav',

    // Music
    'menu_music': 'assets/sounds/music/menu_loop.ogg',
    'gameplay_music': 'assets/sounds/music/gameplay_loop.ogg',
    'victory_music': 'assets/sounds/music/victory.ogg',
    'defeat_music': 'assets/sounds/music/defeat.ogg',
  };

  /// Get sprite asset path by ID
  static String? getSpriteAsset(String assetId) {
    return spriteAssets[assetId];
  }

  /// Get audio asset path by ID
  static String? getAudioAsset(String assetId) {
    return audioAssets[assetId];
  }

  /// Check if sprite asset exists
  static bool hasSpriteAsset(String assetId) {
    return spriteAssets.containsKey(assetId);
  }

  /// Check if audio asset exists
  static bool hasAudioAsset(String assetId) {
    return audioAssets.containsKey(assetId);
  }

  /// Get all sprite asset IDs
  static List<String> getAllSpriteAssets() {
    return spriteAssets.keys.toList();
  }

  /// Get all audio asset IDs
  static List<String> getAllAudioAssets() {
    return audioAssets.keys.toList();
  }

  /// Get sprite assets by category
  static List<String> getSpritesByCategory(String category) {
    return spriteAssets.entries
        .where((e) => e.value.contains(category))
        .map((e) => e.key)
        .toList();
  }

  /// Get asset summary
  static String getAssetSummary() {
    return 'Assets: ${spriteAssets.length} sprites, ${audioAssets.length} audio tracks';
  }

  /// Get missing assets (for development/QA)
  static List<String> getMissingAssets() {
    // TODO: Check actual file system in real implementation
    return [];
  }
}

/// Asset loading status tracker
class AssetLoadingStatus {
  final String assetId;
  final String assetType; // 'sprite' or 'audio'
  final bool isLoaded;
  final DateTime? loadedAt;
  final String? error;

  AssetLoadingStatus({
    required this.assetId,
    required this.assetType,
    required this.isLoaded,
    this.loadedAt,
    this.error,
  });

  /// Create a loaded status
  factory AssetLoadingStatus.loaded(String assetId, String assetType) {
    return AssetLoadingStatus(
      assetId: assetId,
      assetType: assetType,
      isLoaded: true,
      loadedAt: DateTime.now(),
    );
  }

  /// Create a failed status
  factory AssetLoadingStatus.failed(
    String assetId,
    String assetType,
    String error,
  ) {
    return AssetLoadingStatus(
      assetId: assetId,
      assetType: assetType,
      isLoaded: false,
      error: error,
    );
  }

  /// Create a pending status
  factory AssetLoadingStatus.pending(String assetId, String assetType) {
    return AssetLoadingStatus(
      assetId: assetId,
      assetType: assetType,
      isLoaded: false,
    );
  }
}
