part of tank;

class Npc extends RotationEnemy
    with
        _BaseTankMix,
        DieExplosion,
        ObjectCollision,
        _RandomMovement,
        _TargetedMovement,
        _RandomFire {
  Npc({required Vector2 position})
      : super(
            position: position,
            speed: 0,
            life: 1,
            size: SpriteSheetRegistry().tankBasic.spriteSize,
            animIdle: SpriteSheetRegistry().tankBasic.animationIdle,
            animRun: SpriteSheetRegistry().tankBasic.animationRun) {
    final tankBasic = SpriteSheetRegistry().tankBasic;
    init(tankBasic);
    _sizePx = max(tankBasic.spriteSize.x, tankBasic.spriteSize.y);
    _visionRevealRadius = _sizePx * 5;
    _fireOptimalDistance = _sizePx * 10;
    _defaultSpeed = _sizePx * 3;
    speed = _defaultSpeed;
  }

  late final _sizePx;
  late final _visionRevealRadius;
  late final _defaultSpeed;
  late final _fireOptimalDistance;

  Direction _fireDirection = Direction.up;

  List<Direction> availableDirections = [];

  Direction get fireDirection => _fireDirection;

  @override
  void update(double dt) {
    if (isIdle) {
      animation = animIdle;
    } else {
      animation = animRun;
    }

    /// продолжаем идти по маршруту, когда потеряли цель
    if (noTarget && hasRoute) {
      super.update(dt);
      return;
    }

    _targetInRevealArea1();

    if (noTarget) {
      randomMovement = true;
      randomFire = true;
    } else if (noRoute) {
      // _updateRoute();
    }

    super.update(dt);
  }

  _updateRoute() {
    if (isDead) return;
    updateRoute().then((hasRoute) {
      if (hasRoute) {
        // randomMovement = false;
        // randomFire = false;
      }
      Future.delayed(const Duration(seconds: 2)).then((_) {
        if (hasTarget) {
          _updateRoute();
        }
      });
    });
  }

  /// Цель есть в области ближнего обнаружения: любая цель в радиусе 360 градусов,
  /// не важно, скрытая или нет.
  /// Важно, что обновляет последнюю наблюдаемую позицию цели!!!
  bool _targetInRevealArea1() {
    // попадает ли игрок в область обнаружения скрытых целей?
    seePlayer(
        radiusVision: _visionRevealRadius, observed: _onEnemyInRevealArea);
    return hasTarget;
  }

  bool _findEnemyOnLineSight() {
    return false;
  }

  /// противник на линии видимости
  void _onEnemyOnLineSight() {}

  /// противник в области видимости, в которой раскрываются даже скрытые цели.
  void _onEnemyInRevealArea(bonfire.Player player) {
    lastKnownTargetPosition = player.position.clone();
  }

  bool _shouldFireTo(GameComponent target) {
    if (reloadingMainWeapon) return false;
    Rect? lineOfVision;

    switch (_fireDirection) {
      case Direction.left:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(-_fireOptimalDistance, _sizePx));
        break;
      case Direction.right:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(_fireOptimalDistance, _sizePx));
        break;
      case Direction.up:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(_sizePx, -_fireOptimalDistance));
        break;
      case Direction.down:
        lineOfVision = Rect.fromPoints(position.toOffset(),
            position.toOffset() + Offset(_sizePx, _fireOptimalDistance));
        break;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        break;
    }

    return lineOfVision?.overlaps(getRectAndCollision(gameRef.player)) ?? false;
  }

  /// Added to perform rotation calculations
  /// By default sprite is not rotated when moving NPS by AStar algorithm
  @override
  void onMove(double speed, Direction direction, double angle) {
    this.angle = angle;
    _fireDirection = direction;
    super.onMove(speed, direction, angle);
    _checkNewDirections();
  }

  _checkNewDirections() {
    if (speed <= 0) return;

    final prevDirections = availableDirections.toList();

    final checkDirections = {
      Direction.left: position.translate(-_tileSize * 2, 0), //Left
      Direction.right: position.translate(_tileSize * 2, 0), //Right
      Direction.down: position.translate(0, _tileSize * 2), //Bottom
      Direction.up: position.translate(0, -_tileSize * 2), //Top
    };
    availableDirections = checkDirections.keys.toList();

    final allCollisions = gameRef.collisions();

    for (final collisionObject in allCollisions) {
      if (collisionObject == this) continue;

      for (var pos in checkDirections.entries) {
        if (checkCollision(collisionObject, displacement: pos.value)) {
          availableDirections.remove(pos.key);
        }
      }
    }

    final newDirections = <Direction>[];
    for (final direction in availableDirections) {
      if (!prevDirections.contains(direction)) {
        newDirections.add(direction);
      }
    }
    newDirections.remove(_fireDirection.opposite);

    if (randomMovement && newDirections.isNotEmpty) {
      final rnd = Random();
      if (rnd.nextDouble() < 0.7) {
        print('change: $newDirections');
        final newDirection = changeRandomDirection(newDirections);
        _fireDirection = newDirection;
        fireASAP();
      }
    }
  }

  @override
  die() {
    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      MyGameController().addEnemy();
    });
    super.die();
  }

  @override
  AttackFromEnum get myRole => AttackFromEnum.ENEMY;
}

extension on Direction {
  Direction get opposite {
    switch (this) {
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        throw 'Unsupported direction';
    }
  }
}
