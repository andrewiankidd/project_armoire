import 'dart:developer' as developer;
import 'package:bonfire/bonfire.dart';
import '../main.dart';
import '../net/net.dart';
import '../player/game_player.dart';

import '../player/remote_player.dart';
import '../player/sprite_sheet_hero.dart';

// networked player methods
class NetPlayer {

    static List<RemotePlayer> remotePlayers = [];

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
        if (GamePlayer.playerData != null && playerData.playerId == GamePlayer.playerData.playerId) {
            // ignore our own id
            return;
        }
        // announce own presence
        if (_existingPlayerById(playerData.playerId) == null) {
            this.playerJoin(GamePlayer.playerData);
        }
        // prevent dupes
        this._removePlayer(playerData);
        // add player
        this._addPlayer(playerData);
    }

    RemotePlayer _existingPlayerById(String playerId) {
        return NetPlayer.remotePlayers.firstWhere((player) => player.playerData.playerId == playerId, orElse: () => null);
    }

    void _removePlayer(PlayerData playerData) {
        // remove any matching playerIds to prevent duplication
        RemotePlayer existingPlayer = _existingPlayerById(playerData.playerId);
        if (existingPlayer != null) {
            NetPlayer.remotePlayers = (List.from(Set.from(NetPlayer.remotePlayers).difference(Set.from([playerData]))));
            gameStateKey.currentState.removeComponent(existingPlayer);
        }
    }

    void _addPlayer(PlayerData playerData) {
        //create remoteplayer
        RemotePlayer remotePlayer = RemotePlayer(playerData, Vector2(tileSize * 2, tileSize * 10), SpriteSheetHero.current);

        // dump em in
        NetPlayer.remotePlayers.add(remotePlayer);

        gameStateKey.currentState.addComponent(remotePlayer);
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

        RemotePlayer remotePlayer = NetPlayer.remotePlayers.firstWhere((remotePlayer) => remotePlayer.playerData.playerId == moveData.playerId);
        gameStateKey.currentState.moveComponent(remotePlayer, moveData);
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
    Vector2 position;

    PlayerMoveData({this.playerId, this.direction, this.position}) {
        this.playerId = playerId;
        this.direction = direction;
        this.position = position;
    }

    PlayerMoveData.fromJson(Map<String, dynamic> json)
        : playerId =  json['playerId'],
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