import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:game/entities/tank/tank.dart' as tank;
import 'package:game/services/spritesheet/spritesheet.dart';

import 'controllers/game.dart';
import 'entities/environment/brick.dart';
import 'entities/environment/tree.dart';
import 'ui/joystick.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RayWorld',
    home: MainGame(),
  ));
}

class MainGame extends StatelessWidget {
  final GameController _notificator = GameController();
  final MyGameController _controller = MyGameController();

  MainGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SpriteSheetRegistry(); //warm up entities
    final player = tank.Player(position: Vector2(30 * 8, 16 * 8));
    return BonfireTiledWidget(
      gameController: _notificator..addListener(_controller),
      joystick: MyJoystick(),
      // required
      map: TiledWorldMap('mapnew.json', tileBuilder: {
        'brick': (props, position, offset) => Brick(
            sprite: props.sprite!.getSprite(),
            position: position,
            collisions: props.collisions),
      }, decorationBuilder: {
        'tree': (props, position, offset) => Tree(
            sprite: props.sprite!.getFutureSprite(),
            position: position,
            collisions: props.collisions),
      }),
      // required
      player: player,
      // If player is omitted, the joystick directional will control the map view, being very useful in the process of building maps
      // interface: KnightInterface(),
      // decorations: <GameDecoration>[],
      // enemies: <Enemy>[],
      // background: GameComponent(),
      // to color you can use `BackgroundColorGame(Colors.blue)` or create your own background (to use parallax for example) extending from `GameComponent`
      constructionMode: false,
      // If true, activates hot reload to ease the map constructions and draws the grid
      showCollisionArea: false,
      // If true, show collision area of the elements
      constructionModeColor: Colors.blue,
      // If you wan customize the grid color.
      collisionAreaColor: Colors.blue,
      // If you wan customize the collision area color.
      lightingColorGame: Colors.black.withOpacity(0.4),
      // if you want to add general lighting for the game
      cameraConfig: CameraConfig(
        target: player,
        smoothCameraEnabled: true,
        sizeMovementWindow: Vector2(16 * 10, 16 * 10),
        moveOnlyMapArea: true,
        zoom: 3,
        // here you can set the default zoom for the camera. You can still zoom directly on the camera
        // target: GameComponent(),
      ),
      showFPS: true,
      onReady: (game) {
        game.camera.snapTo(Vector2(46 * 8, 46 * 8));
        _controller.init(game);
        _controller.addEnemy(Vector2(46 * 8, 46 * 8));
      },
      colorFilter: GameColorFilter(),
    );
  }
}
