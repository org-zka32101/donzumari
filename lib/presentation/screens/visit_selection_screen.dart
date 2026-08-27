import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitSelectionScreen extends ConsumerWidget {
  const VisitSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('訪問先選択'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('複合スコアで候補3件を提示'),
              ),
              _DoorwayCard(
                title: '実力帯マッチ',
                description: '自分の最高到達スコア±20%の玄関',
                height: 120,
                visitors: 5,
                onTap: () {
                  // TODO: Navigate to play screen with selected doorway
                },
              ),
              _DoorwayCard(
                title: '活動優先',
                description: '直近24時間以内に積まれた玄関',
                height: 95,
                visitors: 3,
                onTap: () {
                  // TODO: Navigate to play screen with selected doorway
                },
              ),
              _DoorwayCard(
                title: '未訪問優先',
                description: 'まだ訪問していない玄関',
                height: 80,
                visitors: 1,
                onTap: () {
                  // TODO: Navigate to play screen with selected doorway
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoorwayCard extends StatelessWidget {
  final String title;
  final String description;
  final double height;
  final int visitors;
  final VoidCallback onTap;

  const _DoorwayCard({
    required this.title,
    required this.description,
    required this.height,
    required this.visitors,
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('現在の高さ: ${height.toStringAsFixed(0)} cm'),
                  Text('今週の挑戦者: $visitors'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
