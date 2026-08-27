import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Set user ID for analytics tracking
final setAnalyticsUserIdProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  await AnalyticsService.setUserId(userId);
});

/// Log game start event
final logGameStartProvider = FutureProvider.family<void, String>((ref, doorwayId) async {
  await AnalyticsService.logGameStart(doorwayId);
});

/// Log game end event
final logGameEndProvider =
    FutureProvider.family<void, (String, double, bool, int)>((ref, args) async {
  final (doorwayId, height, collapsed, durationSeconds) = args;
  await AnalyticsService.logGameEnd(
    doorwayId,
    height,
    collapsed,
    durationSeconds,
  );
});

/// Log parcel dropped event
final logParcelDroppedProvider =
    FutureProvider.family<void, (String, int)>((ref, args) async {
  final (parcelType, parcelIndex) = args;
  await AnalyticsService.logParcelDropped(parcelType, parcelIndex);
});

/// Log tower collapse event
final logTowerCollapseProvider =
    FutureProvider.family<void, (String, double, int)>((ref, args) async {
  final (doorwayId, height, parcelCount) = args;
  await AnalyticsService.logTowerCollapse(doorwayId, height, parcelCount);
});

/// Log perfect stack achievement
final logPerfectStackProvider =
    FutureProvider.family<void, (String, double)>((ref, args) async {
  final (doorwayId, height) = args;
  await AnalyticsService.logPerfectStack(doorwayId, height);
});

/// Log purchase event
final logPurchaseProvider =
    FutureProvider.family<void, (String, double, String)>((ref, args) async {
  final (cosmeticId, price, currency) = args;
  await AnalyticsService.logPurchase(cosmeticId, price, currency);
});

/// Log screen view
final logScreenViewProvider =
    FutureProvider.family<void, String>((ref, screenName) async {
  await AnalyticsService.logScreenView(screenName);
});

/// Log user engagement
final logUserEngagementProvider =
    FutureProvider.family<void, String>((ref, engagementType) async {
  await AnalyticsService.logUserEngagement(engagementType);
});

/// Log multiplayer match
final logMultiplayerMatchProvider =
    FutureProvider.family<void, (String, String, String)>((ref, args) async {
  final (doorwayId, opponentId, result) = args;
  await AnalyticsService.logMultiplayerMatch(doorwayId, opponentId, result);
});

/// Log error event
final logErrorProvider =
    FutureProvider.family<void, (String, String?)>((ref, args) async {
  final (errorCode, errorMessage) = args;
  await AnalyticsService.logError(errorCode, errorMessage);
});

/// Set user property
final setUserPropertyProvider =
    FutureProvider.family<void, (String, String)>((ref, args) async {
  final (name, value) = args;
  await AnalyticsService.setUserProperty(name, value);
});
