part of tank;

class Player extends GameComponent
    with
        _BaseTankMix,
        UseAssetsLoader,
        ObjectCollision,
        Movement,
        Attackable,
        MoveToPositionAlongThePath,
        JoystickListener
    implements bonfire.Player {
  Player({Vector2? position}) {
    final tankSheet = SpriteSheetRegistry().tankBasic;
    init(tankSheet);
    speed = 16 * 5;
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
    initialLife(1000000000);
    this.position = position ?? Vector2(10 * 16, 10 * 16);
    size = tankSheet.spriteSize;
    _animIdle = tankSheet.animationIdle;
    _animRun = tankSheet.animationRun;
  }

  late Future<SpriteAnimation> _animIdle;
  late Future<SpriteAnimation> _animRun;

  int _treeCollisions = 0;

  bool invisibleInTrees = false;

  @override
  bool dPadAngles = true;

  @override
  double movementRadAngle = 0;

  @override
  double get innerCurrentDirectionalAngle => currentDirectionalAngle;

  @override
  JoystickMoveDirectional? get innerCurrentDirectional => currentDirectional;

  SpriteAnimation? animation;

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == MyJoystickActions.attack ||
        event.id == MyJoystick.btnSpace) {
      fire();
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) async {
    super.joystickChangeDirectional(event);
    if (event.directional != JoystickMoveDirectional.IDLE && !isDead) {
      animation = await _animRun;
    } else {
      animation = await _animIdle;
    }
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (animation == null) return;
    animation?.getSprite().renderWithOpacity(
          c,
          position,
          size,
          opacity: opacity,
        );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await SpriteSheetRegistry().tankBasic.animationIdle;
  }

  @override
  void update(double dt) {
    _treeCollisions = 0;
    _moveDirectional(innerCurrentDirectional!, speed);
    final newAngle = _getAngleByDirectional();
    if (innerCurrentDirectional != JoystickMoveDirectional.IDLE &&
        newAngle != 0.0) {
      angle = newAngle;
    }
    animation?.update(dt);

    super.update(dt);
  }

  void _moveDirectional(
    JoystickMoveDirectional direction,
    double speed,
  ) {
    switch (direction) {
      case JoystickMoveDirectional.MOVE_UP:
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft(speed);
        break;
      case JoystickMoveDirectional.IDLE:
        if (!isIdle) {
          idle();
        }
        break;
    }
  }

  double _getAngleByDirectional() {
    switch (innerCurrentDirectional) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return 180 / (180 / pi);
      case JoystickMoveDirectional.MOVE_RIGHT:
        // we can't use 0 here because then no movement happens
        // we're just going as close to 0.0 without being exactly 0.0
        // if you have a better idea. Please be my guest
        return 0.0000001 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP:
        return -90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN:
        return 90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return -90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return -90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return 90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return 90 / (180 / pi);
      default:
        return 0;
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is Tree) {
      _treeCollisions++;
      if (_treeCollisions == 2) {
        invisibleInTrees = true;
      }
      return false;
    }
    if (component is _Bullet && component.firedFrom == this) return false;

    return super.onCollision(component, active);
  }

  @override
  void onMove(
    double speed,
    Direction direction,
    double angle,
  ) {
    if (_treeCollisions < 2) {
      Future.delayed(const Duration(milliseconds: 700)).then((value) {
        if (_treeCollisions < 2) {
          invisibleInTrees = false;
        }
      });
    }
  }

  @override
  AttackFromEnum get myRole => AttackFromEnum.PLAYER;

  @override
  void moveTo(Vector2 position) {}
}
