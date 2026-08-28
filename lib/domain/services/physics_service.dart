import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:math';
import '../../data/models/parcel_model.dart';

/// Service for physics-related calculations and simulations
class PhysicsService {
  // Gravity constant (m/s²)
  static const double gravity = 9.81;

  /// Calculate center of mass from parcel shape
  static Vector2 calculateCenterOfMass(ParcelShape shape) {
    if (shape.vertices.isEmpty) {
      return Vector2.zero();
    }

    double sumX = 0;
    double sumY = 0;

    for (final vertex in shape.vertices) {
      sumX += vertex['x'] as double;
      sumY += vertex['y'] as double;
    }

    return Vector2(
      sumX / shape.vertices.length,
      sumY / shape.vertices.length,
    );
  }

  /// Check if a parcel is stable (center of mass within bounds)
  static bool isStable(
    List<Vector2> vertices,
    Vector2 centerOfMass,
    double stabilityThreshold,
  ) {
    if (vertices.isEmpty) return false;

    // Find the convex hull or bounding box
    double minX = vertices.first.x;
    double maxX = vertices.first.x;

    for (final v in vertices) {
      if (v.x < minX) minX = v.x;
      if (v.x > maxX) maxX = v.x;
    }

    // Check if center of mass is within the support base
    return centerOfMass.x >= minX + stabilityThreshold &&
        centerOfMass.x <= maxX - stabilityThreshold;
  }

  /// Calculate the angle needed for a parcel to be placed
  static double calculatePlacementAngle(
    Vector2 tapPosition,
    Vector2 referencePoint,
  ) {
    final dx = tapPosition.x - referencePoint.x;
    final dy = tapPosition.y - referencePoint.y;
    return dy.abs() > 0 ? atan2(dy, dx) : 0;
  }

  /// Simulate parcel collision and determine stability
  static bool simulateCollision(
    Vector2 parcelPosition,
    Vector2 otherParcelPosition,
    double parcelRadius,
    double otherRadius,
  ) {
    final distance =
        parcelPosition.distanceTo(otherParcelPosition);
    return distance < (parcelRadius + otherRadius);
  }

  /// Calculate tower height based on stacked parcels
  static double calculateTowerHeight(List<Vector2> parcelPositions) {
    if (parcelPositions.isEmpty) return 0;
    return parcelPositions.map((p) => p.y).reduce((a, b) => a > b ? a : b);
  }

  /// Check if tower has collapsed based on center of mass
  static bool hasTowerCollapsed(
    List<Vector2> parcelCenters,
    double widthThreshold,
  ) {
    if (parcelCenters.length < 2) return false;

    // Simple heuristic: if any two consecutive parcels are too far apart
    for (int i = 0; i < parcelCenters.length - 1; i++) {
      final distance = (parcelCenters[i] - parcelCenters[i + 1]).length;
      if (distance > widthThreshold) {
        return true;
      }
    }

    return false;
  }

  /// Damping factor for smooth physics (0-1, lower = more damping)
  static const double velocityDamping = 0.95;
  static const double angularDamping = 0.90;
}
