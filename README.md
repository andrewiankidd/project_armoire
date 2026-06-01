# Project Armoire
##### _Open-source, cross-platform, hacky._

![logo](.github/pages/logo.png)

## About
**Project Armoire** is an open-source, cross-platform multiplayer RPG sandbox built with the [Flame](https://flame-engine.org) + [Bonfire](https://bonfire-engine.github.io) engines on top of [Flutter](https://flutter.dev). Pick a username, roam tile-based biomes, and watch other players move around you in real time over a serverless [PubNub](https://www.pubnub.com) backbone. One codebase runs in the browser and on Windows, macOS, and Android.

> Started as "an attempt at building something open source, cross-platform and hacky." It is a tech-demo playground rather than a finished game — expect rough edges.

## Features
- 👥 **Real-time multiplayer** — see other players join and move, peer-to-peer over PubNub, no server
- 🌍 Tile-based biome maps authored in Tiled, with seamless map-to-map transitions
- 🕹️ Virtual joystick + keyboard controls, plus an action / cast button
- 🧝 Eight-direction sprite-sheet hero animations — idle, run, cast
- 🌊 Environmental effects — water slows you and cloaks your sprite
- 🧭 45° rotated camera with map-bounded follow
- 📱 One Flutter codebase — Web, Windows, macOS, Android, iOS
- 🎮 Pick a username and drop straight into the shared world

### Links
<p align="center">
    <a href="https://andrewiankidd.github.io/project_armoire/">
        <img src="https://img.shields.io/badge/%F0%9F%97%84%EF%B8%8F%20Project%20Armoire-deeppink.svg" height="50" target="_blank" />
    </a>
    <br>
    <strong>Play:</strong>
    <br>
    <a href="https://andrewiankidd.github.io/project_armoire/game/">
        <img src="https://img.shields.io/badge/%f0%9f%8c%90%20Browser-deeppink.svg" />
    </a>
    <a href="https://github.com/andrewiankidd/project_armoire/releases/download/latest-main/windows-release.zip">
        <img src="https://img.shields.io/badge/Windows-deeppink.svg?logo=windows" />
    </a>
    <a href="https://github.com/andrewiankidd/project_armoire/releases/download/latest-main/macos-release.app.zip">
        <img src="https://img.shields.io/badge/MacOS-deeppink.svg?logo=macos" />
    </a>
    <a href="https://github.com/andrewiankidd/project_armoire/releases/download/latest-main/android-release.apk">
        <img src="https://img.shields.io/badge/Android-deeppink.svg?logo=android" />
    </a>
    <br>
    <strong>Source Code:</strong>
    <br>
    <a href="https://github.com/andrewiankidd/project_armoire">
        <img src="https://img.shields.io/badge/GitHub-deeppink.svg?logo=gitHub" />
    </a>
    <br>
    <a href="https://github.com/andrewiankidd/project_armoire/actions/workflows/publish.yml">
        <img src="https://github.com/andrewiankidd/project_armoire/actions/workflows/publish.yml/badge.svg?branch=master" />
    </a>
</p>

## Documentation

See the [full documentation](docs/index.md) for guides on the game and its code:

- [Controls](docs/playing/controls.md)
- [Gameplay](docs/playing/gameplay.md)
- [Multiplayer](docs/multiplayer.md)
- [Architecture](docs/development/architecture.md)
- [Build & CI](docs/development/build.md)
- [Changelog](CHANGELOG.md)

## Built with
[![Powered by Flame](https://img.shields.io/badge/%F0%9F%94%A5%20Flame%20Engine-orange.svg?logo)](https://flame-engine.org) [![Powered by Bonfire](https://img.shields.io/badge/%F0%9F%94%A5%20Bonfire-red.svg)](https://bonfire-engine.github.io) [![Powered by Flutter](https://img.shields.io/badge/Flutter-black.svg?logo=flutter)](https://flutter.io) [![Powered by Dart](https://img.shields.io/badge/Dart-blue.svg?logo=dart)](https://dart.dev) [![Powered by PubNub](https://img.shields.io/badge/PubNub-e8004c.svg)](https://www.pubnub.com)

## License

No `LICENSE` file is present yet — treat this as source-available and ask before reuse.
