import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('積む'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ゲーム画面（Flame Engine で実装予定）'),
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('玄関・荷物・物理演算表示'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement game logic
              },
              child: const Text('荷物を配置'),
            ),
          ],
        ),
      ),
    );
  }
}
