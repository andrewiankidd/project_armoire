import 'dart:convert';
import 'dart:math';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:project_armoire/game/map.dart';
import 'package:project_armoire/net/net_player.dart';
import '../main.dart';
import '../player/game_player.dart';
import '../player/remote_player.dart';
import '../player/sprite_sheet_hero.dart';

class Game extends StatefulWidget {
  final PlayerData playerData;

  const Game({Key key, this.playerData}) : super(key: key);

  @override
  GameState createState({key, playerData}) => GameState(playerData: this.playerData);
}

class GameState extends State<Game> with WidgetsBindingObserver implements GameListener {
  GameController _controller;
  GamePlayer gamePlayer;

  final PlayerData playerData;
  final Vector2 cameraOffset;

  String mapName = 'biome1';
  TiledMapData tiledMapData = TiledMapData('biome1', 'spawn');

  var b;

  // player
  static final Map<String, RemotePlayer> remotePlayers = <String, RemotePlayer>{};

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _controller = GameController()..addListener(this);
    b = this._buildBonfire();
    print('nutsack');
    super.initState();
  }

  GameState({Key key, this.playerData, this.cameraOffset});
  @override
  Widget build(BuildContext context) {

    var child = new FutureBuilder<Widget>(
      future: b,
      initialData: new Text("Loading.."),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('waiting');
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            return snapshot.data; //snapshot.data;
        // You can reach your snapshot.data['url'] in here
        }
        return null; // unreachable
      }
    );

    print('ballsacks');
    return kDebugMode ? Scaffold(
      appBar: AppBar(
        title: Text(this.mapName),
      ),
      body: Center(
          child: child
      ),
    ) : child;
  }

  Future<Widget> _buildBonfire() async {

    tiledMapData = await TiledMapBuilder(
        refreshMap: (TiledMapData _tiledMapData) {
          setState(() {
            print('tiledMapData:' );
            print('->:mapName: ' + _tiledMapData.mapName);
            print('->:fromMapName: ' + _tiledMapData.fromMapName);
            this.tiledMapData = _tiledMapData;
            this.mapName = _tiledMapData.mapName;
            b = _buildBonfire();
          });
        }
    ).buildTiledWorldMap(this.tiledMapData.mapName, this.tiledMapData.fromMapName);

    var x = BonfireTiledWidget(
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
      // // add to component
      player: this._initGamePlayer(),
      map: tiledMapData.tiledWorldMap,
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

    print('beezits');
    if (this.tiledMapData.mapSensors.containsKey(this.tiledMapData.fromMapName)) {
      print('Setting player location: ' + this.tiledMapData.mapSensors[this.tiledMapData.fromMapName].toString());
      x.player.position = this.tiledMapData.mapSensors[this.tiledMapData.fromMapName];
    }
    print('cheezits');
    return x;
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



    var val = this._getDirectionalOffset(playerMoveData);
    /*
    if (this.fromSensor.isNotEmpty && mapSensors.containsKey(this.fromSensor)) {
      print('getting location of sensor: ${this.fromSensor}}');
      print('sensorOffset: ${mapSensors[this.fromSensor]}}');
      print('playerLocation: ${playerMoveData.position}}');
      print('cameraOffset: ${this.cameraOffset}}');
      print('direction: ${playerMoveData.direction}}');
      print('directionalOffset: ${this._getDirectionalOffset(playerMoveData)}}');
      //var val = (mapSensors[this.fromSensor] + (this.cameraOffset/2)) + this._getDirectionalOffset(playerMoveData);
      var val = mapSensors[this.fromSensor] + this._getDirectionalOffset(playerMoveData);

      if (this.cameraOffset != null) {
        if (playerMoveData.direction == JoystickMoveDirectional.MOVE_RIGHT) {
          val += this.cameraOffset;
        }
        else if (playerMoveData.direction == JoystickMoveDirectional.MOVE_LEFT) {
          val += this.cameraOffset;
        } else {
          val -= this.cameraOffset;

        }
      }

      print('val: ${val}}');
      return val;
    }
    */
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
