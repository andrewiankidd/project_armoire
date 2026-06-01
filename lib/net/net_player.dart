import 'dart:developer' as developer;
import 'package:bonfire/bonfire.dart';
import '../main.dart';
import '../game/game.dart';
import '../net/net.dart';
import '../player/game_player.dart';
import '../player/remote_player.dart';
import '../player/sprite_sheet_hero.dart';
import '../util/game_logic.dart';

// networked player methods
class NetPlayer {

    static List<RemotePlayer> remotePlayers = [];

    // how long without a snapshot before we treat a remote as gone
    static const int staleTimeoutMs = 6000;

    void handleMessage(NetMessage message) {
        switch (message.messageType) {
            case 'playerState':
                onPlayerState(PlayerState.fromJson(message.data));
                break;
            case 'playerLeave':
                onPlayerLeave(message.data['playerId']);
                break;
            default:
                developer.log('unknown message type ${message.messageType}', name: 'project_armoire.NetPlayer');
        }
    }

    // broadcast our current state (doubles as movement + presence heartbeat)
    void broadcastState(PlayerState state) {
        Net().broadcastUpdate('player', 'playerState', state);
    }

    // best-effort departure notice
    void broadcastLeave(String playerId) {
        Net().broadcastUpdate('player', 'playerLeave', {'playerId': playerId});
    }

    // what to do with a remote player's snapshot
    void onPlayerState(PlayerState state) {
        // ignore traffic until we're actually in the game ourselves
        if (GamePlayer.playerData == null || GameState.current == null) return;
        // ignore our own id (pubnub echoes our own publishes back to us)
        if (state.playerId == GamePlayer.playerData.playerId) return;
        // cheap sanity: drop obviously bad payloads (anti-grief, not security)
        if (!isSanePosition(state.position.x, state.position.y, tileSize * 200)) return;

        final existing = _existingPlayerById(state.playerId);

        // map filter: only render players who are on our current map
        if (state.map != GameState.mapLocation) {
            // they walked off to another map; drop them from our world
            if (existing != null) _removePlayer(state.playerId);
            return;
        }

        if (existing == null) {
            _addPlayer(state);
        } else {
            // update in place; no destroy/recreate, no flicker
            existing.applySnapshot(state);
        }
    }

    void onPlayerLeave(String playerId) {
        if (playerId == null) return;
        _removePlayer(playerId);
    }

    RemotePlayer _existingPlayerById(String playerId) {
        return NetPlayer.remotePlayers.firstWhere((p) => p.playerData.playerId == playerId, orElse: () => null);
    }

    void _removePlayer(String playerId) {
        final existing = _existingPlayerById(playerId);
        if (existing != null) {
            NetPlayer.remotePlayers.removeWhere((p) => p.playerData.playerId == playerId);
            GameState.current?.removeComponent(existing);
        }
    }

    void _addPlayer(PlayerState state) {
        RemotePlayer remotePlayer = RemotePlayer(
            PlayerData(playerId: state.playerId, playerUsername: state.username),
            state.position.clone(),
            SpriteSheetHero.current,
        );
        remotePlayer.applySnapshot(state);
        NetPlayer.remotePlayers.add(remotePlayer);
        GameState.current?.addComponent(remotePlayer);
    }

    // drop the whole roster (e.g. when a map transition builds a fresh game)
    static void clearRoster() {
        remotePlayers.clear();
    }

    // remove remotes we haven't heard a snapshot from recently
    static void cullStale() {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final stale = remotePlayers.where((p) => nowMs - p.lastSeenMs > staleTimeoutMs).toList();
        for (final p in stale) {
            remotePlayers.remove(p);
            GameState.current?.removeComponent(p);
        }
    }
}

// stable identity for a player (id + display name)
class PlayerData {
    String playerId;
    String playerUsername;

    PlayerData({this.playerId, this.playerUsername});
    PlayerData.fromJson(Map<String, dynamic> json)
        : playerId = json['playerId'],
        playerUsername = json['playerUsername'];

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'playerUsername': playerUsername,
    };
}

// a periodic snapshot of where a player is + what they're doing; also carries
// identity (id/username) and map so any single message fully describes a player
class PlayerState {
    String playerId;
    String username;
    String map;
    Vector2 position;
    JoystickMoveDirectional direction;
    double intensity;
    int sentAt;

    PlayerState({
        this.playerId,
        this.username,
        this.map,
        this.position,
        this.direction,
        this.intensity,
        this.sentAt,
    });

    PlayerState.fromJson(Map<String, dynamic> json)
        : playerId = json['playerId'],
        username = json['username'],
        map = json['map'],
        position = Vector2(
            (json['position']['x'] as num).toDouble(),
            (json['position']['y'] as num).toDouble(),
        ),
        direction = directionFromIndex(json['direction']),
        intensity = (json['intensity'] as num).toDouble(),
        sentAt = json['sentAt'];

    Map<String, dynamic> toJson() =>
    {
        'playerId': playerId,
        'username': username,
        'map': map,
        'position': {
            'x': position.x,
            'y': position.y,
        },
        'direction': direction.index,
        'intensity': intensity,
        'sentAt': sentAt,
    };
}
