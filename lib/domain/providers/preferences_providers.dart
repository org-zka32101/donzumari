import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../services/audio_service.dart';

/// Preferences service provider
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

/// SFX volume provider (StateProvider for reactive updates)
final sfxVolumeProvider = StateProvider<double>((ref) {
  return PreferencesService.getSFXVolume();
});

/// Music volume provider (StateProvider for reactive updates)
final musicVolumeProvider = StateProvider<double>((ref) {
  return PreferencesService.getMusicVolume();
});

/// Sound enabled provider
final soundEnabledProvider = StateProvider<bool>((ref) {
  return PreferencesService.isSoundEnabled();
});

/// Music enabled provider
final musicEnabledProvider = StateProvider<bool>((ref) {
  return PreferencesService.isMusicEnabled();
});

/// Haptic enabled provider
final hapticEnabledProvider = StateProvider<bool>((ref) {
  return PreferencesService.isHapticEnabled();
});

/// Auto-save enabled provider
final autoSaveEnabledProvider = StateProvider<bool>((ref) {
  return PreferencesService.isAutoSaveEnabled();
});

/// Graphics quality provider
final graphicsQualityProvider = StateProvider<String>((ref) {
  return PreferencesService.getGraphicsQuality();
});

/// Language provider
final languageProvider = StateProvider<String>((ref) {
  return PreferencesService.getLanguage();
});

/// Dark mode enabled provider
final darkModeProvider = StateProvider<bool>((ref) {
  return PreferencesService.isDarkModeEnabled();
});

/// SFX volume setter with persistence and audio sync
final setSFXVolumeProvider = FutureProvider.family<void, double>((ref, volume) async {
  // Update audio service immediately
  AudioService.setSFXVolume(volume);
  // Persist to preferences
  await PreferencesService.setSFXVolume(volume);
  // Update provider state
  ref.read(sfxVolumeProvider.notifier).state = volume;
});

/// Music volume setter with persistence and audio sync
final setMusicVolumeProvider = FutureProvider.family<void, double>((ref, volume) async {
  // Update audio service immediately
  AudioService.setMusicVolume(volume);
  // Persist to preferences
  await PreferencesService.setMusicVolume(volume);
  // Update provider state
  ref.read(musicVolumeProvider.notifier).state = volume;
});

/// Sound enabled setter with persistence and audio sync
final setSoundEnabledProvider = FutureProvider.family<void, bool>((ref, enabled) async {
  // Update audio service immediately
  AudioService.setSoundEnabled(enabled);
  // Persist to preferences
  await PreferencesService.setSoundEnabled(enabled);
  // Update provider state
  ref.read(soundEnabledProvider.notifier).state = enabled;
});

/// Music enabled setter with persistence and audio sync
final setMusicEnabledProvider = FutureProvider.family<void, bool>((ref, enabled) async {
  // Update audio service immediately
  AudioService.setMusicEnabled(enabled);
  // Persist to preferences
  await PreferencesService.setMusicEnabled(enabled);
  // Update provider state
  ref.read(musicEnabledProvider.notifier).state = enabled;
});

/// Haptic enabled setter with persistence
final setHapticEnabledProvider = FutureProvider.family<void, bool>((ref, enabled) async {
  await PreferencesService.setHapticEnabled(enabled);
  ref.read(hapticEnabledProvider.notifier).state = enabled;
});

/// Auto-save enabled setter with persistence
final setAutoSaveEnabledProvider = FutureProvider.family<void, bool>((ref, enabled) async {
  await PreferencesService.setAutoSaveEnabled(enabled);
  ref.read(autoSaveEnabledProvider.notifier).state = enabled;
});

/// Graphics quality setter with persistence
final setGraphicsQualityProvider = FutureProvider.family<void, String>((ref, quality) async {
  await PreferencesService.setGraphicsQuality(quality);
  ref.read(graphicsQualityProvider.notifier).state = quality;
});

/// Language setter with persistence
final setLanguageProvider = FutureProvider.family<void, String>((ref, language) async {
  await PreferencesService.setLanguage(language);
  ref.read(languageProvider.notifier).state = language;
});

/// Dark mode setter with persistence
final setDarkModeProvider = FutureProvider.family<void, bool>((ref, enabled) async {
  await PreferencesService.setDarkModeEnabled(enabled);
  ref.read(darkModeProvider.notifier).state = enabled;
});

/// Reset preferences to defaults
final resetPreferencesProvider = FutureProvider<void>((ref) async {
  await PreferencesService.resetToDefaults();
  // Reset all provider states
  ref.read(sfxVolumeProvider.notifier).state = 1.0;
  ref.read(musicVolumeProvider.notifier).state = 0.7;
  ref.read(soundEnabledProvider.notifier).state = true;
  ref.read(musicEnabledProvider.notifier).state = true;
  ref.read(hapticEnabledProvider.notifier).state = true;
  ref.read(autoSaveEnabledProvider.notifier).state = true;
  ref.read(graphicsQualityProvider.notifier).state = 'high';
  ref.read(languageProvider.notifier).state = 'ja';
  ref.read(darkModeProvider.notifier).state = false;
  // Sync audio service
  AudioService.setSFXVolume(1.0);
  AudioService.setMusicVolume(0.7);
  AudioService.setSoundEnabled(true);
  AudioService.setMusicEnabled(true);
});

/// Initialize preferences service
final initializePreferencesProvider = FutureProvider<void>((ref) async {
  await PreferencesService.initialize();
});
