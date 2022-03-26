part of tank;

class Enemy extends RotationEnemy
    with
        _BaseTankMix,
        DieExplosion,
        ObjectCollision,
        _RandomMovement,
        _MoveToPositionAlongThePath {
  Enemy({required Vector2 position})
      : super(
            position: position,
            speed: defaultSpeed,
            life: 1,
            size: SpriteSheetRegistry().tankBasic.spriteSize,
            animIdle: SpriteSheetRegistry().tankBasic.animationIdle,
            animRun: SpriteSheetRegistry().tankBasic.animationRun) {
    init(SpriteSheetRegistry().tankBasic);
    setupMoveToPositionAlongThePath(showBarriersCalculated: true);
  }

  static const sizePx = 16.0;
  static const visionRadius = sizePx * 5;
  static const defaultSpeed = sizePx * 2;

  @override
  AttackFromEnum get myRole => AttackFromEnum.ENEMY;

  bool _updatePath = true;
  bool _updateScheduled = false;

  Vector2? _lastTargetPosition;
  Vector2? _targetPositionOfPrevCalculation;
  bool _targetedMovement = false;

  Direction _fireDirection = Direction.up;

  @override
  void update(double dt) {
    super.update(dt);

    if (movementCorrection != null) {
      position = movementCorrection!.clone();
      movementCorrection = null;
    } else {
      seePlayer(
        notObserved: onPlayerNotObserved,
        observed: onPlayerIsObserved,
        radiusVision: visionRadius,
      );
    }
  }

  void onPlayerNotObserved() {
    if (_lastTargetPosition != null) {
      _moveToTarget(_lastTargetPosition!);
    } else {
      randomMovement = true;
    }
  }

  void onPlayerIsObserved(bonfire.Player player) {
    if (player is Player &&
        player.invisibleInTrees &&
        player.position.distanceTo(position) > sizePx * 3) {
      randomMovement = true;
      return;
    }

    _lastTargetPosition = player.position + (player.size / 2);
    _moveToTarget(_lastTargetPosition!, force: !_targetedMovement);

    if (_shouldFireTo(player)) {
      fire();
    }
  }

  bool _shouldFireTo(GameComponent target) {
    if (reloadingMainWeapon) return false;
    Rect? lineOfVision;

    switch (_fireDirection) {
      case Direction.left:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(-visionRadius, 16));
        break;
      case Direction.right:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(visionRadius, sizePx));
        break;
      case Direction.up:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(sizePx, -visionRadius));
        break;
      case Direction.down:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(sizePx, visionRadius));
        break;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        break;
    }

    return lineOfVision?.overlaps(getRectAndCollision(gameRef.player)) ?? false;
  }

  void _moveToTarget(Vector2 targetPosition, {var force = false}) async {
    randomMovement = false;
    if (_updatePath || force) {
      _updatePath = false;
      final ignoreCollisionsWith = <ObjectCollision>[];
      ignoreCollisionsWith.add(gameRef.player as ObjectCollision);
      for (var element in myBullets) {
        ignoreCollisionsWith.add(element);
      }
      if (!_updateScheduled) {
        Future.delayed(const Duration(milliseconds: 1500)).then((_) {
          _updatePath = true;
          _updateScheduled = false;
        });
      }
      if (_targetPositionOfPrevCalculation != null &&
          ((_targetPositionOfPrevCalculation!.x - targetPosition.x).abs() < 8 ||
              (_targetPositionOfPrevCalculation!.y - targetPosition.y).abs() <
                  8)) {
        return;
      }
      _targetPositionOfPrevCalculation = targetPosition.clone();
      await moveToPositionAlongThePath(targetPosition,
          ignoreCollisions: ignoreCollisionsWith);
      _targetedMovement = true;
    }
    if (isIdle &&
        _lastTargetPosition != null &&
        _lastTargetPosition!.distanceTo(position) < sizePx) {
      _lastTargetPosition = null;
    }
  }

  // void _moveRandom() {
  //   if (!isIdle) return;
  //   _targetedMovement = false;
  //   var targetPosition = _getRandomTarget();
  //   final mapSize = gameRef.map.mapSize;
  //   if (mapSize == null) return;
  //
  //   if (targetPosition.x >= mapSize.width - sizePx) {
  //     targetPosition.x = mapSize.width - sizePx * 2;
  //   }
  //   if (targetPosition.x <= 0 + sizePx) {
  //     targetPosition.x = sizePx * 2;
  //   }
  //   if (targetPosition.y >= mapSize.height - sizePx) {
  //     targetPosition.y = mapSize.height - sizePx * 2;
  //   }
  //   if (targetPosition.y <= 0 + sizePx) {
  //     targetPosition.y = sizePx * 2;
  //   }
  //
  //   final allCollisions = gameRef.collisions();
  //   var collision = false;
  //   for (final i in allCollisions) {
  //     if (i == this) continue;
  //     collision = checkCollision(i, displacement: targetPosition);
  //     if (collision) {
  //       break;
  //     }
  //   }
  //   if (collision) {
  //     _moveRandom();
  //     return;
  //   }
  //
  //   _moveToTarget(targetPosition);
  // }

  Vector2 _getRandomTarget() {
    final random = Random();
    final randX = sizePx * 5 - random.nextInt(sizePx.toInt() * 5) * 2;
    final randy = sizePx * 5 - random.nextInt(sizePx.toInt() * 5) * 2;
    final targetPosition = position.translate(randX, randy);
    return targetPosition;
  }

  /// Added to perform rotation calculations
  /// By default sprite is not rotated when moving NPS by AStar algorithm
  @override
  void onMove(double speed, Direction direction, double angle) {
    this.angle = angle;
    _fireDirection = direction;
    super.onMove(speed, direction, angle);
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is TileWithCollision) {
      final vector = center - component.center;
      final limit = 0.5; // component.rectCollision.width / 2;
      if (vector.x.abs() > limit) {
        vector.x = limit * (vector.x > 0 ? 1 : -1);
      }
      if (vector.y.abs() > limit) {
        vector.y = limit * (vector.y > 0 ? 1 : -1);
      }
      movementCorrection = position.translate(vector.x, vector.y);
      if (currentIndex < currentPath.length) {
        var targetPoint = currentPath[currentIndex];
        targetPoint = targetPoint.translate(vector.x, vector.y);
        currentPath[currentIndex] = targetPoint;
      }
      // return false;
    }
    return super.onCollision(component, active);
  }

  @override
  die() {
    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      MyGameController().addEnemy();
    });
    super.die();
  }
}
