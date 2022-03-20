part of tank;

class Enemy extends RotationEnemy
    with _BaseTankMix, ObjectCollision, _MoveToPositionAlongThePath {
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
  static const visionRadius = sizePx * 10;
  static const defaultSpeed = sizePx * 2;

  @override
  AttackFromEnum get myRole => AttackFromEnum.ENEMY;

  bool _updatePath = true;
  bool _updateScheduled = false;

  Vector2? _movementCorrection;

  Vector2? _lastTargetPosition;
  bool _targetedMovement = false;

  Direction _fireDirection = Direction.up;

  @override
  void update(double dt) {
    super.update(dt);

    if (_movementCorrection != null) {
      position = _movementCorrection!;
      _movementCorrection = null;
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
      _moveRandom();
    }
  }

  void onPlayerIsObserved(bonfire.Player player) {
    if (player is Player &&
        player.invisibleInTrees &&
        player.position.distanceTo(position) > sizePx * 3) {
      _moveRandom();
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

  void _moveToTarget(Vector2 targetPosition, {var force = false}) {
    if (_updatePath || force) {
      _updatePath = false;
      final ignoreCollisionsWith = <ObjectCollision>[];
      ignoreCollisionsWith.add(gameRef.player as ObjectCollision);
      for (var element in myBullets) {
        ignoreCollisionsWith.add(element);
      }

      moveToPositionAlongThePath(targetPosition,
          ignoreCollisions: ignoreCollisionsWith);
      if (!_updateScheduled) {
        Future.delayed(const Duration(milliseconds: 1500)).then((_) {
          _updatePath = true;
          _updateScheduled = false;
        });
      }
    }
    if (isIdle &&
        _lastTargetPosition != null &&
        _lastTargetPosition!.distanceTo(position) < sizePx) {
      _lastTargetPosition = null;
    }
  }

  void _moveRandom() {
    if (!isIdle) return;
    _targetedMovement = false;
    var targetPosition = _getRandomTarget();
    final mapSize = gameRef.map.mapSize;
    if (mapSize == null) return;

    if (targetPosition.x >= mapSize.width - sizePx) {
      targetPosition.x = mapSize.width - sizePx * 2;
    }
    if (targetPosition.x <= 0 + sizePx) {
      targetPosition.x = sizePx * 2;
    }
    if (targetPosition.y >= mapSize.height - sizePx) {
      targetPosition.y = mapSize.height - sizePx * 2;
    }
    if (targetPosition.y <= 0 + sizePx) {
      targetPosition.y = sizePx * 2;
    }

    final allCollisions = gameRef.collisions();
    var collision = false;
    for (final i in allCollisions) {
      collision = checkCollision(i, displacement: targetPosition);
      if (collision) {
        break;
      }
    }
    if (collision) {
      _moveRandom();
      return;
    }

    _moveToTarget(targetPosition);
  }

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
      const limit = 0.5;
      if (vector.x.abs() > limit) {
        vector.x = limit * (vector.x > 0 ? 1 : -1);
      }
      if (vector.y.abs() > limit) {
        vector.y = limit * (vector.y > 0 ? 1 : -1);
      }
      _movementCorrection = position.translate(vector.x, vector.y);
    }
    return super.onCollision(component, active);
  }

  @override
  die() {
    final boomBig = SpriteSheetRegistry().boomBig;
    final animationDestroy = boomBig.animation;

    final explosionSize = boomBig.spriteSize;
    final positionDestroy =
        center.translate(-explosionSize.x / 2, -explosionSize.y / 2);
    gameRef.add(
      AnimatedObjectOnce(
        animation: animationDestroy,
        position: positionDestroy,
        lightingConfig: LightingConfig(
          radius: boomBig.spriteSize.x / 2,
          blurBorder: boomBig.spriteSize.x,
          color: Colors.orange.withOpacity(0.3),
        ),
        size: boomBig.spriteSize,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      MyGameController().addEnemy(Vector2(46 * 8, 46 * 8));
    });

    if (!shouldRemove) {
      removeFromParent();
    }
    super.die();
  }
}
