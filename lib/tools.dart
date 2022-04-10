import 'package:game/services/sound/sound.dart';

extension Shortcuts on Sound {
  Sfx get movePlayer => sfx('move_player')!;
  Sfx get moveEnemies => sfx('move_enemies')!;
  Sfx get explosionPlayer => sfx('explosion_player')!;
  Sfx get playerFireBullet => sfx('player_fire_bullet')!;
  Sfx get playerBulletWall => sfx('player_bullet_wall')!;
  Sfx get playerBulletStrongWall => sfx('player_bullet_strong_wall')!;
  Sfx get bulletStrongTank => sfx('bullet_strong_tank')!;
  Sfx get explosionEnemy => sfx('explosion_enemy')!;
}
