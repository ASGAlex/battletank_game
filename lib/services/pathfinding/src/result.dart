part of pathfinding;

@immutable
class PathFindingResult {
  const PathFindingResult(this.currentPath);

  final List<Offset> currentPath;

  cleanPath(List<Offset> oldPath, int currentIndex, Offset position) {
    if (oldPath.isEmpty) return;
    var oldFrom = position;
    final oldTo = oldPath[currentIndex];

    final oldDirection = _getDirectionByCoords(oldFrom, oldTo);
    var actualIndex = -1;
    for (var i = 0; i < currentPath.length; i++) {
      final newFrom = currentPath[i];
      final bounds =
          Rect.fromPoints(position.translate(-8, -8), position.translate(8, 8));
      if (bounds.contains(newFrom)) {
        actualIndex = i;
        continue;
      }

      if (i + 1 == currentPath.length) break;
      final newTo = currentPath[i + 1];
      final newDirection = _getDirectionByCoords(newFrom, newTo);

      if (newFrom.dx > oldFrom.dx) {
        print('!!!!');
      }

      if (newDirection != oldDirection) break;

      switch (newDirection.direction) {
        case Direction.left:
          if (newTo.dx > oldFrom.dx) {
            continue;
          } else {
            actualIndex = i;
            break;
          }
        case Direction.right:
          if (newTo.dx < oldFrom.dx) {
            continue;
          } else {
            actualIndex = i;
            break;
          }
        case Direction.up:
          if (newTo.dy > oldFrom.dy) {
            continue;
          } else {
            actualIndex = i;
            break;
          }
        case Direction.down:
          if (newTo.dy < oldFrom.dy) {
            continue;
          } else {
            actualIndex = i;
            break;
          }
        case Direction.upLeft:
        case Direction.upRight:
        case Direction.downLeft:
        case Direction.downRight:
          throw 'Direction impossible!';
      }
    }
    print(actualIndex);
    if (actualIndex < 0) return;

    for (var i = 0; i <= actualIndex; i++) {
      currentPath.removeAt(0);
    }
  }

  StrengthDirection _getDirectionByCoords(Offset from, Offset to) {
    final diffX = to.dx - from.dx;
    final diffY = to.dy - from.dy;
    var directionStrength = diffX.abs() - diffY.abs();
    Direction direction;
    if (directionStrength > 0) {
      direction = diffX > 0 ? Direction.right : Direction.left;
    } else {
      direction = diffY > 0 ? Direction.down : Direction.up;
    }

    directionStrength =
        1 - min(diffX.abs(), diffY.abs()) / max(diffX.abs(), diffY.abs());

    return StrengthDirection(direction, directionStrength);
  }
}

class StrengthDirection {
  StrengthDirection(this._direction, this._strength);

  final Direction _direction;
  final double _strength;

  Direction get direction => _direction;

  double get strength => _strength;

  @override
  bool operator ==(Object other) {
    if (other is StrengthDirection) {
      return _direction == other._direction;
    }
    if (other is Direction) {
      return _direction == other;
    }
    return false;
  }

  bool? operator >(Object other) {
    if (other is StrengthDirection) {
      return _strength > _strength;
    }
    return null;
  }

  bool? operator <(Object other) {
    if (other is StrengthDirection) {
      return _strength < _strength;
    }
    return null;
  }

  bool? isEqualStrength(StrengthDirection other) {
    return _strength == other._strength;
  }
}
