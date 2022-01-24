import 'dart:developer' as developer;
import 'package:pubnub/pubnub.dart';
import 'package:project_armoire/main.dart';
import 'package:project_armoire/config/config.dart';

import 'net_player.dart';

class NetMessage {
  String messageType;
  var data;

  NetMessage(messageType, data){
    this.messageType = messageType;
    this.data = data;
  }

  NetMessage.fromJson(Map<String, dynamic> json)
      : messageType =  json['messageType'],
        data = json['data'];

  Map<String, dynamic> toJson() =>
      {
        'messageType': messageType,
        'data': data
      };
}

class Net {

  List<PlayerData> activePlayers;

  void init() async {
    developer.log('pubnub init', name: 'project_armoire.Net');

    // Create PubNub instance with default keyset.
    pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: Config().get('PUBSUB_SUBSCRIBEKEY'),
            publishKey: Config().get('PUBSUB_PUBLISHKEY'),
            uuid: UUID(Config().get('PUBSUB_UUID'))
        )
    );

    if (pubnub == null) {
      developer.log('failed to init pubnub!', name: 'project_armoire.Net');
    }
    // Subscribe to a channel
    Subscription subscription = pubnub.subscribe(channels: {'player', 'messages'});
    subscription.messages.take(1).listen((message) {
      this.handleMessage(message);
    });
  }

  void handleMessage(Envelope envelope) {
    developer.log('handleMessage: ${developer.inspect(envelope.content)}', name: 'project_armoire.Net');
    NetMessage netMessage = NetMessage.fromJson(envelope.content);
    switch(envelope.channel) {
      case "player":
          NetPlayer().handleMessage(netMessage);
        break;
      default:
        throw "unknown message type ${envelope.channel}";
    }
  }

  Future<PublishResult> publishMessage(String channel, dynamic message,
      {Keyset keyset,
        String using,
        dynamic meta,
        bool storeMessage,
        int ttl
      }
    ) async {
    return pubnub.publish(channel, message, keyset: keyset, using: using, storeMessage: storeMessage, ttl: ttl);
  }

  Future<void> broadcastUpdate(String channel, String messageType, var data) async {
    // Channel abstraction for easier usage
    PublishResult publishResult = await this.publishMessage(channel, NetMessage(messageType, data));
    //developer.log('broadcastUpdate(${developer.inspect(publishResult)})', name: 'project_armoire.Net');
  }
}