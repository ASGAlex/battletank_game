part of tank;

abstract class _BaseTank extends GameComponent with ObjectCollision {
  AttackFromEnum get myRole;
  List<FlyingAttackObject> get myBullets;
}

mixin _BaseTankMix on GameComponent implements _BaseTank {
  Duration fireInterval = const Duration(milliseconds: 1000);
  bool reloadingMainWeapon = false;

  @override
  final List<FlyingAttackObject> myBullets = [];

  var _onWeaponReloaded = Future.value(null);

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

  fireASAP() {
    final success = tryFire();
    if (!success) {
      _onWeaponReloaded.then((value) => tryFire());
    }
  }

  bool tryFire() {
    if (reloadingMainWeapon) return false;
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

    _onWeaponReloaded = Future.delayed(fireInterval).then((_) {
      reloadingMainWeapon = false;
    });
    return true;
  }
}
