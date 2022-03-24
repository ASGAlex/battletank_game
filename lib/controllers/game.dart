import 'package:bonfire/bonfire.dart';
import 'package:game/entities/tank/tank.dart' as tank;

import '../entities/environment/spawn.dart';
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

  void addEnemy() async {
    var spawn = await Spawn.waitFree();
    final object = tank.Enemy(position: spawn.position.clone());
    spawn.createTank(object);
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
