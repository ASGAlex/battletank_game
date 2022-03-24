part of spritesheet;

class _Boom extends _SpriteSheetBase {
  _Boom() : super() {
    compileAnimation(
      name: 'boom',
      stepTime: 0.1,
    );
  }

  @override
  String get fileName => 'spritesheets/boom.png';

  @override
  Vector2 get spriteSize => Vector2.all(16);

  Future<SpriteAnimation> get animation => getPrecompiledAnimation('boom');
}

class _BoomBig extends _SpriteSheetBase {
  _BoomBig() : super() {
    compileAnimation(
      name: 'boom',
      stepTime: 0.1,
    );
  }

  @override
  String get fileName => 'spritesheets/boom_big.png';

  @override
  Vector2 get spriteSize => Vector2.all(32);

  Future<SpriteAnimation> get animation => getPrecompiledAnimation('boom');
}

class _TankBasic extends _SpriteSheetBase {
  _TankBasic() : super() {
    compileAnimation(
      name: 'run',
      stepTime: 0.2,
    );
    compileAnimation(
      name: 'idle',
      from: 0,
      to: 1,
      stepTime: 10,
    );
  }

  @override
  String get fileName => 'spritesheets/tank_basic.png';

  @override
  Vector2 get spriteSize => Vector2(13, 13);

  Future<SpriteAnimation> get animationRun => getPrecompiledAnimation('run');

  Future<SpriteAnimation> get animationIdle => getPrecompiledAnimation('idle');
}

class _Bullet extends _SpriteSheetBase {
  _Bullet() : super() {
    compileAnimation(
      name: 'basic',
      stepTime: 0.1,
    );
  }

  @override
  String get fileName => 'spritesheets/bullet.png';

  @override
  Vector2 get spriteSize => Vector2(4, 3);

  Future<SpriteAnimation> get animation => getPrecompiledAnimation('basic');
}

class _Ground extends _SpriteSheetBase {
  _Ground() : super() {
    compileAnimation(name: 'grass', stepTime: 1, from: 0, to: 1);
    compileAnimation(name: 'dirt', stepTime: 1, from: 1, to: 2);
    compileAnimation(name: 'ash', stepTime: 1, from: 2, to: 3);
  }

  @override
  String get fileName => 'ground_tiles.png';

  @override
  Vector2 get spriteSize => Vector2.all(8);

  Future<Sprite> get dirt => getPrecompiledAnimation('dirt')
      .then((value) => value.frames.first.sprite);

  Future<Sprite> get grass => getPrecompiledAnimation('grass')
      .then((value) => value.frames.first.sprite);

  Future<Sprite> get ash =>
      getPrecompiledAnimation('ash').then((value) => value.frames.first.sprite);
}

class _Spawn extends _SpriteSheetBase {
  _Spawn() : super() {
    compileAnimation(name: 'basic', stepTime: 0.09, loop: false);
  }
  @override
  String get fileName => 'spritesheets/spawn.png';

  @override
  Vector2 get spriteSize => Vector2(15, 15);

  Future<SpriteAnimation> get animation => getPrecompiledAnimation('basic');
}
