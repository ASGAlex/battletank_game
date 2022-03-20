import 'package:bonfire/bonfire.dart';

import '../tank/tank.dart' as tank;

class Tree extends GameDecoration with Sensor {
  Tree(
      {required Future<Sprite> sprite,
      required Vector2 position,
      Iterable<CollisionArea>? collisions})
      : super.withSprite(
            sprite: sprite, position: position, size: Vector2(8, 8)) {
    aboveComponents = true;
    if (collisions != null) {
      setupSensorArea(areaSensor: collisions.toList());
    }
  }

  @override
  void onContact(GameComponent component) {
    if (component is tank.Player) {
      component.contactWithTrees();
    }
  }
}
