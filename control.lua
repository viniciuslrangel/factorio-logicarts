local mod = nil

local NORTH = defines.direction.north
local SOUTH = defines.direction.south
local EAST = defines.direction.east
local WEST = defines.direction.west

-- kph
local CAR_SPEED = 10

-- entity.speed of cars
local CAR_ENTITY_SPEED = CAR_SPEED/216

-- Bounds determining when a car x,y is centered on a tile
local TILE_CENTER_LOW = 0.5-(CAR_ENTITY_SPEED*2)
local TILE_CENTER_HIGH = 0.5+(CAR_ENTITY_SPEED*2)

-- Tick delay between updates after a car starts to move to the next tile
-- Since cars don't start moving until the path is free, this should be close to
-- the expected ticks required to traverse a tile
local CAR_TICK_STARTING = math.max(1, math.ceil(1/CAR_ENTITY_SPEED))

-- Tick delay between updates when a car is approaching the center of the next tile
-- This needs to be short enough to allow CENTER* to catch a car's position in time
-- If CAR_TICK_STARTING is accurate enough this won't be used...
local CAR_TICK_ARRIVING = math.max(1, math.ceil(1/CAR_ENTITY_SPEED/60))

-- Tick delay between updates when a car is blocked (off path, crashed, behind another car)
-- No point in making this much smaller than the number of ticks a car takes to traverse a tile
local CAR_TICK_BLOCKED = math.max(60, CAR_TICK_STARTING + CAR_TICK_ARRIVING + 1)

-- Tick delay that a car "owns" a tile
-- This needs to be >= CAR_TICK_STARTING + CAR_TICK_ARRIVING
local CAR_TICK_MARGIN = CAR_TICK_BLOCKED

-- Tick delay before the first update after a car is placed
-- This allows the player to rapidly place cars while running without causing concertina crashes
local CAR_TICK_PLACED = CAR_TICK_BLOCKED

-- Since cars are using zero friction and constant speed, without touching entity.riding_state,
-- the fuel consumption needs to be deducted manually once per tile https://wiki.factorio.com/Types/Energy
local CAR_CONSUMPTION = 50*1000

-- Tick delay between signal updates when a car is at a logicarts-stop.
local CAR_TICK_STOPPED = CAR_TICK_BLOCKED

-- Tick delay (used x3) for inactivity check when car at a logicarts-stop.
local CAR_TICK_ACTIVITY = CAR_TICK_BLOCKED

local floor = math.floor
local abs = math.abs

local function State()
	mod = global

	if mod.grid == nil then
		mod.grid = {}
	end
	if mod.queues == nil then
		mod.queues = {}
	end
	if mod.entities == nil then
		mod.entities = {}
	end
	if mod.carStates == nil then
		mod.carStates = {}
	end
end

-- Schedule the next position check for a car in "ticks" time
local function carQueue(car, ticks)
	local tick = game.tick+ticks
	local queues = mod.queues
	local queue = queues[tick]
	if queue == nil then
		queue = {}
		queues[tick] = queue
	end
	queue[#queue+1] = car
end

local function cellClaim(cell, car, ticks)
	cell.car_id = car.unit_number
	cell.car_tick = game.tick + ticks
end

local function cellClaimed(cell)
	return cell.car_id ~= nil and mod.entities[cell.car_id] ~= nil and (cell.car_tick or 0) > game.tick
end

local function gridKey(x, y)
	return floor(x)..":"..floor(y)
end

-- g.grid cells holds tables describing tiles with paths or cars, or both
-- cell = {
--	entity = <path entity>,
--	direction = <entity.direction pulled from logicarts-stop>,
--  is_path = bool,
--  is_turn = bool,
--  is_stop = bool,
--  is_yield = bool,
--	car_id = <car entity.unit_number>,
--	car_tick = <tick delay until car_id is assumed departed or invalid (removed)>,
--}

local function gridCell(x, y)
	local grid = mod.grid
	local tile = gridKey(x, y)
	local cell = grid[tile]
	if cell == nil then
		cell = {
			is_path = false,
			is_turn = false,
			is_stop = false,
			is_yield = false,
		}
		grid[tile] = cell
	end
	return cell
end

local function gridCellEmpty(cell)
	return cell.entity == nil and not cellClaimed(cell)
end

local directionNames = {
	[NORTH] = "north",
	[SOUTH] = "south",
	[EAST] = "east",
	[WEST] = "west",
}

local directionOrientations = {
	[NORTH] = 0,
	[SOUTH] = 0.5,
	[EAST] = 0.25,
	[WEST] = 0.75,
}

local pathEntities = {
	["logicarts-path-north"] = NORTH,
	["logicarts-path-south"] = SOUTH,
	["logicarts-path-east"] = EAST,
	["logicarts-path-west"] = WEST,
}

local turnEntities = {
	["logicarts-turn-north"] = NORTH,
	["logicarts-turn-south"] = SOUTH,
	["logicarts-turn-east"] = EAST,
	["logicarts-turn-west"] = WEST,
}

local stopEntities = {
	["logicarts-stop-north"] = NORTH,
	["logicarts-stop-south"] = SOUTH,
	["logicarts-stop-east"] = EAST,
	["logicarts-stop-west"] = WEST,
}

local function updateEntityCell(entity)

	if entity.name == "logicarts-yield" then
		local cell = gridCell(entity.position.x, entity.position.y)
		cell.entity = entity
		cell.direction = NORTH -- actually none, but can't be nil
		cell.is_path = true
		cell.is_yield = true
		mod.entities[entity.unit_number] = entity
		return true
	end

	if pathEntities[entity.name] ~= nil then
		local cell = gridCell(entity.position.x, entity.position.y)
		cell.entity = entity
		cell.direction = pathEntities[entity.name]
		cell.is_path = true
		mod.entities[entity.unit_number] = entity
		return true
	end

	if turnEntities[entity.name] ~= nil then
		local cell = gridCell(entity.position.x, entity.position.y)
		cell.entity = entity
		cell.direction = turnEntities[entity.name]
		cell.is_path = true
		cell.is_turn = true
		mod.entities[entity.unit_number] = entity
		return true
	end

	if stopEntities[entity.name] ~= nil then
		local cell = gridCell(entity.position.x, entity.position.y)
		cell.entity = entity
		cell.direction = stopEntities[entity.name]
		cell.is_path = true
		cell.is_stop = true
		mod.entities[entity.unit_number] = entity
		return true
	end

	return false
end

local function replaceEntityWith(entity, name)
	local surface = entity.surface
	local direction = entity.direction
	local replace = {
		name = name,
		position = entity.position,
		direction = direction,
		force = entity.force,
	}
	entity.destroy()
	return surface.create_entity(replace)
end

local function OnEntityCreated(event)
	State()
	local entity = event.created_entity

	if entity.name == "logicarts-car" then
		entity.friction_modifier = 0

		local cell = gridCell(entity.position.x, entity.position.y)
		cellClaim(cell, entity, CAR_TICK_MARGIN)
		carQueue(entity, CAR_TICK_PLACED)
		mod.entities[entity.unit_number] = entity
	end

	if updateEntityCell(entity) then
		return
	end

	if entity.name == "logicarts-path" then
		entity = replaceEntityWith(entity, "logicarts-path-"..directionNames[entity.direction])
		updateEntityCell(entity)
		return
	end

	if entity.name == "logicarts-turn" then
		entity = replaceEntityWith(entity, "logicarts-turn-"..directionNames[entity.direction])
		updateEntityCell(entity)
		return
	end

	if entity.name == "logicarts-stop" then
		entity = replaceEntityWith(entity, "logicarts-stop-"..directionNames[entity.direction])
		updateEntityCell(entity)
		return
	end
end

local function OnEntityRotated(event)
	State()
	updateEntityCell(event.entity)
end

local function OnEntityRemoved(event)
	State()
	local entity = event.entity

	if mod.entities[entity.unit_number] ~= nil then
		if entity.name ~= "logicarts-car" then
			local cell = gridCell(entity.position.x, entity.position.y)
			cell.entity = nil
			cell.direction = nil
			cell.is_path = nil
			cell.is_turn = nil
			cell.is_yield = nil
			if gridCellEmpty(cell) then
				mod.grid[gridKey(entity.position.x, entity.position.y)] = nil
			end
		end
		mod.entities[entity.unit_number] = nil
		mod.carStates[entity.unit_number] = nil
	end
end

local function checkDirection(car, direction, gate)

	local x = car.position.x
	local y = car.position.y

	if direction == NORTH then
		y = y - 1
	elseif direction == EAST then
		x = x + 1
	elseif direction == SOUTH then
		y = y + 1
	elseif direction == WEST then
		x = x - 1
	end

	local cell = mod.grid[gridKey(x, y)]

	if cell ~= nil then

		local isPath = cell.is_path
		local isFree = not cellClaimed(cell)
		local isClear = gate == nil or gate.is_opened()

		return (isPath and isFree and isClear), cell
	end

	return false, cell
end

local quadrantDirections = {
	NORTH,
	EAST,
	SOUTH,
	WEST,
}

local leftDirections = {
	[NORTH] = WEST,
	[EAST] = NORTH,
	[SOUTH] = EAST,
	[WEST] = SOUTH,
}

local rightDirections = {
	[NORTH] = EAST,
	[EAST] = SOUTH,
	[SOUTH] = WEST,
	[WEST] = NORTH,
}

local function runCar(car)

	if not car.valid then
		return 0
	end

	local state = mod.carStates[car.unit_number]
	if state == nil then
		state = {}
		mod.carStates[car.unit_number] = state
	end

	-- default action is full stop
	car.speed = 0

	local x = car.position.x
	local y = car.position.y

	local n = abs(y)
	local d = n - floor(n)
	local yc = d > TILE_CENTER_LOW and d < TILE_CENTER_HIGH

	local n = abs(x)
	local d = n - floor(n)
	local xc = d > TILE_CENTER_LOW and d < TILE_CENTER_HIGH

	local centered = xc and yc

	local cell = mod.grid[gridKey(x, y)]

	-- have we somehow entered a tile already in use?
	local cellConflict = cell ~= nil
		and cell.car_id ~= nil
		and cell.car_id ~= car.unit_number
		and cell.car_tick >= game.tick

	-- most likely that damage occuring is because of cart collision when
	-- something has screwed up the tick checks
	local beingDamaged = (state.health or car.health) < car.health

	if cellConflict or beingDamaged then
		-- Something is wrong! Just stop to avoid making it worse.
		-- Of course, if this is biter attack, we're now a sitting duck...
		return CAR_TICK_BLOCKED
	end

	state.health = car.health

	-- have we strayed off the path, or perhaps had it deconstructed
	-- out from underneath us while we were diligently delivering items?
	local offPath = cell == nil
		or cell.entity == nil
		or cell.direction == nil
		or not cell.is_path

	if offPath then
		-- record our where-abouts to avoid crashes until rescue
		cell = gridCell(x, y)
		cellClaim(cell, car, CAR_TICK_MARGIN)
		return CAR_TICK_BLOCKED
	end

	-- Direction to exit the tile
	local pathDirection = cell.direction

	-- Current direction
	local carDirection = quadrantDirections[floor(car.orientation*4+1)] or NORTH

	local burner = car.burner
	local fueltank = burner.inventory
	local fuelstoke = burner.currently_burning == nil or burner.remaining_burning_fuel < CAR_CONSUMPTION
	local fuelempty = fueltank.is_empty()
	local fueled = not fuelstoke or not fuelempty

	-- since we don't use riding_state, manually stoke the burner
	if fuelstoke and not fuelempty then
		for item, count in pairs(fueltank.get_contents()) do
			burner.currently_burning = game.item_prototypes[item]
			burner.remaining_burning_fuel = burner.currently_burning.fuel_value
			fueltank.remove({ name = item, count = count > 1 and 1 or count })
			fueled = true
			break
		end
	end

	-- If on a belt we obviously can't stop, and can therefore skip some checks
	local onBelt = car.surface.count_entities_filtered({ position = car.position, type = "transport-belt" }) > 0

	if onBelt then
		nextOK, nextCell = checkDirection(car, carDirection, nil)
		if nextOK then
			-- hope for the best; the added speed may screw up center alignment checks
			cellClaim(nextCell, car, CAR_TICK_MARGIN)
			car.speed = CAR_ENTITY_SPEED
			burner.remaining_burning_fuel = burner.remaining_burning_fuel - CAR_CONSUMPTION
		end
		return CAR_TICK_STARTING
	end

	if not centered and fueled then
		-- keep moving
		car.speed = CAR_ENTITY_SPEED
		cellClaim(cell, car, CAR_TICK_MARGIN)
		return CAR_TICK_ARRIVING
	end

	-- Nearby entities
	local stopCombinator = nil
	local stopGatePath = nil -- gate in direction of cell
	local stopGateCar = nil -- gate in direction of car (checked when turning is blocked)

	-- Signals to control a car
	local red = false
	local green = false
	local yellow = false
	local left = false
	local right = false
	local straight = false

	local cx = floor(x)
	local cy = floor(y)

	local area = {
		{ x = cx - 1, y = cy - 1 },
		{ x = cx + 2, y = cy + 2 },
	}

	-- TODO use type = { ... } once Factorio stable moves past 0.16.36
	local combinators = car.surface.find_entities_filtered({ area = area, type = "constant-combinator" })

	for i = 1,#combinators,1 do
		local en = combinators[i]
		local ed = en.direction
		local alignH = floor(en.position.y) == cy
		local alignV = floor(en.position.x) == cx
		if   (alignH and (ed == EAST or ed == WEST))
			or (alignV and (ed == NORTH or ed == SOUTH))
		then
			stopCombinator = en
			break
		end
	end

	if stopCombinator ~= nil then
		local signals = stopCombinator.get_merged_signals()
		if type(signals) == "table" then
			for _, v in pairs(signals) do
				if v.signal.type == "virtual" then
					if v.signal.name == "signal-green" then
						green = true
					elseif v.signal.name == "signal-red" then
						red = true
					elseif v.signal.name == "signal-yellow" then
						yellow = true
					elseif v.signal.name == "signal-L" then
						left = true
					elseif v.signal.name == "signal-R" then
						right = true
					elseif v.signal.name == "signal-S" then
						straight = true
					end
				end
			end
		end
	end

	if left then
		pathDirection = leftDirections[pathDirection] or pathDirection
	elseif right then
		pathDirection = rightDirections[pathDirection] or pathDirection
	elseif straight then
		pathDirection = carDirection
	end

	-- Special control tiles
	local yield = cell.entity ~= nil and cell.is_yield
	local turn = (not left and not right and not straight) and cell.entity ~= nil and cell.is_turn

	-- TODO use type = { ... } once Factorio stable moves past 0.16.36
	local gates = car.surface.find_entities_filtered({ area = area, type = "gate" })

	for i = 1,#gates,1 do
		local continue = false
		local en = gates[i]
		local ed = en.direction
		local ex = en.position.x
		local ey = en.position.y
		local alignH = floor(ey) == cy
		local alignV = floor(ex) == cx
		if not continue and stopGatePath == nil
			and (
					 (alignV and pathDirection == NORTH and ey < cy)
				or (alignV and pathDirection == SOUTH and ey > cy)
				or (alignH and pathDirection == EAST and ex > cx)
				or (alignH and pathDirection == WEST and ex < cx)
			)
		then
			stopGatePath = en
			continue = true
		end
		if not continue and stopGateCar == nil
			and (
					 (alignV and carDirection == NORTH and ey < cy)
				or (alignV and carDirection == SOUTH and ey > cy)
				or (alignH and carDirection == EAST and ex > cx)
				or (alignH and carDirection == WEST and ex < cx)
			)
		then
			stopGateCar = en
			continue = true
		end
	end

	if turn and stopGatePath ~= nil and not stopGatePath.is_opened() then
		stopGatePath = stopGateCar
		pathDirection = carDirection
	end

	local wouldStop = cell.is_stop or (stopGatePath ~= nil and not stopGatePath.is_opened())
	local stop = red or (wouldStop and not green) or not fueled

	if stop then

		local contents = car.get_fuel_inventory().get_contents()
		local trunk = car.get_inventory(defines.inventory.car_trunk).get_contents()
		for k,v in pairs(trunk) do
			contents[k] = (contents[k] or 0) + v
		end

		if stopCombinator ~= nil then

			local parameters = {}
			for item, count in pairs(trunk) do
				local index = #parameters+1
				parameters[index] = {
					index = index,
					signal = {
						type = "item",
						name = item,
					},
					count = count,
				}
			end

			local index = #parameters+1
			parameters[index] = {
				index = index,
				signal = {
					type = "virtual",
					name = "signal-C",
				},
				count = car.unit_number,
			}

			local index = #parameters+1
			parameters[index] = {
				index = index,
				signal = {
					type = "virtual",
					name = "signal-F",
				},
				count = car.get_fuel_inventory().get_item_count(),
			}

			local equipment = car.grid.get_contents()
			for item, count in pairs(equipment) do
				local index = #parameters+1
				parameters[index] = {
					index = index,
					signal = {
						type = "item",
						name = item,
					},
					count = count,
				}
			end

			stopCombinator.get_control_behavior().parameters = {
				parameters = parameters
			}
		end

		if red or not fueled then
			cellClaim(cell, car, CAR_TICK_STOPPED)
			return CAR_TICK_STOPPED
		end

		local autoWait = true
		-- automatic mode: check for activity once per second, for three seconds
		if autoWait and state.contents ~= nil and state.stopCount >= 3 then
			state.stopCount = 0
			autoWait = false
			for item, count in pairs(contents) do
				if state.contents[item] ~= count then
					autoWait = true
					break
				end
			end
			for item, count in pairs(state.contents) do
				if contents[item] ~= count then
					autoWait = true
					break
				end
			end
		end

		if autoWait then
			cellClaim(cell, car, CAR_TICK_ACTIVITY)
			state.stopCount = (state.stopCount or 0) + 1
			state.contents = contents
			return CAR_TICK_ACTIVITY
		end
	end

	state.stopCount = nil
	state.contents = nil

	if stopCombinator ~= nil then
		stopCombinator.get_control_behavior().parameters = nil
	end

	-- centered; claim the cell but figure out what to do next
	cellClaim(cell, car, CAR_TICK_MARGIN)

	-- yield reuse the car's current direction
	local direction = yield and carDirection or pathDirection
	local gate = yield and stopGateCar or stopGatePath
	local nextOK, nextCell = checkDirection(car, direction, gate)

	if (turn and nextOK) or (not yield and not turn) then
		car.orientation = directionOrientations[pathDirection] or NORTH
	end

	if turn and not nextOK then
		nextOK, nextCell = checkDirection(car, carDirection, stopGateCar)
	end

	if nextOK then
		-- claim the next cell and go!
		car.speed = CAR_ENTITY_SPEED
		cellClaim(nextCell, car, CAR_TICK_MARGIN)
		burner.remaining_burning_fuel = burner.remaining_burning_fuel - CAR_CONSUMPTION
		return CAR_TICK_STARTING
	end

	return CAR_TICK_BLOCKED
end

-- Updating the positions of a bunch of entities every tick is a
-- recipe for a Factorio UPS crash. We try to be tricksy by using
-- car.speed deterministically and scheduling individual car
-- position checks as infrequently as possible.
local function OnTick(event)
	State()

	-- Bugfix for saved games in <= 0.1.2
	if mod.check == nil or mod.check < 2 then
		for tick, queue in pairs(mod.queues) do
			if tick < game.tick then
				mod.queues[tick] = nil
			end
		end
		for xy, cell in pairs(mod.grid) do
			if gridCellEmpty(cell) then
				mod.grid[xy] = nil
			end
		end
		mod.check = 2
	end

	local queue = mod.queues[game.tick]

	if queue == nil then
		return
	end

	mod.queues[game.tick] = nil

	for i = 1,#queue,1 do
		local car = queue[i]
		queue[i] = nil

		local ticks = runCar(car)
		-- reschedule
		if ticks > 0 then
			carQueue(car, ticks)
		end
	end
end

script.on_init(function()
	State()
	script.on_event(defines.events.on_tick, OnTick)
	script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, OnEntityCreated)
	script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, OnEntityRemoved)
	script.on_event({defines.events.on_player_rotated_entity}, OnEntityRotated)
end)

script.on_load(function()
	script.on_event(defines.events.on_tick, OnTick)
	script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, OnEntityCreated)
	script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, OnEntityRemoved)
	script.on_event({defines.events.on_player_rotated_entity}, OnEntityRotated)
end)
