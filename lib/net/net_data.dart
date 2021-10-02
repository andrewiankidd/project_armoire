import 'dart:developer' as developer;
import 'package:pubnub/pubnub.dart';
import 'package:project_armoire/main.dart';
import 'package:project_armoire/config/config.dart';


class NetData {

  void init() async {
    developer.log('pubnub init', name: 'project_armoire.NetData');

    // Create PubNub instance with default keyset.
    pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: Config().get('PUBSUB_SUBSCRIBEKEY'),
            publishKey: Config().get('PUBSUB_PUBLISHKEY'),
            uuid: UUID('demo')
        )
    );

    if (pubnub == null) {
      developer.log('failed to init pubnub!', name: 'project_armoire.NetData');
    }
    // Subscribe to a channel
    Subscription subscription = pubnub.subscribe(channels: {'playermove'});

    subscription.messages.take(1).listen((message) {
      developer.log('MESSAGE: ${developer.inspect(message.content)}', name: 'project_armoire.NetData');
    });
  }

  Future<PublishResult> publish(String channel, dynamic message,
      {Keyset keyset,
        String using,
        dynamic meta,
        bool storeMessage,
        int ttl
      }
    ) async {
    return pubnub.publish(channel, message, keyset: keyset, using: using, storeMessage: storeMessage, ttl: ttl);
  }
}