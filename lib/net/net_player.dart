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

        // ignore network traffic until we're actually in the game ourselves
        if (GamePlayer.playerData == null || gameStateKey.currentState == null) {
            return;
        }
        if (playerData.playerId == GamePlayer.playerData.playerId) {
            // ignore our own id
            return;
        }
        // announce own presence to a player we haven't seen before
        if (_existingPlayerById(playerData.playerId) == null) {
            // include our current position so we spawn in the right place for them
            if (GamePlayer.current != null) {
                GamePlayer.playerData.position = GamePlayer.current.position.clone();
            }
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
            NetPlayer.remotePlayers.removeWhere((player) => player.playerData.playerId == playerData.playerId);
            gameStateKey.currentState.removeComponent(existingPlayer);
        }
    }

    void _addPlayer(PlayerData playerData) {
        // spawn at the joiner's reported position, falling back to the default
        Vector2 spawn = playerData.position ?? Vector2(tileSize * 2, tileSize * 10);

        //create remoteplayer
        RemotePlayer remotePlayer = RemotePlayer(playerData, spawn, SpriteSheetHero.current);

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

        // ignore network traffic until we're actually in the game ourselves
        if (GamePlayer.playerData == null || gameStateKey.currentState == null) {
            return;
        }
        if (moveData.playerId == GamePlayer.playerData.playerId) {
            // ignore our own id
            return;
        }

        RemotePlayer remotePlayer = _existingPlayerById(moveData.playerId);
        if (remotePlayer == null) {
            // move arrived for a player we haven't added yet; ignore it
            return;
        }
        gameStateKey.currentState.moveComponent(remotePlayer, moveData);
    }
}

// networked player properties
class PlayerData {
    String playerId;
    String playerUsername;
    Vector2 position;

    PlayerData({this.playerId, this.playerUsername, this.position});
    PlayerData.fromJson(Map<String, dynamic> json)
        : playerId =  json['playerId'],
        playerUsername = json['playerUsername'],
        position = json['position'] != null
            ? Vector2(json['position']['x'], json['position']['y'])
            : null;

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'playerUsername': playerUsername,
        'position': position == null ? null : {
            'x': position.x,
            'y': position.y,
        }
    };
}

// networked player movement properties
class PlayerMoveData {
    String playerId;
    JoystickMoveDirectional direction;
    Vector2 position;

    PlayerMoveData({this.playerId, this.direction, this.position});

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