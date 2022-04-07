part of tank;

mixin _TargetedMovement on _BaseTank, Movement, ObjectCollision {
  Vector2? _lastKnownTargetPosition;
  Vector2? _previousTargetPosition;

  bool get noTarget => _lastKnownTargetPosition == null;
  bool get hasTarget => !noTarget;

  Vector2? get lastKnownTargetPosition => _lastKnownTargetPosition;

  set lastKnownTargetPosition(Vector2? newPosition) {
    _previousTargetPosition = _lastKnownTargetPosition?.clone();
    _lastKnownTargetPosition = newPosition;
  }

  bool _calculationInProgress = false;
  bool showLinePath = true;

  List<Offset> _currentPath = [];
  int _currentIndex = 0;

  Offset get currentOffset => _currentPath[_currentIndex];
  bool get hasRoute => _currentPath.isNotEmpty;
  bool get noRoute => !hasRoute;

  /// не обновляем маршрут, если:
  ///  - Цель не двигалась
  ///  - Предыдущее обновление уже в процессе
  Future<bool> updateRoute() async {
    if (_calculationInProgress) return Future.value(false);
    if (isTargetNotMoved && hasRoute) return Future.value(false);
    _calculationInProgress = true;
    final mapSize = gameRef.map.getMapSize();
    print('calc!');
    final parameters = PathFindingParameters.fromObjectCollision(
      ignoreCollisions: _ignoredCollisions,
      collisions: gameRef.map.getCollisions(),
      finalPosition: _lastKnownTargetPosition!,
      positionPlayer: rectCollision.center.toVector2(),
      gameSize: Vector2(mapSize.width, mapSize.height),
      tileSize: _tileSize,
    );
    final result =
        await PathfindingService().runTask(parameters).catchError((_) {
      _calculationInProgress = true;
    });
    _currentPath = _removeRepeatingPoints(result);
    _currentIndex = 0;
    _calculationInProgress = false;
    if (showLinePath) {
      gameRef.map.setLinePath(_currentPath, Colors.red.withOpacity(0.7), 1);
    }
    print('finished!');
    return _currentPath.isNotEmpty;
  }

  /// Достаточно ли передвинулась цель? Если изменение позиции меньше,
  /// чем на длину корпуса, то считаем, что цель стоит на месте.
  bool get isTargetMoved {
    if (_lastKnownTargetPosition == null && _previousTargetPosition != null) {
      return false;
    }

    if (_previousTargetPosition != null) {
      final distance =
          _previousTargetPosition!.distanceTo(_lastKnownTargetPosition!);

      return distance < max(size.x, size.y);
    }
    return false;
  }

  bool get isTargetNotMoved => !isTargetMoved;

  List<ObjectCollision> get _ignoredCollisions {
    final ignoreCollisionsWith = <ObjectCollision>[];
    ignoreCollisionsWith.add(gameRef.player as ObjectCollision);
    for (var element in myBullets) {
      ignoreCollisionsWith.add(element);
    }
    return ignoreCollisionsWith;
  }

  double get _tileSize {
    if (gameRef.map.tiles.isNotEmpty) {
      return gameRef.map.tiles.first.width;
    }
    throw ArgumentError('No tiles in map');
  }

  /// Область, в пределах которой считаем, что новая точка маршрута повторяет
  /// старую
  double get _repeatingDetectionTreshold => _tileSize * 10;

  /// Проверяем, если новые точки маршрута лежат там же, где и старые, то
  /// удаляем их. Позволяет избежать бага, при котором танк возвращается назад
  /// при обновлении маршрута во время движения.
  List<Offset> _removeRepeatingPoints(PathFindingResult result) {
    try {
      var compareWithIndex = -1;
      final currentTarget = _currentPath[_currentIndex].toVector2();
      for (var index = 0; index < result.currentPath.length; index++) {
        final plannedPos = result.currentPath[index].toVector2();
        if (plannedPos.distanceTo(currentTarget) <
            _repeatingDetectionTreshold) {
          compareWithIndex = index;
          break;
        }
      }

      if (compareWithIndex > 0) {
        final pointCompareWith =
            result.currentPath[compareWithIndex].toVector2();
        for (var index = 0; index < result.currentPath.length; index++) {
          if (index >= compareWithIndex) {
            break;
          }
          final plannedPos = result.currentPath[index].toVector2();
          if (plannedPos.distanceTo(pointCompareWith) >
              currentTarget.distanceTo(pointCompareWith)) {
            result.currentPath.removeAt(index);
            index--;
            compareWithIndex--;
          }
        }
      }
      return result.currentPath;
    } catch (e) {
      return result.currentPath;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_currentPath.isNotEmpty) {
      _move(dt);
    }
  }

  void _move(double dt) {
    double innerSpeed = speed * dt;

    double diffX = currentOffset.dx - center.x;
    double diffY = currentOffset.dy - center.y;
    double displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    double displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.01 && diffY.abs() < 0.01) {
      _goToNextPosition();
    } else {
      bool onMove = false;

      if (diffX.abs() > 0.01) {
        if (diffX > 0) {
          onMove = moveRight(displacementX);
        } else if (diffX < 0) {
          onMove = moveLeft(displacementX);
        }
      } else if (diffY.abs() > 0.01) {
        if (diffY > 0) {
          onMove = moveDown(displacementY);
        } else if (diffY < 0) {
          onMove = moveUp(displacementY);
        }
      }

      if (!onMove) {
        // _goToNextPosition();
      }
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is TileWithCollision) {
      final vector = center - component.center;
      final limit = 0.5; // component.rectCollision.width / 2;
      if (vector.x.abs() > limit) {
        vector.x = limit * (vector.x > 0 ? 1 : -1);
      }
      if (vector.y.abs() > limit) {
        vector.y = limit * (vector.y > 0 ? 1 : -1);
      }
      position = position.translate(vector.x, vector.y);
    }
    return super.onCollision(component, active);
  }

  void _goToNextPosition() {
    if (_currentIndex < _currentPath.length - 1) {
      _currentIndex++;
    } else {
      _currentPath.clear();
      _currentIndex = 0;
      _lastKnownTargetPosition = null;
      idle();
    }
  }
}
