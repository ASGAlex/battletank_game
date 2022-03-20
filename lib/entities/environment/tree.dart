import 'package:bonfire/bonfire.dart';

import '../tank/tank.dart' as tank;

class Tree extends GameDecorationWithCollision {
  static List<Tree> trees = [];

  Tree(
      {required Future<Sprite> sprite,
      required Vector2 position,
      Iterable<CollisionArea>? collisions})
      : super.withSprite(
            sprite: sprite,
            position: position,
            size: Vector2(8, 8),
            collisions: collisions) {
    aboveComponents = true;
    trees.add(this);
  }

  @override
  bool onCollision(GameComponent component, bool active) =>
      component is tank.Player;

  @override
  void removeFromParent() {
    trees.remove(this);
    super.removeFromParent();
  }
}
