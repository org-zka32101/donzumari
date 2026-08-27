import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../data/models/matchmaking_model.dart';

/// Service for managing multiplayer matchmaking and rankings
class MatchmakingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _initialized = false;

  // Matchmaking configuration
  static const int _baseMMR = 1200;
  static const int _mmrPerTier = 300;
  static const int _kFactor = 32; // ELO K-factor

  /// Initialize matchmaking service
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    print('✅ Matchmaking service initialized');
  }

  /// Get player stats
  static Future<PlayerStats?> getPlayerStats(String userId) async {
    _ensureInitialized();

    try {
      final doc = await _firestore.collection('playerStats').doc(userId).get();
      if (doc.exists) {
        return PlayerStats.fromJson({...doc.data()!, 'userId': userId});
      }
      return null;
    } catch (e) {
      print('⚠️ Failed to get player stats: $e');
      return null;
    }
  }

  /// Get player ranking
  static Future<PlayerRanking?> getPlayerRanking(String userId) async {
    _ensureInitialized();

    try {
      final doc = await _firestore.collection('playerRankings').doc(userId).get();
      if (doc.exists) {
        return PlayerRanking.fromJson({...doc.data()!, 'userId': userId});
      }

      // Create default ranking for new player
      final defaultRanking = PlayerRanking(
        userId: userId,
        mmr: _baseMMR,
        tier: PlayerRankTier.bronze,
        tierPoints: 0,
        globalRank: 99999, // Will be updated
        regionRank: 99999,
        isSeasonActive: true,
        seasonPoints: 0,
        seasonResetDate: DateTime.now().add(const Duration(days: 30)),
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('playerRankings')
          .doc(userId)
          .set(defaultRanking.toJson());

      return defaultRanking;
    } catch (e) {
      print('⚠️ Failed to get player ranking: $e');
      return null;
    }
  }

  /// Record a match result
  static Future<bool> recordMatchResult(
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
  ) async {
    _ensureInitialized();

    try {
      // Get both players' current rankings
      final p1Ranking = await getPlayerRanking(player1Id);
      final p2Ranking = await getPlayerRanking(player2Id);

      if (p1Ranking == null || p2Ranking == null) {
        print('⚠️ Could not find player rankings');
        return false;
      }

      // Calculate MMR changes
      final (mmrChange1, mmrChange2) = _calculateMMRChange(
        p1Ranking.mmr,
        p2Ranking.mmr,
        player1Result,
        isRanked,
      );

      // Create match record
      final match = Match(
        matchId: matchId,
        player1Id: player1Id,
        player2Id: player2Id,
        player1Result: player1Result,
        player1TowerHeight: player1Height,
        player2TowerHeight: player2Height,
        player1Score: player1Score,
        player2Score: player2Score,
        durationSeconds: durationSeconds,
        difficulty: _calculateDifficulty(p1Ranking.mmr, p2Ranking.mmr),
        doorwayId: doorwayId,
        isRanked: isRanked,
        mmrChange1: mmrChange1,
        mmrChange2: mmrChange2,
        createdAt: DateTime.now(),
      );

      // Save match record
      await _firestore
          .collection('matches')
          .doc(matchId)
          .set(match.toJson());

      // Update player rankings and stats
      await _updatePlayerStats(
        player1Id,
        player2Id,
        player1Result,
        p1Ranking,
        p2Ranking,
        mmrChange1,
        mmrChange2,
        player1Height,
        player2Height,
        player1Score,
        player2Score,
        durationSeconds,
        isRanked,
      );

      print('🎯 Match recorded: $matchId');
      return true;
    } catch (e) {
      print('⚠️ Failed to record match: $e');
      return false;
    }
  }

  /// Find a match opponent
  static Future<String?> findOpponent(
    String userId,
    MatchDifficulty difficulty,
    int timeoutSeconds,
  ) async {
    _ensureInitialized();

    try {
      final userRanking = await getPlayerRanking(userId);
      if (userRanking == null) return null;

      // Search for players in similar MMR range
      final mmrRange = _getMmrSearchRange(difficulty, userRanking.mmr);

      final snapshot = await _firestore
          .collection('playerRankings')
          .where('mmr', isGreaterThanOrEqualTo: mmrRange.$1)
          .where('mmr', isLessThanOrEqualTo: mmrRange.$2)
          .where('isSeasonActive', isEqualTo: true)
          .limit(10)
          .get();

      // Filter out the requesting player and recently matched players
      final recentMatches = await _getRecentMatchIds(userId, 5);

      for (final doc in snapshot.docs) {
        final opponentId = doc.id;
        if (opponentId != userId && !recentMatches.contains(opponentId)) {
          return opponentId;
        }
      }

      return null;
    } catch (e) {
      print('⚠️ Failed to find opponent: $e');
      return null;
    }
  }

  /// Get match history for a player
  static Future<List<MatchHistoryEntry>> getMatchHistory(
    String userId, {
    int limit = 20,
  }) async {
    _ensureInitialized();

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('player1Id', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final matches = <MatchHistoryEntry>[];

      for (final doc in snapshot.docs) {
        final match = Match.fromJson({...doc.data(), 'matchId': doc.id});
        // Only show matches where this user was player1 (to avoid duplicates)
        if (match.player1Id == userId) {
          matches.add(MatchHistoryEntry(
            matchId: match.matchId,
            opponentId: match.player2Id,
            opponentName: 'Player ${match.player2Id.substring(0, 6)}',
            result: match.player1Result,
            matchTime: match.createdAt,
            playerTowerHeight: match.player1TowerHeight,
            opponentTowerHeight: match.player2TowerHeight,
            mmrChange: match.mmrChange1,
            playerScore: match.player1Score,
            opponentScore: match.player2Score,
          ));
        }
      }

      return matches;
    } catch (e) {
      print('⚠️ Failed to get match history: $e');
      return [];
    }
  }

  /// Get global leaderboard
  static Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
  }) async {
    _ensureInitialized();

    try {
      final snapshot = await _firestore
          .collection('playerRankings')
          .orderBy('mmr', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];

      int rank = 1;
      for (final doc in snapshot.docs) {
        final ranking = PlayerRanking.fromJson({...doc.data(), 'userId': doc.id});
        final stats = await getPlayerStats(doc.id);

        if (stats != null) {
          entries.add(LeaderboardEntry(
            userId: ranking.userId,
            userName: 'Player ${ranking.userId.substring(0, 6)}',
            globalRank: rank++,
            mmr: ranking.mmr,
            tier: ranking.tier,
            wins: stats.wins,
            losses: stats.losses,
            winRate: stats.winRate,
            seasonPoints: ranking.seasonPoints,
          ));
        }
      }

      return entries;
    } catch (e) {
      print('⚠️ Failed to get leaderboard: $e');
      return [];
    }
  }

  // Private helper methods

  /// Calculate MMR change based on match result
  static (int, int) _calculateMMRChange(
    int player1MMR,
    int player2MMR,
    MatchResult player1Result,
    bool isRanked,
  ) {
    if (!isRanked) return (0, 0);

    // Calculate expected scores using ELO formula
    final qA = pow(10, player1MMR / 400).toDouble();
    final qB = pow(10, player2MMR / 400).toDouble();
    final expectedA = qA / (qA + qB);
    final expectedB = qB / (qA + qB);

    // Determine actual scores
    late double scoreA, scoreB;
    switch (player1Result) {
      case MatchResult.win:
        scoreA = 1.0;
        scoreB = 0.0;
        break;
      case MatchResult.loss:
        scoreA = 0.0;
        scoreB = 1.0;
        break;
      case MatchResult.draw:
        scoreA = 0.5;
        scoreB = 0.5;
        break;
      case MatchResult.abandoned:
        scoreA = 0.0;
        scoreB = 1.0;
        break;
    }

    // Calculate new ratings
    final newA = (player1MMR + (_kFactor * (scoreA - expectedA))).toInt();
    final newB = (player2MMR + (_kFactor * (scoreB - expectedB))).toInt();

    return (newA - player1MMR, newB - player2MMR);
  }

  /// Calculate difficulty level based on MMR difference
  static MatchDifficulty _calculateDifficulty(int mmr1, int mmr2) {
    final diff = (mmr1 - mmr2).abs();

    if (diff > 400) {
      return MatchDifficulty.champion;
    } else if (diff > 200) {
      return MatchDifficulty.veteran;
    } else if (diff > 100) {
      return MatchDifficulty.amateur;
    } else {
      return MatchDifficulty.rookie;
    }
  }

  /// Get MMR search range for matchmaking
  static (int, int) _getMmrSearchRange(MatchDifficulty difficulty, int currentMMR) {
    late int range;
    switch (difficulty) {
      case MatchDifficulty.rookie:
        range = 50;
        break;
      case MatchDifficulty.amateur:
        range = 100;
        break;
      case MatchDifficulty.veteran:
        range = 200;
        break;
      case MatchDifficulty.champion:
        range = 300;
        break;
    }

    return (currentMMR - range, currentMMR + range);
  }

  /// Get recent match IDs to avoid matching same player
  static Future<List<String>> _getRecentMatchIds(String userId, int limit) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('player1Id', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) {
            final match = Match.fromJson({...doc.data(), 'matchId': doc.id});
            return match.player2Id;
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Update player stats after a match
  static Future<bool> _updatePlayerStats(
    String player1Id,
    String player2Id,
    MatchResult player1Result,
    PlayerRanking p1Ranking,
    PlayerRanking p2Ranking,
    int mmrChange1,
    int mmrChange2,
    double p1Height,
    double p2Height,
    int p1Score,
    int p2Score,
    int durationSeconds,
    bool isRanked,
  ) async {
    try {
      // Get current stats
      final p1Stats = await getPlayerStats(player1Id);
      final p2Stats = await getPlayerStats(player2Id);

      // Calculate new stats for player 1
      final p1Wins = p1Stats?.wins ?? 0;
      final p1Losses = p1Stats?.losses ?? 0;
      final p1Draws = p1Stats?.draws ?? 0;

      int newP1Wins = p1Wins;
      int newP1Losses = p1Losses;
      int newP1Draws = p1Draws;

      switch (player1Result) {
        case MatchResult.win:
          newP1Wins++;
          break;
        case MatchResult.loss:
          newP1Losses++;
          break;
        case MatchResult.draw:
          newP1Draws++;
          break;
        case MatchResult.abandoned:
          newP1Losses++;
          break;
      }

      // Update rankings
      final newP1MMR = p1Ranking.mmr + mmrChange1;
      final newP2MMR = p2Ranking.mmr + mmrChange2;

      final newP1Tier = _getTierFromMMR(newP1MMR);
      final newP2Tier = _getTierFromMMR(newP2MMR);

      await _firestore.collection('playerRankings').doc(player1Id).update({
        'mmr': newP1MMR,
        'tier': newP1Tier.toString(),
        'lastUpdated': DateTime.now().toIso8601String(),
        if (isRanked) 'seasonPoints': FieldValue.increment(mmrChange1.abs()),
      });

      await _firestore.collection('playerRankings').doc(player2Id).update({
        'mmr': newP2MMR,
        'tier': newP2Tier.toString(),
        'lastUpdated': DateTime.now().toIso8601String(),
        if (isRanked) 'seasonPoints': FieldValue.increment(mmrChange2.abs()),
      });

      // Update stats
      final totalMatches = (p1Stats?.totalMatches ?? 0) + 1;
      final newWinRate =
          totalMatches > 0 ? (newP1Wins / totalMatches) * 100 : 0.0;

      await _firestore.collection('playerStats').doc(player1Id).set(
        PlayerStats(
          userId: player1Id,
          totalMatches: totalMatches,
          wins: newP1Wins,
          losses: newP1Losses,
          draws: newP1Draws,
          winRate: newWinRate,
          currentStreak: _calculateStreak(player1Result, p1Stats?.currentStreak ?? 0),
          longestWinStreak: p1Stats?.longestWinStreak ?? 0,
          averageTowerHeight: ((p1Stats?.averageTowerHeight ?? 0) * (totalMatches - 1) +
                  p1Height) /
              totalMatches,
          totalDamageDealt: (p1Stats?.totalDamageDealt ?? 0) + p1Score.toInt(),
          totalDamageTaken: (p1Stats?.totalDamageTaken ?? 0) + p2Score.toInt(),
          lastMatchTime: DateTime.now(),
          createdAt: p1Stats?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ).toJson(),
      );

      return true;
    } catch (e) {
      print('⚠️ Failed to update player stats: $e');
      return false;
    }
  }

  /// Get tier from MMR
  static PlayerRankTier _getTierFromMMR(int mmr) {
    if (mmr < 1200) {
      return PlayerRankTier.bronze;
    } else if (mmr < 1500) {
      return PlayerRankTier.silver;
    } else if (mmr < 1800) {
      return PlayerRankTier.gold;
    } else if (mmr < 2100) {
      return PlayerRankTier.platinum;
    } else {
      return PlayerRankTier.diamond;
    }
  }

  /// Calculate winning/losing streak
  static int _calculateStreak(MatchResult result, int currentStreak) {
    switch (result) {
      case MatchResult.win:
        return currentStreak > 0 ? currentStreak + 1 : 1;
      case MatchResult.loss:
        return currentStreak < 0 ? currentStreak - 1 : -1;
      case MatchResult.draw:
        return 0;
      case MatchResult.abandoned:
        return currentStreak < 0 ? currentStreak - 1 : -1;
    }
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'MatchmakingService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'MatchmakingService: initialized=$_initialized';
  }
}
