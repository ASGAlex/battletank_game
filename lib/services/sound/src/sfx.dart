part of sound;

class Sfx {
  Sfx(this.fileName);

  final String fileName;

  PlayerController? _controller;

  PlayerController? get controller => _controller;

  load(String prefix) {
    _controller = Player.asset(prefix + fileName);
  }

  play() {
    _controller?.pause();
    _controller?.play();
  }

  pause() {
    _controller?.pause();
  }
}

class SfxLongLoop extends Sfx {
  SfxLongLoop(String fileName) : super(fileName);

  bool isPlaying = false;

  @override
  load(String prefix) {
    super.load(prefix);
    controller?.loop = true;
  }

  @override
  play() async {
    if (isPlaying) return;
    controller?.play();
    isPlaying = true;
  }

  @override
  pause() {
    controller?.pause();
    isPlaying = false;
  }
}
