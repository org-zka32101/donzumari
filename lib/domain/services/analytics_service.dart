import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service for Firebase Analytics integration
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static bool _initialized = false;
  static String? _userId;

  /// Initialize analytics
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Enable analytics
      await _analytics.setAnalyticsCollectionEnabled(true);
      _initialized = true;
      print('✅ Analytics service initialized');
    } catch (e) {
      print('⚠️ Analytics initialization warning: $e');
    }
  }

  /// Set user ID for tracking
  static Future<void> setUserId(String userId) async {
    _ensureInitialized();
    try {
      _userId = userId;
      await _analytics.setUserId(userId);
      print('👤 User ID set for analytics: $userId');
    } catch (e) {
      print('⚠️ Failed to set user ID: $e');
    }
  }

  /// Track game session start
  static Future<void> logGameStart(String doorwayId) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'game_start',
        parameters: {
          'doorway_id': doorwayId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      print('⚠️ Failed to log game start: $e');
    }
  }

  /// Track game session end
  static Future<void> logGameEnd(
    String doorwayId,
    double height,
    bool collapsed,
    int durationSeconds,
  ) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'game_end',
        parameters: {
          'doorway_id': doorwayId,
          'height': height.toStringAsFixed(2),
          'collapsed': collapsed,
          'duration_seconds': durationSeconds,
        },
      );
    } catch (e) {
      print('⚠️ Failed to log game end: $e');
    }
  }

  /// Track parcel drop
  static Future<void> logParcelDropped(String parcelType, int parcelIndex) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'parcel_dropped',
        parameters: {
          'parcel_type': parcelType,
          'parcel_index': parcelIndex,
        },
      );
    } catch (e) {
      print('⚠️ Failed to log parcel dropped: $e');
    }
  }

  /// Track tower collapse
  static Future<void> logTowerCollapse(
    String doorwayId,
    double height,
    int parcelCount,
  ) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'tower_collapse',
        parameters: {
          'doorway_id': doorwayId,
          'height': height.toStringAsFixed(2),
          'parcel_count': parcelCount,
        },
      );
    } catch (e) {
      print('⚠️ Failed to log tower collapse: $e');
    }
  }

  /// Track perfect stack achievement
  static Future<void> logPerfectStack(String doorwayId, double height) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'perfect_stack',
        parameters: {
          'doorway_id': doorwayId,
          'height': height.toStringAsFixed(2),
        },
      );
    } catch (e) {
      print('⚠️ Failed to log perfect stack: $e');
    }
  }

  /// Track purchase
  static Future<void> logPurchase(
    String cosmeticId,
    double price,
    String currency,
  ) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'purchase',
        parameters: {
          'cosmetic_id': cosmeticId,
          'price': price.toStringAsFixed(2),
          'currency': currency,
        },
      );
    } catch (e) {
      print('⚠️ Failed to log purchase: $e');
    }
  }

  /// Track screen view
  static Future<void> logScreenView(String screenName) async {
    _ensureInitialized();
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
      print('📱 Screen view logged: $screenName');
    } catch (e) {
      print('⚠️ Failed to log screen view: $e');
    }
  }

  /// Track user engagement
  static Future<void> logUserEngagement(String engagementType) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'user_engagement',
        parameters: {
          'engagement_type': engagementType,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      print('⚠️ Failed to log engagement: $e');
    }
  }

  /// Track multiplayer match
  static Future<void> logMultiplayerMatch(
    String doorwayId,
    String opponentId,
    String result,
  ) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'multiplayer_match',
        parameters: {
          'doorway_id': doorwayId,
          'opponent_id': opponentId,
          'result': result, // 'win', 'loss', 'draw'
        },
      );
    } catch (e) {
      print('⚠️ Failed to log multiplayer match: $e');
    }
  }

  /// Track error event
  static Future<void> logError(String errorCode, String? errorMessage) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_code': errorCode,
          'error_message': errorMessage ?? 'Unknown error',
        },
      );
    } catch (e) {
      print('⚠️ Failed to log error: $e');
    }
  }

  /// Log generic event with parameters
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    _ensureInitialized();
    try {
      await _analytics.logEvent(
        name: name,
        parameters: _sanitizeParameters(parameters ?? {}),
      );
    } catch (e) {
      print('⚠️ Failed to log event $name: $e');
    }
  }

  /// Sanitize parameters for Firebase Analytics (must be string, int, or double)
  static Map<String, dynamic> _sanitizeParameters(
      Map<String, dynamic> params) {
    final sanitized = <String, dynamic>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value is String || value is int || value is double || value is bool) {
        sanitized[entry.key] = value;
      } else if (value != null) {
        sanitized[entry.key] = value.toString();
      }
    }
    return sanitized;
  }

  /// Set user properties
  static Future<void> setUserProperty(String name, String value) async {
    _ensureInitialized();
    try {
      await _analytics.setUserProperty(name: name, value: value);
      print('📊 User property set: $name = $value');
    } catch (e) {
      print('⚠️ Failed to set user property: $e');
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Analytics: initialized=$_initialized, userId=$_userId';
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'AnalyticsService not initialized. Call initialize() first.',
      );
    }
  }
}
