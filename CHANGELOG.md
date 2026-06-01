# Changelog

Public changelog for Project Armoire.

## Unreleased

- README and website brought in line with the standard project layout — hero, download buttons, play-in-browser, features grid, dark/light toggle, animated wave header, dual-host (GitHub Pages / Cloudflare) hooks.
- Standalone Changelog and Docs pages added to the website nav.
- Web client now deploys to its own `game/` path on GitHub Pages, with the landing site served from the root.
- This changelog added.

## 2022-01 — Multiplayer & macOS

- Experimental real-time multiplayer — players join a shared session and movement syncs over PubNub, with a desync snap-correction.
- macOS desktop build added to the release matrix and finalized.
- Sample PubNub credentials wired through a `.env` file; stopped tracking `.env` in source.
- Web build no longer pulls in `dart:io`, fixing the browser target.
- Android and web builds fixed; dependency/package updates.

## 2021-10 — Networking foundations

- PubNub pub/sub integration.
- Initial networked player layer.

## 2021-06 — Maps, CI & first website

- Codeless map objects driven by Tiled object layers (e.g. map-exit sensors).
- GitHub Actions build-and-deploy pipeline for Web, Android, and Windows, with timestamped releases.
- First landing page and README, plus a build status badge.
- Collision overlay hidden unless running in debug mode.

## 2021-04 — First steps

- Initial project scaffold.
- Hero sprite sheets and animations.
- First hand-made Tiled biome map.
- Basic main-menu UI.
