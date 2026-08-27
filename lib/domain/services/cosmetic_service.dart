import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/cosmetic_model.dart';
import '../services/network_error_handler.dart';

/// Service for managing cosmetics (skins, effects, etc.)
class CosmeticService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static late List<Cosmetic> _cosmeticCache;
  static bool _initialized = false;

  /// Initialize cosmetics from Firestore
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _loadCosmetics();
      _initialized = true;
      print('✅ Cosmetic service initialized');
    } catch (e) {
      print('⚠️ Cosmetic service initialization warning: $e');
    }
  }

  /// Load all cosmetics from Firestore
  static Future<void> _loadCosmetics() async {
    try {
      final snapshot = await _firestore.collection('cosmetics').get();
      _cosmeticCache = snapshot.docs
          .map((doc) => Cosmetic.fromJson({...doc.data(), 'cosmeticId': doc.id}))
          .toList();
      print('📦 Loaded ${_cosmeticCache.length} cosmetics');
    } catch (e) {
      print('⚠️ Failed to load cosmetics: $e');
      _cosmeticCache = [];
    }
  }

  /// Get all available cosmetics
  static List<Cosmetic> getAllCosmetics() {
    _ensureInitialized();
    return List.from(_cosmeticCache);
  }

  /// Get cosmetics by type
  static List<Cosmetic> getCosmeticsByType(CosmeticType type) {
    _ensureInitialized();
    return _cosmeticCache.where((c) => c.type == type).toList();
  }

  /// Get cosmetics by rarity
  static List<Cosmetic> getCosmeticsByRarity(CosmeticRarity rarity) {
    _ensureInitialized();
    return _cosmeticCache.where((c) => c.rarity == rarity).toList();
  }

  /// Get single cosmetic by ID
  static Cosmetic? getCosmeticById(String cosmeticId) {
    _ensureInitialized();
    try {
      return _cosmeticCache.firstWhere((c) => c.cosmeticId == cosmeticId);
    } catch (e) {
      return null;
    }
  }

  /// Get user's cosmetics from Firestore
  static Future<UserCosmetics> getUserCosmetics(String userId) async {
    _ensureInitialized();

    try {
      final doc = await _firestore.collection('userCosmetics').doc(userId).get();

      if (doc.exists) {
        return UserCosmetics.fromJson({...doc.data()!, 'userId': userId});
      } else {
        // Create default cosmetics collection for new user
        final defaultCosmetics = UserCosmetics(
          userId: userId,
          ownedCosmeticIds: [], // No cosmetics by default
          equippedParcelSkinId: 'default',
          equippedEffectTrailId: 'default',
        );

        await _firestore
            .collection('userCosmetics')
            .doc(userId)
            .set(defaultCosmetics.toJson());

        return defaultCosmetics;
      }
    } catch (e) {
      print('⚠️ Failed to get user cosmetics: $e');
      throw StateError('Failed to load user cosmetics: $e');
    }
  }

  /// Add cosmetic to user's collection
  static Future<bool> addCosmeticToUser(
    String userId,
    String cosmeticId,
  ) async {
    _ensureInitialized();

    try {
      final userCosmeticsDoc =
          _firestore.collection('userCosmetics').doc(userId);

      await userCosmeticsDoc.update({
        'ownedCosmeticIds': FieldValue.arrayUnion([cosmeticId]),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });

      print('🎁 Cosmetic $cosmeticId added to user $userId');
      return true;
    } catch (e) {
      print('⚠️ Failed to add cosmetic: $e');
      return false;
    }
  }

  /// Equip cosmetic for user
  static Future<bool> equipCosmetic(
    String userId,
    String cosmeticId,
    CosmeticType type,
  ) async {
    _ensureInitialized();

    try {
      final userCosmeticsDoc =
          _firestore.collection('userCosmetics').doc(userId);

      final updateData = {
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      if (type == CosmeticType.parcelSkin) {
        updateData['equippedParcelSkinId'] = cosmeticId;
      } else if (type == CosmeticType.effectTrail) {
        updateData['equippedEffectTrailId'] = cosmeticId;
      }

      await userCosmeticsDoc.update(updateData);

      print('🎨 Cosmetic $cosmeticId equipped by user $userId');
      return true;
    } catch (e) {
      print('⚠️ Failed to equip cosmetic: $e');
      return false;
    }
  }

  /// Record purchase
  static Future<bool> recordPurchase(
    String userId,
    String cosmeticId,
    String productId,
    double amount,
    String currency,
    String transactionId,
  ) async {
    _ensureInitialized();

    try {
      final purchaseRecord = PurchaseRecord(
        purchaseId: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        cosmeticId: cosmeticId,
        productId: productId,
        amount: amount,
        currency: currency,
        purchasedAt: DateTime.now().millisecondsSinceEpoch,
        revenueCatTransactionId: transactionId,
      );

      await _firestore
          .collection('purchaseRecords')
          .doc(purchaseRecord.purchaseId)
          .set(purchaseRecord.toJson());

      // Add to user's owned cosmetics
      await addCosmeticToUser(userId, cosmeticId);

      print('💰 Purchase recorded: $cosmeticId by $userId');
      return true;
    } catch (e) {
      print('⚠️ Failed to record purchase: $e');
      return false;
    }
  }

  /// Check if user owns cosmetic
  static Future<bool> userOwnsCosmetic(
    String userId,
    String cosmeticId,
  ) async {
    _ensureInitialized();

    try {
      final userCosmetics = await getUserCosmetics(userId);
      return userCosmetics.ownedCosmeticIds.contains(cosmeticId);
    } catch (e) {
      print('⚠️ Failed to check cosmetic ownership: $e');
      return false;
    }
  }

  /// Get cosmetics by tag
  static List<Cosmetic> getCosmeticsByTag(String tag) {
    _ensureInitialized();
    return _cosmeticCache.where((c) => c.tags.contains(tag)).toList();
  }

  /// Seed initial cosmetics (admin function)
  static Future<void> seedCosmetics() async {
    try {
      final cosmetics = _getDefaultCosmetics();

      for (final cosmetic in cosmetics) {
        await _firestore
            .collection('cosmetics')
            .doc(cosmetic.cosmeticId)
            .set(cosmetic.toJson());
      }

      print('🌱 Seeded ${cosmetics.length} cosmetics');
      await _loadCosmetics();
    } catch (e) {
      print('⚠️ Failed to seed cosmetics: $e');
    }
  }

  /// Get default cosmetics
  static List<Cosmetic> _getDefaultCosmetics() {
    return [
      // Common parcels
      Cosmetic(
        cosmeticId: 'skin_box_blue',
        name: 'ブルーボックス',
        description: '青色の配達箱スキン',
        type: CosmeticType.parcelSkin,
        rarity: CosmeticRarity.common,
        productId: 'skin_box_blue',
        price: 0.99,
        currency: 'USD',
        thumbnailUrl: 'assets/cosmetics/skin_box_blue.png',
        previewImageUrl: 'assets/cosmetics/preview_skin_box_blue.png',
        tags: ['parcel', 'box', 'blue'],
      ),
      Cosmetic(
        cosmeticId: 'skin_box_red',
        name: 'レッドボックス',
        description: '赤色の配達箱スキン',
        type: CosmeticType.parcelSkin,
        rarity: CosmeticRarity.common,
        productId: 'skin_box_red',
        price: 0.99,
        currency: 'USD',
        thumbnailUrl: 'assets/cosmetics/skin_box_red.png',
        previewImageUrl: 'assets/cosmetics/preview_skin_box_red.png',
        tags: ['parcel', 'box', 'red'],
      ),
      Cosmetic(
        cosmeticId: 'skin_box_gold',
        name: 'ゴールドボックス',
        description: 'レアな金色の配達箱スキン',
        type: CosmeticType.parcelSkin,
        rarity: CosmeticRarity.rare,
        productId: 'skin_box_gold',
        price: 2.99,
        currency: 'USD',
        thumbnailUrl: 'assets/cosmetics/skin_box_gold.png',
        previewImageUrl: 'assets/cosmetics/preview_skin_box_gold.png',
        tags: ['parcel', 'box', 'gold', 'rare'],
      ),
      // Effects
      Cosmetic(
        cosmeticId: 'effect_trail_sparkle',
        name: 'キラキラエフェクト',
        description: 'パーティクルエフェクト: キラキラ',
        type: CosmeticType.effectTrail,
        rarity: CosmeticRarity.uncommon,
        productId: 'effect_trail_sparkle',
        price: 1.99,
        currency: 'USD',
        thumbnailUrl: 'assets/cosmetics/effect_trail_sparkle.png',
        tags: ['effect', 'particle', 'sparkle'],
      ),
      Cosmetic(
        cosmeticId: 'effect_trail_fire',
        name: 'ファイアエフェクト',
        description: 'パーティクルエフェクト: 炎',
        type: CosmeticType.effectTrail,
        rarity: CosmeticRarity.rare,
        productId: 'effect_trail_fire',
        price: 2.99,
        currency: 'USD',
        thumbnailUrl: 'assets/cosmetics/effect_trail_fire.png',
        tags: ['effect', 'particle', 'fire', 'rare'],
      ),
    ];
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'CosmeticService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Cosmetics: initialized=$_initialized, loaded=${_cosmeticCache.length}';
  }
}
