import 'package:bonfire/bonfire.dart';
import 'package:game/entities/tank/tank.dart' as tank;

import '../services/spritesheet/spritesheet.dart';

class MyGameController implements GameListener {
  static final MyGameController _singleton = MyGameController._internal();

  factory MyGameController() {
    return _singleton;
  }

  MyGameController._internal();

  Component? game;
  bool needNewEnemies = true;

  init(Component game) {
    this.game = game;
  }

  void addEnemy(Vector2 position) {
    game?.add(tank.Enemy(
      gameController: this,
      position: position,
    ));
  }

  void addGround(Vector2 position) {
    final registry = SpriteSheetRegistry();
    game?.add(Tile.fromFutureSprite(
      sprite: registry.ground.dirt,
      position: position,
      size: registry.ground.spriteSize,
    ));
  }

  @override
  void changeCountLiveEnemies(int count) {}

  @override
  void updateGame() {}
}
