# Project Armoire

An open-source, cross-platform, hacky multiplayer RPG sandbox built with the
[Flame](https://flame-engine.org) + [Bonfire](https://bonfire-engine.github.io)
engines on top of [Flutter](https://flutter.dev). Pick a username, roam
tile-based biomes, and watch other players move around you in real time over a
serverless [PubNub](https://www.pubnub.com) backbone.

> Project Armoire started as "an attempt at building something open source,
> cross-platform and hacky." It is a tech-demo playground rather than a finished
> game — expect rough edges.

## Contents

- [Controls](playing/controls.md) — joystick, keyboard, and the action button.
- [Gameplay](playing/gameplay.md) — biomes, map transitions, and water.
- [Multiplayer](multiplayer.md) — how players join and sync over PubNub.
- [Architecture](development/architecture.md) — how the code fits together.
- [Build & CI](development/build.md) — running locally and the release pipeline.

## Platforms

One Flutter codebase targets **Web, Windows, macOS, Android, and iOS**. The
release pipeline currently ships Web, Windows, macOS, and Android builds; iOS is
scaffolded but not published.

## Play

- **Browser:** [andrewiankidd.github.io/project_armoire/game/](https://andrewiankidd.github.io/project_armoire/game/)
- **Downloads:** see the [latest release](https://github.com/andrewiankidd/project_armoire/releases/latest).
