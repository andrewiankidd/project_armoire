import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../net/net_player.dart';
import '../util/game_logic.dart';

// a remote player is a non-colliding interpolated avatar; we never treat it as
// a real enemy and it never physically blocks the local player
class RemotePlayer extends SimpleEnemy {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  JoystickMoveDirectional currentMove = JoystickMoveDirectional.IDLE;

  // stop dead-reckoning if we stop hearing from this player
  double _timeSinceLastMove = 0;
  static const double _moveTimeoutSeconds = 0.5;

  // newest-wins ordering + presence bookkeeping
  int _lastSentAt = -1;
  int lastSeenMs = 0;

  // authoritative position from the latest snapshot; we replay movement for the
  // animation but gently correct toward this so we don't drift
  Vector2 _targetPosition;

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

    lastSeenMs = DateTime.now().millisecondsSinceEpoch;
    _targetPosition = initPosition.clone();

    // setup label sizes
    this.playerUsernameLabel = new TextSpan(style: new TextStyle(color: Colors.red[600]), text: this.playerData.playerUsername);
    this.textPainter = new TextPainter(text: this.playerUsernameLabel, textAlign: TextAlign.left, textDirection: TextDirection.ltr);

    // no collision: remotes are non-blocking avatars
  }

  // ingest a network snapshot; stale (out-of-order) snapshots are dropped
  void applySnapshot(PlayerState state) {
    lastSeenMs = DateTime.now().millisecondsSinceEpoch;
    if (!acceptSnapshot(state.sentAt, _lastSentAt)) return;
    _lastSentAt = state.sentAt;

    currentMove = state.direction;
    _targetPosition = state.position.clone();
    // replay at the sender's actual speed so we drift less between updates
    speed = (baseSpeed * state.intensity).clamp(0.0, baseSpeed);
    _timeSinceLastMove = 0;
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
    // if we haven't heard from this player recently, stop moving them
    _timeSinceLastMove += dt;
    if (_timeSinceLastMove >= _moveTimeoutSeconds) {
      currentMove = JoystickMoveDirectional.IDLE;
    }
    _moveRemotePlayer(currentMove);
    _correctPosition(dt);
    super.update(dt);
  }

  // pull toward the latest authoritative position: snap if far off, otherwise
  // chase smoothly so the replay never drifts away
  void _correctPosition(double dt) {
    if (_targetPosition == null) return;
    if (shouldSnapToPosition(_targetPosition, position, tileSize * 2)) {
      position = _targetPosition.clone();
    } else if (shouldSnapToPosition(_targetPosition, position, 0.5)) {
      final t = (dt * 6).clamp(0.0, 1.0);
      position = lerpVector(position, _targetPosition, t);
    }
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
