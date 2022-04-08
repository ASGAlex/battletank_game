part of tank;

mixin _Detection on Enemy, _BaseTankMix {
  initDetection(double mySize) {
    _visionRevealRadius = mySize * 3;
    _visionForwardDistance = mySize * 15;
    _mySize = mySize;
  }

  double _mySize = 0;
  double _visionRevealRadius = 0;
  double _visionForwardDistance = 0;

  Direction visionDirection = Direction.up;

  Direction? targetLastDirection;
  Vector2? targetLastPosition;

  bonfire.Player? get player {
    bonfire.Player? player = gameRef.player;
    if (player == null || player.isDead || player.shouldRemove) {
      return null;
    }
    return player;
  }

  GameComponent? seeHiddenObject() {
    Rect fieldOfVision = Rect.fromCircle(
      center: center.toOffset(),
      radius: _visionRevealRadius,
    );
    if (fieldOfVision.overlaps(getRectAndCollision(player))) {
      return player;
    }

    return null;
  }

  GameComponent? seeObjectInFront() {
    Rect? lineOfVision;

    switch (visionDirection) {
      case Direction.left:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(-_visionForwardDistance, _mySize));
        break;
      case Direction.right:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(_visionForwardDistance, _mySize));
        break;
      case Direction.up:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(_mySize, -_visionForwardDistance));
        break;
      case Direction.down:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(_mySize, _visionForwardDistance));
        break;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        break;
    }

    if (lineOfVision?.overlaps(getRectAndCollision(player)) ?? false) {
      return player;
    }
    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final targetInFront = seeObjectInFront();
    if (targetInFront != null) {
      tryFire();
      if (targetInFront is _Detection) {
        targetLastDirection = targetInFront.visionDirection;
      } else if (targetInFront is Player) {
        targetLastDirection = targetInFront.direction;
      }
      targetLastPosition = targetInFront.position.clone();
    }
  }
}
