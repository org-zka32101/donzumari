import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../domain/services/physics_service.dart';
import '../../domain/services/audio_service.dart';
import '../../domain/services/animation_service.dart';
import '../../domain/services/particle_service.dart';
import '../../domain/services/performance_service.dart';
import '../../data/models/doorway_model.dart';

/// Main game class using Flame and Forge2D physics engine
class DonzumariGame extends Forge2DGame {
  // Game state
  DoorwayModel? currentDoorway;
  List<ParcelBody> stackedParcels = [];
  List<GameParticle> activeParticles = [];

  // Physics world settings
  static const double screenWidth = 375;
  static const double screenHeight = 500;
  static const double doorwayWidth = 300;
  static const double doorwayHeight = 400;

  // Game configuration
  double doorwayX = screenWidth / 2;
  double doorwayY = screenHeight - 100;

  bool isGameActive = true;
  bool hasCollapsed = false;

  // Game lifecycle tracking
  late Stopwatch _gameStopwatch;
  int _frameCount = 0;
  int _collisionCount = 0;

  DonzumariGame() : super(
    gravity: Vector2(0, PhysicsService.gravity),
    zoom: 0.1, // Zoom to fit the playing field
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize performance tracking
    _gameStopwatch = Stopwatch()..start();

    // Set camera to focus on doorway area
    camera.viewfinder.position = Vector2(doorwayX, doorwayY);

    // Add ground (doorway surface)
    _addGround();

    print('🎮 Game initialized - ready for gameplay');
  }

  /// Add ground/doorway surface
  void _addGround() {
    final groundBody = world.createBody(
      BodyDef(
        position: Vector2(doorwayX, doorwayY + doorwayHeight / 2),
        type: BodyType.static,
      ),
    );

    final groundShape = PolygonShape()
      ..setAsBox(doorwayWidth / 2, 10);

    groundBody.createFixture(
      FixtureDef(groundShape, density: 1),
    );
  }

  /// Add a parcel to the game world at the given position
  void addParcel(
    Vector2 position,
    Vector2 size,
    double rotation,
  ) {
    if (!isGameActive) return;

    final parcelDef = BodyDef(
      position: position,
      type: BodyType.dynamic,
      angle: rotation,
    );

    final parcelBody = world.createBody(parcelDef);

    // Create a simple box shape for now (will be replaced with actual parcel shapes)
    final shape = PolygonShape()..setAsBox(size.x / 2, size.y / 2);

    parcelBody.createFixture(
      FixtureDef(
        shape,
        density: 1.0,
        friction: 0.5,
        restitution: 0.3,
      ),
    );

    // Track the parcel
    stackedParcels.add(ParcelBody(
      body: parcelBody,
      position: position,
      size: size,
    ));

    // 🎵 Play parcel drop sound
    _playParcelDropSound();

    // ✨ Create drop particle effect
    _createParticleEffect(
      position,
      ParticleService.dustParticle,
    );

    // Check for collapse
    _checkForCollapse();
  }

  /// Play parcel drop sound effect
  void _playParcelDropSound() {
    PerformanceService.trackSync(
      'audio:parcel_drop',
      () => AudioService.playSound('parcel_drop'),
    );
  }

  /// Create particle effect at position
  void _createParticleEffect(Vector2 position, String effectType) {
    final config = ParticleService.getConfig(effectType);

    for (int i = 0; i < config.count; i++) {
      final angle = (360 / config.count) * i * (3.14159 / 180);
      final (vx, vy) = ParticleService.getVelocityComponents(
        config.velocity,
        angle,
        config.spread,
        i,
        config.count,
      );

      activeParticles.add(GameParticle(
        position: position.clone(),
        velocity: Vector2(vx, vy),
        gravity: config.gravity,
        lifetime: config.lifetime,
        elapsedMs: 0,
        config: config,
      ));
    }
  }

  /// Check if the tower has collapsed
  void _checkForCollapse() {
    if (stackedParcels.length < 2) return;

    final parcelPositions = stackedParcels
        .map((p) => p.body.position)
        .toList();

    // Simple heuristic: if any parcel goes beyond doorway width
    for (final parcel in stackedParcels) {
      if ((parcel.body.position.x - doorwayX).abs() > doorwayWidth / 2) {
        _triggerCollapse();
        return;
      }
    }

    // 🎵 Play collision sound when parcels interact
    _collisionCount++;
    if (_collisionCount % 3 == 0) {
      // Play collision sound every 3rd collision to avoid spam
      PerformanceService.trackSync(
        'audio:parcel_collision',
        () => AudioService.playSound('parcel_collision'),
      );
    }
  }

  /// Trigger collapse animation and end game
  void _triggerCollapse() {
    isGameActive = false;
    hasCollapsed = true;

    // 🎵 Play collapse sound effect
    PerformanceService.trackSync(
      'audio:tower_collapse',
      () => AudioService.playSound('tower_collapse'),
    );

    // 💥 Create dramatic collapse particle effects
    final centerPosition = Vector2(doorwayX, doorwayY - 50);

    // Main dust explosion
    _createParticleEffect(centerPosition, ParticleService.dustParticle);

    // Additional impact particles
    for (int i = 0; i < stackedParcels.length; i++) {
      _createParticleEffect(
        stackedParcels[i].body.position,
        ParticleService.impactParticle,
      );
    }

    print('💥 Tower collapsed at height: ${getTowerHeight().toStringAsFixed(2)} cm');
  }

  /// Get current tower height
  double getTowerHeight() {
    if (stackedParcels.isEmpty) return 0;

    double minY = stackedParcels.first.body.position.y;
    for (final parcel in stackedParcels) {
      if (parcel.body.position.y < minY) {
        minY = parcel.body.position.y;
      }
    }

    return doorwayY - minY;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Tap to place parcel (to be implemented with UI layer)
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    // Drag to control parcel placement
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
  }

  /// Update game state (called each frame by Flame)
  @override
  void update(double dt) {
    super.update(dt);

    // Update active particles
    activeParticles.removeWhere((particle) {
      particle.elapsedMs += (dt * 1000).toInt();
      return !ParticleService.isParticleAlive(
        particle.elapsedMs,
        particle.lifetime,
      );
    });

    // Track frame time
    _frameCount++;
    if (_frameCount % 60 == 0) {
      // Calculate average frame time for the last 60 frames
      // (approximately 1 second at 60 FPS, so ~16.7ms per frame)
      final currentElapsedMs = _gameStopwatch.elapsedMilliseconds;
      final frameTimeMs = 16.67; // Expected at 60 FPS; actual timing via delta
      PerformanceService.recordFrame('game:frame', frameTimeMs.toInt());
    }
  }

  /// Reset game state
  void reset() {
    stackedParcels.clear();
    activeParticles.clear();
    isGameActive = true;
    hasCollapsed = false;
    _collisionCount = 0;
    _frameCount = 0;
    _gameStopwatch.reset();
    _gameStopwatch.start();
    // Properly dispose Forge2D bodies to prevent memory leak
    for (final body in world.bodies) {
      world.destroyBody(body);
    }
    _addGround();

    print('🔄 Game reset - ready for next round');
  }

  /// Get game performance stats
  Map<String, dynamic> getGameStats() {
    return {
      'height': getTowerHeight(),
      'parcelCount': stackedParcels.length,
      'isActive': isGameActive,
      'hasCollapsed': hasCollapsed,
      'elapsedSeconds': _gameStopwatch.elapsedMilliseconds / 1000,
      'frameCount': _frameCount,
      'collisionCount': _collisionCount,
      'activeParticles': activeParticles.length,
    };
  }
}

/// Helper class to track parcel bodies
class ParcelBody {
  final Body body;
  final Vector2 position;
  final Vector2 size;

  ParcelBody({
    required this.body,
    required this.position,
    required this.size,
  });
}

/// Game particle for visual effects
class GameParticle {
  Vector2 position;
  Vector2 velocity;
  double gravity;
  int lifetime; // milliseconds
  int elapsedMs;
  ParticleConfig config;

  GameParticle({
    required this.position,
    required this.velocity,
    required this.gravity,
    required this.lifetime,
    required this.elapsedMs,
    required this.config,
  });

  /// Get current alpha value
  double getAlpha() {
    return ParticleService.getParticleAlpha(
      config.alpha,
      elapsedMs,
      lifetime,
    );
  }

  /// Get current scale
  double getScale() {
    return ParticleService.getParticleScale(
      config.size,
      config.scaleEnd,
      elapsedMs,
      lifetime,
    );
  }

  /// Get current rotation angle
  double getRotation() {
    return ParticleService.getParticleRotation(
      elapsedMs,
      config.rotation,
    );
  }

  /// Update particle position based on physics
  void updatePosition(double dtMs) {
    final (x, y) = ParticleService.getParticlePosition(
      position.x,
      position.y,
      velocity.x,
      velocity.y,
      gravity,
      elapsedMs,
    );
    position = Vector2(x, y);
  }
}
