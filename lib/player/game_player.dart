import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flutter/material.dart';
import 'package:project_armoire/main.dart';
import 'package:project_armoire/net/net_player.dart';

class GamePlayer extends SimplePlayer with ObjectCollision {
  final PlayerData playerData;
  final Position initPosition;
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  TextSpan playerUsernameLabel;
  TextPainter textPainter;

  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;
  bool isWater = false;

  GamePlayer(this.playerData, this.initPosition, SpriteSheet spriteSheet, {Direction initDirection = Direction.right})
      : super(
          animation:SimpleDirectionAnimation(
              idleTop: spriteSheet.createAnimation(0, stepTime: 0.1, loop: true, from: 0, to: 1),
              idleLeft: spriteSheet.createAnimation(1, stepTime: 0.1, loop: true, from: 0, to: 1),
              idleBottom: spriteSheet.createAnimation(2, stepTime: 0.1, loop: true, from: 0, to: 1),
              idleRight: spriteSheet.createAnimation(3, stepTime: 0.1, loop: true, from: 0, to: 1),
              runTop: spriteSheet.createAnimation(8, stepTime: 0.1),
              runLeft: spriteSheet.createAnimation(9, stepTime: 0.1),
              runBottom: spriteSheet.createAnimation(10, stepTime: 0.1),
              runRight: spriteSheet.createAnimation(11, stepTime: 0.1),
              others:
              {
                "castTop": spriteSheet.createAnimation(12, stepTime: 0.1, from: 0, to: 5, loop: false),
                "castLeft": spriteSheet.createAnimation(13, stepTime: 0.1, from: 0, to: 5, loop: false),
                "castBottom": spriteSheet.createAnimation(14, stepTime: 0.1, from: 0, to: 5, loop: false),
                "castRight": spriteSheet.createAnimation(15, stepTime: 0.1, from: 0, to: 5, loop: false),
              }
          ),
          width: sizePlayer,
          height: sizePlayer,
          initPosition: initPosition,
          initDirection: initDirection,
          life: 100,
          speed: sizePlayer * 2,

      ) {

    // setup label sizes
    this.playerUsernameLabel = new TextSpan(style: new TextStyle(color: Colors.red[600]), text: this.playerData.playerUsername);
    this.textPainter = new TextPainter(text: this.playerUsernameLabel, textAlign: TextAlign.left, textDirection: TextDirection.ltr);

    // setup collision (redundant)
    this.setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea(
            height: sizePlayer / 3,
            width: sizePlayer * 0.5,
            align: Offset(sizePlayer * 0.25, sizePlayer * 0.65),
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

    // network broadcast movement data
    var data = PlayerMoveData(
      playerId: playerData.playerId.toString(),
      direction: event.directional,
      position: Offset(
        (position.left / tileSize),
        (position.top / tileSize),
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
    this.textPainter.paint(canvas, new Offset(this.position.left, this.position.top - 20));
  }

  @override
  void render(Canvas canvas) {
    this.renderUsername(canvas);
    if (isWater) {
      canvas.saveLayer(position, Paint());
    }
    super.render(canvas);
    if (isWater) {
      canvas.drawRect(
        Rect.fromLTWH(
          position.left,
          position.top + height * 0.62,
          position.width,
          position.height * 0.38,
        ),
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
