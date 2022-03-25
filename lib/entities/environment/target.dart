import 'package:bonfire/bonfire.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

class Target extends GameDecorationWithCollision {
  Target.withSprite({required Vector2 position, required Vector2 size})
      : super.withSprite(
            sprite: SpriteSheetRegistry().target.life,
            position: position,
            size: size);
}
