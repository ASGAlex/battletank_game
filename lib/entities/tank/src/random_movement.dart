part of tank;

mixin _RandomMovement on ObjectCollision, Movement {
  bool randomMovement = false;
  Direction _randomMoveDirection = Direction.up;
  double movementDistance = 0;
  double _movementMaxDistance = 0;

  double get movementMaxDistance {
    if (_movementMaxDistance == 0) {
      _movementMaxDistance = min(gameRef.map.mapSize?.width ?? 100,
          gameRef.map.mapSize?.height ?? 100);
    }
    return _movementMaxDistance;
  }

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
      _changeDirection();
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    _changeDirection();
    return super.onCollision(component, active);
  }

  _changeDirection() {
    final rnd = Random();
    _randomMoveDirection = _fromIndex(rnd.nextInt(4));
    movementDistance = rnd.nextInt(movementMaxDistance.toInt()).toDouble();
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
