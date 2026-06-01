import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../game/game.dart';
import '../player/game_player.dart';
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

  @override
  void initState() {
    super.initState();
    // pre-fill a throwaway username in debug builds for quick iteration
    if (kDebugMode && _playerUsernameController.text.isEmpty) {
      _playerUsernameController.text = UniqueKey().toString();
    }
  }

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

                                GamePlayer.playerData = PlayerData(
                                  playerId: kDebugMode ? "${Config.deviceId}-${_playerUsernameController.value.text}" : Config.deviceId,
                                  playerUsername: _playerUsernameController.value.text,
                                );
                                // no explicit join: GamePlayer broadcasts its
                                // state (which carries identity + map) on entry

                              context.goTo(Game());
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