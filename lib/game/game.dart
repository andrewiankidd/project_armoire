import 'dart:convert';
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

class Game extends StatefulWidget {
  final PlayerData playerData;
  final String fromSensor;
  final Vector2 cameraOffset;

  const Game({Key key, this.playerData, this.fromSensor = "", this.cameraOffset}) : super(key: key);

  @override
  GameState createState({key, playerData, fromSensor}) => GameState(playerData: this.playerData, fromSensor: this.fromSensor, cameraOffset: this.cameraOffset);
}

class GameState extends State<Game> with WidgetsBindingObserver implements GameListener {
  GameController _controller;
  GamePlayer gamePlayer;

  final PlayerData playerData;
  final String fromSensor;
  final Vector2 cameraOffset;

  static String mapLocation = 'biome1';
  static TiledWorldMap mapData;
  static Map<String, Vector2> mapSensors = {};

  // player
  static final Map<String, RemotePlayer> remotePlayers = <String, RemotePlayer>{};

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _controller = GameController()..addListener(this);
    super.initState();
  }

  GameState({Key key, this.playerData, this.fromSensor, this.cameraOffset});
  @override
  Widget build(BuildContext context) {

    print('map init');
    GameState.mapData = this._initMap(context);

    print('object loader init');
    return FutureBuilder(
      future: rootBundle.loadString('assets/images/' + GameState.mapData.path),
      // ignore: missing_return
      builder: (context, snapshot) {
        final decoded = json.decode(snapshot.data.toString());
        print('mapdata decoded successfully');

        if (decoded == null) {
          return Center(
            child: Text("Loading"),
          );
        } else {

          final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");
          print('found ${objectGroups.length} objectGroups');

          GameState.mapSensors = {};
          objectGroups.forEach((objectGroup) {
            print('objectGroup: ${objectGroup['name']}');

            // load objects
            objectGroup['objects'].forEach((object) {
              if (object['name'].startsWith('sensor')) {

                String sensorTarget = object['name'].substring(object['name'].lastIndexOf(":") + 1, object['name'].length);

                // track sensor
                GameState.mapSensors[sensorTarget] = Vector2(object['x'].toDouble(), object['y'].toDouble());

                // register sensor
                GameState.mapData.registerObject(
                  object['name'],
                  (p) => ExitMapSensor(
                    object['name'],
                    p.position,
                    p.size,
                    (v) => _exitMap(v, context),
                  ),
                );
              }
            });
          });

          return this._buildInterface(context);
        }
      },
    );
  }

  void addComponent(GameComponent gameComponent) {
    this._controller.addGameComponent(gameComponent);
  }

  void removeComponent(GameComponent gameComponent) {
    this._controller.remove(gameComponent);
  }

  void moveComponent(GameComponent gameComponent, PlayerMoveData playerMoveData) {
    var remotePlayer = this._controller.livingEnemies.first as RemotePlayer;
    remotePlayer.moveRemotePlayer(playerMoveData);
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
      showFPS: true,
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
      // // add to component
      player: this._initGamePlayer(),
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

  GamePlayer _initGamePlayer() {
    this.gamePlayer = new GamePlayer(
        PlayerData(
            playerId: this.playerData.playerId,
            playerUsername: this.playerData.playerUsername,
            playerMoveData: PlayerMoveData(
                playerId: this.playerData.playerId,
                direction: this.playerData.playerMoveData.direction,
                position: _getPlayerPosition(this.playerData.playerMoveData)
            )
        ),
        SpriteSheetHero.current
    );
    return this.gamePlayer;
  }

  Vector2 _getDirectionalOffset(PlayerMoveData playerMoveData) {
    switch (playerMoveData.direction) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return Vector2(-tileSize, 0);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Vector2(tileSize, 0);
        break;
      case JoystickMoveDirectional.MOVE_UP:
        return Vector2(0, -tileSize);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        return Vector2(0, tileSize);
        break;
      default:
        return Vector2.zero();
    }
  }

  Vector2 _getPlayerPosition(PlayerMoveData playerMoveData) {

    //todo rewrite to make better

    if (this.fromSensor.isNotEmpty && mapSensors.containsKey(this.fromSensor)) {
      print('getting location of sensor: ${this.fromSensor}}');
      print('sensorOffset: ${mapSensors[this.fromSensor]}}');
      print('playerLocation: ${playerMoveData.position}}');
      print('cameraOffset: ${this.cameraOffset}}');
      print('direction: ${playerMoveData.direction}}');
      print('directionalOffset: ${this._getDirectionalOffset(playerMoveData)}}');
      //var val = (mapSensors[this.fromSensor] + (this.cameraOffset/2)) + this._getDirectionalOffset(playerMoveData);
      var val = mapSensors[this.fromSensor] + this._getDirectionalOffset(playerMoveData);

      // if (this.cameraOffset != null) {
      //   if (playerMoveData.direction == JoystickMoveDirectional.MOVE_RIGHT) {
      //     val += this.cameraOffset;
      //   }
      //   else if (playerMoveData.direction == JoystickMoveDirectional.MOVE_LEFT) {
      //     val += this.cameraOffset;
      //   } else {
      //     val -= this.cameraOffset;
      //
      //   }
      // }

      print('val: ${val}}');
      return val;
    }

    switch (playerMoveData.direction) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return Vector2(tileSize * 2, tileSize * 10);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Vector2(tileSize * 27, tileSize * 12);
        break;
      case JoystickMoveDirectional.MOVE_UP:
        return Vector2.zero();
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        return Vector2.zero();
        break;
      default:
        return Vector2.zero();
    }
  }

  void _exitMap(String value, BuildContext context) {
    var curMapName = GameState.mapLocation;
    var targetMapName = value.substring(value.lastIndexOf(":") + 1, value.length);
    var cameraOffset = _controller.camera.relativeOffset;
    // var cameraOffset = _controller.camera.position;// - _controller.camera.relativeOffset;
    // print('camera.position ${_controller.camera.position}');
    // print('camera.cameraRect ${_controller.camera.cameraRect}');
    // print('camera.relativeOffset ${_controller.camera.relativeOffset}');
    // print('camera.canvasSize ${_controller.camera.canvasSize}');
    // print('camera.viewport.canvasSize ${_controller.camera.viewport.canvasSize}');
    // print('camera.viewport.effectiveSize ${_controller.camera.viewport.effectiveSize}');
    // print('camera.gameSize ${_controller.camera.gameSize}');
    // print('player.position ${_controller.player.position}');
    // print('cameraOffset ${cameraOffset}');
    // _controller.player.absolutePosition;

    GameState.mapLocation = targetMapName;
    Navigator.push(context, MaterialPageRoute(builder: (_) => new Game(
      playerData: this.gamePlayer.playerData,
      fromSensor: curMapName,
      cameraOffset: cameraOffset,
    )));
  }

  Direction _getDirection() {
    switch (this.playerData.playerMoveData.direction) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return Direction.right;
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Direction.left;
        break;
      case JoystickMoveDirectional.MOVE_UP:
        return Direction.right;
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        return Direction.right;
        break;
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
