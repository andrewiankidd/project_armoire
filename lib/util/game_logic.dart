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

// throttle: always broadcast a direction change (incl. stopping), otherwise
// only once per interval so we don't flood pubnub on a continuous drag
bool shouldBroadcastMove({
  JoystickMoveDirectional current,
  JoystickMoveDirectional lastBroadcast,
  DateTime now,
  DateTime lastBroadcastAt,
  Duration interval,
}) {
  final directionChanged = current != lastBroadcast;
  return directionChanged || now.difference(lastBroadcastAt) >= interval;
}

// de-sync check: snap a remote player to the broadcast position when our
// dead-reckoned position has drifted further than the threshold
bool shouldSnapToPosition(Vector2 broadcast, Vector2 current, double threshold) {
  return broadcast.distanceTo(current) > threshold;
}
