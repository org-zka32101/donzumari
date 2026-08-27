/// Parcel preset definitions for the game
/// This data will be seeded into Firestore on app initialization
import '../../data/models/parcel_model.dart';

class ParcelPresets {
  static final List<Map<String, dynamic>> presets = [
    // ===== STABLE PARCELS (5) =====
    {
      'id': 'parcel_box_small',
      'name': '小箱',
      'stabilityTier': 'stable',
      'rarity': 'common',
      'weight': 1.0,
      'vertices': [
        {'x': -20.0, 'y': -30.0},
        {'x': 20.0, 'y': -30.0},
        {'x': 20.0, 'y': 30.0},
        {'x': -20.0, 'y': 30.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/box_small.png',
    },
    {
      'id': 'parcel_box_medium',
      'name': '中箱',
      'stabilityTier': 'stable',
      'rarity': 'common',
      'weight': 2.0,
      'vertices': [
        {'x': -30.0, 'y': -40.0},
        {'x': 30.0, 'y': -40.0},
        {'x': 30.0, 'y': 40.0},
        {'x': -30.0, 'y': 40.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/box_medium.png',
    },
    {
      'id': 'parcel_letter',
      'name': 'レター便',
      'stabilityTier': 'stable',
      'rarity': 'common',
      'weight': 0.5,
      'vertices': [
        {'x': -25.0, 'y': -10.0},
        {'x': 25.0, 'y': -10.0},
        {'x': 25.0, 'y': 10.0},
        {'x': -25.0, 'y': 10.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/letter.png',
    },
    {
      'id': 'parcel_cylinder',
      'name': 'チューブ便',
      'stabilityTier': 'stable',
      'rarity': 'common',
      'weight': 1.2,
      'vertices': [
        {'x': -15.0, 'y': -35.0},
        {'x': 15.0, 'y': -35.0},
        {'x': 15.0, 'y': 35.0},
        {'x': -15.0, 'y': 35.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/cylinder.png',
    },
    {
      'id': 'parcel_book',
      'name': '書籍',
      'stabilityTier': 'stable',
      'rarity': 'common',
      'weight': 1.5,
      'vertices': [
        {'x': -18.0, 'y': -25.0},
        {'x': 18.0, 'y': -25.0},
        {'x': 18.0, 'y': 25.0},
        {'x': -18.0, 'y': 25.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/book.png',
    },

    // ===== MODERATE STABILITY (5) =====
    {
      'id': 'parcel_triangle_box',
      'name': '三角箱',
      'stabilityTier': 'moderate',
      'rarity': 'common',
      'weight': 1.3,
      'vertices': [
        {'x': -20.0, 'y': 25.0},
        {'x': 20.0, 'y': 25.0},
        {'x': 0.0, 'y': -25.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 2.0},
      'spriteRef': 'assets/parcels/triangle_box.png',
    },
    {
      'id': 'parcel_tall_box',
      'name': '背の高い箱',
      'stabilityTier': 'moderate',
      'rarity': 'common',
      'weight': 1.8,
      'vertices': [
        {'x': -12.0, 'y': -40.0},
        {'x': 12.0, 'y': -40.0},
        {'x': 12.0, 'y': 40.0},
        {'x': -12.0, 'y': 40.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 3.0},
      'spriteRef': 'assets/parcels/tall_box.png',
    },
    {
      'id': 'parcel_wide_box',
      'name': '横幅広い箱',
      'stabilityTier': 'moderate',
      'rarity': 'common',
      'weight': 1.6,
      'vertices': [
        {'x': -35.0, 'y': -15.0},
        {'x': 35.0, 'y': -15.0},
        {'x': 35.0, 'y': 15.0},
        {'x': -35.0, 'y': 15.0},
      ],
      'centerOfMass': {'x': 1.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/wide_box.png',
    },
    {
      'id': 'parcel_round_item',
      'name': '丸い荷物',
      'stabilityTier': 'moderate',
      'rarity': 'common',
      'weight': 2.0,
      'vertices': [
        {'x': -25.0, 'y': 0.0},
        {'x': 0.0, 'y': -25.0},
        {'x': 25.0, 'y': 0.0},
        {'x': 0.0, 'y': 25.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/round_item.png',
    },
    {
      'id': 'parcel_slanted',
      'name': 'ナナメ箱',
      'stabilityTier': 'moderate',
      'rarity': 'common',
      'weight': 1.4,
      'vertices': [
        {'x': -18.0, 'y': -25.0},
        {'x': 22.0, 'y': -18.0},
        {'x': 18.0, 'y': 28.0},
        {'x': -22.0, 'y': 22.0},
      ],
      'centerOfMass': {'x': 2.0, 'y': 1.0},
      'spriteRef': 'assets/parcels/slanted.png',
    },

    // ===== UNSTABLE PARCELS (5) =====
    {
      'id': 'parcel_narrow_tower',
      'name': '細長タワー',
      'stabilityTier': 'unstable',
      'rarity': 'common',
      'weight': 0.8,
      'vertices': [
        {'x': -8.0, 'y': -45.0},
        {'x': 8.0, 'y': -45.0},
        {'x': 8.0, 'y': 45.0},
        {'x': -8.0, 'y': 45.0},
      ],
      'centerOfMass': {'x': 1.5, 'y': 5.0},
      'spriteRef': 'assets/parcels/narrow_tower.png',
    },
    {
      'id': 'parcel_wobble_cone',
      'name': 'ぐらぐらコーン',
      'stabilityTier': 'unstable',
      'rarity': 'common',
      'weight': 1.1,
      'vertices': [
        {'x': -15.0, 'y': 25.0},
        {'x': 15.0, 'y': 25.0},
        {'x': 0.0, 'y': -40.0},
      ],
      'centerOfMass': {'x': 2.0, 'y': -8.0},
      'spriteRef': 'assets/parcels/wobble_cone.png',
    },
    {
      'id': 'parcel_tilted_cube',
      'name': '傾いた立方体',
      'stabilityTier': 'unstable',
      'rarity': 'common',
      'weight': 1.9,
      'vertices': [
        {'x': -20.0, 'y': -15.0},
        {'x': 15.0, 'y': -25.0},
        {'x': 25.0, 'y': 20.0},
        {'x': -10.0, 'y': 30.0},
      ],
      'centerOfMass': {'x': 3.0, 'y': 2.0},
      'spriteRef': 'assets/parcels/tilted_cube.png',
    },
    {
      'id': 'parcel_asymmetric',
      'name': 'いびつな箱',
      'stabilityTier': 'unstable',
      'rarity': 'common',
      'weight': 1.3,
      'vertices': [
        {'x': -25.0, 'y': -20.0},
        {'x': 10.0, 'y': -30.0},
        {'x': 20.0, 'y': 15.0},
        {'x': -15.0, 'y': 35.0},
      ],
      'centerOfMass': {'x': -2.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/asymmetric.png',
    },
    {
      'id': 'parcel_top_heavy',
      'name': 'ずっしり重い上部',
      'stabilityTier': 'unstable',
      'rarity': 'common',
      'weight': 2.5,
      'vertices': [
        {'x': -12.0, 'y': -35.0},
        {'x': 12.0, 'y': -35.0},
        {'x': 20.0, 'y': -5.0},
        {'x': 20.0, 'y': 15.0},
        {'x': 10.0, 'y': 30.0},
        {'x': -10.0, 'y': 30.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': -15.0},
      'spriteRef': 'assets/parcels/top_heavy.png',
    },

    // ===== RARE/MEME PARCELS (5) =====
    {
      'id': 'parcel_pizza',
      'name': 'ピザボックス',
      'stabilityTier': 'stable',
      'rarity': 'rare',
      'weight': 0.9,
      'vertices': [
        {'x': -30.0, 'y': -5.0},
        {'x': 30.0, 'y': -5.0},
        {'x': 30.0, 'y': 5.0},
        {'x': -30.0, 'y': 5.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/pizza.png',
      'seasonTag': null,
    },
    {
      'id': 'parcel_dumbbell',
      'name': 'ダンベル',
      'stabilityTier': 'unstable',
      'rarity': 'rare',
      'weight': 3.0,
      'vertices': [
        {'x': -10.0, 'y': -25.0},
        {'x': 10.0, 'y': -25.0},
        {'x': 10.0, 'y': 25.0},
        {'x': -10.0, 'y': 25.0},
        {'x': -30.0, 'y': -5.0},
        {'x': -30.0, 'y': 5.0},
        {'x': 30.0, 'y': -5.0},
        {'x': 30.0, 'y': 5.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/dumbbell.png',
    },
    {
      'id': 'parcel_tire',
      'name': 'タイヤ',
      'stabilityTier': 'moderate',
      'rarity': 'rare',
      'weight': 2.8,
      'vertices': [
        {'x': -30.0, 'y': 0.0},
        {'x': 0.0, 'y': -30.0},
        {'x': 30.0, 'y': 0.0},
        {'x': 0.0, 'y': 30.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': 0.0},
      'spriteRef': 'assets/parcels/tire.png',
    },
    {
      'id': 'parcel_crown',
      'name': 'クラウン形',
      'stabilityTier': 'unstable',
      'rarity': 'rare',
      'weight': 0.7,
      'vertices': [
        {'x': -25.0, 'y': 20.0},
        {'x': -12.0, 'y': -30.0},
        {'x': 0.0, 'y': 10.0},
        {'x': 12.0, 'y': -30.0},
        {'x': 25.0, 'y': 20.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': -5.0},
      'spriteRef': 'assets/parcels/crown.png',
    },
    {
      'id': 'parcel_plant',
      'name': '観葉植物',
      'stabilityTier': 'moderate',
      'rarity': 'rare',
      'weight': 1.2,
      'vertices': [
        {'x': -10.0, 'y': 25.0},
        {'x': 10.0, 'y': 25.0},
        {'x': 12.0, 'y': -20.0},
        {'x': 0.0, 'y': -35.0},
        {'x': -12.0, 'y': -20.0},
      ],
      'centerOfMass': {'x': 0.0, 'y': -3.0},
      'spriteRef': 'assets/parcels/plant.png',
      'seasonTag': null,
    },
  ];

  /// Convert preset to ParcelModel
  static ParcelModel presetToModel(Map<String, dynamic> preset) {
    final vertices = (preset['vertices'] as List)
        .cast<Map<String, dynamic>>()
        .map((v) => {'x': v['x'] as double, 'y': v['y'] as double})
        .toList();

    final com = preset['centerOfMass'] as Map<String, dynamic>;

    return ParcelModel(
      parcelId: preset['id'] as String,
      shape: ParcelShape(
        vertices: vertices,
        centerOfMass_x: com['x'] as double,
        centerOfMass_y: com['y'] as double,
      ),
      stabilityTier: _parseStabilityTier(preset['stabilityTier'] as String),
      weight: preset['weight'] as double,
      rarity: _parseRarity(preset['rarity'] as String),
      seasonTag: preset['seasonTag'] as String?,
      spriteRef: preset['spriteRef'] as String,
    );
  }

  static StabilityTier _parseStabilityTier(String tier) {
    switch (tier) {
      case 'stable':
        return StabilityTier.stable;
      case 'moderate':
        return StabilityTier.moderate;
      case 'unstable':
        return StabilityTier.unstable;
      default:
        return StabilityTier.stable;
    }
  }

  static ParcelRarity _parseRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return ParcelRarity.common;
      case 'rare':
        return ParcelRarity.rare;
      default:
        return ParcelRarity.common;
    }
  }
}
