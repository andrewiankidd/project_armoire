import 'dart:convert';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:project_armoire/config/config.dart';
import 'package:project_armoire/main.dart';
import 'package:project_armoire/net/net_player.dart';
import 'package:project_armoire/player/game_player.dart';
import 'package:project_armoire/player/sprite_sheet_hero.dart';
import 'package:project_armoire/util/exit_map_sensor.dart';
import 'package:project_armoire/util/extensions.dart';

class MainMap extends StatelessWidget {
  final ShowInEnum showInEnum;
  static String mapLocation = 'biome1';
  static TiledWorldMap mapData;

  const MainMap({Key key, this.showInEnum = ShowInEnum.left}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('map init');
    MainMap.mapData = this.initMap(context);

    print('object loader init');
    rootBundle.loadString('assets/images/' + MainMap.mapData.path).then((String result){
      final decoded = json.decode(result);
      print('mapdata decoded successfully');

      final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");
      print('found ${objectGroups.length} objectGroups');

      objectGroups.forEach((objectGroup) {

        print('objectGroup: ${objectGroup['name']}');
        objectGroup['objects'].forEach((object) {
          MainMap.mapData.registerObject(
            object['name'],
            (x, y, width, height) => ExitMapSensor(
              object['name'],
              Position(x, y),
              width,
              height,
              (v) => _exitMap(v, context),
           ),
          );
        });

      });
    });

    return this.buildInterface(context);
  }

  TiledWorldMap initMap(BuildContext context) {
    return TiledWorldMap(
      'maps/${MainMap.mapLocation}/data.json',
      forceTileSize: Size(tileSize, tileSize),
    );
  }

  Widget buildInterface(BuildContext context) {
    return BonfireTiledWidget(
      showCollisionArea: kDebugMode,
      showFPS: true,
      joystick: Joystick(
        keyboardEnable: true,
        directional: JoystickDirectional(),
        actions: [
          JoystickAction(
            actionId: 1, //(required) Action identifier, will be sent to 'void joystickAction(JoystickActionEvent event) {}' when pressed
            sprite: Sprite('buttons/background.png'), // the action image
            spritePressed: Sprite('buttons/atack_range.png'), // Optional image to be shown when the action is fired
            align: JoystickActionAlign.BOTTOM_RIGHT,
            color: Colors.blue,
            size: 50,
            margin: EdgeInsets.only(bottom: 50, right: 160),
          )
        ],
      ),
      player: GamePlayer(
        NetPlayer.localPlayerData,
        _getInitPosition(),
        SpriteSheetHero.current,
        initDirection: _getDirection(),
      ),
      map: MainMap.mapData,
      colorFilter: GameColorFilter(color: Color.fromRGBO(255, 112, 214, 0.66), blendMode: BlendMode.hue),
      cameraMoveOnlyMapArea: true,
      progress: SizedBox.shrink(),
    );
  }

  Position _getInitPosition() {
    switch (showInEnum) {
      case ShowInEnum.left:
        return Position(tileSize * 2, tileSize * 10);
        break;
      case ShowInEnum.right:
        return Position(tileSize * 27, tileSize * 12);
        break;
      case ShowInEnum.top:
        return Position.empty();
        break;
      case ShowInEnum.bottom:
        return Position.empty();
        break;
      default:
        return Position.empty();
    }
  }

  void _exitMap(String value, BuildContext context) {
    var mapName = value.substring(value.lastIndexOf(":") + 1, value.length);
    MainMap.mapLocation = mapName;
    context.goTo(MainMap(
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
}
