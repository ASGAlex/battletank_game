import 'package:bonfire/bonfire.dart' as bonfire;
import 'package:game/entities/tank/tank.dart';
import 'package:game/services/sound/sound.dart';
import 'package:game/tools.dart';

mixin AmbientEnemy on BaseTank {
  @override
  void update(double dt) {
    super.update(dt);

    final radiusOfAmbient = mySize * 20;
    seeComponentType<Npc>(
        radiusVision: radiusOfAmbient,
        observed: (enemies) {
          double minDistance = radiusOfAmbient;
          for (final enemy in enemies) {
            final newDistance = enemy.position.distanceTo(position);
            if (newDistance < minDistance) {
              minDistance = newDistance;
            }
          }
          final soundVolume = 1 - minDistance / radiusOfAmbient;
          final player = Sound().moveEnemies;
          player.controller?.volume = soundVolume;
          player.play();
        },
        notObserved: () {
          Sound().moveEnemies.pause();
        });
  }
}
