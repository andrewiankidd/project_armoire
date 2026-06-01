import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:project_armoire/net/net_player.dart';
import '../main.dart';
import '../player/game_player.dart';
import '../player/remote_player.dart';
import '../player/sprite_sheet_hero.dart';
import '../util/exit_map_sensor.dart';
import '../util/extensions.dart';
import '../util/game_logic.dart';
import '../util/show_in_enum.dart';

class Game extends StatefulWidget {
  final ShowInEnum showInEnum;
  const Game({Key key, this.showInEnum = ShowInEnum.left}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> with WidgetsBindingObserver implements GameListener {
  GameController _controller;

  static String mapLocation = 'biome1';
  static TiledWorldMap mapData;
  bool _mapInitialized = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _controller = GameController()..addListener(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // build() can run many times; only init the map + object sensors once
    if (!_mapInitialized) {
      _mapInitialized = true;
      GameState.mapData = this._initMap(context);

      rootBundle.loadString('assets/images/' + GameState.mapData.path).then((String result){
        final decoded = json.decode(result);

        final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");

        objectGroups.forEach((objectGroup) {
          objectGroup['objects'].forEach((object) {
            GameState.mapData.registerObject(
              object['name'],
              (p) => ExitMapSensor(
                object['name'],
                p.position,
                p.size,
                (v) => _exitMap(v, context),
             ),
            );
          });
        });
      });
    }

    return this._buildInterface(context);
  }

  void addComponent(GameComponent gameComponent) {
    this._controller.addGameComponent(gameComponent);
  }

  void removeComponent(GameComponent gameComponent) {
    this._controller.remove(gameComponent);
  }

  void moveComponent(GameComponent gameComponent, PlayerMoveData playerMoveData) {
    // move the player the message is actually for, not just the first enemy
    if (gameComponent is RemotePlayer) {
      gameComponent.moveRemotePlayer(playerMoveData);
    }
  }

  TiledWorldMap _initMap(BuildContext context) {
    return TiledWorldMap(
      'maps/${GameState.mapLocation}/data.json',
      forceTileSize: Size(tileSize, tileSize),
    );
  }

  Widget _buildInterface(BuildContext context) {
    return BonfireTiledWidget(
      showCollisionArea: kDebugMode,
      showFPS: kDebugMode,
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(
          enable: true,
        ),
        directional: JoystickDirectional(),
        actions: [
          JoystickAction(
            actionId: 1, //(required) Action identifier, will be sent to 'void joystickAction(JoystickActionEvent event) {}' when pressed
            sprite: Sprite.load('buttons/background.png'), // the action image
            spritePressed: Sprite.load('buttons/atack_range.png'), // Optional image to be shown when the action is fired
            align: JoystickActionAlign.BOTTOM_RIGHT,
            color: Colors.blue,
            size: 50,
            margin: EdgeInsets.only(bottom: 50, right: 160),
          )
        ],
      ),
      player: GamePlayer(
        _getInitPosition(),
        SpriteSheetHero.current,
        initDirection: _getDirection(),
      ),
      map: GameState.mapData,
      colorFilter: GameColorFilter(color: Color.fromRGBO(255, 112, 214, 0.66), blendMode: BlendMode.hue),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        sizeMovementWindow: Vector2(50,50),
        zoom:  1.0,
        angle: 45 * pi/180, // rotate view 45 degrees
      ),
      progress: SizedBox.shrink(),
      gameController: this._controller,
    );
  }

  Vector2 _getInitPosition() {
    return initPositionFor(widget.showInEnum, tileSize);
  }

  void _exitMap(String value, BuildContext context) {
    final target = parseExit(value);
    if (target == null) {
      developer.log('exit sensor "$value" has no target biome; ignoring', name: 'project_armoire.Game');
      return;
    }
    GameState.mapLocation = target.biome;
    // reuse the global key so networking (gameStateKey.currentState) keeps
    // working after a map transition
    context.goTo(Game(
      key: gameStateKey,
      showInEnum: target.entrySide,
    ));
  }

  Direction _getDirection() {
    switch (widget.showInEnum) {
      case ShowInEnum.left:
        return Direction.right;
      case ShowInEnum.right:
        return Direction.left;
      case ShowInEnum.top:
        return Direction.right;
      case ShowInEnum.bottom:
        return Direction.right;
      default:
        return Direction.right;
    }
  }

  @override
  void changeCountLiveEnemies(int count) {
    // TODO: implement changeCountLiveEnemies
  }

  @override
  void updateGame() {
    // TODO: implement updateGame
  }
}
