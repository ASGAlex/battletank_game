import 'package:bonfire/bonfire.dart';
import 'package:game/entities/tank/tank.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

class Target extends GameDecorationWithCollision with Attackable, DieExplosion {
  Target.withSprite({required Vector2 position, required Vector2 size})
      : super.withSprite(
            sprite: SpriteSheetRegistry().target.life,
            position: position,
            size: size) {
    life = 1;
    setupCollision(
        CollisionConfig(collisions: [CollisionArea.rectangle(size: size)]));
  }
}
