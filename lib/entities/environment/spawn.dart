import 'package:bonfire/bonfire.dart';
import 'package:flutter/rendering.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

class Spawn extends GameDecoration {
  static final _instances = <Spawn>[];
  static const spawnDurationSec = 3;

  static Spawn? _getFree([bool forPlayer = false]) {
    for (var spawn in _instances) {
      if (!spawn.busy &&
          spawn.isForPlayer == forPlayer &&
          spawn.notOverlappedByObjects()) {
        return spawn;
      }
    }
    return null;
  }

  static Future<Spawn> waitFree([bool forPlayer = false]) {
    var spawn = _getFree(forPlayer);
    if (spawn == null) {
      return Future.delayed(const Duration(seconds: spawnDurationSec))
          .then((value) => waitFree(forPlayer));
    }
    return Future.value(spawn);
  }

  bool busy = false;
  bool isForPlayer = false;

  Spawn.withAnimation({required Vector2 position, this.isForPlayer = false})
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

  Future createTank(GameComponent object, [bool isPlayer = false]) {
    busy = true;
    object.isVisible = false;
    animation?.reset();
    return Future.delayed(const Duration(seconds: spawnDurationSec))
        .then((value) {
      object.position = position.clone();
      object.isVisible = true;
      // if (!isPlayer) {
      gameRef.add(object);
      // }
      Future.delayed(const Duration(seconds: spawnDurationSec)).then((value) {
        busy = false;
      });
      return null;
    });
  }

  @override
  void render(Canvas canvas) {
    if (busy) {
      super.render(canvas);
    }
  }
}
