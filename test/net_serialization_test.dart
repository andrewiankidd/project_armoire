import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_armoire/net/net.dart';
import 'package:project_armoire/net/net_player.dart';

void main() {
  group('PlayerData', () {
    test('round-trips id, username and position', () {
      final data = PlayerData(
        playerId: 'abc',
        playerUsername: 'tester',
        position: Vector2(12.5, 34.0),
      );
      final restored = PlayerData.fromJson(data.toJson());
      expect(restored.playerId, 'abc');
      expect(restored.playerUsername, 'tester');
      expect(restored.position.x, 12.5);
      expect(restored.position.y, 34.0);
    });

    test('handles a null position (pre-game join)', () {
      final data = PlayerData(playerId: 'abc', playerUsername: 'tester');
      final wire = data.toJson();
      expect(wire['position'], isNull);
      final restored = PlayerData.fromJson(wire);
      expect(restored.position, isNull);
    });

    test('survives a JSON string round-trip', () {
      final data = PlayerData(
        playerId: 'abc',
        playerUsername: 'tester',
        position: Vector2(12.5, 34.5),
      );
      final restored = PlayerData.fromJson(json.decode(json.encode(data.toJson())));
      expect(restored.position.x, 12.5);
      expect(restored.position.y, 34.5);
    });
  });

  group('PlayerMoveData', () {
    test('round-trips id, direction and position', () {
      final data = PlayerMoveData(
        playerId: 'abc',
        direction: JoystickMoveDirectional.MOVE_UP_RIGHT,
        position: Vector2(1.5, 2.5),
      );
      final restored = PlayerMoveData.fromJson(data.toJson());
      expect(restored.playerId, 'abc');
      expect(restored.direction, JoystickMoveDirectional.MOVE_UP_RIGHT);
      expect(restored.position.x, 1.5);
      expect(restored.position.y, 2.5);
    });

    test('survives a JSON string round-trip', () {
      final data = PlayerMoveData(
        playerId: 'abc',
        direction: JoystickMoveDirectional.MOVE_DOWN,
        position: Vector2(3.5, 4.5),
      );
      final restored = PlayerMoveData.fromJson(json.decode(json.encode(data.toJson())));
      expect(restored.direction, JoystickMoveDirectional.MOVE_DOWN);
      expect(restored.position.x, 3.5);
    });
  });

  group('NetMessage', () {
    test('round-trips type and data payload', () {
      final msg = NetMessage('playerMoveData', {'playerId': 'abc'});
      final restored = NetMessage.fromJson(msg.toJson());
      expect(restored.messageType, 'playerMoveData');
      expect(restored.data['playerId'], 'abc');
    });

    test('wraps a PlayerData payload end to end', () {
      final data = PlayerData(playerId: 'abc', playerUsername: 'tester');
      final wire = NetMessage('playerJoinData', data.toJson()).toJson();
      final restored = NetMessage.fromJson(json.decode(json.encode(wire)));
      final restoredData = PlayerData.fromJson(restored.data);
      expect(restored.messageType, 'playerJoinData');
      expect(restoredData.playerId, 'abc');
      expect(restoredData.playerUsername, 'tester');
    });
  });
}
