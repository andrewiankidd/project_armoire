import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../net/net_player.dart';

class GamePlayer extends SimplePlayer with ObjectCollision {

  // player data
  PlayerData playerData;
  Vector2 playerPosition;

  // rendering
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;
  bool isWater = false;

  // ui
  TextSpan playerUsernameLabel;
  TextPainter textPainter;
  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;


  GamePlayer(
        PlayerData this.playerData,
        SpriteSheet spriteSheet
      )
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
          position: playerData.playerMoveData.position,
          initDirection: Direction.down,
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
          // CollisionArea.rectangle(
          //   size: Vector2(sizePlayer / 2, sizePlayer * 0.5),
          //   align: Vector2(sizePlayer * 0.25, sizePlayer * 0.5),
          // ),
        ],
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {

    this.playerData.playerMoveData.direction = event.directional;

    if (event.directional != JoystickMoveDirectional.IDLE) {
      speed = (baseSpeed * (isWater ? 0.5 : 1)) * event.intensity;
    }
    super.joystickChangeDirectional(event);
    isWater = tileIsWater();

    // network broadcast movement data
    var data = PlayerMoveData(
      playerId: this.playerData.playerId,
      direction: event.directional,
      position: Vector2(
        position.x,
        position.y
      ),
    );
    NetPlayer().playerMoveData(data);
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

extension CapExtension on String {
  String get inCaps => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
