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
import '../player/sprite_sheet_hero.dart';
import '../util/exit_map_sensor.dart';
import '../util/extensions.dart';
import '../util/game_logic.dart';
import '../util/show_in_enum.dart';

class Game extends StatefulWidget {
  final ShowInEnum showInEnum;
  // the map we came from (null on first entry); used to spawn at the paired
  // return doorway so we arrive relative to where we left
  final String fromMap;
  const Game({Key key, this.showInEnum = ShowInEnum.left, this.fromMap}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> with WidgetsBindingObserver implements GameListener {
  GameController _controller;

  // the running game, so networking can reach it without a shared GlobalKey
  // (a shared key would make Flutter reuse this State across map transitions
  // and the new map would never load)
  static GameState current;
  static String mapLocation = 'biome1';
  static TiledWorldMap mapData;
  bool _mapInitialized = false;

  @override
  void initState() {
    GameState.current = this;
    WidgetsBinding.instance.addObserver(this);
    // fresh game (incl. after a map transition): start with an empty roster and
    // let snapshots repopulate only the players on this map
    NetPlayer.clearRoster();
    _controller = GameController()..addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    // only clear if a newer game hasn't already taken over (transition overlap)
    if (GameState.current == this) GameState.current = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // build() can run many times; only init the map + object sensors once
    if (!_mapInitialized) {
      _mapInitialized = true;
      GameState.mapData = this._initMap(context);

      rootBundle.loadString('assets/images/' + GameState.mapData.path).then((String result){
        final decoded = json.decode(result);

        // tiled object coords are in original tile units; the map is rendered at
        // runtime tileSize, so scale to world coords
        final double scaleX = tileSize / decoded['tilewidth'];
        final double scaleY = tileSize / decoded['tileheight'];
        final Vector2 mapCenter = Vector2(
          (decoded['width'] * tileSize) / 2,
          (decoded['height'] * tileSize) / 2,
        );

        final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");

        // doorways on this map that lead back to where we came from
        final List<Vector2> returnSensors = [];

        objectGroups.forEach((objectGroup) {
          objectGroup['objects'].forEach((object) {
            final String name = object['name'];
            GameState.mapData.registerObject(
              name,
              (p) => ExitMapSensor(
                name,
                p.position,
                p.size,
                (v) => _exitMap(v, context),
             ),
            );

            final exit = parseExit(name);
            if (widget.fromMap != null && exit != null && exit.biome == widget.fromMap) {
              final cx = (object['x'] + (object['width'] ?? 0) / 2) * scaleX;
              final cy = (object['y'] + (object['height'] ?? 0) / 2) * scaleY;
              returnSensors.add(Vector2(cx, cy));
            }
          });
        });

        _spawnAtReturnSensor(returnSensors, mapCenter);
      });
    }

    return this._buildInterface(context);
  }

  // place the local player just inside the doorway that leads back to the map
  // we came from, so a round trip lands you relative to where you left
  void _spawnAtReturnSensor(List<Vector2> candidates, Vector2 mapCenter) {
    if (candidates.isEmpty || GamePlayer.current == null) return;

    // pick the doorway on the side we should arrive on (matches entry side)
    Vector2 chosen = candidates.first;
    for (final c in candidates) {
      switch (widget.showInEnum) {
        case ShowInEnum.right:  if (c.x > chosen.x) chosen = c; break;
        case ShowInEnum.left:   if (c.x < chosen.x) chosen = c; break;
        case ShowInEnum.top:    if (c.y < chosen.y) chosen = c; break;
        case ShowInEnum.bottom: if (c.y > chosen.y) chosen = c; break;
        default: break;
      }
    }

    // step inward from the doorway so we don't immediately re-trigger it
    final inward = mapCenter - chosen;
    if (inward.length2 > 0) {
      inward.normalize();
      chosen = chosen + inward * (tileSize * 2.5);
    }
    GamePlayer.current.position = chosen;
  }

  void addComponent(GameComponent gameComponent) {
    this._controller.addGameComponent(gameComponent);
  }

  void removeComponent(GameComponent gameComponent) {
    this._controller.remove(gameComponent);
  }

  TiledWorldMap _initMap(BuildContext context) {
    return TiledWorldMap(
      'maps/${GameState.mapLocation}/data.json',
      forceTileSize: Size(tileSize, tileSize),
    );
  }

  static bool get _isTouchPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  Joystick _buildJoystick() {
    return Joystick(
      keyboardConfig: KeyboardConfig(enable: true),
      directional: _isTouchPlatform ? JoystickDirectional() : null,
      actions: _isTouchPlatform ? [
        JoystickAction(
          actionId: 1,
          sprite: Sprite.load('buttons/background.png'),
          spritePressed: Sprite.load('buttons/atack_range.png'),
          align: JoystickActionAlign.BOTTOM_RIGHT,
          color: Colors.blue,
          size: 50,
          margin: EdgeInsets.only(bottom: 50, right: 160),
        )
      ] : [],
    );
  }

  Widget _buildInterface(BuildContext context) {
    return BonfireTiledWidget(
      showCollisionArea: kDebugMode,
      showFPS: kDebugMode,
      joystick: _buildJoystick(),
      player: GamePlayer(
        _getInitPosition(),
        SpriteSheetHero.current,
        initDirection: _getDirection(),
        map: GameState.mapLocation,
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
    final fromMap = GameState.mapLocation;
    GameState.mapLocation = target.biome;
    // this is a transition, not a real exit: don't broadcast a leave
    GamePlayer.suppressLeaveOnRemove = true;
    // build a fresh game for the new map (no shared key); networking reaches it
    // via GameState.current. fromMap lets us spawn at the paired return doorway
    context.goTo(Game(
      showInEnum: target.entrySide,
      fromMap: fromMap,
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
