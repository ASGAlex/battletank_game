library tank;

import 'dart:math';

import 'package:async_task/async_task_extension.dart';
import 'package:bonfire/bonfire.dart' hide Player, Tile;
import 'package:bonfire/bonfire.dart' as bonfire show Player, Tile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game/controllers/game.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

import '../../services/pathfinding/pathfinding.dart';
import '../../ui/joystick.dart';

part 'src/base.dart';
part 'src/bullet.dart';
part 'src/mix/detection.dart';
part 'src/mix/die_explosion.dart';
part 'src/mix/move_to_position_along_the_path.dart';
part 'src/mix/random_fire.dart';
part 'src/mix/random_movement.dart';
part 'src/mix/targeted_movement.dart';
part 'src/npc.dart';
part 'src/player.dart';
