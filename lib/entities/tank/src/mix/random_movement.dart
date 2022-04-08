part of tank;

mixin _RandomMovement on ObjectCollision, Movement {
  bool randomMovement = false;
  Direction _randomMoveDirection = Direction.up;
  double movementDistance = 0;

  double get movementMaxDistance => gameRef.map.tiles.first.width * 2 * 10;

  double get movementMinDistance => gameRef.map.tiles.first.width * 2 * 2;

  @override
  void update(double dt) {
    super.update(dt);
    if (!randomMovement) return;

    bool distanceFinished = false;
    movementDistance -= speed * dt;
    if (movementDistance <= 0) {
      distanceFinished = true;
    }
    bool onMove = false;
    switch (_randomMoveDirection) {
      case Direction.left:
        onMove = moveLeft(speed);
        break;
      case Direction.right:
        onMove = moveRight(speed);
        break;
      case Direction.up:
        onMove = moveUp(speed);
        break;
      case Direction.down:
        onMove = moveDown(speed);
        break;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        throw ArgumentError('Invalid direction');
    }
    if (!onMove || distanceFinished) {
      changeRandomDirection();
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    changeRandomDirection();
    return super.onCollision(component, active);
  }

  Direction changeRandomDirection([List<Direction>? availableDirection]) {
    final rnd = Random();
    _randomMoveDirection = _fromIndex(rnd.nextInt(4));
    if (availableDirection != null) {
      while (!availableDirection.contains(_randomMoveDirection)) {
        _randomMoveDirection = _fromIndex(rnd.nextInt(4));
      }
    }
    movementDistance = rnd.nextInt(movementMaxDistance.toInt()).toDouble();
    movementDistance = movementMaxDistance < movementMinDistance
        ? movementMinDistance
        : movementMaxDistance;

    return _randomMoveDirection;
  }

  Direction _fromIndex(int index) {
    switch (index) {
      case 0:
        return Direction.up;
      case 1:
        return Direction.down;
      case 2:
        return Direction.left;
      case 3:
        return Direction.right;
    }
    throw RangeError('Index $index not in range [0 - 3]');
  }
}
