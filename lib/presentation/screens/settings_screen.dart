import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('サウンド'),
            trailing: Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text('BGM'),
            value: true,
            onChanged: (value) {
              // TODO: Toggle BGM
            },
          ),
          SwitchListTile(
            title: const Text('SE'),
            value: true,
            onChanged: (value) {
              // TODO: Toggle SE
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('通知'),
            trailing: Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('プッシュ通知'),
            value: true,
            onChanged: (value) {
              // TODO: Toggle notifications
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('その他'),
          ),
          ListTile(
            title: const Text('プライバシーポリシー'),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            title: const Text('利用規約'),
            onTap: () {
              // TODO: Open terms
            },
          ),
          ListTile(
            title: const Text('バージョン情報'),
            subtitle: const Text('v1.0.0'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Sign out
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('ログアウト'),
            ),
          ),
        ],
      ),
    );
  }
}
