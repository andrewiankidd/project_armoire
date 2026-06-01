# Gameplay

## Biomes & maps

The world is made of tile-based maps authored in [Tiled](https://www.mapeditor.org/).
Each biome (`biome1`, `biome2`, …) is a Tiled map with a tileset and an object
layer. Maps are rendered through Bonfire's `TiledWorldMap` with a 45° rotated
camera that follows the player within the map bounds.

## Map transitions

Object layers in the Tiled map define **exit sensors**. Walking your hero into
one of these regions triggers a transition to the named destination biome — the
sensor's name encodes the target map, and crossing it loads that map fresh.

## Water

Tiles flagged as water change how the hero behaves:

- **Speed** — moving through water halves your movement speed.
- **Appearance** — your sprite is rendered with a cut-out/cloak effect while
  standing in water.

## Heroes

The hero is drawn from a sprite sheet with eight-direction idle, run, and cast
animations. Two sheets ship today (`cloaked` and `uncloaked`); the cloaked sheet
is the default.
