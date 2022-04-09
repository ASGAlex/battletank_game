part of sound;

class Sfx {
  Sfx(this.fileName) {
    audio.audioCache.prefix = Sound().prefix;
  }

  final String fileName;
  final audio = AudioPlayer();

  play() {
    audio.audioCache.prefix = Sound().prefix;
    audio.play(AssetSource(fileName));
  }

  pause() {
    audio.pause();
  }
}
