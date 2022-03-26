part of tank;

class Npc extends RotationEnemy
    with
        _BaseTankMix,
        DieExplosion,
        ObjectCollision,
        _RandomMovement,
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
    _defaultSpeed = _sizePx * 2;
    speed = _defaultSpeed;
  }

  late final _sizePx;
  late final _visionRevealRadius;
  late final _defaultSpeed;
  late final _fireOptimalDistance;

  Vector2? _lastKnownTargetPosition;
  Direction _fireDirection = Direction.up;

  Direction get fireDirection => _fireDirection;

  bool get noTarget => _lastKnownTargetPosition == null;

  @override
  void update(double dt) {
    if (isIdle) {
      animation = animIdle;
    } else {
      animation = animRun;
    }
    // попадает ли игрок в область обнаружения скрытых целей?
    seePlayer(
        radiusVision: _visionRevealRadius, observed: _onEnemyInRevealArea);

    // если не нашли в ближней области видимости, тогда ищем на "линии зрения"
    if (noTarget) {
      _findEnemyOnLineSight();
    }
    if (noTarget) {
      randomMovement = true;
      randomFire = true;
    } else {
      /// строим маршрут движения и уничтожения цели
      _onEnemyOnLineSight();
    }

    super.update(dt);
  }

  bool _findEnemyOnLineSight() {
    return false;
  }

  /// противник на линии видимости
  void _onEnemyOnLineSight() {}

  /// противник в области видимости, в которой раскрываются даже скрытые цели.
  void _onEnemyInRevealArea(bonfire.Player player) {
    //TODO: лучше вызывать. когда маршрут уже будет построен
    randomMovement = false;
    randomFire = false;
    _lastKnownTargetPosition = player.position.clone();
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
