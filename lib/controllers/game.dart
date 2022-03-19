import 'package:bonfire/bonfire.dart';
import 'package:game/entities/tank/tank.dart' as tank;

import '../services/spritesheet/spritesheet.dart';

class MyGameController implements GameListener {
  static final MyGameController _singleton = MyGameController._internal();

  factory MyGameController() {
    return _singleton;
  }

  MyGameController._internal();

  BonfireGame? game;
  bool needNewEnemies = true;

  init(BonfireGame game) {
    this.game = game;
  }

  void addEnemy(Vector2 position) {
    game?.add(tank.Enemy(
      position: position,
    ));
  }

  void addGroundAsh(Vector2 position, Vector2 size) {
    final registry = SpriteSheetRegistry();
    final tile = Tile.fromFutureSprite(
      sprite: registry.ground.ash,
      position: position,
      bleedingPixel: false,
      size: size,
    );
    tile.belowComponents = true;
    game?.add(tile);
  }

  @override
  void changeCountLiveEnemies(int count) {}

  @override
  void updateGame() {}
}
