import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../net/net_player.dart';
import '../util/extensions.dart';
import '../util/game_logic.dart';

class GamePlayer extends SimplePlayer with ObjectCollision {
  static PlayerData playerData;
  static GamePlayer current;

  final Vector2 initPosition;
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  // throttle networked movement broadcasts so we don't flood pubnub
  DateTime _lastMoveBroadcast = DateTime.fromMillisecondsSinceEpoch(0);
  JoystickMoveDirectional _lastBroadcastDirection = JoystickMoveDirectional.IDLE;
  static const Duration _moveBroadcastInterval = Duration(milliseconds: 100);

  TextSpan playerUsernameLabel;
  TextPainter textPainter;

  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;
  bool isWater = false;

  GamePlayer(this.initPosition, SpriteSheet spriteSheet, {Direction initDirection = Direction.right})
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
    GamePlayer.current = this;

    // setup label sizes
    this.playerUsernameLabel = new TextSpan(style: new TextStyle(color: Colors.red[600]), text: GamePlayer.playerData.playerUsername);
    this.textPainter = new TextPainter(text: this.playerUsernameLabel, textAlign: TextAlign.left, textDirection: TextDirection.ltr);

    // setup collision (redundant comment)
    this.setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(sizePlayer / 2, sizePlayer * 0.5),
            align: Vector2(sizePlayer * 0.25, sizePlayer * 0.5),
          ),
        ],
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional != JoystickMoveDirectional.IDLE) {
      speed = (baseSpeed * (isWater ? 0.5 : 1)) * event.intensity;
    }
    super.joystickChangeDirectional(event);
    isWater = tileIsWater();

    // network broadcast movement data, throttled so we don't flood pubnub
    // direction changes (including coming to a stop) are always sent
    final now = DateTime.now();
    if (shouldBroadcastMove(
      current: event.directional,
      lastBroadcast: _lastBroadcastDirection,
      now: now,
      lastBroadcastAt: _lastMoveBroadcast,
      interval: _moveBroadcastInterval,
    )) {
      _lastMoveBroadcast = now;
      _lastBroadcastDirection = event.directional;

      var data = PlayerMoveData(
        playerId: GamePlayer.playerData.playerId,
        direction: event.directional,
        position: Vector2(
          position.x,
          position.y
        ),
      );
      NetPlayer().playerMoveData(data);
    }
  }


  @override
  void joystickAction(JoystickActionEvent event) {
    if (isDead) return;

    String dir = (super.lastDirection.toString().split(".")[1].inCaps);

    switch (event.id) {
      case 1: {
        this.attack(dir);
        break;
      }
      default: {

      }
    }

    super.joystickAction(event);
  }

  void renderUsername(Canvas canvas) {
    this.textPainter.layout();
    this.textPainter.paint(canvas, new Offset(this.position.x, this.position.y - 20));
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

  bool tileIsWater() => tileTypeBelow() == 'water';

  void attack(String direction) {
    String animName = 'cast' + direction;
    this.playOtherAnimation(animName, (){
      // give damage
    });
  }

  void playOtherAnimation(String animName, Function onFinish) {
    var anim = super.animation.others[animName];
    super.animation.playOnce(anim, onFinish: (){
      anim.reset();
      onFinish();
    }, runToTheEnd: true);
  }
}
