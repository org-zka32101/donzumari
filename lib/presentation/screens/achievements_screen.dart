import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/achievement_providers.dart';
import '../../data/models/achievement_model.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAchievementsAsync = ref.watch(allAchievementsProvider);
    final userAchievementsAsync = ref.watch(userAchievementsProvider);
    final userPercentageAsync = ref.watch(userAchievementPercentageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('実績'),
        centerTitle: true,
      ),
      body: userAchievementsAsync.when(
        data: (userAchievements) => userPercentageAsync.when(
          data: (percentage) => DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // Header with progress
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '実績進捗',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${userAchievements.unlockedAchievementIds.length}/${allAchievementsAsync.length}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            '${userAchievements.totalPoints}ポイント',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs
                TabBar(
                  tabs: [
                    const Tab(text: 'すべて'),
                    const Tab(text: '未解除'),
                    const Tab(text: '解除済み'),
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    children: [
                      _AchievementListView(
                        achievements: allAchievementsAsync,
                        unlockedIds: userAchievements.unlockedAchievementIds,
                      ),
                      _AchievementListView(
                        achievements: allAchievementsAsync
                            .where((a) => !userAchievements.unlockedAchievementIds.contains(a.achievementId))
                            .toList(),
                        unlockedIds: userAchievements.unlockedAchievementIds,
                      ),
                      _AchievementListView(
                        achievements: allAchievementsAsync
                            .where((a) => userAchievements.unlockedAchievementIds.contains(a.achievementId))
                            .toList(),
                        unlockedIds: userAchievements.unlockedAchievementIds,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('エラー: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}

/// Achievement list view
class _AchievementListView extends ConsumerWidget {
  final List<AchievementDefinition> achievements;
  final List<String> unlockedIds;

  const _AchievementListView({
    required this.achievements,
    required this.unlockedIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (achievements.isEmpty) {
      return Center(
        child: Text(
          'ここに表示する実績はありません',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isUnlocked = unlockedIds.contains(achievement.achievementId);

        return _AchievementCard(
          achievement: achievement,
          isUnlocked: isUnlocked,
        );
      },
    );
  }
}

/// Achievement card widget
class _AchievementCard extends ConsumerWidget {
  final AchievementDefinition achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _AchievementDetailDialog(
              achievement: achievement,
              isUnlocked: isUnlocked,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Achievement icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.blue.shade100 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(achievement.category),
                      size: 32,
                      color: isUnlocked
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    if (isUnlocked)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Achievement info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked || !achievement.isHidden
                          ? achievement.name
                          : '????',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.black : Colors.grey[500],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked || !achievement.isHidden
                          ? achievement.description
                          : '条件を満たすと表示されます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Points
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+${achievement.points}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  ),
                  Text(
                    'ポイント',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.stacking:
        return Icons.layers;
      case AchievementCategory.scoring:
        return Icons.trending_up;
      case AchievementCategory.collection:
        return Icons.collections;
      case AchievementCategory.gameplay:
        return Icons.sports_esports;
      case AchievementCategory.exploration:
        return Icons.explore;
      case AchievementCategory.competitive:
        return Icons.emoji_events;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}

/// Achievement detail dialog
class _AchievementDetailDialog extends ConsumerWidget {
  final AchievementDefinition achievement;
  final bool isUnlocked;

  const _AchievementDetailDialog({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(achievement.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDifficultyColor(achievement.difficulty),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getDifficultyLabel(achievement.difficulty),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Points and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+${achievement.points} ポイント',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '解除済み',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '未解除',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Color _getDifficultyColor(AchievementDifficulty difficulty) {
    switch (difficulty) {
      case AchievementDifficulty.easy:
        return Colors.green;
      case AchievementDifficulty.medium:
        return Colors.blue;
      case AchievementDifficulty.hard:
        return Colors.purple;
      case AchievementDifficulty.legendary:
        return Colors.orange;
    }
  }

  String _getDifficultyLabel(AchievementDifficulty difficulty) {
    switch (difficulty) {
      case AchievementDifficulty.easy:
        return '簡単';
      case AchievementDifficulty.medium:
        return '普通';
      case AchievementDifficulty.hard:
        return '難しい';
      case AchievementDifficulty.legendary:
        return 'レジェンダリー';
    }
  }
}
