import 'dart:async';
import 'dart:convert';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_armoire/net/net_player.dart';
import '../main.dart';
import '../util/exit_map_sensor.dart';

class TiledMap {
  final Function(String tiledWorldMapName) refreshMap;

  final PlayerData playerData;
  final String fromSensor;
  final Vector2 cameraOffset;
  final String mapName;

  TiledWorldMap tiledWorldMap;
  static Map<String, Vector2> mapSensors = {};

  TiledMap({
    BuildContext context,
    this.playerData,
    this.mapName,
    this.fromSensor = null,
    this.cameraOffset = null,
    @required this.refreshMap
  }) {
      this.tiledWorldMap = this.buildTiledWorldMap(context, this.mapName);
      this.refreshMap(this.mapName);
  }

  TiledWorldMap buildTiledWorldMap(BuildContext context, String mapName) {
    TiledWorldMap newTiledWorldMap = TiledWorldMap(
      'maps/${mapName}/data.json',
      forceTileSize: Size(tileSize, tileSize),
    );

    final snapshot = rootBundle.loadString('assets/images/' + newTiledWorldMap.path);
    snapshot.then((value) {

      final decoded = json.decode(value);
      print('mapdata decoded successfully');
      final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");
      print('found ${objectGroups.length} objectGroups');

      TiledMap.mapSensors = {};
      objectGroups.forEach((objectGroup) {
        print('objectGroup: ${objectGroup['name']}');

        // load objects
        objectGroup['objects'].forEach((object) {
          if (object['name'].startsWith('sensor')) {

            String sensorTarget = object['name'].substring(object['name'].lastIndexOf(":") + 1, object['name'].length);

            // track sensor
            TiledMap.mapSensors[sensorTarget] = Vector2(object['x'].toDouble(), object['y'].toDouble());

            // register sensor
            newTiledWorldMap.registerObject(
              object['name'],
              (p) => ExitMapSensor(
                object['name'],
                p.position,
                p.size,
                (v) => this._exitMap(v, context),
              ),
            );
          }
        });
      });

      print('map init');
    });

    return newTiledWorldMap;
  }

  void _exitMap(String value, BuildContext context) {
    var curMapName = this.mapName;
    var targetMapName = value.substring(value.lastIndexOf(":") + 1, value.length);
    //
    // print('exit map: ${curMapName} > ${targetMapName}');
    //this.tiledWorldMap = TiledMap.buildTiledWorldMap(context, targetMapName);
    this.refreshMap(targetMapName);

    //

    // var cameraOffset = _controller.camera.relativeOffset;
    // // var cameraOffset = _controller.camera.position;// - _controller.camera.relativeOffset;
    // // print('camera.position ${_controller.camera.position}');
    // // print('camera.cameraRect ${_controller.camera.cameraRect}');
    // // print('camera.relativeOffset ${_controller.camera.relativeOffset}');
    // // print('camera.canvasSize ${_controller.camera.canvasSize}');
    // // print('camera.viewport.canvasSize ${_controller.camera.viewport.canvasSize}');
    // // print('camera.viewport.effectiveSize ${_controller.camera.viewport.effectiveSize}');
    // // print('camera.gameSize ${_controller.camera.gameSize}');
    // // print('player.position ${_controller.player.position}');
    // // print('cameraOffset ${cameraOffset}');
    // // _controller.player.absolutePosition;
    //
    // GameState.mapName = targetMapName;
    // Navigator.push(context, MaterialPageRoute(builder: (_) => new Game(
    //   playerData: this.gamePlayer.playerData,
    //   fromSensor: curMapName,
    //   cameraOffset: cameraOffset,
    // )));
  }
}
