library sound;

import 'package:audioplayers/audioplayers.dart';

part 'src/sfx.dart';

class Sound {
  static final Sound _instance = Sound._();

  Sound._() {
    AudioCache.instance = AudioCache(prefix: prefix);
  }

  final String prefix = 'assets/audio/sfx/';

  factory Sound() {
    return _instance;
  }

  final Map<String, Sfx> _sfx = {};

  Sfx? sfx(String name) => _sfx[name];

  init(List<Sfx> preloadSfx) {
    final sfxFiles = <String>[];
    for (final sfx in preloadSfx) {
      final key = sfx.fileName.replaceAll('.mp3', '').replaceAll('/', '_');
      _sfx[key] = sfx;
      sfxFiles.add(sfx.fileName);
    }
    AudioCache.instance.loadAll(sfxFiles);
  }

  playMusic(String fileName) {
    final player = AudioPlayer();
    player.audioCache.prefix = 'assets/audio/music/';
    player.play(AssetSource(fileName));
  }
}
