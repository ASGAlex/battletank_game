part of tank;

mixin _RandomFire on _BaseTankMix {
  bool _randomFire = false;

  Duration get maxRandomInterval => fireInterval * 5;

  bool get randomFire => _randomFire;

  set randomFire(bool enabled) {
    if (!_randomFire && enabled) {
      _fireScheduled = false;
    }
    _randomFire = enabled;
  }

  bool _fireScheduled = false;

  @override
  void update(double dt) {
    if (_randomFire && !_fireScheduled) {
      _fireScheduled = true;
      final rnd = Random();
      Duration nextInterval =
          Duration(milliseconds: rnd.nextInt(maxRandomInterval.inMilliseconds));
      Future.delayed(nextInterval).then((value) {
        tryFire();
        _fireScheduled = false;
      });
    }
    super.update(dt);
  }
}
