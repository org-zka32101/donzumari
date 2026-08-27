import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('結果'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('プレイ結果（スコア/崩落GIF）'),
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('GIF または 静止画表示'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '高さ: 150 cm',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Share
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('共有'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Retry with reward ad
                  },
                  child: const Text('リトライ（広告視聴）'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
