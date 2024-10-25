import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
// import 'package:flame/input.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame 
    with HasKeyboardHandlerComponents
  {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final CameraComponent cam;
  @override
  final world = Level(levelname: 'Level-01');

  @override
  Future<void> onLoad() async {

    // load all images into cache before start
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640, 
      height: 360
    );
    
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }
}