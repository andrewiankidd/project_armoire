import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:bonfire/bonfire.dart';
import 'package:project_armoire/net/net.dart';
import 'package:pubnub/pubnub.dart';

// networked player methods
class NetPlayer {

    static PlayerData localPlayerData;

    void handleMessage(NetMessage message) {
        developer.log('handleMessage: ${developer.inspect(message)}', name: 'project_armoire.NetPlayer');


        switch(message.messageType) {
            case "playerJoinData":
                var decodedMessage = PlayerData().fromJson(message.content);

                NetPlayer().onPlayerJoin(message.data);
                break;
            case "playerMoveData":
                NetPlayer().onPlayerMove(message.data);
                break;
            default:
                throw "unknown message type ${message.messageType}";
        }
    }

    // to join a session
    void playerJoin(PlayerData playerData) {
        Net().broadcastUpdate('player', 'playerJoinData', playerData);
    }

    // what to do when player joins session
    void onPlayerJoin(PlayerData playerData) {
        developer.log('onPlayerJoin: ${developer.inspect(playerData)}', name: 'project_armoire.NetPlayer');
    }

    // to move in a session
    void playerMoveData(PlayerMoveData moveData) {
        Net().broadcastUpdate('player', 'playerMoveData', moveData);
    }

    // what to do when player moves in a session
    void onPlayerMove(PlayerData moveData) {
        developer.log('onPlayerMove: ${developer.inspect(moveData)}', name: 'project_armoire.NetPlayer');

    }
}

// networked player properties
class PlayerData {
    String playerId;
    String playerUsername;

    PlayerData({this.playerId, this.playerUsername});
    PlayerData.fromJson(Map<String, dynamic> json)
        : playerId =  json['playerId'],
        playerUsername = json['playerUsername'];

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'playerUsername': playerUsername
    };
}

// networked player movement properties
class PlayerMoveData {
    String playerId;
    JoystickMoveDirectional direction;
    Offset position;

    PlayerMoveData({this.playerId, this.direction, this.position});
    PlayerMoveData.fromJson(Map<String, dynamic> json)
        : playerId =  json['playerId'],
        direction = json['direction'],
        position = json['position'];

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'direction': direction,
        'position': position,
    };
}