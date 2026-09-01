import 'dart:math' as math;

/// Service for managing particle effects during gameplay
class ParticleService {
  // Particle types
  static const String dustParticle = 'dust';
  static const String sparkParticle = 'spark';
  static const String scoreParticle = 'score';
  static const String collisionParticle = 'collision';
  static const String rareLootParticle = 'rare_loot';
  static const String impactParticle = 'impact';

  /// Get particle configuration for effect type
  static ParticleConfig getConfig(String effectType) {
    switch (effectType) {
      case dustParticle:
        return ParticleConfig(
          type: dustParticle,
          count: 12,
          lifetime: 800,
          velocity: 50,
          spread: 360,
          gravity: 100,
          colorHex: '#D3D3D3',
          alpha: 0.7,
          size: 3.0,
        );
      case sparkParticle:
        return ParticleConfig(
          type: sparkParticle,
          count: 8,
          lifetime: 600,
          velocity: 120,
          spread: 360,
          gravity: 50,
          colorHex: '#FFD700',
          alpha: 0.8,
          size: 2.0,
        );
      case scoreParticle:
        return ParticleConfig(
          type: scoreParticle,
          count: 1,
          lifetime: 1000,
          velocity: 0,
          spread: 0,
          gravity: -20, // Float upward
          colorHex: '#FFD700',
          alpha: 1.0,
          size: 16.0,
          scaleEnd: 0.5,
        );
      case collisionParticle:
        return ParticleConfig(
          type: collisionParticle,
          count: 6,
          lifetime: 400,
          velocity: 80,
          spread: 360,
          gravity: 200,
          colorHex: '#FF6347',
          alpha: 0.6,
          size: 4.0,
        );
      case rareLootParticle:
        return ParticleConfig(
          type: rareLootParticle,
          count: 16,
          lifetime: 1200,
          velocity: 150,
          spread: 360,
          gravity: 30,
          colorHex: '#FFD700',
          alpha: 0.8,
          size: 5.0,
          rotation: true,
          shimmer: true,
        );
      case impactParticle:
        return ParticleConfig(
          type: impactParticle,
          count: 4,
          lifetime: 300,
          velocity: 100,
          spread: 180,
          gravity: 300,
          colorHex: '#808080',
          alpha: 0.5,
          size: 6.0,
        );
      default:
        return ParticleConfig(
          type: effectType,
          count: 0,
          lifetime: 0,
          velocity: 0,
          spread: 0,
          gravity: 0,
          colorHex: '#FFFFFF',
          alpha: 0,
          size: 0,
        );
    }
  }

  /// Calculate particle position at time
  static (double x, double y) getParticlePosition(
    double startX,
    double startY,
    double velocityX,
    double velocityY,
    double gravity,
    int elapsedMs,
  ) {
    final seconds = elapsedMs / 1000.0;
    final x = startX + velocityX * seconds;
    final y = startY + velocityY * seconds + 0.5 * gravity * seconds * seconds;
    return (x, y);
  }

  /// Calculate particle alpha based on lifetime
  static double getParticleAlpha(
    double startAlpha,
    int elapsedMs,
    int lifetimeMs,
  ) {
    final progress = (elapsedMs / lifetimeMs).clamp(0.0, 1.0);

    // Fade out in last 30% of lifetime
    if (progress > 0.7) {
      return startAlpha * (1 - (progress - 0.7) / 0.3);
    }
    return startAlpha;
  }

  /// Calculate particle scale
  static double getParticleScale(
    double startSize,
    double endSize,
    int elapsedMs,
    int lifetimeMs,
  ) {
    final progress = (elapsedMs / lifetimeMs).clamp(0.0, 1.0);
    return startSize + (endSize - startSize) * progress;
  }

  /// Get particle rotation angle
  static double getParticleRotation(
    int elapsedMs,
    bool shouldRotate,
  ) {
    if (!shouldRotate) return 0;
    return (elapsedMs / 10.0) * (math.pi / 180); // Rotate over time
  }

  /// Generate random velocity components for spread
  static (double vx, double vy) getVelocityComponents(
    double speed,
    double angle,
    double spreadDegrees,
    int index,
    int totalCount,
  ) {
    // Distribute particles evenly across spread angle
    final spreadRadians = spreadDegrees * (math.pi / 180);
    final particleAngle = angle + (spreadRadians * (index / (totalCount - 1))) - (spreadRadians / 2);

    return (
      speed * (particleAngle).cos(),
      speed * (particleAngle).sin(),
    );
  }

  /// Check if particle is still alive
  static bool isParticleAlive(int elapsedMs, int lifetimeMs) {
    return elapsedMs < lifetimeMs;
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Particles: dust=$dustParticle, spark=$sparkParticle, '
        'score=$scoreParticle, rare=$rareLootParticle';
  }
}

/// Particle effect configuration
class ParticleConfig {
  final String type;
  final int count;
  final int lifetime; // milliseconds
  final double velocity; // pixels per second
  final double spread; // degrees (0-360)
  final double gravity; // acceleration
  final String colorHex;
  final double alpha;
  final double size;
  final double scaleEnd;
  final bool rotation;
  final bool shimmer;

  ParticleConfig({
    required this.type,
    required this.count,
    required this.lifetime,
    required this.velocity,
    required this.spread,
    required this.gravity,
    required this.colorHex,
    required this.alpha,
    required this.size,
    this.scaleEnd = 0,
    this.rotation = false,
    this.shimmer = false,
  });

  /// Get config as map for serialization
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'count': count,
      'lifetime': lifetime,
      'velocity': velocity,
      'spread': spread,
      'gravity': gravity,
      'colorHex': colorHex,
      'alpha': alpha,
      'size': size,
      'scaleEnd': scaleEnd,
      'rotation': rotation,
      'shimmer': shimmer,
    };
  }
}
