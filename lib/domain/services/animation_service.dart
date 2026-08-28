/// Service for managing game animations and transitions
class AnimationService {
  // Animation durations (milliseconds)
  static const int screenTransitionDuration = 300;
  static const int parcelDropDuration = 500;
  static const int parcelLandDuration = 200;
  static const int towerCollapseDuration = 800;
  static const int scoreBounceAnimationDuration = 600;
  static const int buttonPressDuration = 100;
  static const int fadeInDuration = 400;
  static const int fadeOutDuration = 300;

  // Easing curves
  static const double easeInOutQuad = 0.25;
  static const double easeOutBack = 1.5;

  /// Get smooth easing value using cubic bezier approximation
  static double ease(double t, {String curve = 'easeInOutQuad'}) {
    t = t.clamp(0.0, 1.0);

    switch (curve) {
      case 'easeInOutQuad':
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
      case 'easeOutQuad':
        return 1 - (1 - t) * (1 - t);
      case 'easeInQuad':
        return t * t;
      case 'easeOutBack':
        const c1 = 1.70158;
        const c3 = c1 + 1;
        return c3 * t * t * t - c1 * t * t;
      case 'linear':
        return t;
      default:
        return t;
    }
  }

  /// Calculate drop animation offset (y position)
  static double getDropOffset(double progress) {
    // Parabolic motion (accelerating drop)
    return progress * progress;
  }

  /// Calculate bounce animation offset
  static double getBounceOffset(double progress) {
    // Ease out cubic with bounce
    final eased = ease(progress, curve: 'easeOutBack');
    return eased * 100;
  }

  /// Calculate rotate animation (for spinning effect)
  static double getRotationAngle(double progress) {
    return progress * 360 * (3.14159 / 180); // Full rotation
  }

  /// Calculate scale animation for pulse effect
  static double getScaleValue(double progress, {double minScale = 0.9, double maxScale = 1.1}) {
    // Sine wave oscillation
    final oscillation = (progress * 2 * 3.14159).sin() * 0.1;
    return 1.0 + oscillation;
  }

  /// Get color lerp value for fade animations
  static double getFadeValue(double progress) {
    return ease(progress, curve: 'easeInOutQuad');
  }

  /// Calculate parallax offset for background
  static double getParallaxOffset(double progress, double depth) {
    return progress * depth * -20;
  }

  /// Get score text scale animation
  static double getScoreBounceScale(double progress) {
    if (progress < 0.3) {
      // Quick scale up
      return 1.0 + (progress / 0.3) * 0.3;
    } else if (progress < 0.7) {
      // Hold scaled up
      return 1.3;
    } else {
      // Bounce down
      final bounce = (1 - progress) / 0.3;
      return 1.0 + bounce * 0.3;
    }
  }

  /// Get shimmer effect offset (for rare items)
  static double getShimmerOffset(double progress) {
    // Continuous sweep animation
    return ((progress * 2) % 1.0) - 1.0;
  }

  /// Get particle spawn offset based on angle and distance
  static (double x, double y) getParticleOffset(
    double angle,
    double distance,
    double progress,
  ) {
    // Accelerate outward based on progress
    final scaledDistance = distance * progress * progress; // Quadratic acceleration
    return (
      scaledDistance * angle.cos(),
      scaledDistance * angle.sin(),
    );
  }

  /// Get tower sway animation for idle state
  static double getTowerSway(double progress, {double amplitude = 5}) {
    // Gentle sine wave sway
    return amplitude * ((progress * 2 * 3.14159).sin());
  }

  /// Calculate collapse animation intensity
  static double getCollapseIntensity(double progress) {
    if (progress < 0.3) {
      // Shake effect start
      return (progress / 0.3) * 10;
    } else if (progress < 0.7) {
      // Dust effect
      return 10 - (progress - 0.3) / 0.4 * 5;
    } else {
      // Fade out
      return 5 * (1 - progress);
    }
  }

  /// Get UI element slide animation
  static double getSlideOffset(double progress, {double distance = 300}) {
    return distance * (1 - ease(progress, curve: 'easeOutQuad'));
  }

  /// Get debug animation string
  static String getDebugInfo() {
    return 'Animation: screenTransition=${screenTransitionDuration}ms, '
        'parcelDrop=${parcelDropDuration}ms, collapse=${towerCollapseDuration}ms';
  }
}

/// Animation configuration for different game events
class AnimationConfigs {
  // Parcel drop animation
  static const parcelDropConfig = {
    'duration': 500,
    'curve': 'easeInOutQuad',
    'bounce': true,
  };

  // Tower collapse animation
  static const towerCollapseConfig = {
    'duration': 800,
    'curve': 'easeOutBack',
    'shake': true,
    'particles': true,
  };

  // UI transition animation
  static const uiTransitionConfig = {
    'duration': 300,
    'curve': 'easeInOutQuad',
    'fade': true,
  };

  // Score popup animation
  static const scorePopupConfig = {
    'duration': 600,
    'curve': 'easeOutQuad',
    'scale': true,
    'fade': true,
  };

  // Rare item shimmer
  static const rareShimmerConfig = {
    'duration': 1000,
    'curve': 'linear',
    'loop': true,
  };

  // Button press animation
  static const buttonPressConfig = {
    'duration': 100,
    'curve': 'easeOutQuad',
    'scale': true,
  };
}
