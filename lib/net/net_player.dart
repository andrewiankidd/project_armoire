import 'dart:developer' as developer;
import 'dart:ui';
import 'package:bonfire/bonfire.dart';
import 'package:project_armoire/net/net.dart';
import 'package:pubnub/pubnub.dart';

class NetPLayer {
    Future<void> broadcastUpdate(String channel, String messageType, String data) async {
        // Channel abstraction for easier usage
        PublishResult publishResult = await Net().publishMessage(channel, {
            'messageType': messageType,
            'data': data,
        });
        developer.log('broadcastUpdate(${developer.inspect(publishResult)})', name: 'project_armoire.PlayerNetData');
    }

    // to join a session
    void playerJoin(PlayerData playerData) {

    }

    // what to do when player joins session
    void onPlayerJoin(PlayerData playerData) {

    }
}

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