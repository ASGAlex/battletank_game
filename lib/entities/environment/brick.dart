import 'package:bonfire/bonfire.dart';
import 'package:game/entities/tank/tank.dart';

import '../../controllers/game.dart';

class Brick extends TileWithCollision {
  static const halfBrick = 4.0;
  static final brickSize = Vector2.all(halfBrick * 2);

  Brick(
      {required Sprite sprite,
      required Vector2 position,
      Iterable<CollisionArea>? collisions})
      : super.fromSprite(
            sprite: sprite,
            position: position,
            size: Brick.brickSize,
            collisions: collisions);

  int _hitsByBullet = 0;

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is BulletInterface) {
      _collideWithBullet(component);
    }
    return super.onCollision(component, active);
  }

  void _collideWithBullet(GameComponent bullet) {
    final vector = center - bullet.center;
    if (vector.x.abs() > vector.y.abs()) {
      //horizontal
      if (vector.x > 0) {
        //from left
        if (_hitsByBullet == 0) {
          size.x -= halfBrick;
          final originalPosition = position.clone();
          position.x += halfBrick;
          MyGameController().addGroundAsh(originalPosition, size.clone());
        } else {
          MyGameController().addGroundAsh(position.clone(), size.clone());
          _die();
        }
      } else {
        //from right
        if (_hitsByBullet == 0) {
          size.x -= halfBrick;
          MyGameController()
              .addGroundAsh(position.translate(halfBrick, 0), size.clone());
        } else {
          _die();
          MyGameController().addGroundAsh(position.clone(), size.clone());
        }
      }
    } else {
      //vertical
      if (vector.y > 0) {
        //from top
        if (_hitsByBullet == 0) {
          size.y -= halfBrick;
          final originalPosition = position.clone();
          position.y += halfBrick;
          MyGameController().addGroundAsh(originalPosition, size.clone());
        } else {
          MyGameController().addGroundAsh(position.clone(), size.clone());
          _die();
        }
      } else {
        //from bottom
        if (_hitsByBullet == 0) {
          size.y -= halfBrick;
          MyGameController()
              .addGroundAsh(position.translate(0, halfBrick), size.clone());
        } else {
          _die();
          MyGameController().addGroundAsh(position.clone(), size.clone());
        }
      }
    }
    _updateCollisions();
    _hitsByBullet++;
  }

  _updateCollisions() {
    if (shouldRemove) return;
    setupCollision(
        CollisionConfig(collisions: [CollisionArea.rectangle(size: size)]));
  }

  _die() {
    if (shouldRemove) return;
    removeFromParent();
  }
}
