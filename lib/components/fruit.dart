import 'dart:async';
// import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  // ignore: use_super_parameters
  Fruit({
    this.fruit = 'Apple',
    position,
    size,
  }): super(
    position: position,
    size: size,
    removeOnFinish: true,
  );

  bool _collected = false;
  final stepTime = 0.05;
  final CustomHitbox hitbox = CustomHitbox(
    offsetX: 10, 
    offsetY: 10, 
    width: 12, 
    height: 12
  );

  @override
  FutureOr<void> onLoad() {
    priority = 1;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,  // Just to remove colliding with eachother
    ));

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'), 
      SpriteAnimationData.sequenced(
        amount: 17, 
        stepTime: stepTime, 
        textureSize: Vector2.all(32)
      )
    );
    return super.onLoad();
  }

  void collidedWithPlayer() {
    if (!_collected) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'), 
        SpriteAnimationData.sequenced(
          amount: 6, 
          stepTime: stepTime, 
          textureSize: Vector2.all(32),
          loop: false,
        ),
        
      );
      _collected = true;
    }
    // removeFromParent();
  }
}