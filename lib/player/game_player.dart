import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../net/net_player.dart';
import '../util/extensions.dart';
import '../util/game_logic.dart';

class GamePlayer extends SimplePlayer with ObjectCollision {
  static PlayerData playerData;
  static GamePlayer current;
  // set true right before a map transition so onRemove doesn't broadcast a
  // spurious leave (the new-map snapshot + map filter handle that instead)
  static bool suppressLeaveOnRemove = false;

  final Vector2 initPosition;
  final String map;
  static final sizePlayer = tileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  // state broadcast cadence: fast while moving, slow heartbeat while idle
  DateTime _lastStateBroadcast = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCull = DateTime.fromMillisecondsSinceEpoch(0);
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;
  double _currentIntensity = 0;
  static const Duration _movingInterval = Duration(milliseconds: 100);
  static const Duration _idleInterval = Duration(milliseconds: 2000);
  static const Duration _cullInterval = Duration(milliseconds: 1000);

  TextSpan playerUsernameLabel;
  TextPainter textPainter;

  Paint _paintFocus = Paint()
    ..blendMode = BlendMode.clear;
  bool isWater = false;

  GamePlayer(this.initPosition, SpriteSheet spriteSheet, {Direction initDirection = Direction.right, this.map})
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

    // remember intent; the actual broadcast happens at a fixed cadence in
    // update() so remotes get a steady stream + presence heartbeat
    _currentDirectional = event.directional;
    _currentIntensity = event.intensity;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _maybeBroadcastState();
    _maybePruneRemotes();
  }

  // broadcast our state at 10hz while moving, ~0.5hz while idle (presence)
  void _maybeBroadcastState() {
    if (GamePlayer.playerData == null) return;
    final now = DateTime.now();
    final moving = _currentDirectional != JoystickMoveDirectional.IDLE;
    if (!shouldBroadcastState(
      now: now,
      lastAt: _lastStateBroadcast,
      moving: moving,
      movingInterval: _movingInterval,
      idleInterval: _idleInterval,
    )) {
      return;
    }
    _lastStateBroadcast = now;
    NetPlayer().broadcastState(PlayerState(
      playerId: GamePlayer.playerData.playerId,
      username: GamePlayer.playerData.playerUsername,
      map: map,
      position: Vector2(position.x, position.y),
      direction: _currentDirectional,
      intensity: _currentIntensity,
      sentAt: now.millisecondsSinceEpoch,
    ));
  }

  // periodically drop remotes we've stopped hearing from (disconnects)
  void _maybePruneRemotes() {
    final now = DateTime.now();
    if (now.difference(_lastCull) < _cullInterval) return;
    _lastCull = now;
    NetPlayer.cullStale();
  }

  @override
  void onRemove() {
    // best-effort departure notice on a real exit; suppressed on map
    // transitions (app-close is handled by the staleness cull on other clients)
    if (!GamePlayer.suppressLeaveOnRemove && GamePlayer.playerData != null) {
      NetPlayer().broadcastLeave(GamePlayer.playerData.playerId);
    }
    GamePlayer.suppressLeaveOnRemove = false;
    super.onRemove();
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
