part of tank;

abstract class _BaseTank extends GameComponent with ObjectCollision {
  AttackFromEnum get myRole;
}

mixin _BaseTankMix on GameComponent implements _BaseTank {
  Duration fireInterval = const Duration(milliseconds: 500);
  bool reloadingMainWeapon = false;

  final List<FlyingAttackObject> myBullets = [];

  void init(SpriteSheetPublicInterface spriteSheet) {
    setupCollision(
      CollisionConfig(
        enable: true,
        collisions: [
          //required
          CollisionArea.rectangle(
            size: spriteSheet.spriteSize,
          ),
        ],
      ),
    );
  }

  void fire() {
    if (reloadingMainWeapon) return;
    reloadingMainWeapon = true;
    _Bullet? bullet;
    bullet = _Bullet(
        position: center,
        attackFrom: myRole,
        angle: angle,
        firedFrom: this,
        onDestroy: () {
          if (bullet != null) {
            myBullets.remove(bullet);
          }
        });
    gameRef.add(bullet);
    myBullets.add(bullet);

    Future.delayed(fireInterval).then((_) {
      reloadingMainWeapon = false;
    });
  }
}
