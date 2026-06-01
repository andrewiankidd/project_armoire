import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_armoire/util/game_logic.dart';
import 'package:project_armoire/util/show_in_enum.dart';

void main() {
  group('parseExit', () {
    test('parses target biome and explicit entry side', () {
      final t = parseExit('sensorRight:biome2:left');
      expect(t, isNotNull);
      expect(t.biome, 'biome2');
      expect(t.entrySide, ShowInEnum.left);
    });

    test('defaults entry side to left when omitted', () {
      final t = parseExit('sensorRight:biome2');
      expect(t.biome, 'biome2');
      expect(t.entrySide, ShowInEnum.left);
    });

    test('round trip a>b>a arrives on opposite sides', () {
      // walk off the right of biome1 -> arrive on the left of biome2
      expect(parseExit('sensorRight:biome2:left').entrySide, ShowInEnum.left);
      // walk off the left of biome2 -> arrive on the right of biome1
      expect(parseExit('sensorLeft:biome1:right').entrySide, ShowInEnum.right);
    });

    test('returns null when there is no target biome', () {
      expect(parseExit('sensorLeft'), isNull);
      expect(parseExit('sensorLeft:'), isNull);
    });
  });

  group('parseShowIn', () {
    test('maps known sides case-insensitively', () {
      expect(parseShowIn('left'), ShowInEnum.left);
      expect(parseShowIn('RIGHT'), ShowInEnum.right);
      expect(parseShowIn('Top'), ShowInEnum.top);
      expect(parseShowIn('bottom'), ShowInEnum.bottom);
    });

    test('falls back to left for an unknown side', () {
      expect(parseShowIn('sideways'), ShowInEnum.left);
    });
  });

  group('initPositionFor', () {
    test('left spawns near the left edge', () {
      final p = initPositionFor(ShowInEnum.left, 32);
      expect(p.x, 64);
      expect(p.y, 320);
    });

    test('right spawns near the right edge', () {
      final p = initPositionFor(ShowInEnum.right, 32);
      expect(p.x, 864);
      expect(p.y, 384);
    });

    test('left and right are on opposite sides', () {
      final l = initPositionFor(ShowInEnum.left, 32);
      final r = initPositionFor(ShowInEnum.right, 32);
      expect(r.x, greaterThan(l.x));
    });
  });

  group('shouldBroadcastMove', () {
    final t0 = DateTime(2020);
    final interval = Duration(milliseconds: 100);

    test('always sends on a direction change, even within the interval', () {
      expect(
        shouldBroadcastMove(
          current: JoystickMoveDirectional.MOVE_LEFT,
          lastBroadcast: JoystickMoveDirectional.MOVE_RIGHT,
          now: t0,
          lastBroadcastAt: t0,
          interval: interval,
        ),
        isTrue,
      );
    });

    test('suppresses same-direction spam within the interval', () {
      expect(
        shouldBroadcastMove(
          current: JoystickMoveDirectional.MOVE_LEFT,
          lastBroadcast: JoystickMoveDirectional.MOVE_LEFT,
          now: t0.add(Duration(milliseconds: 50)),
          lastBroadcastAt: t0,
          interval: interval,
        ),
        isFalse,
      );
    });

    test('sends the same direction once the interval has elapsed', () {
      expect(
        shouldBroadcastMove(
          current: JoystickMoveDirectional.MOVE_LEFT,
          lastBroadcast: JoystickMoveDirectional.MOVE_LEFT,
          now: t0.add(Duration(milliseconds: 100)),
          lastBroadcastAt: t0,
          interval: interval,
        ),
        isTrue,
      );
    });

    test('always sends a stop (IDLE) immediately', () {
      expect(
        shouldBroadcastMove(
          current: JoystickMoveDirectional.IDLE,
          lastBroadcast: JoystickMoveDirectional.MOVE_LEFT,
          now: t0,
          lastBroadcastAt: t0,
          interval: interval,
        ),
        isTrue,
      );
    });
  });

  group('shouldSnapToPosition', () {
    test('snaps when drift exceeds the threshold', () {
      expect(shouldSnapToPosition(Vector2(100, 0), Vector2(0, 0), 16), isTrue);
    });

    test('does not snap within the threshold', () {
      expect(shouldSnapToPosition(Vector2(10, 0), Vector2(0, 0), 16), isFalse);
    });

    test('does not snap exactly at the threshold', () {
      expect(shouldSnapToPosition(Vector2(16, 0), Vector2(0, 0), 16), isFalse);
    });
  });
}
