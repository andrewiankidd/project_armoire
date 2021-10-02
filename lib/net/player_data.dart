import 'dart:developer' as developer;
import 'dart:ui';
import 'package:bonfire/bonfire.dart';
import 'package:project_armoire/net/net_data.dart';
import 'package:pubnub/pubnub.dart';

class PlayerNetData {
    Future<void> broadcastUpdate(String channel, String messageType, String data) async {
        // Channel abstraction for easier usage
        PublishResult publishResult = await NetData().publish(channel, {
            'messageType': messageType,
            'data': data,
        });
        developer.log('broadcastUpdate(${developer.inspect(publishResult)})', name: 'project_armoire.PlayerNetData');
    }
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