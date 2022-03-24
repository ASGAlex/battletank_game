import 'package:bonfire/bonfire.dart';

class Target extends GameDecorationWithCollision {
  Target.withSprite(
      {required Future<Sprite> sprite,
      required Vector2 position,
      required Vector2 size})
      : super.withSprite(sprite: sprite, position: position, size: size);
}
