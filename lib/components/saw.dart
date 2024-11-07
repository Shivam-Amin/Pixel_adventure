import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure>  {
  final bool isVertical;
  final double offNegative;
  final double offPositive;
  // ignore: use_super_parameters
  Saw({
    this.isVertical = false,
    this.offNegative = 0.0,
    this.offPositive = 0.0,
    position, 
    size
  }): super(
    position: position, 
    size: size
  );
  
  final sawSpeed = 0.03;
  static const moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;      // just to take care of left-right/up-down symultaniouslly.
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    debugMode = true;
    add(CircleHitbox());

    if (isVertical) {
      rangeNeg = position.y - tileSize * offNegative;
      rangePos = position.y + tileSize * offPositive;
    } else {
      rangeNeg = position.x - tileSize * offNegative;
      rangePos = position.x + tileSize * offPositive;
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'), 
      SpriteAnimationData.sequenced(
        amount: 8, 
        stepTime: sawSpeed, 
        textureSize: Vector2.all(38)
      )
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }
  
  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }
  
  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }


}