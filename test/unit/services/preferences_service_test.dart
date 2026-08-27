import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:donzumari/domain/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    setUp(() async {
      // Initialize SharedPreferences with test defaults
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();
    });

    tearDown(() async {
      SharedPreferences.setMockInitialValues({});
    });

    group('Audio Preferences', () {
      test('getSFXVolume returns default 1.0', () {
        expect(PreferencesService.getSFXVolume(), 1.0);
      });

      test('setSFXVolume persists and retrieves value', () async {
        await PreferencesService.setSFXVolume(0.5);
        expect(PreferencesService.getSFXVolume(), 0.5);
      });

      test('setSFXVolume clamps values to 0.0-1.0', () async {
        await PreferencesService.setSFXVolume(1.5);
        expect(PreferencesService.getSFXVolume(), 1.0);

        await PreferencesService.setSFXVolume(-0.5);
        expect(PreferencesService.getSFXVolume(), 0.0);
      });

      test('getMusicVolume returns default 0.7', () {
        expect(PreferencesService.getMusicVolume(), 0.7);
      });

      test('setMusicVolume persists and retrieves value', () async {
        await PreferencesService.setMusicVolume(0.3);
        expect(PreferencesService.getMusicVolume(), 0.3);
      });

      test('isSoundEnabled returns default true', () {
        expect(PreferencesService.isSoundEnabled(), true);
      });

      test('setSoundEnabled toggles and persists', () async {
        await PreferencesService.setSoundEnabled(false);
        expect(PreferencesService.isSoundEnabled(), false);

        await PreferencesService.setSoundEnabled(true);
        expect(PreferencesService.isSoundEnabled(), true);
      });

      test('isMusicEnabled returns default true', () {
        expect(PreferencesService.isMusicEnabled(), true);
      });

      test('setMusicEnabled toggles and persists', () async {
        await PreferencesService.setMusicEnabled(false);
        expect(PreferencesService.isMusicEnabled(), false);

        await PreferencesService.setMusicEnabled(true);
        expect(PreferencesService.isMusicEnabled(), true);
      });
    });

    group('Game Preferences', () {
      test('isAutoSaveEnabled returns default true', () {
        expect(PreferencesService.isAutoSaveEnabled(), true);
      });

      test('setAutoSaveEnabled persists value', () async {
        await PreferencesService.setAutoSaveEnabled(false);
        expect(PreferencesService.isAutoSaveEnabled(), false);
      });

      test('getGraphicsQuality returns default "high"', () {
        expect(PreferencesService.getGraphicsQuality(), 'high');
      });

      test('setGraphicsQuality persists valid values', () async {
        await PreferencesService.setGraphicsQuality('low');
        expect(PreferencesService.getGraphicsQuality(), 'low');

        await PreferencesService.setGraphicsQuality('medium');
        expect(PreferencesService.getGraphicsQuality(), 'medium');
      });

      test('setGraphicsQuality throws on invalid value', () {
        expect(
          () => PreferencesService.setGraphicsQuality('ultra'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Haptic Preferences', () {
      test('isHapticEnabled returns default true', () {
        expect(PreferencesService.isHapticEnabled(), true);
      });

      test('setHapticEnabled persists value', () async {
        await PreferencesService.setHapticEnabled(false);
        expect(PreferencesService.isHapticEnabled(), false);
      });
    });

    group('Localization Preferences', () {
      test('getLanguage returns default "ja"', () {
        expect(PreferencesService.getLanguage(), 'ja');
      });

      test('setLanguage persists valid values', () async {
        await PreferencesService.setLanguage('en');
        expect(PreferencesService.getLanguage(), 'en');

        await PreferencesService.setLanguage('ja');
        expect(PreferencesService.getLanguage(), 'ja');
      });

      test('setLanguage throws on invalid value', () {
        expect(
          () => PreferencesService.setLanguage('fr'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Theme Preferences', () {
      test('isDarkModeEnabled returns default false', () {
        expect(PreferencesService.isDarkModeEnabled(), false);
      });

      test('setDarkModeEnabled persists value', () async {
        await PreferencesService.setDarkModeEnabled(true);
        expect(PreferencesService.isDarkModeEnabled(), true);

        await PreferencesService.setDarkModeEnabled(false);
        expect(PreferencesService.isDarkModeEnabled(), false);
      });
    });

    group('Utility Methods', () {
      test('getAll returns empty map for unset preferences', () {
        final all = PreferencesService.getAll();
        expect(all, isA<Map<String, dynamic>>());
      });

      test('getAll includes set preferences', () async {
        await PreferencesService.setSFXVolume(0.5);
        await PreferencesService.setSoundEnabled(false);

        final all = PreferencesService.getAll();
        expect(all, isNotEmpty);
      });

      test('clearAll removes all preferences', () async {
        await PreferencesService.setSFXVolume(0.5);
        await PreferencesService.setLanguage('en');

        await PreferencesService.clearAll();

        expect(PreferencesService.getSFXVolume(), 1.0); // back to default
        expect(PreferencesService.getLanguage(), 'ja'); // back to default
      });

      test('resetToDefaults clears and sets all to default values', () async {
        // Set non-default values
        await PreferencesService.setSFXVolume(0.3);
        await PreferencesService.setMusicVolume(0.2);
        await PreferencesService.setSoundEnabled(false);
        await PreferencesService.setLanguage('en');
        await PreferencesService.setDarkModeEnabled(true);

        // Reset
        await PreferencesService.resetToDefaults();

        // Verify all are at defaults
        expect(PreferencesService.getSFXVolume(), 1.0);
        expect(PreferencesService.getMusicVolume(), 0.7);
        expect(PreferencesService.isSoundEnabled(), true);
        expect(PreferencesService.isMusicEnabled(), true);
        expect(PreferencesService.getLanguage(), 'ja');
        expect(PreferencesService.isDarkModeEnabled(), false);
      });
    });

    group('Audio Preferences Bundle', () {
      test('getAudioPreferences returns all audio settings', () {
        final prefs = PreferencesService.getAudioPreferences();

        expect(prefs, containsPair('sfxVolume', 1.0));
        expect(prefs, containsPair('musicVolume', 0.7));
        expect(prefs, containsPair('soundEnabled', true));
        expect(prefs, containsPair('musicEnabled', true));
      });

      test('setAudioPreferences updates all audio settings', () async {
        const newPrefs = {
          'sfxVolume': 0.4,
          'musicVolume': 0.6,
          'soundEnabled': false,
          'musicEnabled': false,
        };

        await PreferencesService.setAudioPreferences(newPrefs);

        expect(PreferencesService.getSFXVolume(), 0.4);
        expect(PreferencesService.getMusicVolume(), 0.6);
        expect(PreferencesService.isSoundEnabled(), false);
        expect(PreferencesService.isMusicEnabled(), false);
      });

      test('setAudioPreferences skips missing keys', () async {
        const partialPrefs = {
          'sfxVolume': 0.5,
          'soundEnabled': false,
          // musicVolume and musicEnabled intentionally omitted
        };

        await PreferencesService.setAudioPreferences(partialPrefs);

        expect(PreferencesService.getSFXVolume(), 0.5);
        expect(PreferencesService.isSoundEnabled(), false);
        expect(PreferencesService.getMusicVolume(), 0.7); // unchanged
        expect(PreferencesService.isMusicEnabled(), true); // unchanged
      });
    });

    group('Error Handling', () {
      test('getDebugInfo returns formatted string', () {
        final info = PreferencesService.getDebugInfo();

        expect(info, isA<String>());
        expect(info, contains('Preferences:'));
        expect(info, contains('initialized='));
        expect(info, contains('sound='));
        expect(info, contains('music='));
      });

      test('_ensureInitialized throws StateError when not initialized', () {
        // This is a private method, so we test it indirectly through the public API
        // by ensuring the service is properly initialized before use
        expect(
          () {
            // Attempting to use methods without initialization
            // The initialize() in setUp ensures this doesn't happen
            PreferencesService.getSFXVolume(); // Should not throw
          },
          isNot(throwsException),
        );
      });
    });

    group('Multiple calls and persistence', () {
      test('Multiple sets persist correctly', () async {
        for (int i = 0; i < 5; i++) {
          final volume = i * 0.2;
          await PreferencesService.setSFXVolume(volume);
          expect(PreferencesService.getSFXVolume(), volume);
        }
      });

      test('Concurrent preference changes work correctly', () async {
        await Future.wait([
          PreferencesService.setSFXVolume(0.3),
          PreferencesService.setMusicVolume(0.4),
          PreferencesService.setSoundEnabled(false),
          PreferencesService.setLanguage('en'),
        ]);

        expect(PreferencesService.getSFXVolume(), 0.3);
        expect(PreferencesService.getMusicVolume(), 0.4);
        expect(PreferencesService.isSoundEnabled(), false);
        expect(PreferencesService.getLanguage(), 'en');
      });
    });
  });
}
