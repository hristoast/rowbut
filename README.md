# rowbut
---

This script will make your mining turtle strip mine in a zig-zag fashion; First it goes forward a hardcoded number of blocks (mining everything in its way), then it turns (first right, then left, and so on) to bank back the way it came, parallel to the strip it just cut out.

The rowbut runs in "paranoid mode" by default. This means that each step forward, the rowbut checks the six surrounding blocks of the corridor to (attempt to) ensure that lava or other things don't flow in. This makes it move a bit slowly, but you aren't supposed to watch it!

This could easily be disabled ("DGAF mode") by commenting the two places where I call the checks. Perhaps in the future I will allow for an option to tweak this.

By default it places a torch every 11 blocks, which is the max distance they can be apart while still keeping things lit up enough.

It will mine away until it runs out of fuel.

## Use case
---

An ideal scenario for the usage of this script would be one where you have two rowbuts, each starting with their backs to one another. Fuel them each up to 2 or 3 thousand, this will be enough for them to run for hours.

Start them up, then go do some other things but **try to make sure that their chunks to not unload (see known issues below)!**

Come back in a few hours and you will find several hundred-block long strips dotted with chests full of goodies here and there. The real take home being that you will now have more exposed ore than you will know what to do with!

 * Try it on the diamond layer (~12y)!
 * Try it on the tin layer (~50y)!

## TODO
---

 * Some sort of refueling functionality
 * Tweak corner turning logic to allow for placing a torch
 * Add the ability to change initial turn direction (presently hardcoded to right)
 * Add the option to disable "paranoid mode" (checking every surrounding block, every turn)
 * Make my code more idomatic (where applicable)
 * ????

## Known Issues / Quirks
---

Most or all of these issues can be "solved" by breaking cobble that ends up in your way.

 * If the rowbut needs to place a chest while turning a corner, it may result in the corner being blocked by cobble
 * No torches are placed while turning corners, resulting in light levels low enough for mobs to spawn
 * If the rowbut encounters more than a few (2 or 3, maybe) blocks of falling gravel, it will eventually clear the falling blocks faster than they actually fall - this results in the rowbut moving underneath the falling gravel and thus it does not properly clear it
 * There are no checks for running out of cobble, torches, or chests. This means that when one of these runs out, I don't know what will happen. I assume it will stop.
 * If the chunk the rowbut is on gets unloaded, they simply freeze and the script will stop. This is a limitation of the game, I can't fix this.
 * Maybe some other things, too!
