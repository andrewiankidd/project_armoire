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
      expect(parseExit('sensorRight:biome2:left').entrySide, ShowInEnum.left);
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
      expect(initPositionFor(ShowInEnum.right, 32).x,
          greaterThan(initPositionFor(ShowInEnum.left, 32).x));
    });
  });

  group('shouldBroadcastState', () {
    final t0 = DateTime(2020);
    final moving = Duration(milliseconds: 100);
    final idle = Duration(milliseconds: 2000);

    test('broadcasts while moving once the moving interval elapses', () {
      expect(
        shouldBroadcastState(
          now: t0.add(Duration(milliseconds: 100)),
          lastAt: t0,
          moving: true,
          movingInterval: moving,
          idleInterval: idle,
        ),
        isTrue,
      );
    });

    test('suppresses while moving within the moving interval', () {
      expect(
        shouldBroadcastState(
          now: t0.add(Duration(milliseconds: 50)),
          lastAt: t0,
          moving: true,
          movingInterval: moving,
          idleInterval: idle,
        ),
        isFalse,
      );
    });

    test('uses the slow idle interval when idle', () {
      // 500ms elapsed: would send if moving, but idle waits for the 2s heartbeat
      expect(
        shouldBroadcastState(
          now: t0.add(Duration(milliseconds: 500)),
          lastAt: t0,
          moving: false,
          movingInterval: moving,
          idleInterval: idle,
        ),
        isFalse,
      );
      expect(
        shouldBroadcastState(
          now: t0.add(Duration(milliseconds: 2000)),
          lastAt: t0,
          moving: false,
          movingInterval: moving,
          idleInterval: idle,
        ),
        isTrue,
      );
    });
  });

  group('acceptSnapshot', () {
    test('accepts strictly newer timestamps', () {
      expect(acceptSnapshot(100, 50), isTrue);
    });

    test('rejects older or equal timestamps (stale / out of order)', () {
      expect(acceptSnapshot(50, 100), isFalse);
      expect(acceptSnapshot(100, 100), isFalse);
    });

    test('accepts the first snapshot (initial -1)', () {
      expect(acceptSnapshot(0, -1), isTrue);
    });
  });

  group('shouldSnapToPosition', () {
    test('snaps when drift exceeds the threshold', () {
      expect(shouldSnapToPosition(Vector2(100, 0), Vector2(0, 0), 16), isTrue);
    });

    test('does not snap within the threshold', () {
      expect(shouldSnapToPosition(Vector2(10, 0), Vector2(0, 0), 16), isFalse);
    });
  });

  group('lerpVector', () {
    test('midpoint at t=0.5', () {
      final p = lerpVector(Vector2(0, 0), Vector2(10, 20), 0.5);
      expect(p.x, 5);
      expect(p.y, 10);
    });

    test('endpoints at t=0 and t=1', () {
      expect(lerpVector(Vector2(2, 3), Vector2(8, 9), 0).x, 2);
      expect(lerpVector(Vector2(2, 3), Vector2(8, 9), 1).y, 9);
    });
  });

  group('isSanePosition', () {
    test('accepts in-range finite positions', () {
      expect(isSanePosition(100, 200, 1000), isTrue);
    });

    test('rejects NaN / infinity', () {
      expect(isSanePosition(double.nan, 0, 1000), isFalse);
      expect(isSanePosition(0, double.infinity, 1000), isFalse);
    });

    test('rejects out-of-range positions', () {
      expect(isSanePosition(5000, 0, 1000), isFalse);
      expect(isSanePosition(0, -5000, 1000), isFalse);
    });
  });

  group('directionFromIndex', () {
    test('maps a valid index', () {
      expect(directionFromIndex(JoystickMoveDirectional.MOVE_LEFT.index),
          JoystickMoveDirectional.MOVE_LEFT);
    });

    test('falls back to IDLE for bad input', () {
      expect(directionFromIndex(9999), JoystickMoveDirectional.IDLE);
      expect(directionFromIndex(-1), JoystickMoveDirectional.IDLE);
      expect(directionFromIndex('x'), JoystickMoveDirectional.IDLE);
      expect(directionFromIndex(null), JoystickMoveDirectional.IDLE);
    });
  });
}
