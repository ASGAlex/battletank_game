library sound;

import 'package:kplayer/kplayer.dart';

part 'src/sfx.dart';

typedef SfxBuilder = Sfx Function();

class Sound {
  static final Sound _instance = Sound._();

  Sound._();

  factory Sound() {
    return _instance;
  }

  final Map<String, SfxBuilder> _sfxBuilders = {};
  final Map<String, List<Sfx>> _sfxInstances = {};
  final Map<String, int> _sfxInstancesCounter = {};

  Sfx? createSfx(String name) {
    final sfx = _sfxBuilders[name]?.call();
    if (sfx != null) {
      sfx.load('assets/audio/sfx/');
    }
    return sfx;
  }

  Sfx? sfx(String name) {
    var currentPos = _sfxInstancesCounter[name];
    final listOfInstances = _sfxInstances[name];
    if (currentPos == null || listOfInstances == null) {
      throw 'Sfx $name does not exists';
    }
    final instance = listOfInstances[currentPos];
    currentPos++;
    if (currentPos == listOfInstances.length) {
      currentPos = 0;
    }
    _sfxInstancesCounter[name] = currentPos;
    return instance;
  }

  init(List<SfxBuilder> preloadSfx) {
    for (final sfx in preloadSfx) {
      final sfxTemp = sfx.call();
      final key = sfxTemp.fileName
          .replaceAll('.mp3', '')
          .replaceAll('.ogg', '')
          .replaceAll('/', '_');
      _sfxBuilders[key] = sfx;

      _sfxInstances[key] = [];
      _sfxInstancesCounter[key] = 0;
      for (var i = 0; i < sfxTemp.instances; i++) {
        final newSfx = createSfx(key);
        if (newSfx != null) {
          _sfxInstances[key]?.add(newSfx);
        }
      }
    }
  }

  playMusic(String fileName) {
    Player.asset("assets/audio/music/$fileName").play();
  }
}
