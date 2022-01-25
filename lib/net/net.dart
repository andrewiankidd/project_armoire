import 'dart:developer' as developer;
import 'package:pubnub/pubnub.dart';
import '../main.dart';
import '../config/config.dart';

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

  void init() async {
    developer.log('pubnub init', name: 'project_armoire.Net');

    // Create PubNub instance with default keyset.
    // default to rate limited demo keys
    pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: Config().get(configKey: 'PUBNUB_SUBSCRIBEKEY', defaultValue: 'sub-c-3990fb9c-7d41-11ec-add2-a260b15b99c5'),
            publishKey: Config().get(configKey: 'PUBNUB_PUBLISHKEY', defaultValue: 'pub-c-fa8e2515-5698-49ff-bd0d-788d4a0cc04f'),
            uuid: UUID(Config().get(configKey: 'PUBNUB_UUID', defaultValue: 'demo'))
        )
    );

    if (pubnub == null) {
      developer.log('failed to init pubnub!', name: 'project_armoire.Net');
    }
    // Subscribe to a channel
    Subscription subscription = pubnub.subscribe(channels: {'player', 'messages'});
    subscription.messages.listen((message) {
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
    developer.log('broadcastUpdate(${developer.inspect(publishResult)})', name: 'project_armoire.Net');
  }
}