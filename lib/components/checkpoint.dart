import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks  {
  // ignore: use_super_parameters
  Checkpoint({
    super.position, 
    super.size
  });

  final CustomHitbox hitbox = CustomHitbox(
    offsetX: 18, 
    offsetY: 28, 
    width: 11, 
    height: 36
  );

  bool reachedCheckpoint = false;


  @override
  FutureOr<void> onLoad() {
    debugMode = true;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive
    ));

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'), 
      SpriteAnimationData.sequenced(
        amount: 1, 
        stepTime: 1, 
        textureSize: Vector2.all(64)
      )
    );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {

    if (other is Player && !reachedCheckpoint) _reachedCheckpoint();

    super.onCollision(intersectionPoints, other);
  }
  
  void _reachedCheckpoint() async {

    reachedCheckpoint = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );

    await animationTicker?.completed;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );
  }


}