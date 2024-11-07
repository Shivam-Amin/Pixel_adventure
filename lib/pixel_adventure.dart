import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/actors/player.dart';
// import 'package:flame/input.dart';
import 'package:pixel_adventure/components/levels/level.dart';

class PixelAdventure extends FlameGame 
  with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Virtual Guy');
  late JoystickComponent joystick;
  bool showJoystick = false;
  List<String> Levels = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;
  

  @override
  Future<void> onLoad() async {

    // load all images into cache before start
    await images.loadAllImages();

    // overriding here, caz player object can't be assigned before it loads
    // so will assign it when onLoad is called.
    _loadLevel();

    if (showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 2,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png')
        )
      ),
      knobRadius: 25,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png')
        )
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32)
    );

    add(joystick);
  }
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        // player.playerDirection = PlayerDirection.left;
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        // player.playerDirection = PlayerDirection.right;
        player.horizontalMovement = 1;
        break;
      default:
        // player.playerDirection = PlayerDirection.idel;
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < Levels.length - 1) {
      currentLevelIndex ++;
      _loadLevel();
    } else {
      // no mroe levels
    }
  }
  
  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      final world = Level(
        levelname: Levels[currentLevelIndex],
        player: player,
      );

      CameraComponent cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640, 
        height: 360
      );
      cam.priority = 1;
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
  }

}