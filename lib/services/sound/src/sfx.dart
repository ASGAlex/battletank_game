part of sound;

class Sfx {
  Sfx(this.fileName, [this.instances = 1]);

  final String fileName;
  String _prefix = '';

  String get fullPathToAsset => _prefix + fileName;

  final int instances;

  AudioPlayer? _controller;

  AudioPlayer? get controller => _controller;

  AssetSource? _assetSource;

  load(String prefix) {
    _prefix = prefix;
    final cache = AudioCache();
    cache.load(fullPathToAsset);
    _controller = AudioPlayer();
    controller?.setReleaseMode(ReleaseMode.stop);
    _assetSource = AssetSource(fullPathToAsset);
  }

  play() {
    final src = _assetSource;
    if (src != null) {
      _controller?.pause();
      _controller?.play(src);
    }
  }

  pause() {
    _controller?.pause();
  }

  dispose() {
    _controller?.stop();
    _controller?.dispose();
  }
}

class SfxLongLoop extends Sfx {
  SfxLongLoop(String fileName) : super(fileName);

  bool isPlaying = false;

  @override
  load(String prefix) {
    super.load(prefix);
    controller?.setReleaseMode(ReleaseMode.loop);
  }

  @override
  play() async {
    if (isPlaying) return;
    super.play();
    isPlaying = true;
  }

  @override
  pause() {
    controller?.pause();
    isPlaying = false;
  }
}
