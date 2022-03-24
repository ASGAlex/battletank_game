part of tank;

/// Mixin responsible for find path using `a_star_algorithm` and moving the component through the path
mixin _MoveToPositionAlongThePath on Movement, ObjectCollision {
  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Offset> currentPath = [];
  int currentIndex = 0;
  bool _gridSizeIsCollisionSize = false;

  bool _calculating = false;

  Vector2? movementCorrection;
  List ignoreCollisions = [];

  var ignoreCollisionCheck = false;

  Color _pathLineColor = const Color(0xFFFF6D40).withOpacity(0.5);
  double _pathLineStrokeWidth = 1;

  final Paint _paintShowBarriers = Paint()
    ..color = const Color(0xFF40C4FF).withOpacity(0.5);

  void setupMoveToPositionAlongThePath({
    /// Use to set line path color
    Color? pathLineColor,
    Color? barriersCalculatedColor,

    /// Use to set line path width
    double pathLineStrokeWidth = 1,

    /// Use to debug and show area collision calculated
    bool showBarriersCalculated = false,

    /// If `false` the algorithm use map tile size with base of the grid. if true this use collision size of the component.
    bool gridSizeIsCollisionSize = false,
  }) {
    _paintShowBarriers.color =
        barriersCalculatedColor ?? const Color(0xFF2196F3).withOpacity(0.5);
    _pathLineColor = pathLineColor ?? const Color(0xFFFF6D40).withOpacity(0.9);
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  Future moveToPositionAlongThePath(
    Vector2 targetPosition, {
    List? ignoreCollisions,
  }) async {
    if (_calculating) return;
    _calculating = true;
    this.ignoreCollisions.clear();
    this.ignoreCollisions.add(this);
    if (ignoreCollisions != null) {
      this.ignoreCollisions.addAll(ignoreCollisions);
    }

    currentIndex = 0;
    var player = this;
    final positionPlayer = player.rectCollision.center.toVector2();

    final parameters = PathFindingParameters.fromObjectCollision(
        ignoreCollisions: this.ignoreCollisions,
        showBarriers: false,
        gridSizeIsCollisionSize: false,
        finalPosition: //Vector2(246.5, 183.83328),
            targetPosition,
        positionPlayer: // Vector2(215.46681599999863, 359.0),
            positionPlayer,
        gameSize:
            Vector2(gameRef.map.mapSize!.width, gameRef.map.mapSize!.height),
        tileSize: _tileSize,
        collisions: gameRef.map.getCollisions());

    print('calc!');
    final result =
        await PathfindingService().runTask(parameters).catchError((_) {
      _calculating = true;
    });
    currentIndex = 0;

    currentPath = result.currentPath;

    _calculating = false;
    print('finished');

    gameRef.map.setLinePath(
        <Offset>[/*positionPlayer.toOffset(),*/ ...currentPath],
        _pathLineColor,
        _pathLineStrokeWidth);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (movementCorrection == null && currentPath.isNotEmpty) {
      _move(dt);
    }
  }

  void stopMoveAlongThePath() {
    currentPath.clear();
    currentIndex = 0;
    idle();
    gameRef.map.setLinePath(currentPath, _pathLineColor, _pathLineStrokeWidth);
  }

  void _move(double dt) {
    double innerSpeed = speed * dt;

    var currentOffset = currentPath[currentIndex];

    double diffX = currentOffset.dx - center.x;
    double diffY = currentOffset.dy - center.y;
    double displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.01 && diffY.abs() < 0.01) {
      _goToNextPosition();
    } else {
      bool onMove = false;

      if (diffX.abs() > 0.01) {
        if (diffX > 0) {
          onMove = moveRight(displacementX);
        } else if (diffX < 0) {
          onMove = moveLeft(displacementX);
        }
      } else if (diffY.abs() > 0.01) {
        if (diffY > 0) {
          onMove = moveDown(displacementY);
        } else if (diffY < 0) {
          onMove = moveUp(displacementY);
        }
      }

      if (!onMove) {
        _goToNextPosition();
      }
    }
  }

  /// Get size of the grid used on algorithm to calculate path
  double get _tileSize {
    double tileSize = 0.0;
    if (gameRef.map.tiles.isNotEmpty) {
      tileSize = gameRef.map.tiles.first.width;
    }
    if (_gridSizeIsCollisionSize) {
      if (isObjectCollision()) {
        return max(
          rectCollision.width,
          rectCollision.height,
        );
      }
      return max(height, width) + REDUCTION_TO_AVOID_ROUNDING_PROBLEMS;
    }
    return tileSize;
  }

  bool get isMovingAlongThePath => currentPath.isNotEmpty;

  void _goToNextPosition() {
    if (currentIndex < currentPath.length - 1) {
      currentIndex++;
    } else {
      stopMoveAlongThePath();
    }
  }
}
