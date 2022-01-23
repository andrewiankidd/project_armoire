
import 'package:flutter/material.dart';
import 'package:project_armoire/config/config.dart';
import 'package:project_armoire/maps/mainmap.dart';
import 'package:project_armoire/util/extensions.dart';
import 'package:project_armoire/net/net_player.dart';

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

                                NetPlayer.localPlayerData = PlayerData(
                                  playerId: Config.deviceId(),
                                  playerUsername: _playerUsernameController.value.text,
                                );
                                NetPlayer().playerJoin(NetPlayer.localPlayerData);

                              context.goTo(MainMap());
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