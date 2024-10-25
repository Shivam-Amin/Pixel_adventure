import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

// import 'package:flame/input.dart';
// import 'package:flutter/src/services/hardware_keyboard.dart';
// import 'package:flutter/src/services/keyboard_key.g.dart';
// import 'package:flutter/src/widgets/focus_manager.dart';

import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {idel, running}
enum PlayerDirection {left, right, idel}

class Player extends SpriteAnimationGroupComponent 
    with HasGameRef<PixelAdventure>, KeyboardHandler {


  String character;
  // ignore: use_super_parameters
  Player({ this.character = 'Mask Dude', position}): super(position: position);


  late final SpriteAnimation idelAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  // Player properties
  PlayerDirection playerDirection = PlayerDirection.idel;
  final double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {

    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  // For macos this code crates macos's ding sound on key pressing so,
  // I've used another approch below it.
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {

    // Handle key down events only
    // if (event is KeyDownEvent) {
      bool isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA);
      bool isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD);

      if (isLeftKeyPressed && isRightKeyPressed) {
        playerDirection = PlayerDirection.idel;
      } else if (isLeftKeyPressed) {
        playerDirection = PlayerDirection.left;
      } else if (isRightKeyPressed) {
        playerDirection = PlayerDirection.right;
      } else {
        playerDirection = PlayerDirection.idel;
      }
      // Returning true here ensures the event is consumed and prevents the beep
    //   return true;
    // } 

    // If it's not a KeyDownEvent, pass the event to the parent handler
    return super.onKeyEvent(event, keysPressed);
  }
  
  
  
  void _loadAllAnimations() {
    idelAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);

    // assign animations to spriteAnimations's animations
    animations = {
      PlayerState.idel: idelAnimation,
      PlayerState.running: runningAnimation
    };

    // current state of spriteAnimation is set to idel
    current = PlayerState.idel;
  }

  SpriteAnimation _spriteAnimation(String state, int frameAmount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'), 
      SpriteAnimationData.sequenced(
        amount: frameAmount, 
        stepTime: stepTime, 
        textureSize: Vector2(32, 32)
      ),
    );
  }
  
  void _updatePlayerMovement(double dt) {
    double dx = 0.0;

    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dx -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dx += moveSpeed;
        break;
      case PlayerDirection.idel:
        current = PlayerState.idel;
        break;
      default:
    }

    // set player velocity and position
    velocity = Vector2(dx, 0.0);
    position += velocity * dt;
  }


}