library tank;

import 'dart:math';

import 'package:bonfire/bonfire.dart' hide Player, Tile;
import 'package:bonfire/bonfire.dart' as bonfire show Player, Tile;
import 'package:flutter/material.dart';
import 'package:game/controllers/game.dart';
import 'package:game/services/spritesheet/spritesheet.dart';

import '../../services/pathfinding/pathfinding.dart';
import '../../ui/joystick.dart';
import '../environment/tree.dart';

part 'src/base.dart';
part 'src/bullet.dart';
part 'src/enemy.dart';
part 'src/move_to_position_along_the_path.dart';
part 'src/player.dart';
