# Controls

Project Armoire uses Bonfire's joystick, which works with touch, mouse, and
keyboard at the same time.

## Movement

| Input | Action |
|-------|--------|
| On-screen directional pad | Move in eight directions |
| Keyboard (WASD / arrow keys) | Move in eight directions |

Movement intensity scales with how far the joystick is pushed, so a light touch
walks and a full push runs. Diagonal movement is speed-corrected so you do not
move faster on the diagonal.

## Action

| Input | Action |
|-------|--------|
| On-screen action button (bottom-right) | Cast / attack in the facing direction |

The action plays a directional cast animation. Combat damage is not wired up
yet — the swing is currently cosmetic.

## Joining

On the main menu, enter a username (at least 5 characters) and press **Play** to
drop into the shared world. In debug builds an empty username is auto-filled so
you can iterate quickly.
