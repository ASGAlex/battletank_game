import 'package:bonfire/bonfire.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

class Spawn extends GameDecoration {
  static final _instances = <Spawn>[];

  static Spawn? _getFree() {
    for (var spawn in _instances) {
      if (!spawn.busy) {
        return spawn;
      }
    }
    return null;
  }

  static Future<Spawn> waitFree() {
    var spawn = _getFree();
    if (spawn == null) {
      return Future.delayed(const Duration(seconds: 3))
          .then((value) => waitFree());
    }
    return Future.value(spawn);
  }

  bool busy = false;

  Spawn.withAnimation({required Vector2 position})
      : super.withAnimation(
            animation: SpriteSheetRegistry().spawn.animation,
            position: position,
            size: Vector2.all(15)) {
    _instances.add(this);
  }

  void createTank(GameComponent object) {
    busy = true;
    object.isVisible = false;
    animation?.reset();
    isVisible = true;
    Future.delayed(const Duration(seconds: 3)).then((value) {
      object.position = position.clone();
      object.isVisible = true;
      gameRef.add(object);
      Future.delayed(const Duration(seconds: 3)).then((value) {
        busy = false;
      });
      isVisible = false;
    });
  }
}
