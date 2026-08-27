import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cosmetic_service.dart';
import '../services/revenueat_service.dart';
import '../../data/models/cosmetic_model.dart';
import '../../data/repositories/firestore_repository.dart';

/// Cosmetic service provider
final cosmeticServiceProvider = Provider<CosmeticService>((ref) {
  return CosmeticService();
});

/// RevenueCat service provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Initialize cosmetics
final initializeCosmeticsProvider = Provider<void>((ref) async {
  await CosmeticService.initialize();
});

/// Initialize RevenueCat
final initializeRevenueCatProvider = FutureProvider<void>((ref) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  await currentUser.when(
    data: (user) async {
      if (user != null) {
        await RevenueCatService.initialize(
          'pk_test_donzumari', // Replace with actual API key
          user.uid,
        );
      }
    },
    loading: () async {},
    error: (err, stack) async {},
  );
});

/// Get all available cosmetics
final allCosmeticsProvider = Provider<List<Cosmetic>>((ref) {
  return CosmeticService.getAllCosmetics();
});

/// Get cosmetics filtered by type
final cosmeticsByTypeProvider =
    Provider.family<List<Cosmetic>, CosmeticType>((ref, type) {
  return CosmeticService.getCosmeticsByType(type);
});

/// Get cosmetics filtered by rarity
final cosmeticsByRarityProvider =
    Provider.family<List<Cosmetic>, CosmeticRarity>((ref, rarity) {
  return CosmeticService.getCosmeticsByRarity(rarity);
});

/// Get single cosmetic by ID
final cosmeticByIdProvider =
    Provider.family<Cosmetic?, String>((ref, cosmeticId) {
  return CosmeticService.getCosmeticById(cosmeticId);
});

/// Get cosmetics filtered by tag
final cosmeticsByTagProvider =
    Provider.family<List<Cosmetic>, String>((ref, tag) {
  return CosmeticService.getCosmeticsByTag(tag);
});

/// Get user's cosmetics
final userCosmeticsProvider = FutureProvider<UserCosmetics>((ref) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await CosmeticService.getUserCosmetics(user.uid);
      }
      throw StateError('User not authenticated');
    },
    loading: () async => throw StateError('Loading user'),
    error: (err, stack) async => throw err,
  );
});

/// Check if user owns cosmetic
final userOwnsCosmeticProvider =
    FutureProvider.family<bool, String>((ref, cosmeticId) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await CosmeticService.userOwnsCosmetic(user.uid, cosmeticId);
      }
      return false;
    },
    loading: () async => false,
    error: (err, stack) async => false,
  );
});

/// Purchase cosmetic
final purchaseCosmeticProvider =
    FutureProvider.family<bool, String>((ref, cosmeticId) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  final cosmetic = CosmeticService.getCosmeticById(cosmeticId);

  if (cosmetic == null) {
    throw StateError('Cosmetic not found: $cosmeticId');
  }

  return currentUser.when(
    data: (user) async {
      if (user != null) {
        // Make purchase through RevenueCat
        final success =
            await RevenueCatService.purchaseProduct(cosmetic.productId);

        if (success) {
          // Record purchase in Firestore
          await CosmeticService.recordPurchase(
            user.uid,
            cosmeticId,
            cosmetic.productId,
            cosmetic.price,
            cosmetic.currency,
            'transaction_${DateTime.now().millisecondsSinceEpoch}',
          );

          // Refresh user cosmetics
          ref.refresh(userCosmeticsProvider);
          return true;
        }
        return false;
      }
      throw StateError('User not authenticated');
    },
    loading: () async => throw StateError('Loading user'),
    error: (err, stack) async => throw err,
  );
});

/// Equip cosmetic
final equipCosmeticProvider =
    FutureProvider.family<bool, (String, CosmeticType)>((ref, args) async {
  final (cosmeticId, type) = args;
  final currentUser = ref.watch(currentUserAsyncProvider);

  return currentUser.when(
    data: (user) async {
      if (user != null) {
        final success =
            await CosmeticService.equipCosmetic(user.uid, cosmeticId, type);

        if (success) {
          ref.refresh(userCosmeticsProvider);
        }

        return success;
      }
      throw StateError('User not authenticated');
    },
    loading: () async => throw StateError('Loading user'),
    error: (err, stack) async => throw err,
  );
});

/// Get available products from RevenueCat
final availableProductsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await RevenueCatService.fetchProducts();
});

/// Get customer info from RevenueCat
final customerInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await RevenueCatService.getCustomerInfo();
});

/// Restore purchases
final restorePurchasesProvider = FutureProvider<List<String>>((ref) async {
  return await RevenueCatService.restorePurchases();
});

/// Get parcel skin cosmetics
final parcelSkinCosmeticsProvider = Provider<List<Cosmetic>>((ref) {
  return CosmeticService.getCosmeticsByType(CosmeticType.parcelSkin);
});

/// Get effect cosmetics
final effectCosmeticsProvider = Provider<List<Cosmetic>>((ref) {
  return CosmeticService.getCosmeticsByType(CosmeticType.effectTrail);
});

/// Get rare cosmetics
final rareCosmeticsProvider = Provider<List<Cosmetic>>((ref) {
  return CosmeticService.getCosmeticsByRarity(CosmeticRarity.rare);
});

/// Featured cosmetics (limited time)
final featuredCosmeticsProvider = Provider<List<Cosmetic>>((ref) {
  return CosmeticService.getCosmeticsByTag('featured');
});

// Imported from existing providers
final currentUserAsyncProvider = FutureProvider<CurrentUser?>((ref) async {
  // This would be imported from auth_providers.dart
  // For now, returning null to show the pattern
  return null;
});
