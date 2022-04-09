library sound;

import 'package:kplayer/kplayer.dart';

part 'src/sfx.dart';

class Sound {
  static final Sound _instance = Sound._();

  Sound._();

  factory Sound() {
    return _instance;
  }

  final Map<String, Sfx> _sfx = {};

  Sfx? sfx(String name) => _sfx[name];

  init(List<Sfx> preloadSfx) {
    for (final sfx in preloadSfx) {
      final key = sfx.fileName.replaceAll('.mp3', '').replaceAll('/', '_');
      _sfx[key] = sfx;
      sfx.load('assets/audio/sfx/');
    }
  }

  playMusic(String fileName) {
    Player.asset("assets/audio/music/$fileName").play();
  }

  dispose() {
    for (final entry in _sfx.entries) {
      entry.value.controller?.stop();
      entry.value.controller?.dispose();
    }
    _sfx.clear();
  }
}
