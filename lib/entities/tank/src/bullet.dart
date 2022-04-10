part of tank;

abstract class BulletInterface {
  GameComponent get firedFrom;

  Sfx get dieSound;

  Sfx get createSound;
}

class _Bullet extends FlyingAttackObject implements BulletInterface {
  _Bullet._byAngle(
      {required Vector2 position,
      required Vector2 size,
      required Future<SpriteAnimation> flyAnimation,
      required double angle,
      dynamic id,
      Future<SpriteAnimation>? animationDestroy,
      Vector2? destroySize,
      double speed = 150,
      double damage = 1,
      AttackFromEnum attackFrom = AttackFromEnum.ENEMY,
      bool withDecorationCollision = true,
      VoidCallback? onDestroy,
      LightingConfig? lightingConfig,
      CollisionConfig? collision,
      required this.firedFrom})
      : super.byAngle(
            id: id,
            position: position,
            size: size,
            angle: angle,
            damage: damage,
            speed: speed,
            attackFrom: attackFrom,
            collision: collision,
            withDecorationCollision: withDecorationCollision,
            onDestroy: onDestroy,
            destroySize: destroySize,
            flyAnimation: flyAnimation,
            animationDestroy: animationDestroy,
            lightingConfig: lightingConfig,
            enabledDiagonal: false);

  factory _Bullet({
    required Vector2 position,
    required AttackFromEnum attackFrom,
    required double angle,
    required GameComponent firedFrom,
    dynamic id,
    VoidCallback? onDestroy,
    double speed = 150,
    double damage = 1,
  }) {
    final spriteSheetRegistry = SpriteSheetRegistry();
    final bulletSize = spriteSheetRegistry.bullet.spriteSize;
    final auraRadius = bulletSize.x;

    Vector2 startPosition = position;

    double displacement = max(spriteSheetRegistry.tankBasic.spriteSize.x / 2,
        spriteSheetRegistry.tankBasic.spriteSize.y / 2);
    double nextX = displacement * cos(angle);
    double nextY = displacement * sin(angle);

    Vector2 diffBase = Vector2(nextX, nextY);

    startPosition.add(diffBase);
    startPosition.add(Vector2(-bulletSize.x / 2, -bulletSize.y / 2));
    final collisionConfig = CollisionConfig(
        collisions: [CollisionArea.rectangle(size: bulletSize)]);
    collisionConfig.collisionOnlyVisibleScreen = false;

    return _Bullet._byAngle(
      angle: angle,
      id: id,
      firedFrom: firedFrom,
      position: startPosition,
      onDestroy: onDestroy,
      speed: speed,
      damage: damage,
      attackFrom: attackFrom,
      flyAnimation: spriteSheetRegistry.bullet.animation,
      animationDestroy: spriteSheetRegistry.boom.animation,
      destroySize: spriteSheetRegistry.boom.spriteSize,
      size: bulletSize,
      collision: collisionConfig,
      lightingConfig: LightingConfig(
        radius: auraRadius / 2,
        blurBorder: auraRadius,
        color: Colors.orange.withOpacity(0.3),
      ),
    );
  }

  @override
  final GameComponent firedFrom;

  @override
  Sfx dieSound = Sound().playerBulletWall;

  @override
  final Sfx createSound = Sound().playerFireBullet;

  /// Fix error when fired bullet instantly destroys, collided with parent tank
  @override
  bool onCollision(GameComponent component, bool active) {
    if (component == firedFrom) return false;
    bool allowBullet = component.properties?['allowBullet'] == true;
    if (allowBullet) return false;

    dieSound = Sound().playerBulletWall;
    if (component is _Bullet) {
      if (component.firedFrom is Npc && firedFrom is Npc) {
        return false;
      }
      dieSound = Sound().bulletStrongTank;
    }

    if (component is Npc) {
      if (firedFrom is Npc) {
        return false;
      }
      dieSound = Sound().bulletStrongTank;
    }

    if (component is Attackable && !component.shouldRemove) {
      dieSound = Sound().bulletStrongTank;
      component.receiveDamage(attackFrom, damage, id);
    } else if (!withDecorationCollision) {
      return false;
    }

    if (component is Brick) {
      dieSound = Sound().playerBulletWall;
    } else if (component is TileWithCollision) {
      dieSound = Sound().playerBulletStrongWall;
    }

    _die();
    return true;
  }

  void _die() {
    if (shouldRemove) return;
    removeFromParent();
    if (animationDestroy != null) {
      final explosionSize = destroySize ?? size;
      final positionDestroy =
          center.translate(-explosionSize.x / 2, -explosionSize.y / 2);

      if (hasGameRef) {
        gameRef.add(
          AnimatedObjectOnce(
            animation: animationDestroy!,
            position: positionDestroy,
            lightingConfig: lightingConfig,
            size: explosionSize,
          ),
        );

        if (firedFrom is Player) {
          dieSound.play();
        } else {
          final player = gameRef.player;
          if (player != null) {
            player as Player;
            seeComponent(player, radiusVision: player.mySize * 3,
                observed: (player) {
              dieSound.play();
            });
          }
        }
      }
    }
    setupCollision(CollisionConfig(collisions: []));
    onDestroy?.call();
  }
}
