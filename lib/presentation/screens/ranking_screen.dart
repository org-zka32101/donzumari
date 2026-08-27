import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text('プレイヤー${index + 1}'),
            trailing: Text('${150 - (index * 5)} cm'),
            subtitle: const Text('玄関ID: door_xxx'),
          );
        },
      ),
    );
  }
}
