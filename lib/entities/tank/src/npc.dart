part of tank;

class Npc extends RotationEnemy
    with
        _BaseTankMix,
        DieExplosion,
        ObjectCollision,
        _Detection,
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
    final mySize = max(tankBasic.spriteSize.x, tankBasic.spriteSize.y);
    init(tankBasic);
    initDetection(mySize);
    randomMovement = true;
    randomFire = true;
    _defaultSpeed = mySize * 3;
    speed = _defaultSpeed;
  }

  double _defaultSpeed = 0;

  @override
  void update(double dt) {
    if (isIdle) {
      animation = animIdle;
    } else {
      animation = animRun;
    }
    super.update(dt);
  }

  @override
  void onMove(double speed, Direction direction, double angle) {
    this.angle = angle;
    visionDirection = direction;
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
