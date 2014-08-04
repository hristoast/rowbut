--[[ rowbut

http://pastebin.com/NgbbQg5i

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

]]

-- It's OK to edit these if you think you really need to
COBBLE_SLOT = 1
TORCH_SLOT_1 = 2
TORCH_SLOT_2 = 3
CHEST_SLOT = 4
FUEL_SLOT = 5
TORCH2_SLOT = 5
MOVES = 100
-- You probably don't want to edit below here
BACK_COUNT = 0
MOVE_COUNT = 0
BACK_MOVES = MOVES
MOVE_LIMIT = MOVES
STRIP_COUNT = 100  -- How long a line bot will strip before turning around
STUCK_COUNT = 0
TORCH_INTERVAL = 11  -- Yes, eleven *IS* the max distance
TORCHES_USED = 0
CURRENT_TORCH_SLOT = TORCH_SLOT_1
TUNNEL_RIGHT = false


function check_surroundings()
  --[[ Ensure there is a block below us, to the right and left of us, and (two blocks) above us ]]
  -- below
  if not turtle.detectDown() then
    turtle.select(COBBLE_SLOT)
    turtle.placeDown()
  end
  -- to the right
  turtle.turnRight()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnLeft()
  -- to the left
  turtle.turnLeft()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnRight()
  -- above
  if turtle.detectUp() then
    turtle.digUp()
  end
  -- above above
  if not turtle.up() then  -- try to see if there is gravel above the rowbut
    turtle.digUp()
  end
  if not turtle.detectUp() then
    turtle.select(COBBLE_SLOT)
    turtle.placeUp()
  end
  -- to the right (only on non-chest cycles)
  if not chest_cycle then
    turtle.turnRight()
    if not turtle.detect() then
      turtle.select(COBBLE_SLOT)
      turtle.place()
    end
    turtle.turnLeft()
  end
  -- to the left
  turtle.turnLeft()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnRight()
  turtle.down()
end

function dig_two_by_one()
  --[[ Makes the bot dig a 2x1 'tunnel' in front of it ]]
  while turtle.detect() do
    turtle.dig()
  end
  turtle.forward()
  if turtle.detectUp() then
    turtle.digUp()
  end
end

function prepare_chest_hole_walls_bottom()
  --[[ verify the presence of 8 blocks; below, behind, to the left and right of the chest, as
  well as the same blocks one above the chest (idk if this is worded well or not..) ]]
  if not turtle.detectDown() then
    turtle.select(COBBLE_SLOT)
    turtle.placeDown()
  end
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnRight()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
end

function prepare_chest_hole_walls_top()
  --[[ verify the presence of 8 blocks; below, behind, to the left and right of the chest, as
  well as the same blocks one above the chest (idk if this is worded well or not..). Seperate version for the upper level as we are
  checking the top block rather than the one below us ]]
  if not turtle.detectUp() then
    turtle.select(COBBLE_SLOT)
    turtle.placeUp()
  end
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnRight()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  if not turtle.detect() then
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
end

function prepare_for_and_place_chest()
  --[[ Digs out a 1x2 hole on the bot's right side of the tunnel for a chest, which it will then use to
  store excess cobble and maybe other things. ]]
  -- dig out the 2x1 hole for the chest if need be
  print('placing chest ...')
  turtle.turnRight()
  dig_two_by_one()
  prepare_chest_hole_walls_bottom()
  turtle.turnRight()  -- now perpendicular to the tunnel
  turtle.up()
  prepare_chest_hole_walls_top()
  turtle.turnRight()
  turtle.down()
  turtle.back()
  turtle.select(CHEST_SLOT)
  turtle.place()
  for slot=5, 16, 1 do
    turtle.select(slot)
    turtle.drop(turtle.getItemCount(slot))
  end
  turtle.turnLeft()  -- bot is now back in mining position
end

function prepare_for_and_place_torch()
  --[[ Places a torch every TORCH_INTERVALth block after ensuring there is a block to place it on.
  bots don't like placing torches in blocks they stand in, so we will place it one above the bot.]]
  print('placing torch ...')
  if chest_cycle then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
  turtle.up()  -- TODO: look before you leap! (?)
  if not turtle.detect() then
    print('placing block for torch!')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.down()
  if TORCHES_USED == 64 then
    CURRENT_TORCH_SLOT = TORCH_SLOT_2
  end
  if TORCHES_USED == 128 then
    print('oh noes! out of torches!')
    shell.exit(0)
  end
  turtle.select(CURRENT_TORCH_SLOT)
  if turtle.getItemCount(CURRENT_TORCH_SLOT) == 0 then -- bail if the selected torch slot is empty
    print('oh noes! out of torches!')
    shell.exit(0)
  end
  turtle.placeUp()
  if chest_cycle then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  TORCHES_USED = TORCHES_USED + 1
  print('torches used: ', TORCHES_USED)
end

function refuel_check()
  -- body TODO
end

function refuel_time()
  -- body
end

function scan_inventory()
  --[[ Iterate through each inventory slot, return false if all are occupied and true if all are not. ]]
  used_slots = 0
  for slot=5, 16, 1 do
    turtle.select(slot)
    if turtle.getItemCount(slot) > 0 then
      used_slots = used_slots + 1
    end
  end
  if used_slots == 12 then
    print('all slots are full!')
    return false
  else
    return true
  end
end

function turn_the_tunnel_left()
  --[[ Once we are done with our strip, turn it left and begin mining back. ]]
  TUNNEL_RIGHT = false
  NEXT = 0
  turtle.turnLeft()
  while NEXT < 3 do
    if NEXT == 2 then -- on the 2nd turn, place a torch
      prepare_for_and_place_torch()
    end
    NEXT = NEXT + 1
    turtle.select(COBBLE_SLOT)  -- so cobble that gets picked up is put into the right slot
    dig_two_by_one()
    check_surroundings()
  end
  turtle.turnLeft()
end

function turn_the_tunnel_right()
  --[[ Once we are done with our strip, turn it right and begin mining back. ]]
  TUNNEL_RIGHT = true
  NEXT = 0
  turtle.turnRight()
  while NEXT < 3 do
    NEXT = NEXT + 1
    turtle.select(COBBLE_SLOT)  -- so cobble that gets picked up is put into the right slot
    dig_two_by_one()
    check_surroundings()
  end
  turtle.turnRight()
end

function mining_while()
  --[[ The main while loop that runs while strip mining ]]
  while MOVE_COUNT < MOVE_LIMIT do
    chest_cycle = false
    torch_cycle = false
    MOVE_COUNT = MOVE_COUNT + 1
    print('move count: ', MOVE_COUNT)
    print("fuel: ", turtle.getFuelLevel())
    if not scan_inventory() then
      chest_cycle = true
      prepare_for_and_place_chest()
    end
    if MOVE_COUNT % TORCH_INTERVAL == 0 then
      torch_cycle = true
      prepare_for_and_place_torch()
    end
    turtle.select(COBBLE_SLOT)  -- so cobble that gets picked up is put into the right slot
    dig_two_by_one()
    check_surroundings()
    -- if refuel_check() then
    --   refuel_time()
    -- end
  end
  -- TODO: make a minimalist version of check_surroundings() that doesn't place blocks for this part (maybe?)
  if not TUNNEL_RIGHT then
    turn_the_tunnel_right()
    MOVE_COUNT = 0
  else
    turn_the_tunnel_left()
    MOVE_COUNT = 0
  end
end

function main()
  --[[ Main program loop ]]
  while turtle.getFuelLevel() > 4 do
    mining_while()
  end
end

main()
