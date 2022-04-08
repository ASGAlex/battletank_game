import 'package:args/args.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:game/entities/environment/spawn.dart';
import 'package:game/services/game.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

import 'controllers/game.dart';
import 'entities/environment/brick.dart';
import 'entities/environment/target.dart';
import 'entities/environment/tree.dart';
import 'ui/joystick.dart';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption('map',
      defaultsTo:
          const String.fromEnvironment("map", defaultValue: 'classic.json'));
  final results = parser.parse(args);
  final map = results['map'];

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RayWorld',
    home: MainGame(map),
  ));
}

class MainGame extends StatelessWidget {
  final GameController _notificator = GameController();
  final MyGameController _controller = MyGameController();

  MainGame(this.map, {Key? key}) : super(key: key);

  final String map;

  @override
  Widget build(BuildContext context) {
    SpriteSheetRegistry(); //warm up entities
    return BonfireTiledWidget(
      customGameBuilder: TankGame.builder,
      gameController: _notificator..addListener(_controller),
      joystick: MyJoystick(),
      // required
      map: TiledWorldMap(map, tileBuilder: {
        'brick': (props, position, offset) => Brick(
            sprite: props.sprite!.getSprite(),
            position: position,
            collisions: props.collisions),
      }, decorationBuilder: {
        'tree': (props, position, offset) => Tree(
            sprite: props.sprite!.getFutureSprite(),
            position: position,
            collisions: props.collisions),
      }, objectsBuilder: {
        'spawn': (props) => Spawn.withAnimation(position: props.position),
        'spawn_player': (props) =>
            Spawn.withAnimation(position: props.position, isForPlayer: true),
        'target': (props) =>
            Target.withSprite(position: props.position, size: props.size),
      }),
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
        // target: player,
        // smoothCameraEnabled: true,
        sizeMovementWindow: Vector2(16 * 10, 16 * 10),
        moveOnlyMapArea: true,
        zoom: 3,
        // here you can set the default zoom for the camera. You can still zoom directly on the camera
        // target: GameComponent(),
      ),
      showFPS: true,
      onReady: (game) async {
        _controller.init(game);
        await _controller.restorePlayer();
        await _controller.addEnemy();
        await _controller.addEnemy();
        await _controller.addEnemy();
        await _controller.addEnemy();
        await _controller.addEnemy();
        await _controller.addEnemy();
      },
      colorFilter: GameColorFilter(),
    );
  }
}
