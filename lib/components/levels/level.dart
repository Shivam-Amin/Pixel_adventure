import 'dart:async';
// import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
// import 'package:pixel_adventure/components/actors/background_tile.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/levels/collision_block.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// world contains all level loadings, cordinates, cams and 
// World extends components that manages all key binds and stuff.
class Level extends World with HasGameRef<PixelAdventure> {
  final String levelname;
  final Player player;
  List<CollisionBlock> collisionBlocks = [];

  Level({ required this.levelname, required this.player });

  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {

    level = await TiledComponent.load('$levelname.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    
    return super.onLoad();
  }
  


  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    // const tileSize = 64;

    // final numTileX  = (game.size.x / tileSize).floor();
    // final numTileY  = (game.size.y / tileSize).floor();


    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');

      // for (double y = 0; y < (game.size.x / numTileY); y++) {
      //   for (double x = 0; x < numTileX; x++) {
      //     final backgroundTile = BackgroundTile(
      //       // color: backgroundColor != null ? backgroundColor : 'Gray',
      //       color: backgroundColor ?? 'Gray',
      //       position: Vector2(x * tileSize, y * tileSize - tileSize )
      //     );

      //     add(backgroundTile);
      //   }
      // }
      final background = ParallaxComponent(
        priority: -1,
        parallax: Parallax(
          [
            ParallaxLayer(
              ParallaxImage(
                game.images.fromCache('Background/$backgroundColor.png'),
                repeat: ImageRepeat.repeat,
                fill: LayerFill.none,
              ),
            ),
          ],
          baseVelocity: Vector2(0, -50),
        ),
      );
      add(background);

      
    }
  }
  
  void _spawningObjects() {
    // ignore: non_constant_identifier_names
    final SpawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (SpawnPointLayer != null) {
      for (final spawnPoint in SpawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            // final player = Player(
            //   character: 'Mask Dude', 
            //   position: Vector2(spawnPoint.x, spawnPoint.y)
            // );
            player.position = Vector2(spawnPoint.x, spawnPoint.y);

            add(player);
            break;
          
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNegative = spawnPoint.properties.getValue('offNegative');
            final offPositive = spawnPoint.properties.getValue('offPositive');
            final saw = Saw(
              isVertical: isVertical,
              offNegative: offNegative,
              offPositive: offPositive,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;

          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
          default:
        }
      }
    }
  }
  
  void _addCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: false
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
  
  
}