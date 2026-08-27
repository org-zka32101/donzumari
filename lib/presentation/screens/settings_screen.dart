import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/preferences_providers.dart';

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
          // Audio Settings
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'サウンド',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SFXVolumeSlider(ref),
          _MusicVolumeSlider(ref),
          _SoundEnabledToggle(ref),
          _MusicEnabledToggle(ref),
          const Divider(height: 32),

          // Game Preferences
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'ゲーム',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _AutoSaveToggle(ref),
          _GraphicsQualityDropdown(ref),
          _HapticToggle(ref),
          const Divider(height: 32),

          // Localization & Theme
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'その他',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _LanguageDropdown(ref),
          _DarkModeToggle(ref),
          const Divider(height: 32),

          // Reset & Info
          ListTile(
            title: const Text('バージョン情報'),
            subtitle: const Text('v1.0.0'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showResetConfirmDialog(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('設定をリセット'),
            ),
          ),
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

  void _showResetConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('設定をリセット'),
          content: const Text('すべての設定をデフォルトに戻してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                ref.read(resetPreferencesProvider);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('設定がリセットされました')),
                );
              },
              child: const Text('リセット'),
            ),
          ],
        );
      },
    );
  }
}

/// SFX Volume Slider
class _SFXVolumeSlider extends ConsumerWidget {
  final WidgetRef ref;

  const _SFXVolumeSlider(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(sfxVolumeProvider);

    return ListTile(
      title: const Text('効果音の音量'),
      subtitle: Slider(
        value: volume,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: '${(volume * 100).toStringAsFixed(0)}%',
        onChanged: (newVolume) {
          ref.read(setSFXVolumeProvider(newVolume));
        },
      ),
      trailing: Text('${(volume * 100).toStringAsFixed(0)}%'),
    );
  }
}

/// Music Volume Slider
class _MusicVolumeSlider extends ConsumerWidget {
  final WidgetRef ref;

  const _MusicVolumeSlider(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(musicVolumeProvider);

    return ListTile(
      title: const Text('BGMの音量'),
      subtitle: Slider(
        value: volume,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: '${(volume * 100).toStringAsFixed(0)}%',
        onChanged: (newVolume) {
          ref.read(setMusicVolumeProvider(newVolume));
        },
      ),
      trailing: Text('${(volume * 100).toStringAsFixed(0)}%'),
    );
  }
}

/// Sound Enabled Toggle
class _SoundEnabledToggle extends ConsumerWidget {
  final WidgetRef ref;

  const _SoundEnabledToggle(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(soundEnabledProvider);

    return SwitchListTile(
      title: const Text('効果音'),
      value: enabled,
      onChanged: (newValue) {
        ref.read(setSoundEnabledProvider(newValue));
      },
    );
  }
}

/// Music Enabled Toggle
class _MusicEnabledToggle extends ConsumerWidget {
  final WidgetRef ref;

  const _MusicEnabledToggle(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(musicEnabledProvider);

    return SwitchListTile(
      title: const Text('BGM'),
      value: enabled,
      onChanged: (newValue) {
        ref.read(setMusicEnabledProvider(newValue));
      },
    );
  }
}

/// Haptic Feedback Toggle
class _HapticToggle extends ConsumerWidget {
  final WidgetRef ref;

  const _HapticToggle(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(hapticEnabledProvider);

    return SwitchListTile(
      title: const Text('バイブレーション'),
      value: enabled,
      onChanged: (newValue) {
        ref.read(setHapticEnabledProvider(newValue));
      },
    );
  }
}

/// Auto-save Toggle
class _AutoSaveToggle extends ConsumerWidget {
  final WidgetRef ref;

  const _AutoSaveToggle(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(autoSaveEnabledProvider);

    return SwitchListTile(
      title: const Text('自動セーブ'),
      value: enabled,
      onChanged: (newValue) {
        ref.read(setAutoSaveEnabledProvider(newValue));
      },
    );
  }
}

/// Graphics Quality Dropdown
class _GraphicsQualityDropdown extends ConsumerWidget {
  final WidgetRef ref;

  const _GraphicsQualityDropdown(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(graphicsQualityProvider);

    return ListTile(
      title: const Text('グラフィック品質'),
      trailing: DropdownButton<String>(
        value: quality,
        items: const [
          DropdownMenuItem(value: 'low', child: Text('低')),
          DropdownMenuItem(value: 'medium', child: Text('中')),
          DropdownMenuItem(value: 'high', child: Text('高')),
        ],
        onChanged: (newQuality) {
          if (newQuality != null) {
            ref.read(setGraphicsQualityProvider(newQuality));
          }
        },
      ),
    );
  }
}

/// Language Dropdown
class _LanguageDropdown extends ConsumerWidget {
  final WidgetRef ref;

  const _LanguageDropdown(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);

    return ListTile(
      title: const Text('言語'),
      trailing: DropdownButton<String>(
        value: language,
        items: const [
          DropdownMenuItem(value: 'ja', child: Text('日本語')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
        onChanged: (newLanguage) {
          if (newLanguage != null) {
            ref.read(setLanguageProvider(newLanguage));
          }
        },
      ),
    );
  }
}

/// Dark Mode Toggle
class _DarkModeToggle extends ConsumerWidget {
  final WidgetRef ref;

  const _DarkModeToggle(this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(darkModeProvider);

    return SwitchListTile(
      title: const Text('ダークモード'),
      value: enabled,
      onChanged: (newValue) {
        ref.read(setDarkModeProvider(newValue));
      },
    );
  }
}
