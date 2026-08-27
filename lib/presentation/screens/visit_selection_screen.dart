import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/doorway_model.dart';
import '../../domain/providers/matching_provider.dart';
import '../../domain/providers/auth_provider.dart';

class VisitSelectionScreen extends ConsumerWidget {
  const VisitSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user (for matching logic)
    final userAsync = ref.watch(currentUserAsyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('訪問先選択'),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ユーザー情報を取得できません'));
          }

          // Get matching candidates with fallback to NPC doorways
          final candidatesAsync = ref.watch(
            getCandidatesWithFallbackProvider(
              (user.uid, 0.0), // TODO: Get user's actual high score
            ),
          );

          return candidatesAsync.when(
            data: (candidates) {
              if (candidates.isEmpty) {
                return const Center(
                  child: Text('利用可能な訪問先がありません'),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('複合スコアで候補を提示'),
                    ),
                    ...candidates
                        .asMap()
                        .entries
                        .map(
                          (entry) => _DoorwayCard(
                            doorway: entry.value,
                            rank: entry.key + 1,
                            onTap: () {
                              // TODO: Navigate to play screen with selected doorway
                              // context.push('/play?doorwayId=${entry.value.doorwayId}');
                              Navigator.pop(context, entry.value.doorwayId);
                            },
                          ),
                        )
                        .toList(),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('エラー: $error'),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('ユーザー情報取得エラー: $error'),
        ),
      ),
    );
  }
}

class _DoorwayCard extends StatelessWidget {
  final DoorwayModel doorway;
  final int rank;
  final VoidCallback onTap;

  const _DoorwayCard({
    required this.doorway,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'マッチ度 #$rank',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('推奨'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${doorway.doorwayId.substring(0, 8)}...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '最高到達高さ',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${doorway.topScore.toStringAsFixed(0)} cm',
                          style:
                              Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '最終アクティビティ',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          _formatActivityTime(doorway.lastActivityAt),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('この玄関に訪問'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}分前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}時間前';
    } else {
      return '${diff.inDays}日前';
    }
  }
}
