import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/matchmaking_service.dart';
import '../../data/models/matchmaking_model.dart';

/// Matchmaking service provider
final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
  return MatchmakingService();
});

/// Initialize matchmaking
final initializeMatchmakingProvider = FutureProvider<void>((ref) async {
  await MatchmakingService.initialize();
});

/// Get player stats
final playerStatsProvider =
    FutureProvider.family<PlayerStats?, String>((ref, userId) async {
  return await MatchmakingService.getPlayerStats(userId);
});

/// Get player ranking
final playerRankingProvider =
    FutureProvider.family<PlayerRanking?, String>((ref, userId) async {
  return await MatchmakingService.getPlayerRanking(userId);
});

/// Find an opponent
final findOpponentProvider =
    FutureProvider.family<String?, (String, MatchDifficulty, int)>(
        (ref, args) async {
  final (userId, difficulty, timeoutSeconds) = args;
  return await MatchmakingService.findOpponent(userId, difficulty, timeoutSeconds);
});

/// Get match history
final matchHistoryProvider =
    FutureProvider.family<List<MatchHistoryEntry>, String>((ref, userId) async {
  return await MatchmakingService.getMatchHistory(userId);
});

/// Get global leaderboard
final globalLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  return await MatchmakingService.getGlobalLeaderboard();
});

/// Record match result
final recordMatchResultProvider = FutureProvider.family<bool, ({
  String matchId,
  String player1Id,
  String player2Id,
  MatchResult player1Result,
  double player1Height,
  double player2Height,
  int player1Score,
  int player2Score,
  int durationSeconds,
  String doorwayId,
  bool isRanked,
})>((ref, args) async {
  final result = await MatchmakingService.recordMatchResult(
    args.matchId,
    args.player1Id,
    args.player2Id,
    args.player1Result,
    args.player1Height,
    args.player2Height,
    args.player1Score,
    args.player2Score,
    args.durationSeconds,
    args.doorwayId,
    args.isRanked,
  );

  if (result) {
    // Refresh relevant data
    ref.refresh(playerStatsProvider(args.player1Id));
    ref.refresh(playerRankingProvider(args.player1Id));
    ref.refresh(playerStatsProvider(args.player2Id));
    ref.refresh(playerRankingProvider(args.player2Id));
    ref.refresh(matchHistoryProvider(args.player1Id));
    ref.refresh(globalLeaderboardProvider);
  }

  return result;
});

/// Current user's ranking (requires auth integration)
final currentUserRankingProvider = FutureProvider<PlayerRanking?>((ref) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await MatchmakingService.getPlayerRanking(user.uid);
      }
      return null;
    },
    loading: () async => null,
    error: (err, stack) async => null,
  );
});

/// Current user's stats
final currentUserStatsProvider = FutureProvider<PlayerStats?>((ref) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await MatchmakingService.getPlayerStats(user.uid);
      }
      return null;
    },
    loading: () async => null,
    error: (err, stack) async => null,
  );
});

/// Current user's match history
final currentUserMatchHistoryProvider =
    FutureProvider<List<MatchHistoryEntry>>((ref) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await MatchmakingService.getMatchHistory(user.uid);
      }
      return [];
    },
    loading: () async => [],
    error: (err, stack) async => [],
  );
});

// Imported from existing providers
final currentUserAsyncProvider = FutureProvider<CurrentUser?>((ref) async {
  // This would be imported from auth_providers.dart
  return null;
});

// Placeholder for CurrentUser type
class CurrentUser {
  final String uid;
  CurrentUser({required this.uid});
}
