import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:project_armoire/main.dart';
import 'dart:ui';

class RemotePlayer extends SimpleEnemy with ObjectCollision {
  final String playerId;
  final Position initPosition;
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;
  bool isWater = false;

  RemotePlayer(this.playerId, this.initPosition, SpriteSheet spriteSheet,
      {Direction initDirection = Direction.right})
      : super(
    animation: SimpleDirectionAnimation(
        idleTop: spriteSheet.createAnimation(
            0, stepTime: 0.1, loop: true, from: 0, to: 1),
        idleLeft: spriteSheet.createAnimation(
            1, stepTime: 0.1, loop: true, from: 0, to: 1),
        idleBottom: spriteSheet.createAnimation(
            2, stepTime: 0.1, loop: true, from: 0, to: 1),
        idleRight: spriteSheet.createAnimation(
            3, stepTime: 0.1, loop: true, from: 0, to: 1),
        runTop: spriteSheet.createAnimation(8, stepTime: 0.1),
        runLeft: spriteSheet.createAnimation(9, stepTime: 0.1),
        runBottom: spriteSheet.createAnimation(10, stepTime: 0.1),
        runRight: spriteSheet.createAnimation(11, stepTime: 0.1),
        others:
        {
          "castTop": spriteSheet.createAnimation(
              12, stepTime: 0.1, from: 0, to: 5, loop: false),
          "castLeft": spriteSheet.createAnimation(
              13, stepTime: 0.1, from: 0, to: 5, loop: false),
          "castBottom": spriteSheet.createAnimation(
              14, stepTime: 0.1, from: 0, to: 5, loop: false),
          "castRight": spriteSheet.createAnimation(
              15, stepTime: 0.1, from: 0, to: 5, loop: false),
        }
    ),
    width: sizePlayer,
    height: sizePlayer,
    initPosition: initPosition,
    initDirection: initDirection,
    life: 100,
    speed: sizePlayer * 2,
  ) {

    //setupServerPlayerControl(socketManager, id);
  }

}