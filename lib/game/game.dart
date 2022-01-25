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
import '../util/extensions.dart';

class Game extends StatefulWidget {
  const Game({Key key, ShowInEnum showInEnum}) : super(key: key);

  @override
  GameState createState({key, showInEnum}) => GameState();
}

class GameState extends State<Game> with WidgetsBindingObserver implements GameListener {
  GameController _controller;

  final ShowInEnum showInEnum;
  static String mapLocation = 'biome1';
  static TiledWorldMap mapData;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _controller = GameController()..addListener(this);
    super.initState();
  }

  GameState({Key key, this.showInEnum = ShowInEnum.left});
  @override
  Widget build(BuildContext context) {
    print('map init');
    GameState.mapData = this._initMap(context);

    print('object loader init');
    rootBundle.loadString('assets/images/' + GameState.mapData.path).then((String result){
      final decoded = json.decode(result);
      print('mapdata decoded successfully');

      final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");
      print('found ${objectGroups.length} objectGroups');

      objectGroups.forEach((objectGroup) {

        print('objectGroup: ${objectGroup['name']}');
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

    return this._buildInterface(context);
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
    switch (showInEnum) {
      case ShowInEnum.left:
        return Vector2(tileSize * 2, tileSize * 10);
        break;
      case ShowInEnum.right:
        return Vector2(tileSize * 27, tileSize * 12);
        break;
      case ShowInEnum.top:
        return Vector2.zero();
        break;
      case ShowInEnum.bottom:
        return Vector2.zero();
        break;
      default:
        return Vector2.zero();
    }
  }

  void _exitMap(String value, BuildContext context) {
    var mapName = value.substring(value.lastIndexOf(":") + 1, value.length);
    GameState.mapLocation = mapName;
    context.goTo(Game(
      showInEnum: ShowInEnum.left,
    ));
  }

  Direction _getDirection() {
    switch (showInEnum) {
      case ShowInEnum.left:
        return Direction.right;
        break;
      case ShowInEnum.right:
        return Direction.left;
        break;
      case ShowInEnum.top:
        return Direction.right;
        break;
      case ShowInEnum.bottom:
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
