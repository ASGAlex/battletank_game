part of sound;

class Sfx {
  Sfx(this.fileName) {
    try {
      audio.setPlayerMode(PlayerMode.lowLatency);
    } catch (e) {
      print('unsupported');
    }
  }

  String prefrix = '';
  final String fileName;
  final audio = AudioPlayer();

  play() {
    audio.pause();
    audio.play(AssetSource(fileName));
  }

  pause() {
    audio.pause();
  }
}

class SfxLong extends Sfx {
  SfxLong(String fileName) : super(fileName);

  bool isPlaying = false;

  @override
  play() async {
    if (isPlaying) return;
    audio.play(AssetSource(prefrix + fileName));
    isPlaying = true;
  }

  @override
  pause() {
    audio.pause();
    isPlaying = false;
  }
}
