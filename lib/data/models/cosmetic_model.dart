import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmetic_model.freezed.dart';

/// Cosmetic type (skin, effect, etc.)
enum CosmeticType {
  parcelSkin,
  effectTrail,
  particleEffect,
  soundEffect,
  uiTheme,
}

/// Rarity tier for cosmetics
enum CosmeticRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Cosmetic model for purchasable skins and effects
@freezed
class Cosmetic with _$Cosmetic {
  const factory Cosmetic({
    required String cosmeticId,
    required String name,
    required String description,
    required CosmeticType type,
    required CosmeticRarity rarity,
    required String productId, // RevenueCat product ID
    required double price,
    required String currency,
    required String thumbnailUrl,
    @Default(false) bool isOwned,
    @Default(0) int unlockedAt, // Unix timestamp
    @Default('') String previewImageUrl,
    @Default([]) List<String> tags,
  }) = _Cosmetic;

  factory Cosmetic.fromJson(Map<String, dynamic> json) =>
      _$CosmeticFromJson(json);
}

/// User cosmetic collection
@freezed
class UserCosmetics with _$UserCosmetics {
  const factory UserCosmetics({
    required String userId,
    required List<String> ownedCosmeticIds,
    required String equippedParcelSkinId,
    required String equippedEffectTrailId,
    @Default(0) int lastUpdated,
  }) = _UserCosmetics;

  factory UserCosmetics.fromJson(Map<String, dynamic> json) =>
      _$UserCosmeticsFromJson(json);
}

/// Purchase record for analytics
@freezed
class PurchaseRecord with _$PurchaseRecord {
  const factory PurchaseRecord({
    required String purchaseId,
    required String userId,
    required String cosmeticId,
    required String productId,
    required double amount,
    required String currency,
    required int purchasedAt,
    required String revenueCatTransactionId,
  }) = _PurchaseRecord;

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) =>
      _$PurchaseRecordFromJson(json);
}
