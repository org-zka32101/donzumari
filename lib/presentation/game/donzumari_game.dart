import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../domain/services/physics_service.dart';
import '../../data/models/doorway_model.dart';

/// Main game class using Flame and Forge2D physics engine
class DonzumariGame extends Forge2DGame {
  // Game state
  DoorwayModel? currentDoorway;
  List<ParcelBody> stackedParcels = [];

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

  DonzumariGame() : super(
    gravity: Vector2(0, PhysicsService.gravity),
    zoom: 0.1, // Zoom to fit the playing field
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set camera to focus on doorway area
    camera.viewfinder.position = Vector2(doorwayX, doorwayY);

    // Add ground (doorway surface)
    _addGround();
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

    // Check for collapse
    _checkForCollapse();
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
  }

  /// Trigger collapse animation and end game
  void _triggerCollapse() {
    isGameActive = false;
    hasCollapsed = true;

    // TODO: Play collapse animation, sound effects
    print('Tower collapsed!');
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

  /// Reset game state
  void reset() {
    stackedParcels.clear();
    isGameActive = true;
    hasCollapsed = false;
    world.bodies.clear();
    _addGround();
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
