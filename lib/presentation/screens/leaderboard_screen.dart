import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/matchmaking_providers.dart';
import '../../data/models/matchmaking_model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);
    final currentUserRanking = ref.watch(currentUserRankingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        data: (leaderboard) => currentUserRanking.when(
          data: (userRanking) => Column(
            children: [
              // Current user rank card
              if (userRanking != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'あなたのランク',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _getTierColor(userRanking.tier),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${leaderboard.indexWhere((entry) => entry.userId == userRanking.userId) + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTierLabel(userRanking.tier),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userRanking.mmr} MMR',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'シーズンポイント',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                '${userRanking.seasonPoints}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // Leaderboard list
              Expanded(
                child: leaderboard.isEmpty
                    ? Center(
                        child: Text(
                          'ランキングデータはまだありません',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: leaderboard.length,
                        itemBuilder: (context, index) {
                          final entry = leaderboard[index];
                          return _LeaderboardEntryTile(entry: entry);
                        },
                      ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('エラー: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Color _getTierColor(PlayerRankTier tier) {
    switch (tier) {
      case PlayerRankTier.bronze:
        return Colors.brown.shade600;
      case PlayerRankTier.silver:
        return Colors.grey.shade400;
      case PlayerRankTier.gold:
        return Colors.amber.shade500;
      case PlayerRankTier.platinum:
        return Colors.cyan.shade400;
      case PlayerRankTier.diamond:
        return Colors.blue.shade600;
    }
  }

  String _getTierLabel(PlayerRankTier tier) {
    switch (tier) {
      case PlayerRankTier.bronze:
        return 'ブロンズ';
      case PlayerRankTier.silver:
        return 'シルバー';
      case PlayerRankTier.gold:
        return 'ゴールド';
      case PlayerRankTier.platinum:
        return 'プラチナ';
      case PlayerRankTier.diamond:
        return 'ダイヤ';
    }
  }
}

/// Leaderboard entry tile
class _LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(entry.globalRank),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#${entry.globalRank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tier
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTierColor(entry.tier),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getTierIcon(entry.tier),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.userName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${entry.mmr} MMR',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.wins}勝',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
                Text(
                  '${entry.winRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) {
      return Colors.amber.shade600;
    } else if (rank == 2) {
      return Colors.grey.shade400;
    } else if (rank == 3) {
      return Colors.orange.shade700;
    } else if (rank <= 10) {
      return Colors.blue.shade500;
    } else if (rank <= 50) {
      return Colors.green.shade500;
    } else {
      return Colors.grey.shade500;
    }
  }

  Color _getTierColor(PlayerRankTier tier) {
    switch (tier) {
      case PlayerRankTier.bronze:
        return Colors.brown.shade600;
      case PlayerRankTier.silver:
        return Colors.grey.shade400;
      case PlayerRankTier.gold:
        return Colors.amber.shade500;
      case PlayerRankTier.platinum:
        return Colors.cyan.shade400;
      case PlayerRankTier.diamond:
        return Colors.blue.shade600;
    }
  }

  IconData _getTierIcon(PlayerRankTier tier) {
    switch (tier) {
      case PlayerRankTier.bronze:
        return Icons.shield;
      case PlayerRankTier.silver:
        return Icons.shield;
      case PlayerRankTier.gold:
        return Icons.shield;
      case PlayerRankTier.platinum:
        return Icons.shield;
      case PlayerRankTier.diamond:
        return Icons.diamond;
    }
  }

  String _getTierLabel(PlayerRankTier tier) {
    switch (tier) {
      case PlayerRankTier.bronze:
        return 'ブロンズ';
      case PlayerRankTier.silver:
        return 'シルバー';
      case PlayerRankTier.gold:
        return 'ゴールド';
      case PlayerRankTier.platinum:
        return 'プラチナ';
      case PlayerRankTier.diamond:
        return 'ダイヤ';
    }
  }
}
