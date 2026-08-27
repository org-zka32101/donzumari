import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting user preferences locally
class PreferencesService {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  // Preference keys
  static const String _sfxVolumeKey = 'sfx_volume';
  static const String _musicVolumeKey = 'music_volume';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';
  static const String _autoSaveKey = 'auto_save_enabled';
  static const String _graphicsQualityKey = 'graphics_quality';
  static const String _languageKey = 'language';
  static const String _darkModeKey = 'dark_mode';

  /// Initialize preferences service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('✅ Preferences service initialized');
    } catch (e) {
      print('⚠️ Preferences initialization warning: $e');
    }
  }

  // Audio Preferences

  /// Get SFX volume (0.0 to 1.0)
  static double getSFXVolume() {
    _ensureInitialized();
    return _prefs.getDouble(_sfxVolumeKey) ?? 1.0;
  }

  /// Set SFX volume
  static Future<bool> setSFXVolume(double volume) async {
    _ensureInitialized();
    return await _prefs.setDouble(_sfxVolumeKey, volume.clamp(0.0, 1.0));
  }

  /// Get music volume (0.0 to 1.0)
  static double getMusicVolume() {
    _ensureInitialized();
    return _prefs.getDouble(_musicVolumeKey) ?? 0.7;
  }

  /// Set music volume
  static Future<bool> setMusicVolume(double volume) async {
    _ensureInitialized();
    return await _prefs.setDouble(_musicVolumeKey, volume.clamp(0.0, 1.0));
  }

  /// Check if sound effects are enabled
  static bool isSoundEnabled() {
    _ensureInitialized();
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Set sound effects enabled
  static Future<bool> setSoundEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(_soundEnabledKey, enabled);
  }

  /// Check if music is enabled
  static bool isMusicEnabled() {
    _ensureInitialized();
    return _prefs.getBool(_musicEnabledKey) ?? true;
  }

  /// Set music enabled
  static Future<bool> setMusicEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(_musicEnabledKey, enabled);
  }

  // Haptics

  /// Check if haptic feedback is enabled
  static bool isHapticEnabled() {
    _ensureInitialized();
    return _prefs.getBool(_hapticEnabledKey) ?? true;
  }

  /// Set haptic feedback enabled
  static Future<bool> setHapticEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(_hapticEnabledKey, enabled);
  }

  // Game Preferences

  /// Check if auto-save is enabled
  static bool isAutoSaveEnabled() {
    _ensureInitialized();
    return _prefs.getBool(_autoSaveKey) ?? true;
  }

  /// Set auto-save enabled
  static Future<bool> setAutoSaveEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(_autoSaveKey, enabled);
  }

  /// Get graphics quality (low, medium, high)
  static String getGraphicsQuality() {
    _ensureInitialized();
    return _prefs.getString(_graphicsQualityKey) ?? 'high';
  }

  /// Set graphics quality
  static Future<bool> setGraphicsQuality(String quality) async {
    _ensureInitialized();
    if (!['low', 'medium', 'high'].contains(quality)) {
      throw ArgumentError('Invalid graphics quality: $quality');
    }
    return await _prefs.setString(_graphicsQualityKey, quality);
  }

  // Localization

  /// Get language preference (ja, en)
  static String getLanguage() {
    _ensureInitialized();
    return _prefs.getString(_languageKey) ?? 'ja';
  }

  /// Set language preference
  static Future<bool> setLanguage(String language) async {
    _ensureInitialized();
    if (!['ja', 'en'].contains(language)) {
      throw ArgumentError('Invalid language: $language');
    }
    return await _prefs.setString(_languageKey, language);
  }

  // Theme

  /// Check if dark mode is enabled
  static bool isDarkModeEnabled() {
    _ensureInitialized();
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  /// Set dark mode enabled
  static Future<bool> setDarkModeEnabled(bool enabled) async {
    _ensureInitialized();
    return await _prefs.setBool(_darkModeKey, enabled);
  }

  // Utility Methods

  /// Get all preferences as map
  static Map<String, dynamic> getAll() {
    _ensureInitialized();
    return Map.from(_prefs.getKeys().fold<Map<String, dynamic>>(
      {},
      (map, key) {
        map[key] = _prefs.get(key);
        return map;
      },
    ));
  }

  /// Clear all preferences
  static Future<bool> clearAll() async {
    _ensureInitialized();
    return await _prefs.clear();
  }

  /// Reset to defaults
  static Future<void> resetToDefaults() async {
    _ensureInitialized();
    await clearAll();
    print('🔄 Preferences reset to defaults');
  }

  /// Get audio preferences as bundle
  static Map<String, dynamic> getAudioPreferences() {
    return {
      'sfxVolume': getSFXVolume(),
      'musicVolume': getMusicVolume(),
      'soundEnabled': isSoundEnabled(),
      'musicEnabled': isMusicEnabled(),
    };
  }

  /// Set audio preferences from bundle
  static Future<void> setAudioPreferences(Map<String, dynamic> prefs) async {
    if (prefs.containsKey('sfxVolume')) {
      await setSFXVolume(prefs['sfxVolume'] as double);
    }
    if (prefs.containsKey('musicVolume')) {
      await setMusicVolume(prefs['musicVolume'] as double);
    }
    if (prefs.containsKey('soundEnabled')) {
      await setSoundEnabled(prefs['soundEnabled'] as bool);
    }
    if (prefs.containsKey('musicEnabled')) {
      await setMusicEnabled(prefs['musicEnabled'] as bool);
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Preferences: initialized=$_isInitialized, '
        'sound=${isSoundEnabled()}, music=${isMusicEnabled()}';
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'PreferencesService not initialized. Call initialize() first.',
      );
    }
  }
}
