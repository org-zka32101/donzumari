import 'audio_service.dart';
import 'particle_service.dart';
import 'animation_service.dart';
import 'performance_service.dart';
import 'analytics_service.dart';

/// Service to coordinate game events across audio, particles, and animations
class GameEventService {
  // Event callbacks
  static Function(String eventName)? onGameEvent;

  // Sound + particle effect combinations
  static const Map<String, GameEventConfig> eventConfigs = {
    'parcel_drop': GameEventConfig(
      soundKey: 'parcel_drop',
      particleType: ParticleService.dustParticle,
      animationDuration: 300,
    ),
    'parcel_land': GameEventConfig(
      soundKey: 'parcel_land',
      particleType: ParticleService.collisionParticle,
      animationDuration: 200,
    ),
    'parcel_collision': GameEventConfig(
      soundKey: 'parcel_collision',
      particleType: ParticleService.sparkParticle,
      animationDuration: 150,
    ),
    'tower_collapse': GameEventConfig(
      soundKey: 'tower_collapse',
      particleType: ParticleService.dustParticle,
      animationDuration: 800,
    ),
    'tower_perfect': GameEventConfig(
      soundKey: 'tower_perfect',
      particleType: ParticleService.rareLootParticle,
      animationDuration: 1000,
    ),
    'score_increase': GameEventConfig(
      soundKey: 'score_increase',
      particleType: ParticleService.scoreParticle,
      animationDuration: 600,
    ),
    'rare_item': GameEventConfig(
      soundKey: 'achievement_unlock',
      particleType: ParticleService.rareLootParticle,
      animationDuration: 1200,
    ),
  };

  /// Trigger a game event with coordinated audio + visual effects
  static Future<void> triggerEvent(
    String eventName, {
    dynamic position,
    Map<String, dynamic>? data,
  }) async {
    final config = eventConfigs[eventName];
    if (config == null) {
      print('⚠️ Unknown game event: $eventName');
      return;
    }

    if (!eventsEnabled) return;

    // Performance tracking
    await PerformanceService.trackAsync(
      'event:$eventName',
      () async {
        // Play sound effect
        await AudioService.playSound(config.soundKey);

        // Callback to UI/game layer for particles
        onGameEvent?.call(eventName);

        // Log analytics event
        try {
          await AnalyticsService.logEvent(
            name: eventName,
            parameters: data ?? {},
          );
        } catch (e) {
          print('⚠️ Failed to log analytics for event $eventName: $e');
        }

        print('✨ Event triggered: $eventName');
      },
    );
  }

  /// Trigger parcel drop event
  static Future<void> onParcelDropped(dynamic position) =>
      triggerEvent('parcel_drop', position: position);

  /// Trigger parcel landing event
  static Future<void> onParcelLanded(dynamic position) =>
      triggerEvent('parcel_land', position: position);

  /// Trigger parcel collision event
  static Future<void> onParcelCollision(dynamic position) =>
      triggerEvent('parcel_collision', position: position);

  /// Trigger tower collapse event
  static Future<void> onTowerCollapse(double height) =>
      triggerEvent('tower_collapse', data: {'height': height});

  /// Trigger perfect stack event
  static Future<void> onPerfectStack(int parcelCount) =>
      triggerEvent('tower_perfect', data: {'parcels': parcelCount});

  /// Trigger score increase event
  static Future<void> onScoreIncrease(double points) =>
      triggerEvent('score_increase', data: {'points': points});

  /// Trigger rare item event
  static Future<void> onRareItemFound(String parcelId) =>
      triggerEvent('rare_item', data: {'parcelId': parcelId});

  /// Get config for event
  static GameEventConfig? getEventConfig(String eventName) {
    return eventConfigs[eventName];
  }

  /// Play sequence of events
  static Future<void> playEventSequence(List<String> events) async {
    for (final event in events) {
      await triggerEvent(event);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Enable/disable all game events
  static bool eventsEnabled = true;

  /// Get debug info
  static String getDebugInfo() {
    return 'GameEventService: ${eventConfigs.length} events configured, '
        'eventsEnabled=$eventsEnabled';
  }
}

/// Configuration for game event
class GameEventConfig {
  final String soundKey;
  final String particleType;
  final int animationDuration; // milliseconds

  const GameEventConfig({
    required this.soundKey,
    required this.particleType,
    required this.animationDuration,
  });
}

/// Game event listener
typedef GameEventListener = void Function(String eventName);
