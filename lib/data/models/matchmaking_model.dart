import 'package:freezed_annotation/freezed_annotation.dart';

part 'matchmaking_model.freezed.dart';
part 'matchmaking_model.g.dart';

/// Match result enum
enum MatchResult {
  win,
  loss,
  draw,
  abandoned,
}

/// Match difficulty level
enum MatchDifficulty {
  rookie,      // Beginner players
  amateur,     // Casual players
  veteran,     // Experienced players
  champion,    // Top players
}

/// Player rank tier
enum PlayerRankTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

/// Player statistics
@freezed
class PlayerStats with _$PlayerStats {
  const factory PlayerStats({
    required String userId,
    required int totalMatches,
    required int wins,
    required int losses,
    required int draws,
    required double winRate,           // 0-100 percentage
    required int currentStreak,        // Win/loss streak (positive = wins)
    required int longestWinStreak,
    required double averageTowerHeight,
    required int totalDamageDealt,
    required int totalDamageTaken,
    required DateTime lastMatchTime,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlayerStats;

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);
}

/// Player ranking
@freezed
class PlayerRanking with _$PlayerRanking {
  const factory PlayerRanking({
    required String userId,
    required int mmr,                  // Matchmaking rating (Elo-like)
    required PlayerRankTier tier,
    required int tierPoints,           // 0-100 points in current tier
    required int globalRank,           // 1-N ranking
    required int regionRank,           // Regional ranking
    required bool isSeasonActive,
    required int seasonPoints,
    required DateTime seasonResetDate,
    required DateTime lastUpdated,
  }) = _PlayerRanking;

  factory PlayerRanking.fromJson(Map<String, dynamic> json) =>
      _$PlayerRankingFromJson(json);
}

/// Match information
@freezed
class Match with _$Match {
  const factory Match({
    required String matchId,
    required String player1Id,
    required String player2Id,
    required MatchResult player1Result,
    required double player1TowerHeight,
    required double player2TowerHeight,
    required int player1Score,
    required int player2Score,
    required int durationSeconds,
    required MatchDifficulty difficulty,
    required String doorwayId,
    required bool isRanked,
    required int mmrChange1,           // MMR change for player 1
    required int mmrChange2,           // MMR change for player 2
    required DateTime createdAt,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) =>
      _$MatchFromJson(json);
}

/// Match queue entry
@freezed
class MatchQueueEntry with _$MatchQueueEntry {
  const factory MatchQueueEntry({
    required String entryId,
    required String userId,
    required int mmr,
    required MatchDifficulty preferredDifficulty,
    required DateTime queuedAt,
    required String? preferredOpponentId,
  }) = _MatchQueueEntry;

  factory MatchQueueEntry.fromJson(Map<String, dynamic> json) =>
      _$MatchQueueEntryFromJson(json);
}

/// Matchmaking request
@freezed
class MatchmakingRequest with _$MatchmakingRequest {
  const factory MatchmakingRequest({
    required String requestId,
    required String userId,
    required MatchDifficulty difficulty,
    required bool isRanked,
    required int timeoutSeconds,      // How long to search before timeout
    required DateTime createdAt,
  }) = _MatchmakingRequest;

  factory MatchmakingRequest.fromJson(Map<String, dynamic> json) =>
      _$MatchmakingRequestFromJson(json);
}

/// Leaderboard entry
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String userName,
    required int globalRank,
    required int mmr,
    required PlayerRankTier tier,
    required int wins,
    required int losses,
    required double winRate,
    required int seasonPoints,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

/// Match history entry
@freezed
class MatchHistoryEntry with _$MatchHistoryEntry {
  const factory MatchHistoryEntry({
    required String matchId,
    required String opponentId,
    required String opponentName,
    required MatchResult result,
    required DateTime matchTime,
    required double playerTowerHeight,
    required double opponentTowerHeight,
    required int mmrChange,
    required int playerScore,
    required int opponentScore,
  }) = _MatchHistoryEntry;

  factory MatchHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$MatchHistoryEntryFromJson(json);
}
