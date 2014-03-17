--[[ rowbut - by johnnyhostile

http://pastebin.com/NgbbQg5i

Digs a 1x2 strip in whatever direction you face it, then turns around and does it again. Repeat.

TODO: refueling? ]]

-- It's OK to edit these if you think you really need to
COBBLE_SLOT = 1
TORCH_SLOT = 2
CHEST_SLOT = 3
MOVES = 100
-- You probably don't want to edit below here
BACK_COUNT = 0
MOVE_COUNT = 0
BACK_MOVES = MOVES
MOVE_LIMIT = MOVES
STRIP_COUNT = 100  -- How long a line bot will strip before turning around
STUCK_COUNT = 0
TORCH_INTERVAL = 11  -- Yes, eleven *IS* the max distance
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
  turtle.up()
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

function come_back()
  -- print('coming back')
  while BACK_COUNT < MOVE_LIMIT do
    if not turtle.detectUp() then
      turtle.select(COBBLE_SLOT)
      turtle.placeUp()
    else
      turtle.digUp()
    end

    turtle.back()
    turtle.place()

    BACK_COUNT = BACK_COUNT + 1
  end
end

function dig_two_by_one()
  --[[ Makes the bot dig a 2x1 'tunnel' in front of it, of blocks are there FIXME ]]
  if turtle.detect() then
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
  -- print('START bottom check chest surround area')
  if not turtle.detectDown() then
    -- print('placing block for below chest')
    turtle.select(COBBLE_SLOT)
    turtle.placeDown()
  end
  if not turtle.detect() then
    -- print('placing block for behind chest')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnRight()
  if not turtle.detect() then
    -- print('placing block to the right of the chest')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  if not turtle.detect() then
    -- print('placing block to the left of the chest')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  -- print('END bottom lower check chest surround area')
end

function prepare_chest_hole_walls_top()
  --[[ verify the presence of 8 blocks; below, behind, to the left and right of the chest, as
  well as the same blocks one above the chest (idk if this is worded well or not..) ]]
  -- print('START top check chest surround area')
  if not turtle.detectUp() then
    -- print('placing block for above chest')
    turtle.select(COBBLE_SLOT)
    turtle.placeUp()
  end
  if not turtle.detect() then
    -- print('placing block for behind chest')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnRight()
  if not turtle.detect() then
    -- print('placing block to the right of the chest')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  if not turtle.detect() then
    -- print('placing block to the left of the chest')
    turtle.select(COBBLE_SLOT)
    turtle.place()
  end
  -- print('END top lower check chest surround area')
end

function prepare_for_and_place_chest()
  --[[ Digs out a 1x2 hole on the bot's right side of the tunnel for a chest, which it will then use to
  store excess cobble and maybe other things. ]]

  -- dig out the 2x1 hole for the chest if need be
  turtle.turnRight()
  dig_two_by_one()

  -- print("begin filling in the surrounding walls so the chest doesn't get destroyed or something")
  prepare_chest_hole_walls_bottom()
  turtle.turnRight()  -- now perpendicular to the tunnel
  turtle.up()
  prepare_chest_hole_walls_top()
  -- print('walls for chest should be in place')

  turtle.turnRight()
  turtle.down()
  turtle.back()

  turtle.select(CHEST_SLOT)
  turtle.place()

  -- print('emptying items into the chest ...')
  for slot=1, 16, 1 do
    if slot > 3 then
      turtle.select(slot)
      if turtle.compareTo(COBBLE_SLOT) then
        -- print('dropping some cobble')
        turtle.drop(turtle.getItemCount(slot))
      end
    end
  end
  turtle.turnLeft()  -- bot is now back in mining position
  -- TODO: empty items into chest!
  -- print('done placing chest, back to mining!')
end

function prepare_for_and_place_torch()
  --[[ Places a torch every TORCH_INTERVALth block after ensuring there is a block to place it on.
  bots don't like placing torches in blocks they stand in, so we will place it one above the bot.]]

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

  -- print('placing torch!')
  turtle.select(TORCH_SLOT)
  turtle.placeUp()
  turtle.turnLeft()
  -- print('done placing torch, back to mining!')
end

function scan_inventory()
  --[[ Iterate through each inventory slot, return false if all are occupied and true if all are not. ]]
  used_slots = 0
  for slot=1, 16, 1 do
    turtle.select(slot)
    if turtle.getItemCount(slot) > 0 then
      used_slots = used_slots + 1
    end
  end

  if used_slots == 16 then
    print('all slots are full!')
    return false
  else
    return true
  end
end

function turn_the_tunnel_left()
  --[[ Once we are done with our strip, turn it right to begin mining back. ]]
  TUNNEL_RIGHT = false

  NEXT = 0
  turtle.turnLeft()
  while NEXT < 3 do
    NEXT = NEXT + 1
    -- print('NEXT L: ', NEXT)
    dig_two_by_one()
    check_surroundings()
  end
  -- print('turn left here?')
  turtle.turnLeft()
end

function turn_the_tunnel_right()
  --[[ Once we are done with our strip, turn it right to begin mining back. ]]
  TUNNEL_RIGHT = true

  NEXT = 0
  turtle.turnRight()
  while NEXT < 3 do
    NEXT = NEXT + 1
    -- print('NEXT R: ', NEXT)
    dig_two_by_one()
    check_surroundings()
  end
  -- print('turn right here?')
  turtle.turnRight()
end

function mining_while()
  while MOVE_COUNT < MOVE_LIMIT do
    chest_cycle = false
    torch_cycle = false

    MOVE_COUNT = MOVE_COUNT + 1
    print('MOVE_COUNT: ', MOVE_COUNT)

    if not scan_inventory() then
      chest_cycle = true
      print('chest cycle')
      prepare_for_and_place_chest()
    end

    if MOVE_COUNT % TORCH_INTERVAL == 0 then
      torch_cycle = true
      -- print('torch cycle')
      prepare_for_and_place_torch()
    end
    -- print('torch_cycle: ', torch_cycle)

    -- print('digging + walking cycle')
    dig_two_by_one()

    check_surroundings()
  end

  if not TUNNEL_RIGHT then
    turn_the_tunnel_right()
    MOVE_COUNT = 0
    -- mining_while()
  else
    turn_the_tunnel_left()
    MOVE_COUNT = 0
    -- mining_while()
  end
end

function main()
  --[[ Main program loop ]]
  while turtle.getFuelLevel() > 1 do
    mining_while()
  end

  -- come_back()
  print("fuel:", turtle.getFuelLevel())
end


main()