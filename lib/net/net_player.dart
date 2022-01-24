import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';
import 'package:project_armoire/net/net.dart';
import 'package:project_armoire/player/game_player.dart';
import 'package:pubnub/pubnub.dart';

// networked player methods
class NetPlayer {

    List<PlayerData> activePlayers;

    void handleMessage(NetMessage message) {
        developer.log('handleMessage: ${developer.inspect(message)}', name: 'project_armoire.NetPlayer');
        switch(message.messageType) {
            case "playerJoinData":
                NetPlayer().onPlayerJoin(PlayerData.fromJson(message.data));
                break;
            case "playerMoveData":
                NetPlayer().onPlayerMove(PlayerMoveData.fromJson(message.data));
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

        //
        this._removePlayer(playerData);
        //
        this._addPlayer(playerData);
    }

    void _removePlayer(PlayerData playerData) {
        // remove any matching playerIds to prevent duplication
        List<PlayerData> matchingPlayers = this.activePlayers.where((player) => player.playerId == playerData.playerId);
        if (matchingPlayers.length > 0) {
            this.activePlayers = (List.from(Set.from(this.activePlayers).difference(Set.from(matchingPlayers ))));
        }
    }

    void _addPlayer(PlayerData playerData) {
        // dump em in
        this.activePlayers.add(playerData);
    }

    // to move in a session
    void playerMoveData(PlayerMoveData moveData) {
        Net().broadcastUpdate('player', 'playerMoveData', moveData);
    }

    // what to do when player moves in a session
    void onPlayerMove(PlayerMoveData moveData) {
        developer.log('onPlayerMove: ${developer.inspect(moveData)}', name: 'project_armoire.NetPlayer');
        if (moveData.playerId == GamePlayer.playerData.playerId) {
            // ignore our own id
            return;
        }
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

    PlayerMoveData({this.playerId, this.direction, this.position}) {
        this.playerId = playerId;
        this.direction = direction;
        this.position = position;
    }

    PlayerMoveData.fromJson(Map<String, dynamic> json)
        : playerId =  json['playerId'],
        direction = JoystickMoveDirectional.values[json['direction']],
        position = Offset(json['position']['dx'],json['position']['dy']);

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'direction': direction.index,
        'position': {
            'dx': position.dx,
            'dy': position.dy,
        }
    };
}