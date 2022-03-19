import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:async_task/async_task.dart';
import 'package:async_task/async_task_extension.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';

List<AsyncTask> _taskTypeRegister() => [_PathfindingTask.getType()];

class PathfindingService {
  static final PathfindingService _singleton = PathfindingService._internal();

  factory PathfindingService() {
    return _singleton;
  }

  PathfindingService._internal() {
    asyncExecutor = AsyncExecutor(
      sequential: false,
      parallelism: 8,
      taskTypeRegister: _taskTypeRegister,
    );
    asyncExecutor.logger.enabled = true;
  }

  Future<PathFindingResult> runTask(PathFindingParameters params) =>
      asyncExecutor.execute(_PathfindingTask(params));

  late AsyncExecutor asyncExecutor;
}

@immutable
class PathFindingParameters {
  const PathFindingParameters(
      {required this.ignoreCollisions,
      required this.showBarriers,
      required this.gridSizeIsCollisionSize,
      required this.tileSize,
      required this.gameSize,
      required this.positionPlayer,
      required this.finalPosition,
      required this.collisions});

  factory PathFindingParameters.fromObjectCollision(
      {required List ignoreCollisions,
      required bool showBarriers,
      required bool gridSizeIsCollisionSize,
      required double tileSize,
      required Vector2 gameSize,
      required Vector2 positionPlayer,
      required Vector2 finalPosition,
      required Iterable<ObjectCollision> collisions}) {
    final vc = <_RectCollision>[];
    final ic = <_RectCollision>[];
    for (var collision in collisions) {
      final rect = _RectCollision(collision);
      vc.add(rect);
      for (var ignore in ignoreCollisions) {
        if (collision == ignore) {
          ic.add(rect);
        }
      }
    }
    return PathFindingParameters(
        ignoreCollisions: ic,
        showBarriers: showBarriers,
        gridSizeIsCollisionSize: gridSizeIsCollisionSize,
        finalPosition: finalPosition,
        positionPlayer: positionPlayer,
        gameSize: gameSize,
        tileSize: tileSize,
        collisions: vc);
  }

  final List ignoreCollisions;
  final bool showBarriers;
  final bool gridSizeIsCollisionSize;
  final double tileSize;
  final Vector2 gameSize;
  final Vector2 positionPlayer;
  final Vector2 finalPosition;
  final Iterable<RectCollisionInterface> collisions;
}

@immutable
class PathFindingResult {
  const PathFindingResult(this.currentPath);

  final List<Offset> currentPath;
}

abstract class RectCollisionInterface {
  Rect get rectCollision;
}

@immutable
class _RectCollision implements RectCollisionInterface {
  _RectCollision(ObjectCollision object) {
    if (object.rectCollision == Rect.zero) {
      object.update(0);
    }
    _rect = object.rectCollision;
  }

  late final Rect _rect;

  @override
  Rect get rectCollision => _rect;
}

class _PathfindingTask
    extends AsyncTask<PathFindingParameters, PathFindingResult> {
  _PathfindingTask(this.params);

  _PathfindingTask.getType()
      : params = PathFindingParameters(
            finalPosition: Vector2.zero(),
            showBarriers: false,
            tileSize: 0,
            positionPlayer: Vector2.zero(),
            gridSizeIsCollisionSize: false,
            gameSize: Vector2.zero(),
            collisions: [],
            ignoreCollisions: []);

  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  final PathFindingParameters params;
  List<Offset> _currentPath = [];
  final List<Offset> _barriers = [];

  @override
  AsyncTaskChannel? channelInstantiator() => AsyncTaskChannel();

  void _calculatePath() {
    Offset playerPosition =
        _getCenterPositionByTile(params.positionPlayer, params.tileSize);

    Offset targetPosition =
        _getCenterPositionByTile(params.finalPosition, params.tileSize);

    _barriers.clear();

    for (var e in params.collisions) {
      if (!params.ignoreCollisions.contains(e)) {
        _addCollisionOffsetsPositionByTile(e.rectCollision, params.tileSize);
      }
    }

    Iterable<Offset> result = [];

    if (_barriers.contains(targetPosition)) {
      _stopMoveAlongThePath();
      return;
    }

    try {
      result = AStar(
              rows: params.gameSize.x ~/ (params.tileSize) + 1,
              columns: params.gameSize.y ~/ (params.tileSize) + 1,
              start: playerPosition,
              end: targetPosition,
              barriers: _barriers,
              withDiagonal: false)
          .findThePath();

      if (result.isNotEmpty || _isNeighbor(playerPosition, targetPosition)) {
        result = AStar.resumePath(result);
        _currentPath = result.map((e) {
          final tileSize = params.tileSize;
          return Offset(e.dx * tileSize, e.dy * tileSize)
              .translate(tileSize / 2, tileSize / 2);
        }).toList();
        _currentPath.removeAt(0);
      }
    } catch (e) {
      print('ERROR(AStar):$e');
    }
  }

  bool _isNeighbor(Offset playerPosition, Offset targetPosition) {
    if ((playerPosition.dx - targetPosition.dx).abs() == 1) {
      return true;
    }
    if ((playerPosition.dy - targetPosition.dy).abs() == 1) {
      return true;
    }
    return false;
  }

  void _addCollisionOffsetsPositionByTile(Rect rect, double tileSize) {
    final leftTop = Offset(
      ((rect.left / tileSize).floor() * tileSize),
      ((rect.top / tileSize).floor() * tileSize),
    );

    List<Rect> grid = [];
    int countColumns = (rect.width / tileSize).ceil() + 1;
    int countRows = (rect.height / tileSize).ceil() + 1;

    List.generate(countRows, (r) {
      List.generate(countColumns, (c) {
        grid.add(Rect.fromLTWH(
          leftTop.dx +
              (c * tileSize) +
              REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
          leftTop.dy +
              (r * tileSize) +
              REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
          tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
          tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
        ));
      });
    });

    List<Rect> listRect = grid.where((element) {
      return rect.overlaps(element);
    }).toList();

    final result = listRect.map((e) {
      return Offset(
        (e.center.dx / tileSize).floorToDouble(),
        (e.center.dy / tileSize).floorToDouble(),
      );
    }).toList();

    for (var element in result) {
      if (!_barriers.contains(element)) {
        _barriers.add(element);
      }
    }
  }

  Offset _getCenterPositionByTile(Vector2 center, double tileSize) {
    return Offset(
      (center.x / tileSize).floor().toDouble(),
      (center.y / tileSize).floor().toDouble(),
    );
  }

  void _stopMoveAlongThePath() {
    _currentPath.clear();
  }

  @override
  FutureOr<PathFindingResult> run() async {
    var channel = channelResolved()!;

    _calculatePath();

    return PathFindingResult(_currentPath);
  }

  @override
  AsyncTask<PathFindingParameters, PathFindingResult> instantiate(
          PathFindingParameters parameters,
          [Map<String, SharedData>? sharedData]) =>
      _PathfindingTask(parameters);

  @override
  PathFindingParameters parameters() => params;
}
