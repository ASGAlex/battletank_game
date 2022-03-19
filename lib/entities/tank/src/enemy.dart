part of tank;

class Enemy extends RotationEnemy
    with _BaseTankMix, ObjectCollision, _MoveToPositionAlongThePath {
  Enemy({required Vector2 position, this.gameController})
      : super(
            position: position,
            speed: 16 * 2,
            life: 1,
            size: SpriteSheetRegistry().tankBasic.spriteSize,
            animIdle: SpriteSheetRegistry().tankBasic.animationIdle,
            animRun: SpriteSheetRegistry().tankBasic.animationRun) {
    init(SpriteSheetRegistry().tankBasic);
    setupMoveToPositionAlongThePath(showBarriersCalculated: true);
  }

  @override
  AttackFromEnum get myRole => AttackFromEnum.ENEMY;

  bool updatePath = true;
  bool _updateScheduled = false;

  Vector2? movementCorrection;

  Vector2? lastTargetPosition;

  Direction _fireDirection = Direction.up;

  MyGameController? gameController;

  @override
  void update(double dt) {
    super.update(dt);

    if (movementCorrection != null) {
      position = movementCorrection!;
      movementCorrection = null;
    } else {
      seePlayer(
        notObserved: onPlayerNotObserved,
        observed: onPlayerIsObserved,
        radiusVision: 16 * 100,
      );
    }
  }

  void onPlayerNotObserved() {
    if (lastTargetPosition != null) {
      _moveToTarget(lastTargetPosition!);
    }
  }

  void onPlayerIsObserved(bonfire.Player player) {
    lastTargetPosition = gameRef.player!.position + (gameRef.player!.size / 2);
    _moveToTarget(lastTargetPosition!);

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
            position.toOffset() + const Offset(-16 * 100, 16));
        break;
      case Direction.right:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(16 * 100, 16));
        break;
      case Direction.up:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(16, -16 * 100));
        break;
      case Direction.down:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + const Offset(16, 16 * 100));
        break;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        break;
    }

    return lineOfVision?.overlaps(getRectAndCollision(gameRef.player)) ?? false;
  }

  void _moveToTarget(Vector2 targetPosition, [var force = false]) {
    if (updatePath || force) {
      updatePath = false;
      final ignoreCollisionsWith = <ObjectCollision>[];
      ignoreCollisionsWith.add(gameRef.player as ObjectCollision);
      for (var element in myBullets) {
        ignoreCollisionsWith.add(element);
      }
      moveToPositionAlongThePath(targetPosition,
          ignoreCollisions: ignoreCollisionsWith);
      if (!_updateScheduled) {
        Future.delayed(const Duration(milliseconds: 1500)).then((_) {
          updatePath = true;
          _updateScheduled = false;
        });
      }
    }
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
      movementCorrection = position.translate(vector.x, vector.y);
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
      gameController?.addEnemy(Vector2(46 * 8, 46 * 8));
    });

    if (!shouldRemove) {
      removeFromParent();
    }
    super.die();
  }
}
