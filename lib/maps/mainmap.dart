import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:project_armoire/main.dart';
import 'package:project_armoire/player/game_player.dart';
import 'package:project_armoire/player/sprite_sheet_hero.dart';
import 'package:project_armoire/util/exit_map_sensor.dart';
import 'package:project_armoire/util/extensions.dart';

class MainMap extends StatelessWidget {
  final ShowInEnum showInEnum;
  static String mapLocation = 'biome1';
  static bool isCloaked = false;

  const MainMap({Key key, this.showInEnum = ShowInEnum.left}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return this.buildMap(context);
  }

  Widget buildMap(BuildContext context) {
    return BonfireTiledWidget(
      showCollisionArea: true,
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
        _getInitPosition(),
        MainMap.isCloaked ? SpriteSheetHero.cloaked : SpriteSheetHero.uncloaked,
        initDirection: _getDirection(),
      ),
      map: TiledWorldMap(
        'maps/${MainMap.mapLocation}/data.json',
        forceTileSize: Size(tileSize, tileSize),
      )..registerObject(
        'sensorRight',
            (x, y, width, height) => ExitMapSensor(
          'sensorRight',
          Position(x, y),
          width,
          height,
              (v) => _exitMap(v, context),
        ),
      ),
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
    if (value == 'sensorRight') {
      MainMap.mapLocation = 'biome2';
      context.goTo(MainMap(
        showInEnum: ShowInEnum.left,
      ));
    }
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
