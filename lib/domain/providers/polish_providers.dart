import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sprite_service.dart';
import '../services/audio_service.dart';
import '../services/animation_service.dart';
import '../services/particle_service.dart';

/// Sprite service provider
final spriteServiceProvider = Provider<SpriteService>((ref) {
  return SpriteService();
});

/// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

/// Animation service provider
final animationServiceProvider = Provider<AnimationService>((ref) {
  return AnimationService();
});

/// Particle service provider
final particleServiceProvider = Provider<ParticleService>((ref) {
  return ParticleService();
});

/// Get sprite variation by parcel ID
final getSpriteProvider = FutureProvider.family<
    dynamic, // _SpriteVariation
    (String parcelId, int colorIndex)>((ref, params) async {
  final (parcelId, colorIndex) = params;
  return await SpriteService.getSpriteVariation(
    parcelId,
    colorIndex: colorIndex,
  );
});

/// Get animation easing value
final getAnimationEaseProvider = Provider.family<
    double,
    (double progress, String curve)>((ref, params) {
  final (progress, curve) = params;
  return AnimationService.ease(progress, curve: curve);
});

/// Get particle configuration
final getParticleConfigProvider = Provider.family<ParticleConfig, String>((
  ref,
  effectType,
) {
  return ParticleService.getConfig(effectType);
});

/// SFX volume state provider
final sfxVolumeProvider = StateProvider<double>((ref) {
  return AudioService.getSFXVolume();
});

/// Music volume state provider
final musicVolumeProvider = StateProvider<double>((ref) {
  return AudioService.getMusicVolume();
});

/// Sound enabled state provider
final soundEnabledProvider = StateProvider<bool>((ref) {
  return AudioService.isSoundEnabled();
});

/// Music enabled state provider
final musicEnabledProvider = StateProvider<bool>((ref) {
  return AudioService.isMusicEnabled();
});

/// Initialize all polish services
final initializePolishProvider = FutureProvider<void>((ref) async {
  try {
    await SpriteService.initialize();
    await AudioService.initialize();
    print('✅ All polish services initialized');
  } catch (e) {
    print('⚠️ Polish services initialization failed: $e');
    rethrow;
  }
});

/// Preload gameplay sprites
final preloadGameplaySpritesProvider = FutureProvider<void>((ref) async {
  try {
    await SpriteService.preloadTier('stable');
    await SpriteService.preloadTier('moderate');
  } catch (e) {
    print('⚠️ Sprite preload failed: $e');
  }
});

/// Preload gameplay sounds
final preloadGameplaySoundsProvider = FutureProvider<void>((ref) async {
  try {
    await AudioService.preloadGameplaySounds();
  } catch (e) {
    print('⚠️ Sound preload failed: $e');
  }
});
