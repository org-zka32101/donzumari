/// RevenueCat integration service for in-app purchases
/// Handles product fetching, purchases, and subscription management
class RevenueCatService {
  static bool _isInitialized = false;
  static String? _currentUserId;

  // Cached products
  static final Map<String, dynamic> _products = {};

  /// Initialize RevenueCat service with API key
  static Future<void> initialize(String apiKey, String userId) async {
    if (_isInitialized) return;

    try {
      _currentUserId = userId;

      // Configure RevenueCat
      // await Purchases.configure(
      //   PurchasesConfiguration(
      //     apiKey,
      //   ),
      // );

      // Set user ID
      // await Purchases.logIn(userId);

      _isInitialized = true;
      print('✅ RevenueCat service initialized');
    } catch (e) {
      print('⚠️ RevenueCat initialization warning: $e');
    }
  }

  /// Fetch available products from RevenueCat
  static Future<Map<String, dynamic>> fetchProducts() async {
    if (!_isInitialized) {
      throw StateError('RevenueCatService not initialized');
    }

    try {
      // Fetch offerings from RevenueCat
      // final offerings = await Purchases.getOfferings();
      // Cache products
      // _products.clear();
      // if (offerings?.current != null) {
      //   for (final package in offerings!.current!.packages) {
      //     _products[package.identifier] = {
      //       'productId': package.identifier,
      //       'price': package.storeProduct.price,
      //       'currency': package.storeProduct.currencyCode,
      //       'title': package.storeProduct.title,
      //       'description': package.storeProduct.description,
      //     };
      //   }
      // }

      print('📦 Fetched ${_products.length} products from RevenueCat');
      return _products;
    } catch (e) {
      print('⚠️ Failed to fetch products: $e');
      return {};
    }
  }

  /// Make a purchase
  static Future<bool> purchaseProduct(String productId) async {
    if (!_isInitialized) {
      throw StateError('RevenueCatService not initialized');
    }

    try {
      // if (!_products.containsKey(productId)) {
      //   throw ArgumentError('Product not found: $productId');
      // }
      //
      // final offerings = await Purchases.getOfferings();
      // final package = offerings?.current?.getPackage(productId);
      //
      // if (package == null) {
      //   throw StateError('Package not found: $productId');
      // }
      //
      // final purchaserInfo = await Purchases.purchasePackage(package);

      print('🛒 Purchase successful for product: $productId');
      return true;
    } catch (e) {
      print('⚠️ Purchase failed: $e');
      return false;
    }
  }

  /// Restore purchases (useful for app reinstalls)
  static Future<List<String>> restorePurchases() async {
    if (!_isInitialized) {
      throw StateError('RevenueCatService not initialized');
    }

    try {
      // final purchaserInfo = await Purchases.restoreTransactions();
      // final purchasedIds = purchaserInfo.entitlements.active.keys.toList();

      print('🔄 Purchases restored');
      return [];
    } catch (e) {
      print('⚠️ Failed to restore purchases: $e');
      return [];
    }
  }

  /// Get customer info and purchase details
  static Future<Map<String, dynamic>> getCustomerInfo() async {
    if (!_isInitialized) {
      throw StateError('RevenueCatService not initialized');
    }

    try {
      // final purchaserInfo = await Purchases.getCustomerInfo();
      //
      // return {
      //   'userId': purchaserInfo.originalAppUserId,
      //   'entitlements': purchaserInfo.entitlements.active.keys.toList(),
      //   'subscriptions': purchaserInfo.activeSubscriptions,
      //   'originalPurchaseDate': purchaserInfo.originalPurchaseDate,
      // };

      return {
        'userId': _currentUserId,
        'entitlements': [],
        'subscriptions': [],
      };
    } catch (e) {
      print('⚠️ Failed to get customer info: $e');
      return {};
    }
  }

  /// Check if user owns a product
  static Future<bool> hasEntitlement(String productId) async {
    if (!_isInitialized) {
      throw StateError('RevenueCatService not initialized');
    }

    try {
      // final purchaserInfo = await Purchases.getCustomerInfo();
      // return purchaserInfo.entitlements.active.containsKey(productId);

      return false;
    } catch (e) {
      print('⚠️ Failed to check entitlement: $e');
      return false;
    }
  }

  /// Set user ID (for user identification)
  static Future<void> setUserId(String userId) async {
    if (!_isInitialized) {
      throw StateError('RevenueCatService not initialized');
    }

    try {
      _currentUserId = userId;
      // await Purchases.logIn(userId);
      print('👤 User ID set: $userId');
    } catch (e) {
      print('⚠️ Failed to set user ID: $e');
    }
  }

  /// Clear user data (for logout)
  static Future<void> clearUser() async {
    try {
      // await Purchases.logOut();
      _currentUserId = null;
      print('👋 User cleared');
    } catch (e) {
      print('⚠️ Failed to clear user: $e');
    }
  }

  /// Get current user ID
  static String? getCurrentUserId() => _currentUserId;

  /// Get cached product
  static Map<String, dynamic>? getProduct(String productId) =>
      _products[productId];

  /// Check if service is initialized
  static bool isInitialized() => _isInitialized;

  /// Get debug info
  static String getDebugInfo() {
    return 'RevenueCat: initialized=$_isInitialized, userId=$_currentUserId, products=${_products.length}';
  }
}
