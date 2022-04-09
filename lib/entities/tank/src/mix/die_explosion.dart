part of tank;

mixin DieExplosion on Attackable {
  Sfx? dieSound;

  initExplosion() {
    if (this is Player || this is Target) {
      dieSound = Sound().explosionPlayer;
    } else {
      dieSound = Sound().explosionEnemy;
    }
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

    dieSound?.play();

    if (!shouldRemove) {
      removeFromParent();
    }
    super.die();
  }
}
