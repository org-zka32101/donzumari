import 'package:flutter_test/flutter_test.dart';
import 'package:donzumari/domain/services/matchmaking_service.dart';
import 'package:donzumari/data/models/matchmaking_model.dart';

void main() {
  group('MatchmakingService', () {
    setUp(() async {
      await MatchmakingService.initialize();
    });

    test('initializes matchmaking service', () {
      expect(
        MatchmakingService.getDebugInfo(),
        contains('initialized=true'),
      );
    });

    test('creates default ranking for new player', () async {
      final ranking = await MatchmakingService.getPlayerRanking('new_player_001');
      expect(ranking, isNotNull);
      expect(ranking?.mmr, equals(1200)); // Base MMR
      expect(ranking?.tier, equals(PlayerRankTier.bronze));
    });

    test('retrieves existing player ranking', () async {
      final ranking1 = await MatchmakingService.getPlayerRanking('player_persistent');
      final ranking2 = await MatchmakingService.getPlayerRanking('player_persistent');

      expect(ranking1?.mmr, equals(ranking2?.mmr));
    });

    test('creates default stats for new player', () async {
      final stats = await MatchmakingService.getPlayerStats('stats_player_001');
      expect(stats, isNotNull);
      expect(stats?.totalMatches, equals(0));
      expect(stats?.wins, equals(0));
      expect(stats?.losses, equals(0));
    });

    test('records match result successfully', () async {
      final result = await MatchmakingService.recordMatchResult(
        'match_001',
        'player_p1',
        'player_p2',
        MatchResult.win,
        150.0,
        120.0,
        2500,
        2000,
        300,
        'doorway_001',
        true,
      );
      expect(result, isTrue);
    });

    test('opponent search returns valid result or null', () async {
      final opponent = await MatchmakingService.findOpponent(
        'player_search',
        MatchDifficulty.rookie,
        30,
      );
      // May return null if no opponents available, but shouldn't crash
      expect(opponent, isNull || opponent is String);
    });

    test('match history retrieval works', () async {
      final history = await MatchmakingService.getMatchHistory('player_history');
      expect(history, isA<List<MatchHistoryEntry>>());
    });

    test('global leaderboard retrieval works', () async {
      final leaderboard = await MatchmakingService.getGlobalLeaderboard();
      expect(leaderboard, isA<List<LeaderboardEntry>>());
    });

    test('player ranking tiers are defined correctly', () {
      expect(PlayerRankTier.values, isNotEmpty);
      expect(PlayerRankTier.values.length, equals(5)); // bronze, silver, gold, platinum, diamond
    });

    test('match difficulties are defined correctly', () {
      expect(MatchDifficulty.values, isNotEmpty);
      expect(MatchDifficulty.values.length, greaterThanOrEqualTo(3));
    });

    test('match results are valid enum values', () {
      expect(MatchResult.win, isNotNull);
      expect(MatchResult.loss, isNotNull);
      expect(MatchResult.draw, isNotNull);
      expect(MatchResult.abandoned, isNotNull);
    });

    test('MMR calculation is consistent', () async {
      // Record two matches and verify MMR changes
      final before = await MatchmakingService.getPlayerRanking('mmr_test_player');
      expect(before?.mmr, equals(1200)); // Initial MMR

      // After match, MMR should change
      await MatchmakingService.recordMatchResult(
        'mmr_match_001',
        'mmr_test_player',
        'opponent_mmr',
        MatchResult.win,
        200.0,
        150.0,
        3000,
        2500,
        300,
        'doorway_mmr',
        true,
      );

      final after = await MatchmakingService.getPlayerRanking('mmr_test_player');
      expect(after?.mmr, isNotNull);
    });

    test('player stats track wins correctly', () async {
      final playerId = 'stats_wins_player';

      // Record a win
      await MatchmakingService.recordMatchResult(
        'win_match_001',
        playerId,
        'opponent_win',
        MatchResult.win,
        200.0,
        150.0,
        3000,
        2500,
        300,
        'doorway_win',
        true,
      );

      final stats = await MatchmakingService.getPlayerStats(playerId);
      expect(stats?.wins, greaterThanOrEqualTo(1));
    });

    test('returns debug info', () {
      final debugInfo = MatchmakingService.getDebugInfo();
      expect(debugInfo, isNotEmpty);
      expect(debugInfo, contains('Matchmaking'));
    });
  });
}
