import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() {
  // setup for full screen and landscape mode.
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  // setup for debug and produciton mode
  PixelAdventure game = PixelAdventure();
  runApp(GameWidget(game: kDebugMode ? PixelAdventure() : game));
}