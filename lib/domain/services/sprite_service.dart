import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import '../../data/fixtures/sprite_definitions.dart';

/// Service for managing sprite assets and color variations
class SpriteService {
  // Sprite cache to avoid reloading
  static final Map<String, _SpriteVariation> _spriteCache = {};
  static bool _isInitialized = false;

  /// Initialize sprite service (preload critical sprites)
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Preload stable parcel sprites for immediate game start
      final stableDefinitions = SpriteDefinitions.getByStability('stable');
      for (final def in stableDefinitions) {
        final variation = await _loadSpriteVariation(def);
        _spriteCache['${def.parcelId}:0'] = variation;
      }

      _isInitialized = true;
      print('✅ Sprite service initialized');
    } catch (e) {
      print('⚠️ Sprite preload warning: $e');
      // Don't block app startup if sprite loading fails
    }
  }

  /// Load sprite for a parcel ID with optional color variation (0-2)
  static Future<_SpriteVariation> getSpriteVariation(
    String parcelId, {
    int colorIndex = 0,
  }) async {
    final definition = SpriteDefinitions.getDefinition(parcelId);
    if (definition == null) {
      throw Exception('No sprite definition found for parcel: $parcelId');
    }

    final cacheKey = '$parcelId:$colorIndex';

    // Return cached sprite if available
    if (_spriteCache.containsKey(cacheKey)) {
      return _spriteCache[cacheKey]!;
    }

    // Load and cache sprite
    final variation = await _loadSpriteVariation(definition, colorIndex: colorIndex);
    _spriteCache[cacheKey] = variation;
    return variation;
  }

  /// Get sprite definition by parcel ID
  static SpriteDefinition? getDefinition(String parcelId) {
    return SpriteDefinitions.getDefinition(parcelId);
  }

  /// Load sprite variation with color tinting
  static Future<_SpriteVariation> _loadSpriteVariation(
    SpriteDefinition definition, {
    int colorIndex = 0,
  }) async {
    try {
      // Load sprite image from assets
      final image = await Flame.images.load(definition.assetPath);

      // Get color variation hex
      final colorHex = definition.colorVariations[
          colorIndex % definition.colorVariations.length];

      return _SpriteVariation(
        parcelId: definition.id,
        image: image,
        colorHex: colorHex,
        width: definition.width,
        height: definition.height,
        isRare: definition.isRare,
        hasParticles: definition.hasParticles,
      );
    } catch (e) {
      print('⚠️ Failed to load sprite for ${definition.id}: $e');
      rethrow;
    }
  }

  /// Clear sprite cache (call on memory pressure)
  static void clearCache() {
    _spriteCache.clear();
    print('🗑️ Sprite cache cleared');
  }

  /// Preload sprites for a stability tier
  static Future<void> preloadTier(String stabilityTier) async {
    final definitions = SpriteDefinitions.getByStability(stabilityTier);
    for (final def in definitions) {
      try {
        await _loadSpriteVariation(def);
      } catch (e) {
        print('⚠️ Preload failed for ${def.id}: $e');
      }
    }
  }

  /// Get color hex value for a sprite variation
  static String getColorHex(String parcelId, int colorIndex) {
    final definition = SpriteDefinitions.getDefinition(parcelId);
    if (definition == null) return '#FFFFFF';
    return definition.colorVariations[colorIndex % definition.colorVariations.length];
  }

  /// Check if sprite has particles (rare effect)
  static bool hasParticleEffect(String parcelId) {
    final definition = SpriteDefinitions.getDefinition(parcelId);
    return definition?.hasParticles ?? false;
  }

  /// Get debug info (sprite cache status)
  static String getDebugInfo() {
    return 'Cached sprites: ${_spriteCache.length}, Initialized: $_isInitialized';
  }
}

/// Sprite variation with color and properties
class _SpriteVariation {
  final String parcelId;
  final dynamic image; // AssetImage type
  final String colorHex;
  final double width;
  final double height;
  final bool isRare;
  final bool hasParticles;

  _SpriteVariation({
    required this.parcelId,
    required this.image,
    required this.colorHex,
    required this.width,
    required this.height,
    required this.isRare,
    required this.hasParticles,
  });
}
