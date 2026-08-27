/// Sprite asset definitions for all parcel types
/// Maps parcel IDs to their corresponding sprite assets and animations
class SpriteDefinitions {
  // Asset paths
  static const String spritePath = 'assets/sprites';
  static const String parcelPath = '$spritePath/parcels';
  static const String animationPath = '$spritePath/animations';

  // Sprite definitions by parcel ID
  static const Map<String, SpriteDefinition> definitions = {
    // Stable parcels (5)
    'small_box': SpriteDefinition(
      id: 'small_box',
      assetPath: '$parcelPath/stable/small_box.png',
      width: 32,
      height: 32,
      colorVariations: ['#D2691E', '#8B4513', '#A0522D'], // Brown tones
    ),
    'medium_box': SpriteDefinition(
      id: 'medium_box',
      assetPath: '$parcelPath/stable/medium_box.png',
      width: 48,
      height: 48,
      colorVariations: ['#DC143C', '#B22222', '#CD5C5C'], // Red tones
    ),
    'letter_mail': SpriteDefinition(
      id: 'letter_mail',
      assetPath: '$parcelPath/stable/letter_mail.png',
      width: 20,
      height: 28,
      colorVariations: ['#FFFFFF', '#F0F0F0', '#FFFACD'], // White/cream
    ),
    'tube_mail': SpriteDefinition(
      id: 'tube_mail',
      assetPath: '$parcelPath/stable/tube_mail.png',
      width: 16,
      height: 40,
      colorVariations: ['#FFD700', '#FFA500', '#FF8C00'], // Yellow/orange
    ),
    'books': SpriteDefinition(
      id: 'books',
      assetPath: '$parcelPath/stable/books.png',
      width: 32,
      height: 24,
      colorVariations: ['#4169E1', '#1E90FF', '#00008B'], // Blue tones
    ),

    // Moderate parcels (5)
    'triangle_box': SpriteDefinition(
      id: 'triangle_box',
      assetPath: '$parcelPath/moderate/triangle_box.png',
      width: 40,
      height: 48,
      colorVariations: ['#32CD32', '#00FF00', '#7CFC00'], // Green tones
    ),
    'tall_box': SpriteDefinition(
      id: 'tall_box',
      assetPath: '$parcelPath/moderate/tall_box.png',
      width: 24,
      height: 60,
      colorVariations: ['#9370DB', '#8A2BE2', '#BA55D3'], // Purple tones
    ),
    'wide_box': SpriteDefinition(
      id: 'wide_box',
      assetPath: '$parcelPath/moderate/wide_box.png',
      width: 64,
      height: 32,
      colorVariations: ['#FF1493', '#FF69B4', '#FFB6C1'], // Pink tones
    ),
    'round_items': SpriteDefinition(
      id: 'round_items',
      assetPath: '$parcelPath/moderate/round_items.png',
      width: 40,
      height: 40,
      colorVariations: ['#FF6347', '#FA8072', '#FFA07A'], // Salmon/red
    ),
    'slanted_box': SpriteDefinition(
      id: 'slanted_box',
      assetPath: '$parcelPath/moderate/slanted_box.png',
      width: 48,
      height: 40,
      colorVariations: ['#DCDCDC', '#A9A9A9', '#808080'], // Gray tones
    ),

    // Unstable parcels (5)
    'narrow_tower': SpriteDefinition(
      id: 'narrow_tower',
      assetPath: '$parcelPath/unstable/narrow_tower.png',
      width: 16,
      height: 56,
      colorVariations: ['#FF4500', '#FF6347', '#FFD700'], // Orange/red
    ),
    'wobble_cone': SpriteDefinition(
      id: 'wobble_cone',
      assetPath: '$parcelPath/unstable/wobble_cone.png',
      width: 44,
      height: 52,
      colorVariations: ['#20B2AA', '#00CED1', '#40E0D0'], // Cyan tones
    ),
    'tilted_cube': SpriteDefinition(
      id: 'tilted_cube',
      assetPath: '$parcelPath/unstable/tilted_cube.png',
      width: 40,
      height: 40,
      colorVariations: ['#9932CC', '#8B008B', '#DA70D6'], // Dark magenta
    ),
    'asymmetric_box': SpriteDefinition(
      id: 'asymmetric_box',
      assetPath: '$parcelPath/unstable/asymmetric_box.png',
      width: 48,
      height: 44,
      colorVariations: ['#FFD700', '#FF8C00', '#FFA500'], // Gold/orange
    ),
    'top_heavy_item': SpriteDefinition(
      id: 'top_heavy_item',
      assetPath: '$parcelPath/unstable/top_heavy_item.png',
      width: 28,
      height: 52,
      colorVariations: ['#00FF00', '#00CD00', '#00FA9A'], // Lime green
    ),

    // Rare parcels (5)
    'pizza_box': SpriteDefinition(
      id: 'pizza_box',
      assetPath: '$parcelPath/rare/pizza_box.png',
      width: 44,
      height: 44,
      colorVariations: ['#8B4513', '#A0522D', '#CD853F'], // Brown tones
      isRare: true,
    ),
    'dumbbell': SpriteDefinition(
      id: 'dumbbell',
      assetPath: '$parcelPath/rare/dumbbell.png',
      width: 52,
      height: 24,
      colorVariations: ['#2F4F4F', '#696969', '#505050'], // Dark gray
      isRare: true,
    ),
    'tire': SpriteDefinition(
      id: 'tire',
      assetPath: '$parcelPath/rare/tire.png',
      width: 48,
      height: 48,
      colorVariations: ['#000000', '#1C1C1C', '#2F2F2F'], // Black
      isRare: true,
    ),
    'crown': SpriteDefinition(
      id: 'crown',
      assetPath: '$parcelPath/rare/crown.png',
      width: 44,
      height: 44,
      colorVariations: ['#FFD700', '#FFA500', '#FF8C00'], // Gold
      isRare: true,
      hasParticles: true,
    ),
    'potted_plant': SpriteDefinition(
      id: 'potted_plant',
      assetPath: '$parcelPath/rare/potted_plant.png',
      width: 36,
      height: 48,
      colorVariations: ['#228B22', '#00AA00', '#00FF00'], // Green
      isRare: true,
    ),
  };

  /// Get sprite definition by parcel ID
  static SpriteDefinition? getDefinition(String parcelId) {
    return definitions[parcelId];
  }

  /// Get all definitions for a stability tier
  static List<SpriteDefinition> getByStability(String stabilityTier) {
    return definitions.values
        .where((def) {
          if (stabilityTier == 'stable') {
            return ['small_box', 'medium_box', 'letter_mail', 'tube_mail', 'books']
                .contains(def.id);
          } else if (stabilityTier == 'moderate') {
            return ['triangle_box', 'tall_box', 'wide_box', 'round_items', 'slanted_box']
                .contains(def.id);
          } else if (stabilityTier == 'unstable') {
            return ['narrow_tower', 'wobble_cone', 'tilted_cube', 'asymmetric_box', 'top_heavy_item']
                .contains(def.id);
          }
          return false;
        })
        .toList();
  }

  /// Get all rare parcel definitions
  static List<SpriteDefinition> getRareDefinitions() {
    return definitions.values.where((def) => def.isRare).toList();
  }
}

/// Sprite definition data class
class SpriteDefinition {
  final String id;
  final String assetPath;
  final double width;
  final double height;
  final List<String> colorVariations;
  final bool isRare;
  final bool hasParticles;

  const SpriteDefinition({
    required this.id,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.colorVariations,
    this.isRare = false,
    this.hasParticles = false,
  });
}
