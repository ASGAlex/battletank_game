import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:game/services/sound/sound.dart';

class TankGame extends BonfireGame with ScrollDetector, ScaleDetector {
  TankGame({
    required BuildContext context,
    required MapGame map,
    JoystickController? joystickController,
    Player? player,
    GameInterface? interface,
    List<Enemy>? enemies,
    List<GameDecoration>? decorations,
    List<GameComponent>? components,
    GameBackground? background,
    bool? constructionMode,
    bool? showCollisionArea,
    GameController? gameController,
    Color? constructionModeColor,
    Color? collisionAreaColor,
    Color? lightingColorGame,
    bool? showFPS,
    ValueChanged<BonfireGame>? onReady,
    TapInGame? onTapDown,
    TapInGame? onTapUp,
    GameColorFilter? colorFilter,
    CameraConfig? cameraConfig,
  }) : super(
            context: context,
            map: map,
            background: background,
            cameraConfig: cameraConfig,
            collisionAreaColor: collisionAreaColor,
            colorFilter: colorFilter,
            components: components,
            constructionMode: constructionMode ?? false,
            constructionModeColor: constructionModeColor,
            decorations: decorations,
            enemies: enemies,
            gameController: gameController,
            interface: interface,
            joystickController: joystickController,
            lightingColorGame: lightingColorGame,
            onReady: onReady,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            player: player,
            showCollisionArea: showCollisionArea ?? false,
            showFPS: showFPS ?? false);

  static TankGame builder({
    required BuildContext context,
    required MapGame map,
    JoystickController? joystickController,
    Player? player,
    GameInterface? interface,
    List<Enemy>? enemies,
    List<GameDecoration>? decorations,
    List<GameComponent>? components,
    GameBackground? background,
    bool? constructionMode,
    bool? showCollisionArea,
    GameController? gameController,
    Color? constructionModeColor,
    Color? collisionAreaColor,
    Color? lightingColorGame,
    bool? showFPS,
    ValueChanged<BonfireGame>? onReady,
    TapInGame? onTapDown,
    TapInGame? onTapUp,
    GameColorFilter? colorFilter,
    CameraConfig? cameraConfig,
  }) =>
      TankGame(
          context: context,
          map: map,
          background: background,
          cameraConfig: cameraConfig,
          collisionAreaColor: collisionAreaColor,
          colorFilter: colorFilter,
          components: components,
          constructionMode: constructionMode ?? false,
          constructionModeColor: constructionModeColor,
          decorations: decorations,
          enemies: enemies,
          gameController: gameController,
          interface: interface,
          joystickController: joystickController,
          lightingColorGame: lightingColorGame,
          onReady: onReady,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          player: player,
          showCollisionArea: showCollisionArea ?? false,
          showFPS: showFPS ?? false);

  static const zoomPerScrollUnit = 0.02;
  late double startZoom;

  @override
  void onScroll(PointerScrollInfo info) {
    camera.zoom += info.scrollDelta.game.y.sign * zoomPerScrollUnit;
    clampZoom();
  }

  @override
  void onScaleStart(_) {
    startZoom = camera.zoom;
  }

  void clampZoom() {
    camera.zoom = camera.zoom.clamp(0.05, 5.0);
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    camera.zoom = startZoom * currentScale.y;
    clampZoom();
  }

  @override
  Future<void>? onLoad() async {
    final sound = Sound();
    sound.playMusic('intro.m4a');
    final sfxList = [
      () => SfxLongLoop('move_player.m4a'),
      () => SfxLongLoop('move_enemies.m4a'),
      () => Sfx('explosion_player.m4a', 2),
      () => Sfx('explosion_enemy.m4a', 3),
      () => Sfx('player_fire_bullet.m4a', 10),
      () => Sfx('player_bullet_wall.m4a', 10),
    ];
    sound.init(sfxList);
    return super.onLoad();
  }
}
