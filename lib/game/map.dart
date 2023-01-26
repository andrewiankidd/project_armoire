import 'dart:convert';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_armoire/game/game.dart';
import '../main.dart';
import '../util/exit_map_sensor.dart';

class TiledMapData {
  String mapName;
  String fromMapName;
  Map<String, Vector2> mapSensors;
  TiledWorldMap tiledWorldMap;

  TiledMapData([
    String this.mapName,
    String this.fromMapName,
    Map<String, Vector2> this.mapSensors,
    TiledWorldMap this.tiledWorldMap,
  ]) {
    print('new TiledMapData created');
  }
}

class TiledMapBuilder {
  final Function(TiledMapData tiledMapData) refreshMap;

  TiledMapData tiledMapData;

  TiledMapBuilder({
    @required this.refreshMap
  }) {
      //this.tiledMapData = this.buildTiledWorldMap(this.mapName, this.fromMapName);
    print('new TiledMapBuilder');
  }

  Future<TiledMapData> buildTiledWorldMap([String mapName, String fromMapName = "spawn"]) async {

    var n = TiledMapData();
    n.mapName = mapName;
    n.fromMapName = fromMapName;
    n.tiledWorldMap = TiledWorldMap(
      'maps/${mapName}/data.json',
      forceTileSize: Size(tileSize, tileSize),
    );
    n.mapSensors = {};

    // load map data
    await rootBundle.loadString('assets/images/' + n.tiledWorldMap.path).then((value) {

      // decode map data
      final decoded = json.decode(value);
      print('mapdata decoded successfully');

      // create objectGroups
      final Iterable objectGroups = decoded['layers'].where((element) => element["type"] == "objectgroup");
      print('found ${objectGroups.length} objectGroups');

      // init sensors
      objectGroups.forEach((objectGroup) {
        print('objectGroup: ${objectGroup['name']}');

        // load objects
        objectGroup['objects'].forEach((object) {
          if (object['name'].startsWith('sensor')) {

            String sensorTarget = object['name'].substring(object['name'].lastIndexOf(":") + 1, object['name'].length);

            // track sensor
            n.mapSensors[sensorTarget] = Vector2(object['x'].toDouble(), object['y'].toDouble());

            // register sensor
            n.tiledWorldMap.registerObject(
              object['name'],
              (p) => ExitMapSensor(
                object['name'],
                p.position,
                p.size,
                (v) => this._exitMap(n.mapName, v),
              ),
            );
          }
        });
        print('sensor init complete');
      });
      print('map init complete');
    });
    return n;
  }

  void _exitMap(String currentMapName, String exitMapSensorName) {
    print('exitMap');
    var targetMapName = exitMapSensorName.substring(exitMapSensorName.lastIndexOf(":") + 1, exitMapSensorName.length);
    this.refreshMap(TiledMapData(targetMapName, currentMapName));
  }
}
