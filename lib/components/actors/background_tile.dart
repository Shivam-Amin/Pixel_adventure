import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({
    this.color = 'Gray', 
    position
  }) : super(
    position: position
  );

  final scrollSpeed = 0.4;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    size = Vector2.all(64.6); // .6 is just to remove extra lines coming while adding multiple of images.
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    double tileSize = 64;

    // whenever sprite reach the max height of game
    // reposition it to 0 - tilesize, to maintain the flow.
    int scrollHeight = (game.size.y / tileSize).floor();

    if (position.y > scrollHeight * tileSize) {
      position.y = -tileSize;
    } 

    super.update(dt);
  }
}