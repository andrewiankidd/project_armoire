import 'dart:developer' as developer;
import 'package:bonfire/bonfire.dart';
import 'package:project_armoire/game/game.dart';
import 'package:project_armoire/menus/main_menu.dart';
import '../main.dart';
import '../net/net.dart';

import '../player/remote_player.dart';
import '../player/sprite_sheet_hero.dart';

// networked player methods
class NetPlayer {

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
        // // ignore local players
        if (MainMenuState.playerData.playerId == playerData.playerId) {
            // ignore our own id
            return;
        }

        Net().broadcastUpdate('player', 'playerJoinData', playerData);
    }

    // what to do when player joins session
    void onPlayerJoin(PlayerData playerData) {

        // // ignore local players
        if (MainMenuState.playerData.playerId == playerData.playerId) {
            // ignore our own id
            return;
        }

        // announce own presence
        developer.log('onPlayerJoin: ${developer.inspect(playerData)}', name: 'project_armoire.NetPlayer');
        if (GameState.remotePlayers.containsKey(playerData.playerId)) {
            this.playerJoin(playerData);
        }

        // prevent dupes
        this._removePlayer(playerData);

        // add player
        this._addPlayer(playerData);
    }

    void _removePlayer(PlayerData playerData) {
        // remove any matching playerIds to prevent duplication
        if (GameState.remotePlayers.containsKey(playerData.playerId)) {

            // remove from state
            GameState.remotePlayers.remove(playerData.playerId);

            // remove component
            gameStateKey.currentState.removeComponent(GameState.remotePlayers[playerData.playerId]);
        }
    }

    void _addPlayer(PlayerData playerData) {
        //create remoteplayer
        RemotePlayer remotePlayer = RemotePlayer(playerData, Vector2(tileSize * 2, tileSize * 10), SpriteSheetHero.current);

        // add to state
        GameState.remotePlayers[playerData.playerId] = remotePlayer;

        // add to component
        gameStateKey.currentState.addComponent(remotePlayer);
    }

    // to move in a session
    void playerMoveData(PlayerMoveData moveData) {
        // // ignore local players
        if (MainMenuState.playerData.playerId == moveData.playerId) {
            // ignore our own id
            return;
        }

        Net().broadcastUpdate('player', 'playerMoveData', moveData);
    }

    // what to do when player moves in a session
    void onPlayerMove(PlayerMoveData moveData) {
        developer.log('onPlayerMove: ${developer.inspect(moveData)}', name: 'project_armoire.NetPlayer');
        if (MainMenuState.playerData.playerId == moveData.playerId) {
            // ignore our own id
            return;
        }

        gameStateKey.currentState.moveComponent(GameState.remotePlayers[moveData.playerId], moveData);
    }
}

// networked player properties
class PlayerData {
    String playerId;
    String playerUsername;
    PlayerMoveData playerMoveData;

    PlayerData({this.playerId, this.playerUsername, this.playerMoveData});
    PlayerData.fromJson(Map<String, dynamic> json):
        playerId =  json['playerId'],
        playerUsername = json['playerUsername'],
        playerMoveData = PlayerMoveData.fromJson(json['playerMoveData']);

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'playerUsername': playerUsername,
        'playerMoveData': playerMoveData
    };
}

// networked player movement properties
class PlayerMoveData {
    String playerId;
    JoystickMoveDirectional direction;
    Vector2 position;

    PlayerMoveData({this.playerId, this.direction, this.position}) {
        this.playerId = playerId;
        this.direction = direction;
        this.position = position;
    }

    PlayerMoveData.fromJson(Map<String, dynamic> json):
        playerId =  json['playerId'],
        direction = JoystickMoveDirectional.values[json['direction']],
        position = Vector2(json['position']['x'], json['position']['y']);

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'direction': direction.index,
        'position': {
            'x': position.x,
            'y': position.y,
        }
    };
}