import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_armoire/net/net.dart';
import 'package:project_armoire/net/net_player.dart';

void main() {
  group('PlayerData', () {
    test('round-trips id and username', () {
      final data = PlayerData(playerId: 'abc', playerUsername: 'tester');
      final restored = PlayerData.fromJson(json.decode(json.encode(data.toJson())));
      expect(restored.playerId, 'abc');
      expect(restored.playerUsername, 'tester');
    });
  });

  group('PlayerState', () {
    PlayerState sample() => PlayerState(
          playerId: 'abc',
          username: 'tester',
          map: 'biome2',
          position: Vector2(12.5, 34.5),
          direction: JoystickMoveDirectional.MOVE_UP_RIGHT,
          intensity: 0.5,
          sentAt: 1717200000000,
        );

    test('round-trips all fields', () {
      final restored = PlayerState.fromJson(sample().toJson());
      expect(restored.playerId, 'abc');
      expect(restored.username, 'tester');
      expect(restored.map, 'biome2');
      expect(restored.position.x, 12.5);
      expect(restored.position.y, 34.5);
      expect(restored.direction, JoystickMoveDirectional.MOVE_UP_RIGHT);
      expect(restored.intensity, 0.5);
      expect(restored.sentAt, 1717200000000);
    });

    test('survives a JSON string round-trip', () {
      final restored = PlayerState.fromJson(json.decode(json.encode(sample().toJson())));
      expect(restored.position.x, 12.5);
      expect(restored.direction, JoystickMoveDirectional.MOVE_UP_RIGHT);
      expect(restored.map, 'biome2');
    });

    test('tolerates integer position/intensity coming back from json', () {
      // whole numbers can decode as int; fromJson must coerce, not throw
      final wire = {
        'playerId': 'a',
        'username': 'b',
        'map': 'biome1',
        'position': {'x': 10, 'y': 20},
        'direction': JoystickMoveDirectional.IDLE.index,
        'intensity': 1,
        'sentAt': 5,
      };
      final restored = PlayerState.fromJson(wire);
      expect(restored.position.x, 10.0);
      expect(restored.intensity, 1.0);
    });

    test('clamps a bad direction index to IDLE', () {
      final wire = sample().toJson();
      wire['direction'] = 9999;
      expect(PlayerState.fromJson(wire).direction, JoystickMoveDirectional.IDLE);
    });
  });

  group('NetMessage', () {
    test('stamps and round-trips the protocol version', () {
      final msg = NetMessage('playerState', {'playerId': 'abc'});
      expect(msg.v, NetMessage.protocolVersion);
      final restored = NetMessage.fromJson(json.decode(json.encode(msg.toJson())));
      expect(restored.v, NetMessage.protocolVersion);
      expect(restored.messageType, 'playerState');
      expect(restored.data['playerId'], 'abc');
    });

    test('wraps a PlayerState payload end to end', () {
      final state = PlayerState(
        playerId: 'abc',
        username: 'tester',
        map: 'biome1',
        position: Vector2(1.0, 2.0),
        direction: JoystickMoveDirectional.MOVE_DOWN,
        intensity: 1.0,
        sentAt: 1,
      );
      final wire = NetMessage('playerState', state.toJson()).toJson();
      final restored = NetMessage.fromJson(json.decode(json.encode(wire)));
      final restoredState = PlayerState.fromJson(restored.data);
      expect(restoredState.playerId, 'abc');
      expect(restoredState.map, 'biome1');
    });
  });
}
