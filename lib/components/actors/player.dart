import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/levels/collision_block.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idel, running, jumping, falling, hit, appearing, disappearing }

// enum PlayerDirection {left, right, idel}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {


  String character;
  // ignore: use_super_parameters
  Player({ 
    this.character = 'Mask Dude', 
    position
  }): super(position: position);


  late final SpriteAnimation idelAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;
  final double stepTime = 0.05;

  final double _gravity = 9.8;
  final double _jumpForce = 360;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0.0;
  final double moveSpeed = 100;
  Vector2 startingPosition = Vector2.all(0);
  Vector2 velocity = Vector2.zero();
  // bool isFacingRight = true;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10, 
    offsetY: 4, 
    width: 14, 
    height: 28
  );

  @override
  FutureOr<void> onLoad() {

    _loadAllAnimations();
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _verticleCollisions();
    }
    super.update(dt);
  }
  
  

  // For macos this code crates macos's ding sound on key pressing so,
  // I've used another approch below it.
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0.0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    // log('lskdjfaljdkflakjdflk');
    // If it's not a KeyDownEvent, pass the event to the parent handler
    // return super.onKeyEvent(event, keysPressed);
    
    // If it's not a KeyDownEvent, pass the event to the parent handler
    return false;
    // return true;
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Checkpoint && !reachedCheckpoint) _reachedCheckpoint();
    }

    super.onCollision(intersectionPoints, other);
  }
  
  
  void _loadAllAnimations() {
    idelAnimation = _spriteAnimation(state: 'Idle', frameAmount: 11);
    runningAnimation = _spriteAnimation(state: 'Run',frameAmount: 12);
    jumpingAnimation = _spriteAnimation(state: 'Jump',frameAmount: 1);
    fallingAnimation = _spriteAnimation(state: 'Fall',frameAmount: 1);
    hitAnimation = _spriteAnimation(state: 'Hit',frameAmount: 7, loop: false);
    appearingAnimation = _specialSpriteAnimation(state: 'Appearing',frameAmount: 7, loop: false);
    disappearingAnimation = _specialSpriteAnimation(state: 'Desappearing',frameAmount: 7, loop: false);

    // assign animations to spriteAnimations's animations
    animations = {
      PlayerState.idel: idelAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // current state of spriteAnimation is set to idel
    current = PlayerState.idel;
  }

  SpriteAnimation _spriteAnimation({
    required String state, 
    required int frameAmount, 
    bool loop = true
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'), 
      SpriteAnimationData.sequenced(
        amount: frameAmount, 
        stepTime: stepTime, 
        textureSize: Vector2(32, 32),
        loop: loop
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation({
    required String state, 
    required int frameAmount, 
    bool loop = true
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'), 
      SpriteAnimationData.sequenced(
        amount: frameAmount, 
        stepTime: stepTime, 
        textureSize: Vector2(96, 96),
        loop: loop
      ),
    );
  }
  
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idel;

    // the sprite is scaled from top left corner as per the tilmap.
    // so through scale we can calculate where the player is facing right now.
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    if (velocity.y > 0) playerState = PlayerState.falling;

    if (velocity.y < 0) playerState = PlayerState.jumping;


    current = playerState;
  }

  void _updatePlayerMovement(double dt) {

    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    // if (velocity.y > _gravity) isOnGround = false; // this will prevent player to jump while falling.

    // set player velocity and position
    // velocity = Vector2(dx, 0.0);
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;  // set onGround = false
    hasJumped = false;  // set hasJumped to false
  }

  
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      // check collision
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  void _verticleCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          // For vartical platform check, we should only check for falling
          // As player can jump through the platform.
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
  
  void _respawn() {
    gotHit = true;
    // current = PlayerState.hit;
    // position = startingPosition;
    // current = PlayerState.appearing;
    // current = PlayerState.idel;
    // gotHit = false;
    current = PlayerState.hit;
    final hitAnimation = animationTickers![PlayerState.hit]!;
    hitAnimation.completed.whenComplete(() {
      current = PlayerState.appearing;
      scale.x = 1;  // to set player to see right when respawn
      position = startingPosition - Vector2.all(96 - 64);
      hitAnimation.reset();

      final appearingAnimation = animationTickers![PlayerState.appearing]!;
        appearingAnimation.completed.whenComplete(() {
          position = startingPosition;
          current = PlayerState.idel;
          gotHit = false;
          appearingAnimation.reset();
      });
    });

  }
  
  void _reachedCheckpoint() async {
    reachedCheckpoint = true;

    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    position = Vector2.all(-640);

    const waitToChangeLevelDuration = Duration(seconds: 2);
    Future.delayed(waitToChangeLevelDuration, () {
      game.loadNextLevel();
    });

  }
  
}