import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../menus/main_menu.dart';
import '../player/sprite_sheet_hero.dart';
import 'package:pubnub/pubnub.dart';

import 'game/game.dart';
import 'net/net.dart';
import 'config/config.dart';

double tileSize = 32.0;
PubNub pubnub;
final gameStateKey = new GlobalKey<GameState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpriteSheetHero.load();
  if (!kIsWeb) {
    await Flame.device.setLandscape(); //TODO Comment when running for web
    await Flame.device.fullScreen(); //TODO Comment when running for web
  }
  await Config().init();
  await Net().init();
  runApp(MyApp());
}

enum ShowInEnum {
  left,
  right,
  top,
  bottom,
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Armoire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LayoutBuilder(builder: (context, constraints) {
        tileSize = max(constraints.maxHeight, constraints.maxWidth) / 30;
        print(tileSize);
        return MainMenu();
      }),
    );
  }
}
