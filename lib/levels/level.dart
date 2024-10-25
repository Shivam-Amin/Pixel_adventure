import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';

// world contains all level loadings, cordinates, cams and 
// World extends components that manages all key binds and stuff.
class Level extends World {
  late final String levelname;
  Level({required this.levelname});
  
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {

    level = await TiledComponent.load('$levelname.tmx', Vector2.all(16));

    add(level);

    // ignore: non_constant_identifier_names
    final SpawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final spawnPoint in SpawnPointLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          final player = Player(character: 'Mask Dude', 
            position: Vector2(spawnPoint.x, spawnPoint.y)
          );

          add(player);
          break;

        default:
      }
    }
    

    return super.onLoad();
  }
}