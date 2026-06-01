import 'package:bonfire/bonfire.dart';

import 'show_in_enum.dart';

// pure game logic, kept out of the engine subclasses + widgets so it can be
// unit tested (and so it survives a bonfire upgrade)

// where an exit sensor sends you: target biome + which side of it you arrive
// on, parsed from a sensor name like "sensorRight:biome2:left"
class ExitTarget {
  final String biome;
  final ShowInEnum entrySide;
  ExitTarget(this.biome, this.entrySide);
}

// exit objects are named "<sensorName>:<targetBiome>[:<entrySide>]"
// entrySide should be the opposite of the exit you walked through, so a round
// trip a>b>a lands you back where you left; returns null if there's no target
ExitTarget parseExit(String name) {
  final parts = name.split(":");
  if (parts.length < 2 || parts[1].isEmpty) {
    return null;
  }
  final side = parts.length > 2 ? parseShowIn(parts[2]) : ShowInEnum.left;
  return ExitTarget(parts[1], side);
}

ShowInEnum parseShowIn(String side) {
  switch (side.toLowerCase()) {
    case 'right':
      return ShowInEnum.right;
    case 'top':
      return ShowInEnum.top;
    case 'bottom':
      return ShowInEnum.bottom;
    case 'left':
    default:
      return ShowInEnum.left;
  }
}

// where a player spawns when arriving on a given side of a map
Vector2 initPositionFor(ShowInEnum showIn, double tileSize) {
  switch (showIn) {
    case ShowInEnum.left:
      return Vector2(tileSize * 2, tileSize * 10);
    case ShowInEnum.right:
      return Vector2(tileSize * 27, tileSize * 12);
    case ShowInEnum.top:
    case ShowInEnum.bottom:
    default:
      return Vector2.zero();
  }
}

// throttle the local player's state broadcast: a fast stream while moving and a
// slow heartbeat while idle, so remotes get steady positions + presence
bool shouldBroadcastState({
  DateTime now,
  DateTime lastAt,
  bool moving,
  Duration movingInterval,
  Duration idleInterval,
}) {
  final interval = moving ? movingInterval : idleInterval;
  return now.difference(lastAt) >= interval;
}

// newest-wins ordering for snapshots; drop anything not strictly newer
bool acceptSnapshot(int incomingSentAt, int lastSentAt) {
  return incomingSentAt > lastSentAt;
}

// de-sync check: hard-snap a remote when it has drifted further than threshold
bool shouldSnapToPosition(Vector2 target, Vector2 current, double threshold) {
  return target.distanceTo(current) > threshold;
}

// smooth chase toward a target position (t clamped to 0..1 by the caller)
Vector2 lerpVector(Vector2 a, Vector2 b, double t) {
  return Vector2(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}

// reject NaN/inf/wildly-out-of-range positions (cheap sanity, not security)
bool isSanePosition(double x, double y, double maxExtent) {
  if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) return false;
  return x >= -maxExtent && x <= maxExtent && y >= -maxExtent && y <= maxExtent;
}

// clamp a raw json index back to a safe enum value
JoystickMoveDirectional directionFromIndex(dynamic index) {
  if (index is int && index >= 0 && index < JoystickMoveDirectional.values.length) {
    return JoystickMoveDirectional.values[index];
  }
  return JoystickMoveDirectional.IDLE;
}
