import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宅配ドン詰まり'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Own Doorway Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('自分の玄関'),
                        const SizedBox(height: 12),
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('玄関プレビュー（実装予定）'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to PlayScreen
                            Navigator.of(context).pushNamed('/play');
                          },
                          child: const Text('積む'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _HomeActionButton(
                      label: '訪問先選択',
                      icon: Icons.door_front_door,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/visit-selection');
                      },
                    ),
                    _HomeActionButton(
                      label: 'ランキング',
                      icon: Icons.leaderboard,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/ranking');
                      },
                    ),
                    _HomeActionButton(
                      label: 'ショップ',
                      icon: Icons.shopping_bag,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/shop');
                      },
                    ),
                    _HomeActionButton(
                      label: '設定',
                      icon: Icons.settings,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _HomeActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
