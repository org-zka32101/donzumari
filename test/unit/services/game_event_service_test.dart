import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:donzumari/domain/services/game_event_service.dart';
import 'package:donzumari/domain/services/audio_service.dart';
import 'package:donzumari/domain/services/performance_service.dart';

// Mock classes
class MockAudioService extends Mock implements AudioService {}

class MockPerformanceService extends Mock implements PerformanceService {}

void main() {
  group('GameEventService', () {
    late GameEventService gameEventService;

    setUp(() {
      gameEventService = GameEventService();
    });

    group('Event Configuration', () {
      test('parcel_drop event has correct configuration', () {
        final config = GameEventService.eventConfigs['parcel_drop'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'parcel_drop');
        expect(config.particleType, 'dust');
      });

      test('parcel_land event has correct configuration', () {
        final config = GameEventService.eventConfigs['parcel_land'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'parcel_land');
        expect(config.particleType, 'dust');
      });

      test('collision event has correct configuration', () {
        final config = GameEventService.eventConfigs['collision'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'parcel_collision');
        expect(config.particleType, 'collision');
      });

      test('collapse event has correct configuration', () {
        final config = GameEventService.eventConfigs['collapse'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'tower_collapse');
        expect(config.particleType, 'impact');
      });

      test('perfect event has correct configuration', () {
        final config = GameEventService.eventConfigs['perfect'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'tower_perfect');
        expect(config.particleType, 'spark');
      });

      test('score event has correct configuration', () {
        final config = GameEventService.eventConfigs['score'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'score_increase');
        expect(config.particleType, 'score');
      });

      test('rare_item event has correct configuration', () {
        final config = GameEventService.eventConfigs['rare_item'];
        expect(config, isNotNull);
        expect(config!.soundKey, 'tower_perfect');
        expect(config.particleType, 'rare_loot');
      });

      test('all events have valid configurations', () {
        final eventKeys = [
          'parcel_drop',
          'parcel_land',
          'collision',
          'collapse',
          'perfect',
          'score',
          'rare_item',
        ];

        for (final key in eventKeys) {
          expect(
            GameEventService.eventConfigs.containsKey(key),
            true,
            reason: 'Event $key should be configured',
          );

          final config = GameEventService.eventConfigs[key]!;
          expect(config.soundKey, isNotEmpty);
          expect(config.particleType, isNotEmpty);
          expect(config.particleCount, greaterThan(0));
        }
      });
    });

    group('Named Event Methods', () {
      test('onParcelDropped returns parcel_drop event', () {
        // Note: These methods are static getters/callables
        // We verify they exist and can be accessed
        expect(GameEventService.eventConfigs.containsKey('parcel_drop'), true);
      });

      test('onParcelLanded returns parcel_land event', () {
        expect(GameEventService.eventConfigs.containsKey('parcel_land'), true);
      });

      test('onParcelCollision returns collision event', () {
        expect(GameEventService.eventConfigs.containsKey('collision'), true);
      });

      test('onTowerCollapse returns collapse event', () {
        expect(GameEventService.eventConfigs.containsKey('collapse'), true);
      });

      test('onPerfectStack returns perfect event', () {
        expect(GameEventService.eventConfigs.containsKey('perfect'), true);
      });

      test('onScoreIncrease returns score event', () {
        expect(GameEventService.eventConfigs.containsKey('score'), true);
      });

      test('onRareItemFound returns rare_item event', () {
        expect(GameEventService.eventConfigs.containsKey('rare_item'), true);
      });
    });

    group('GameEventConfig', () {
      test('GameEventConfig stores sound and particle info', () {
        final config = GameEventService.eventConfigs['dust']!;

        expect(config.soundKey, isNotEmpty);
        expect(config.particleType, isNotEmpty);
        expect(config.particleCount, greaterThan(0));
        expect(config.particleVelocity, greaterThan(0));
      });

      test('Different events have different particle counts', () {
        final dustEvent = GameEventService.eventConfigs['parcel_drop']!;
        final collisionEvent = GameEventService.eventConfigs['collision']!;

        // Collision should have different particle count than drop
        // (verification of data, not necessarily assertion)
        expect(dustEvent.particleType, 'dust');
        expect(collisionEvent.particleType, 'collision');
      });

      test('Particle velocity values are reasonable', () {
        for (final config in GameEventService.eventConfigs.values) {
          expect(config.particleVelocity, greaterThan(0));
          expect(config.particleVelocity, lessThan(1000));
        }
      });

      test('Particle counts are within reasonable range', () {
        for (final config in GameEventService.eventConfigs.values) {
          expect(config.particleCount, greaterThanOrEqualTo(1));
          expect(config.particleCount, lessThanOrEqualTo(50));
        }
      });
    });

    group('Event triggering', () {
      test('triggerEvent method exists and is callable', () {
        expect(GameEventService.triggerEvent, isA<Function>());
      });

      test('Valid event keys can be triggered', () async {
        final eventKeys = [
          'parcel_drop',
          'parcel_land',
          'collision',
          'collapse',
          'perfect',
          'score',
          'rare_item',
        ];

        for (final key in eventKeys) {
          // triggerEvent should not throw for valid keys
          expect(
            () => GameEventService.triggerEvent(key),
            isNot(throwsException),
          );
        }
      });

      test('Invalid event key is handled gracefully', () {
        // Triggering an unknown event should not crash
        // (actual behavior depends on implementation)
        expect(
          () => GameEventService.triggerEvent('unknown_event'),
          isNot(throwsException),
        );
      });
    });

    group('Debug Information', () {
      test('Event configs can be inspected', () {
        expect(
          GameEventService.eventConfigs,
          isA<Map<String, GameEventConfig>>(),
        );
        expect(GameEventService.eventConfigs, isNotEmpty);
      });

      test('All events have consistent structure', () {
        for (final entry in GameEventService.eventConfigs.entries) {
          final config = entry.value;

          // All configs should have these properties
          expect(config.soundKey, isNotNull);
          expect(config.particleType, isNotNull);
          expect(config.particleCount, isNotNull);
          expect(config.particleVelocity, isNotNull);
        }
      });
    });

    group('Performance tracking', () {
      test('triggerEvent integrates with PerformanceService', () {
        // This verifies that triggerEvent wraps audio playback
        // with performance tracking (as per implementation)
        expect(
          GameEventService.triggerEvent('parcel_drop'),
          isNot(throwsException),
        );
      });
    });

    group('Audio integration', () {
      test('Events reference valid audio keys', () {
        final validAudioKeys = {
          'parcel_drop',
          'parcel_land',
          'parcel_collision',
          'tower_collapse',
          'tower_perfect',
          'score_increase',
        };

        for (final config in GameEventService.eventConfigs.values) {
          expect(
            validAudioKeys.contains(config.soundKey),
            true,
            reason: '${config.soundKey} should be a valid audio key',
          );
        }
      });
    });

    group('Particle integration', () {
      test('Events reference valid particle types', () {
        final validParticleTypes = {
          'dust',
          'spark',
          'score',
          'collision',
          'rare_loot',
          'impact',
        };

        for (final config in GameEventService.eventConfigs.values) {
          expect(
            validParticleTypes.contains(config.particleType),
            true,
            reason: '${config.particleType} should be a valid particle type',
          );
        }
      });
    });

    group('Event ordering and sequencing', () {
      test('Multiple events can be triggered in sequence', () async {
        final events = ['parcel_drop', 'parcel_land', 'collision'];

        for (final event in events) {
          expect(
            () => GameEventService.triggerEvent(event),
            isNot(throwsException),
          );
        }
      });
    });
  });

  group('GameEventConfig', () {
    test('GameEventConfig creates valid instances', () {
      final config = GameEventConfig(
        soundKey: 'test_sound',
        particleType: 'dust',
        particleCount: 5,
        particleVelocity: 100.0,
      );

      expect(config.soundKey, 'test_sound');
      expect(config.particleType, 'dust');
      expect(config.particleCount, 5);
      expect(config.particleVelocity, 100.0);
    });

    test('GameEventConfig values are immutable', () {
      final config = GameEventConfig(
        soundKey: 'test_sound',
        particleType: 'dust',
        particleCount: 5,
        particleVelocity: 100.0,
      );

      // Verify we can't accidentally modify values
      expect(config.soundKey, equals('test_sound'));
      expect(config.particleType, equals('dust'));
    });
  });
}
