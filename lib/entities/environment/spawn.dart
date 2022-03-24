import 'package:bonfire/bonfire.dart';
import 'package:flutter/rendering.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

class Spawn extends GameDecoration {
  static final _instances = <Spawn>[];

  static Spawn? _getFree() {
    for (var spawn in _instances) {
      if (!spawn.busy && spawn.notOverlappedByObjects()) {
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (loader == null) {
      animation?.onComplete = reverseAnimation;
    }
  }

  void reverseAnimation() {
    animation = animation?.reversed();
    animation?.onComplete = reverseAnimation;
  }

  bool notOverlappedByObjects() {
    final enemies = gameRef.enemies();
    final player = gameRef.player;

    final objectsToCheck = <GameComponent>[...enemies];
    if (player != null) {
      objectsToCheck.add(player);
    }

    for (var obj in objectsToCheck) {
      if (toRect().overlaps(obj.toRect())) {
        return false;
      }
    }

    return true;
  }

  void createTank(GameComponent object) {
    busy = true;
    object.isVisible = false;
    animation?.reset();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      object.position = position.clone();
      object.isVisible = true;
      gameRef.add(object);
      Future.delayed(const Duration(seconds: 3)).then((value) {
        busy = false;
      });
    });
  }

  @override
  void render(Canvas canvas) {
    if (busy) {
      super.render(canvas);
    }
  }
}
