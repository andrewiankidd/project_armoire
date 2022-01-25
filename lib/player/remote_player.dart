import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'dart:ui';

import '../net/net_player.dart';
import '../player/sprite_sheet_hero.dart';

import '../maps/game.dart';

class RemotePlayer extends SimpleEnemy with ObjectCollision {
  final PlayerData playerData;
  final Vector2 initPosition;
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;
  bool isWater = false;

  RemotePlayer(this.playerData, this.initPosition, SpriteSheet spriteSheet,
      {Direction initDirection = Direction.right})
      : super(
    animation: SimpleDirectionAnimation(
        idleUp: spriteSheet.createAnimation(
            row: 0, stepTime: 0.1, loop: true, from: 0, to: 1),
        idleLeft: spriteSheet.createAnimation(
            row: 1, stepTime: 0.1, loop: true, from: 0, to: 1),
        idleDown: spriteSheet.createAnimation(
            row: 2, stepTime: 0.1, loop: true, from: 0, to: 1),
        idleRight: spriteSheet.createAnimation(
            row: 3, stepTime: 0.1, loop: true, from: 0, to: 1),
        runUp: spriteSheet.createAnimation(row: 8, stepTime: 0.1),
        runLeft: spriteSheet.createAnimation(row: 9, stepTime: 0.1),
        runDown: spriteSheet.createAnimation(row: 10, stepTime: 0.1),
        runRight: spriteSheet.createAnimation(row: 11, stepTime: 0.1),
        others:
        {
          "castTop": spriteSheet.createAnimation(
              row: 12, stepTime: 0.1, from: 0, to: 5, loop: false),
          "castLeft": spriteSheet.createAnimation(
              row: 13, stepTime: 0.1, from: 0, to: 5, loop: false),
          "castBottom": spriteSheet.createAnimation(
              row: 14, stepTime: 0.1, from: 0, to: 5, loop: false),
          "castRight": spriteSheet.createAnimation(
              row: 15, stepTime: 0.1, from: 0, to: 5, loop: false),
        }
    ),
    size: Vector2(sizePlayer, sizePlayer),
    position: initPosition,
    initDirection: initDirection,
    life: 100,
    speed: sizePlayer * 2,
  ) {

    //setupServerPlayerControl(socketManager, id);
  }
}