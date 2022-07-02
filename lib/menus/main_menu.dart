import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../main.dart';
import '../game/game.dart';
import '../player/game_player.dart';
import '../player/sprite_sheet_hero.dart';
import '../util/extensions.dart';
import '../net/net_player.dart';

class MainMenu extends StatefulWidget {

  @override
  MainMenuState createState() {
    return new MainMenuState();
  }
}

class MainMenuState extends State<MainMenu> {
  final TextEditingController _playerUsernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static PlayerData playerData;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width * 0.15,
                margin: EdgeInsets.all(20.0),
                child: Image.asset(
                  "assets/images/icons/menulogo.png",
                  fit: BoxFit.cover,
                ),
              ),
              Text('Project Armoire', style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic)),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                margin: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child:

                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                        ),
                        controller: _playerUsernameController,
                        textAlign: TextAlign.center,
                        validator: (text) {
                          if (text == null || text.isEmpty || text.length < 5) {
                            if (kDebugMode) {
                              _playerUsernameController.text = UniqueKey().toString();
                            }
                            return 'Username must be at least 5 characters!';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        child: Text("Play", style: TextStyle(fontSize: 20)),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {

                                // new player object
                                MainMenuState.playerData = new PlayerData(
                                  playerId: kDebugMode ? "${Config.deviceId}-${_playerUsernameController.value.text}" : Config.deviceId,
                                  playerUsername: _playerUsernameController.value.text,
                                  playerMoveData: new PlayerMoveData(
                                      playerId: kDebugMode ? "${Config.deviceId}-${_playerUsernameController.value.text}" : Config.deviceId,
                                      direction: JoystickMoveDirectional.MOVE_RIGHT,
                                      position: new Vector2(0, 0)
                                  )
                                );

                                // add to network
                                NetPlayer().playerJoin(MainMenuState.playerData);

                              context.goTo(Game(key: gameStateKey, playerData: MainMenuState.playerData));
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      )
    );
  }


}