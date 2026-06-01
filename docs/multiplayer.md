# Multiplayer

Project Armoire's multiplayer is **serverless** — there is no authoritative game
server. Clients talk to each other over [PubNub](https://www.pubnub.com)
publish/subscribe channels.

## How it works

1. **Join.** When you press Play, the client publishes a `playerJoinData`
   message to the `player` channel announcing your id and username.
2. **Presence handshake.** When a client sees a new player join, it re-announces
   itself so the newcomer learns about everyone already in the world. Remote
   players are spawned as in-world characters.
3. **Movement.** Every time you move, the client broadcasts a `playerMoveData`
   message with your direction and position. Other clients replay that movement
   locally each tick.
4. **Desync correction.** If a remote player's replayed position drifts more
   than half a tile from the authoritative position in the message, it snaps to
   the broadcast position.

## Identity

Your player id comes from the device id (via `platform_device_id`). In debug
builds the username is appended so you can run multiple instances from one
machine.

## Credentials

The PubNub keys are read from a `.env` file (`PUBNUB_SUBSCRIBEKEY`,
`PUBNUB_PUBLISHKEY`, `PUBNUB_UUID`). If no `.env` is present, the app falls back
to rate-limited demo keys, so it works out of the box for casual testing.

## Caveats

- There is no authority or anti-cheat — clients trust each other's broadcasts.
- Remote players are modelled as "enemies" internally; there is no combat
  resolution between players yet.
