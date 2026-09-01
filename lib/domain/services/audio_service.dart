import 'package:flame_audio/flame_audio.dart';

/// Audio service for managing game sounds and music
class AudioService {
  static bool _isInitialized = false;
  static double _sfxVolume = 1.0;
  static double _musicVolume = 0.7;
  static bool _soundEnabled = true;
  static bool _musicEnabled = true;

  // Audio cache
  static final Map<String, String> _soundCache = {
    // Game sounds
    'parcel_drop': 'sounds/effects/parcel_drop.wav',
    'parcel_land': 'sounds/effects/parcel_land.wav',
    'parcel_collision': 'sounds/effects/parcel_collision.wav',
    'tower_collapse': 'sounds/effects/tower_collapse.wav',
    'tower_perfect': 'sounds/effects/tower_perfect.wav',
    'score_increase': 'sounds/effects/score_increase.wav',

    // UI sounds
    'button_tap': 'sounds/ui/button_tap.wav',
    'screen_transition': 'sounds/ui/screen_transition.wav',
    'notification': 'sounds/ui/notification.wav',
    'achievement_unlock': 'sounds/ui/achievement_unlock.wav',

    // Music tracks
    'menu_music': 'sounds/music/menu_loop.ogg',
    'gameplay_music': 'sounds/music/gameplay_loop.ogg',
    'victory_music': 'sounds/music/victory.ogg',
    'defeat_music': 'sounds/music/defeat.ogg',
  };

  /// Initialize audio service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure audio pools for frequently used sounds
      await FlameAudio.audioCache.loadAll([
        'sounds/effects/parcel_drop.wav',
        'sounds/effects/parcel_land.wav',
        'sounds/effects/parcel_collision.wav',
        'sounds/effects/tower_collapse.wav',
      ]);

      _isInitialized = true;
      print('✅ Audio service initialized');
    } catch (e) {
      print('⚠️ Audio initialization warning: $e');
      // Don't block app startup if audio fails
    }
  }

  /// Play sound effect
  static Future<void> playSound(String soundKey) async {
    if (!_soundEnabled || !_isInitialized) return;

    try {
      final filePath = _soundCache[soundKey];
      if (filePath == null) {
        print('⚠️ Sound not found: $soundKey');
        return;
      }

      await FlameAudio.play(
        filePath.replaceFirst('sounds/', ''),
        volume: _sfxVolume,
      );
    } catch (e) {
      print('⚠️ Failed to play sound $soundKey: $e');
    }
  }

  /// Play background music (loops)
  static Future<void> playMusic(String musicKey) async {
    if (!_musicEnabled || !_isInitialized) return;

    try {
      final filePath = _soundCache[musicKey];
      if (filePath == null) {
        print('⚠️ Music not found: $musicKey');
        return;
      }

      // Stop current music
      await FlameAudio.bgm.stop();

      // Play new music
      await FlameAudio.bgm.play(
        filePath.replaceFirst('sounds/', ''),
        volume: _musicVolume,
      );
    } catch (e) {
      print('⚠️ Failed to play music $musicKey: $e');
    }
  }

  /// Stop background music
  static Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      print('⚠️ Failed to stop music: $e');
    }
  }

  /// Pause background music
  static Future<void> pauseMusic() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      print('⚠️ Failed to pause music: $e');
    }
  }

  /// Resume background music
  static Future<void> resumeMusic() async {
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      print('⚠️ Failed to resume music: $e');
    }
  }

  /// Set SFX volume (0.0 to 1.0)
  static void setSFXVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// Set music volume (0.0 to 1.0)
  static void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
  }

  /// Get SFX volume
  static double getSFXVolume() => _sfxVolume;

  /// Get music volume
  static double getMusicVolume() => _musicVolume;

  /// Enable/disable all sound effects
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Enable/disable background music
  static Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (!enabled) {
      await stopMusic();
    }
  }

  /// Check if sound is enabled
  static bool isSoundEnabled() => _soundEnabled;

  /// Check if music is enabled
  static bool isMusicEnabled() => _musicEnabled;

  /// Play sequence of sounds with delays
  static Future<void> playSoundSequence(
    List<(String soundKey, int delayMs)> sequence,
  ) async {
    for (final (soundKey, delayMs) in sequence) {
      await playSound(soundKey);
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  /// Preload sounds for gameplay (UI + common effects)
  static Future<void> preloadGameplaySounds() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'sounds/effects/parcel_drop.wav',
        'sounds/effects/parcel_land.wav',
        'sounds/effects/parcel_collision.wav',
        'sounds/effects/tower_collapse.wav',
        'sounds/effects/tower_perfect.wav',
        'sounds/effects/score_increase.wav',
        'sounds/ui/button_tap.wav',
      ]);
      print('✅ Gameplay sounds preloaded');
    } catch (e) {
      print('⚠️ Preload failed: $e');
    }
  }

  /// Clear audio cache (on memory pressure)
  static void clearCache() {
    try {
      FlameAudio.audioCache.clear();
      print('🗑️ Audio cache cleared');
    } catch (e) {
      print('⚠️ Cache clear failed: $e');
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Audio: SFX=${_sfxVolume.toStringAsFixed(2)}, '
        'Music=${_musicVolume.toStringAsFixed(2)}, '
        'SoundEnabled=$_soundEnabled, MusicEnabled=$_musicEnabled';
  }
}
