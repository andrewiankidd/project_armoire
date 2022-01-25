import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../net/net_player.dart';
class RemotePlayer extends SimpleEnemy with ObjectCollision {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  JoystickMoveDirectional currentMove = JoystickMoveDirectional.IDLE;

  final PlayerData playerData;

  final Vector2 initPosition;
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  TextSpan playerUsernameLabel;
  TextPainter textPainter;

  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;
  bool isWater = false;

  RemotePlayer(this.playerData, this.initPosition, SpriteSheet spriteSheet,
      {Direction initDirection = Direction.right})
      : super(
          animation:SimpleDirectionAnimation(
              idleUp: spriteSheet.createAnimation(row: 0, stepTime: 0.1, loop: true, from: 0, to: 1).asFuture(),
              idleLeft: spriteSheet.createAnimation(row: 1, stepTime: 0.1, loop: true, from: 0, to: 1).asFuture(),
              idleDown: spriteSheet.createAnimation(row: 2, stepTime: 0.1, loop: true, from: 0, to: 1).asFuture(),
              idleRight: spriteSheet.createAnimation(row: 3, stepTime: 0.1, loop: true, from: 0, to: 1).asFuture(),
              runUp: spriteSheet.createAnimation(row: 8, stepTime: 0.1, loop: true, from: 0, to: 9).asFuture(),
              runLeft: spriteSheet.createAnimation(row: 9, stepTime: 0.1, loop: true, from: 0, to: 9).asFuture(),
              runDown: spriteSheet.createAnimation(row: 10, stepTime: 0.1, loop: true, from: 0, to: 9).asFuture(),
              runRight: spriteSheet.createAnimation(row: 11, stepTime: 0.1, loop: true, from: 0, to: 9).asFuture(),
              others:
              {
                "castTop": spriteSheet.createAnimation(row: 12, stepTime: 0.1, from: 0, to: 5, loop: false).asFuture(),
                "castLeft": spriteSheet.createAnimation(row: 13, stepTime: 0.1, from: 0, to: 5, loop: false).asFuture(),
                "castBottom": spriteSheet.createAnimation(row: 14, stepTime: 0.1, from: 0, to: 5, loop: false).asFuture(),
                "castRight": spriteSheet.createAnimation(row: 15, stepTime: 0.1, from: 0, to: 5, loop: false).asFuture(),
              }
          ),
          size: Vector2(sizePlayer, sizePlayer),
          position: initPosition,
          initDirection: initDirection,
          life: 100,
          speed: sizePlayer * 2,
        ) {

    // setup label sizes
    this.playerUsernameLabel = new TextSpan(style: new TextStyle(color: Colors.red[600]), text: this.playerData.playerUsername);
    this.textPainter = new TextPainter(text: this.playerUsernameLabel, textAlign: TextAlign.left, textDirection: TextDirection.ltr);

    // setup collision (redundant comment)
    this.setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(sizePlayer / 3, sizePlayer * 0.5),
            align: Vector2(sizePlayer * 0.25, sizePlayer * 0.65),
          ),
        ],
      ),
    );
  }

  void moveRemotePlayer(PlayerMoveData playerMoveData){

    // set intended direction
    // game will pick it up in next tick of update method
    this.currentMove = playerMoveData.direction;

    // de-sync check
    if (playerMoveData.position.distanceTo(position) > (tileSize * 0.5)) {
      position = playerMoveData.position;
    }
  }

  void _moveRemotePlayer(JoystickMoveDirectional direction) {
    switch(direction) {
      case JoystickMoveDirectional.MOVE_LEFT:
        this.moveLeft(speed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        this.moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveUpRight(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveDownRight(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveDownLeft(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveUpLeft(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case JoystickMoveDirectional.MOVE_UP:
        this.moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        this.moveDown(speed);
        break;
      case JoystickMoveDirectional.IDLE:
        this.idle();
    }
  }

  void renderUsername(Canvas canvas) {
    this.textPainter.layout();
    this.textPainter.paint(canvas, new Offset(this.position.x, this.position.y - 20));
  }

  @override
  void update(double dt) {
    _moveRemotePlayer(currentMove);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    this.renderUsername(canvas);
    if (isWater) {
      canvas.saveLayer(position.toRect(), Paint());
    }
    super.render(canvas);
    if (isWater) {
      canvas.drawRect(
        position.toRect(),
        _paintFocus,
      );
      canvas.restore();
    }
  }
}