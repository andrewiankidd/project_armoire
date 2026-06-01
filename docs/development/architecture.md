# Architecture

Project Armoire is a Flutter app. The game-specific code lives under `lib/` and
is intentionally small.

## Entry point

- `lib/main.dart` — boots Flutter, loads hero sprites, forces landscape +
  fullscreen on native targets, initialises `Config` and `Net`, then shows the
  main menu. Holds a few globals: `tileSize`, the shared `pubnub` instance, and
  a `gameStateKey` used to reach the running game from the networking layer.

## Layers

| Path | Role |
|------|------|
| `lib/menus/main_menu.dart` | Username entry → creates `PlayerData`, broadcasts a join, navigates to the game. |
| `lib/game/game.dart` | The `GameState` — builds the Bonfire widget (joystick, rotated camera, colour filter), loads the Tiled map, and registers exit sensors from the map's object layers. |
| `lib/player/game_player.dart` | The local player. Joystick movement, the cast action, username label, water effects, and broadcasting moves to the network. |
| `lib/player/remote_player.dart` | Other players. Receives movement messages, replays them each tick, and snaps on desync. |
| `lib/player/sprite_sheet_hero.dart` | Loads the hero sprite sheets. |
| `lib/net/net.dart` | PubNub wrapper — subscribe, publish, and the `NetMessage` envelope. |
| `lib/net/net_player.dart` | Multiplayer presence + movement logic, plus the `PlayerData` / `PlayerMoveData` DTOs. |
| `lib/util/exit_map_sensor.dart` | A Bonfire `Sensor` that fires a biome change on player contact. |
| `lib/util/extensions.dart` | `context.goTo(page)` navigation helper. |
| `lib/config/config.dart` | Device id + `.env` configuration. |

## Engines

- **Flame** — the underlying 2D game engine (game loop, sprites, input).
- **Bonfire** — an RPG-builder layer on top of Flame (tiled maps, joystick,
  simple players/enemies, sensors, camera).

## Maps

Maps live under `assets/images/maps/<biome>/` as Tiled JSON data plus tilesets.
The object layers carry the exit-sensor definitions that drive map transitions.
