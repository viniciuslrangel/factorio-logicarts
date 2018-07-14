local mod = nil

local NORTH = defines.direction.north
local SOUTH = defines.direction.south
local EAST = defines.direction.east
local WEST = defines.direction.west

-- kph
local CAR_SPEED = 5

-- entity.speed of cars
local CAR_ENTITY_SPEED = CAR_SPEED/216

-- Bounds determining when a car x,y is centered on a tile
local TILE_CENTER_LOW = 0.5-(CAR_ENTITY_SPEED)
local TILE_CENTER_HIGH = 0.5+(CAR_ENTITY_SPEED)

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
local CAR_CONSUMPTION = 18*1000
local CAR_CONSUMPTION_ELECTRIC = CAR_CONSUMPTION
local CAR_CONSUMPTION_BURNER = CAR_CONSUMPTION * 10

-- Tick delay between signal updates when a car is at a logicarts-stop.
local CAR_TICK_STOPPED = 60

-- Tick delay (used x3) for inactivity check when car at a logicarts-stop.
local CAR_TICK_ACTIVITY = 60

local CAR_BURNER = "logicarts-car"
local CAR_ELECTRIC = "logicarts-car-electric"

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

local reverseDirections = {
	[NORTH] = SOUTH,
	[EAST] = WEST,
	[SOUTH] = NORTH,
	[WEST] = EAST,
}

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

local cartEntities = {
	[CAR_BURNER] = true,
	[CAR_ELECTRIC] = true,
}

local pathEntities = {
	["logicarts-path-north"] = NORTH,
	["logicarts-path-south"] = SOUTH,
	["logicarts-path-east"] = EAST,
	["logicarts-path-west"] = WEST,
}

local pathGroupEntities = {
	["logicarts-path-G1-north"] = NORTH,
	["logicarts-path-G1-south"] = SOUTH,
	["logicarts-path-G1-east"]  = EAST,
	["logicarts-path-G1-west"]  = WEST,
	["logicarts-path-G2-north"] = NORTH,
	["logicarts-path-G2-south"] = SOUTH,
	["logicarts-path-G2-east"]  = EAST,
	["logicarts-path-G2-west"]  = WEST,
	["logicarts-path-G3-north"] = NORTH,
	["logicarts-path-G3-south"] = SOUTH,
	["logicarts-path-G3-east"]  = EAST,
	["logicarts-path-G3-west"]  = WEST,
	["logicarts-path-G4-north"] = NORTH,
	["logicarts-path-G4-south"] = SOUTH,
	["logicarts-path-G4-east"]  = EAST,
	["logicarts-path-G4-west"]  = WEST,
	["logicarts-path-G5-north"] = NORTH,
	["logicarts-path-G5-south"] = SOUTH,
	["logicarts-path-G5-east"]  = EAST,
	["logicarts-path-G5-west"]  = WEST,
}

local pathGroupEntitiesN = {
	["logicarts-path-G1-north"] = 1,
	["logicarts-path-G1-south"] = 1,
	["logicarts-path-G1-east"]  = 1,
	["logicarts-path-G1-west"]  = 1,
	["logicarts-path-G2-north"] = 2,
	["logicarts-path-G2-south"] = 2,
	["logicarts-path-G2-east"]  = 2,
	["logicarts-path-G2-west"]  = 2,
	["logicarts-path-G3-north"] = 3,
	["logicarts-path-G3-south"] = 3,
	["logicarts-path-G3-east"]  = 3,
	["logicarts-path-G3-west"]  = 3,
	["logicarts-path-G4-north"] = 4,
	["logicarts-path-G4-south"] = 4,
	["logicarts-path-G4-east"]  = 4,
	["logicarts-path-G4-west"]  = 4,
	["logicarts-path-G5-north"] = 5,
	["logicarts-path-G5-south"] = 5,
	["logicarts-path-G5-east"]  = 5,
	["logicarts-path-G5-west"]  = 5,
}

local turnClearEntities = {
	["logicarts-turn-north"] = NORTH,
	["logicarts-turn-south"] = SOUTH,
	["logicarts-turn-east"] = EAST,
	["logicarts-turn-west"] = WEST,
}

local turnClearGroupEntities = {
	["logicarts-turn-G1-north"] = NORTH,
	["logicarts-turn-G1-south"] = SOUTH,
	["logicarts-turn-G1-east"]  = EAST,
	["logicarts-turn-G1-west"]  = WEST,
	["logicarts-turn-G2-north"] = NORTH,
	["logicarts-turn-G2-south"] = SOUTH,
	["logicarts-turn-G2-east"]  = EAST,
	["logicarts-turn-G2-west"]  = WEST,
	["logicarts-turn-G3-north"] = NORTH,
	["logicarts-turn-G3-south"] = SOUTH,
	["logicarts-turn-G3-east"]  = EAST,
	["logicarts-turn-G3-west"]  = WEST,
	["logicarts-turn-G4-north"] = NORTH,
	["logicarts-turn-G4-south"] = SOUTH,
	["logicarts-turn-G4-east"]  = EAST,
	["logicarts-turn-G4-west"]  = WEST,
	["logicarts-turn-G5-north"] = NORTH,
	["logicarts-turn-G5-south"] = SOUTH,
	["logicarts-turn-G5-east"]  = EAST,
	["logicarts-turn-G5-west"]  = WEST,
}

local turnClearGroupEntitiesN = {
	["logicarts-turn-G1-north"] = 1,
	["logicarts-turn-G1-south"] = 1,
	["logicarts-turn-G1-east"]  = 1,
	["logicarts-turn-G1-west"]  = 1,
	["logicarts-turn-G2-north"] = 2,
	["logicarts-turn-G2-south"] = 2,
	["logicarts-turn-G2-east"]  = 2,
	["logicarts-turn-G2-west"]  = 2,
	["logicarts-turn-G3-north"] = 3,
	["logicarts-turn-G3-south"] = 3,
	["logicarts-turn-G3-east"]  = 3,
	["logicarts-turn-G3-west"]  = 3,
	["logicarts-turn-G4-north"] = 4,
	["logicarts-turn-G4-south"] = 4,
	["logicarts-turn-G4-east"]  = 4,
	["logicarts-turn-G4-west"]  = 4,
	["logicarts-turn-G5-north"] = 5,
	["logicarts-turn-G5-south"] = 5,
	["logicarts-turn-G5-east"]  = 5,
	["logicarts-turn-G5-west"]  = 5,
}

local turnBlockedEntities = {
	["logicarts-turn-blocked-north"] = NORTH,
	["logicarts-turn-blocked-south"] = SOUTH,
	["logicarts-turn-blocked-east"] = EAST,
	["logicarts-turn-blocked-west"] = WEST,
}

local turnFuelEntities = {
	["logicarts-turn-fuel-north"] = NORTH,
	["logicarts-turn-fuel-south"] = SOUTH,
	["logicarts-turn-fuel-east"] = EAST,
	["logicarts-turn-fuel-west"] = WEST,
}

local continueEntities = {
	["logicarts-continue-north"] = NORTH,
	["logicarts-continue-south"] = SOUTH,
	["logicarts-continue-east"] = EAST,
	["logicarts-continue-west"] = WEST,
}

local stopEntities = {
	["logicarts-stop-north"] = NORTH,
	["logicarts-stop-south"] = SOUTH,
	["logicarts-stop-east"] = EAST,
	["logicarts-stop-west"] = WEST,
}

local stopLoadEntities = {
	["logicarts-stop-load-north"] = NORTH,
	["logicarts-stop-load-south"] = SOUTH,
	["logicarts-stop-load-east"] = EAST,
	["logicarts-stop-load-west"] = WEST,
}

local stopUnloadEntities = {
	["logicarts-stop-unload-north"] = NORTH,
	["logicarts-stop-unload-south"] = SOUTH,
	["logicarts-stop-unload-east"] = EAST,
	["logicarts-stop-unload-west"] = WEST,
}

local stopSupplyEntities = {
	["logicarts-stop-supply-north"] = NORTH,
	["logicarts-stop-supply-south"] = SOUTH,
	["logicarts-stop-supply-east"] = EAST,
	["logicarts-stop-supply-west"] = WEST,
}

local stopDumpEntities = {
	["logicarts-stop-dump-north"] = NORTH,
	["logicarts-stop-dump-south"] = SOUTH,
	["logicarts-stop-dump-east"] = EAST,
	["logicarts-stop-dump-west"] = WEST,
}

local stopAcceptEntities = {
	["logicarts-stop-accept-north"] = NORTH,
	["logicarts-stop-accept-south"] = SOUTH,
	["logicarts-stop-accept-east"] = EAST,
	["logicarts-stop-accept-west"] = WEST,
}

local equipmentGroups = {
	["logicarts-equipment-1"] = 1,
	["logicarts-equipment-2"] = 2,
	["logicarts-equipment-3"] = 3,
	["logicarts-equipment-4"] = 4,
	["logicarts-equipment-5"] = 5,
}

local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max = math.max
local min = math.min

local function serialize(t)
	local s = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			v = serialize(v)
		end
		s[#s+1] = tostring(k).." = "..tostring(v)
	end
	return "{ "..table.concat(s, ", ").." }"
end

local function cellCenter(x, y)
	return floor(x) + 0.5, floor(y) + 0.5
end

local function cellCenterPos(x, y)
	x, y = cellCenter(x, y)
	return { x = x, y = y }
end

local cellTranslators = {
	[NORTH] = function(x, y) return x, y-1 end,
	[SOUTH] = function(x, y) return x, y+1 end,
	[EAST]  = function(x, y) return x+1, y end,
	[WEST]  = function(x, y) return x-1, y end,
}

-- Translate x,y in direction by one cell
local function cellTranslate(dir, x, y)
	x, y = cellTranslators[dir](x, y)
	return x, y
end

-- Translate a position in direction by one cell
local function directionPosition(dir, pos)
	local x, y = cellTranslate(dir, pos[1] or pos.x, pos[2] or pos.y)
	return { x = x, y = y }
end

local function State()
	mod = global
	mod.grid = nil
	mod.entities = nil
	mod.sensors = nil
	mod.controllers = nil

	if mod.queues == nil then
		mod.queues = {}
	end
	if mod.carStates == nil then
		mod.carStates = {}
	end
	if mod.markers == nil then
		mod.markers = {}
	end
end

-- Schedule the next position check for a car in "ticks" time
local function carQueue(car, ticks)
	local tick = game.tick+ticks
	local queues = mod.queues
	local queue = queues[tick]
	if queue == nil then
		queue = {nil,nil,nil,nil}
		queues[tick] = queue
	end
	queue[#queue+1] = car
end

-- Schedule removal of a marker in "ticks" time
local function markerQueue(marker, ticks)
	local tick = game.tick+ticks
	local queues = mod.queues
	local queue = queues[tick]
	if queue == nil then
		queue = {nil,nil,nil,nil}
		queues[tick] = queue
	end
	queue[#queue+1] = marker
end

local cellGetters = {
	["logicarts-yield"] = function(cell, en)
		cell.path = true
		cell.yield = true
		cell.direction = NORTH
		cell.entity = en
	end,
	["logicarts-marker"] = function(cell, en)
		cell.car_id = mod.markers[en.unit_number]
	end,
	["transport-belt"] = function(cell, en)
		cell.belt = true
	end,
	["gate"] = function(cell, en)
		cell.gate = true
		cell.opened = en.is_opened()
	end,
}

local function cellGetterPath(cell, en)
	cell.path = true
	cell.direction = pathEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(pathEntities) do
	cellGetters[name] = cellGetterPath
end

local function cellGetterPathGroup(cell, en)
	cell.path = true
	cell.group = pathGroupEntitiesN[en.name]
	cell.direction = pathGroupEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(pathGroupEntities) do
	cellGetters[name] = cellGetterPathGroup
end

local function cellGetterStop(cell, en)
	cell.path = true
	cell.stop = true
	cell.direction = stopEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(stopEntities) do
	cellGetters[name] = cellGetterStop
end

local function cellGetterStopLoad(cell, en)
	cell.path = true
	cell.stop = true
	cell.load = true
	cell.direction = stopLoadEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(stopLoadEntities) do
	cellGetters[name] = cellGetterStopLoad
end

local function cellGetterStopUnload(cell, en)
	cell.path = true
	cell.stop = true
	cell.unload = true
	cell.direction = stopUnloadEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(stopUnloadEntities) do
	cellGetters[name] = cellGetterStopUnload
end

local function cellGetterStopSupply(cell, en)
	cell.path = true
	cell.stop = true
	cell.supply = true
	cell.direction = stopSupplyEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(stopSupplyEntities) do
	cellGetters[name] = cellGetterStopSupply
end

local function cellGetterStopDump(cell, en)
	cell.path = true
	cell.stop = true
	cell.dump = true
	cell.direction = stopDumpEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(stopDumpEntities) do
	cellGetters[name] = cellGetterStopDump
end

local function cellGetterStopAccept(cell, en)
	cell.path = true
	cell.stop = true
	cell.accept = true
	cell.direction = stopAcceptEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(stopAcceptEntities) do
	cellGetters[name] = cellGetterStopAccept
end

local function cellGetterTurnClear(cell, en)
	cell.path = true
	cell.optional = true
	cell.direction = turnClearEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(turnClearEntities) do
	cellGetters[name] = cellGetterTurnClear
end

local function cellGetterTurnClearGroup(cell, en)
	cell.path = true
	cell.optional = true
	cell.group = turnClearGroupEntitiesN[en.name]
	cell.direction = turnClearGroupEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(turnClearGroupEntities) do
	cellGetters[name] = cellGetterTurnClearGroup
end

local function cellGetterTurnBlocked(cell, en)
	cell.path = true
	cell.alternate = true
	cell.direction = turnBlockedEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(turnBlockedEntities) do
	cellGetters[name] = cellGetterTurnBlocked
end

local function cellGetterTurnFuel(cell, en)
	cell.path = true
	cell.fuel = true
	cell.direction = turnFuelEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(turnFuelEntities) do
	cellGetters[name] = cellGetterTurnFuel
end

local function cellGetterContinue(cell, en)
	cell.path = true
	cell.continue = true
	cell.direction = continueEntities[en.name]
	cell.entity = en
end

for name,_ in pairs(continueEntities) do
	cellGetters[name] = cellGetterContinue
end

local function cellGet(x, y, surface)
	local pos = cellCenterPos(x, y)
	local cell = {
		x = floor(x),
		y = floor(y),
		path = false,
		group = nil,
		direction = nil,
		optional = false,
		alternate = false,
		continue = false,
		stop = false,
		load = false,
		unload = false,
		supply = false,
		dump = false,
		accept = false,
		yield = false,
		belt = false,
		gate = false,
		opened = false,
		fuel = false,
		entity = nil,
		car_id = nil,
		tile = surface.get_tile(floor(pos.x), floor(pos.y)),
	}
	local entities = surface.find_entities_filtered({
		position = pos
	})
	for i = 1,#entities,1 do
		local en = entities[i]
		if en.valid and cellGetters[en.name] ~= nil then
			(cellGetters[en.name])(cell, en)
		end
	end
	return cell
end

local grassNames = {
	["grass-1"] = true,
	["grass-2"] = true,
	["grass-3"] = true,
}

local function cellClaim(cell, car, ticks)
	local pos = cellCenterPos(cell.x, cell.y)

	local marker = car.surface.create_entity({
		name = "logicarts-marker",
		position = pos,
		force = car.force,
	})

	if marker ~= nil and marker.valid then
		mod.markers[marker.unit_number] = car.unit_number
		markerQueue(marker, ticks + 10)
	end

	if cell.tile ~= nil and grassNames[cell.tile.name] ~= nil
		and settings.global["logicarts-grass-wearing"].value
	then

		local entities = car.surface.find_entities_filtered({
			name = "logicarts-wear",
			position = pos,
		})

		if entities ~= nil and #entities > 3 then
			car.surface.set_tiles({{ name = "grass-4", position = pos }})
			for _,en in ipairs(entities) do
				en.destroy()
			end
			return
		end

		car.surface.create_entity({
			name = "logicarts-wear",
			position = pos,
		})
	end
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
	if entity == nil then
		return
	end

	if entity.name == CAR_BURNER or entity.name == CAR_ELECTRIC then
		entity.friction_modifier = 0
		entity.consumption_modifier = 0

		local cell = cellGet(entity.position.x, entity.position.y, entity.surface)
		cellClaim(cell, entity, CAR_TICK_MARGIN)
		carQueue(entity, CAR_TICK_PLACED)
		return
	end

	if entity.name == "logicarts-path" then
		replaceEntityWith(entity, "logicarts-path-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-stop" then
		replaceEntityWith(entity, "logicarts-stop-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-stop-load" then
		replaceEntityWith(entity, "logicarts-stop-load-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-stop-unload" then
		replaceEntityWith(entity, "logicarts-stop-unload-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-stop-supply" then
		replaceEntityWith(entity, "logicarts-stop-supply-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-stop-dump" then
		replaceEntityWith(entity, "logicarts-stop-dump-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-stop-accept" then
		replaceEntityWith(entity, "logicarts-stop-accept-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-turn" then
		replaceEntityWith(entity, "logicarts-turn-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-turn-blocked" then
		replaceEntityWith(entity, "logicarts-turn-blocked-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-turn-fuel" then
		replaceEntityWith(entity, "logicarts-turn-fuel-"..directionNames[entity.direction])
		return
	end

	if entity.name == "logicarts-continue" then
		replaceEntityWith(entity, "logicarts-continue-"..directionNames[entity.direction])
		return
	end

	for i = 1,5,1 do
		if entity.name == "logicarts-path-G"..i then
			replaceEntityWith(entity, "logicarts-path-G"..i.."-"..directionNames[entity.direction])
			return
		end
	end

	for i = 1,5,1 do
		if entity.name == "logicarts-turn-G"..i then
			replaceEntityWith(entity, "logicarts-turn-G"..i.."-"..directionNames[entity.direction])
			return
		end
	end
end

local function OnPlayerDrivingStateChanged(event)
	State()
	local entity = event.entity
	if entity == nil then
		return
	end

	if (entity.name == CAR_BURNER or entity.name == CAR_ELECTRIC) and entity.get_driver() ~= nil then
		local player = entity.get_driver()
		entity.set_driver(nil)
		if entity.get_passenger() == nil then
			entity.set_passenger(player)
		end
	end
end

local function OnEntityRemoved(event)
	State()
	local entity = event.entity
	if entity == nil then
		return
	end

	if entity.name == "logicarts-marker" then
		mod.markers[entity.unit_number] = nil
	end

	if cartEntities[entity.name] ~= nil then
		mod.carStates[entity.unit_number] = nil
	end
end

local function checkDirection(car, state, direction)

	local x, y = cellCenter(car.position.x, car.position.y)
	x, y = cellTranslate(direction, x, y)

	local cell = cellGet(x, y, car.surface)

	if cell ~= nil then
		local path = cell.path or state.continue or false
		local free = cell.car_id == nil or cell.car_id == car.unit_number
		local clear = not cell.gate or cell.opened
		return (path and free and clear), cell
	end

	return false, cell
end

local function getCombinator(surface, position)
	local entities = surface.find_entities_filtered({
		name = "constant-combinator",
		position = position,
	})
	return entities ~= nil and entities[1] or nil
end

local function getAdjacentCombinator(surface, x, y)
	local pos = cellCenterPos(x, y)
	local entity = nil

	entity = getCombinator(surface, directionPosition(NORTH, pos))
	if entity ~= nil and entity.direction == SOUTH then
		return entity
	end
	entity = getCombinator(surface, directionPosition(SOUTH, pos))
	if entity ~= nil and entity.direction == NORTH then
		return entity
	end
	entity = getCombinator(surface, directionPosition(EAST, pos))
	if entity ~= nil and entity.direction == WEST then
		return entity
	end
	entity = getCombinator(surface, directionPosition(WEST, pos))
	if entity ~= nil and entity.direction == EAST then
		return entity
	end
	return nil
end

local function setCombinatorSignals(combinator, items, virtuals)
	local parameters = {}
	local limit = combinator.get_control_behavior().signals_count

	if items ~= nil then
		for item, count in pairs(items) do
			local index = #parameters+1
			if index >= limit then
				break
			end
			parameters[index] = {
				index = index,
				signal = {
					type = "item",
					name = item,
				},
				count = count,
			}
		end
	end

	if virtuals ~= nil then
		for item, count in pairs(virtuals) do
			local index = #parameters+1
			if index >= limit then
				break
			end
			parameters[index] = {
				index = index,
				signal = {
					type = "virtual",
					name = item,
				},
				count = count,
			}
		end
	end

	combinator.get_control_behavior().parameters = {
		parameters = parameters
	}
end

local function getCombinatorSignals(combinator)
	local virtuals = {} -- set
	local items = {}  -- map
	local array = {} -- array
	local check = function(signals)
		if signals ~= nil then
			for _, v in pairs(signals) do
				if v.signal.name ~= nil then
					if v.signal.type == "virtual" then
						virtuals[v.signal.name] = true
					elseif v.signal.type == "item" then
						items[v.signal.name] = (items[v.signal.name] or 0) + v.count
						array[#array+1] = v.signal.name
					end
				end
			end
		end
	end
	check(combinator.get_merged_signals())
	check(combinator.get_control_behavior().parameters.parameters)
	return virtuals, items, array
end

local function restrictedVirtuals(virtuals)
	return virtuals ~= nil and (virtuals["signal-T"] or virtuals["signal-G"]) or false
end

local function getLogisticChests(x, y, surface)
	local pos = cellCenterPos(x, y)

	local chests = {}
	local directions = {}

	local check = function(dir)
		local entities = surface.find_entities_filtered({
			type = "logistic-container",
			position = directionPosition(dir, pos),
		})
		if entities ~= nil then
			for i = 1,#entities,1 do
				local en = entities[i]
				if en.prototype.logistic_mode ~= nil then
					chests[#chests+1] = en
					directions[#directions+1] = dir
				end
			end
		end
	end

	check(NORTH)
	check(SOUTH)
	check(EAST)
	check(WEST)

	return chests, directions
end

local function getAllChests(x, y, surface)
	local pos = cellCenterPos(x, y)

	local chests = {}
	local directions = {}

	local check = function(dir)
		local entities = surface.find_entities_filtered({
			type = { "container", "logistic-container" },
			position = directionPosition(dir, pos),
		})
		if entities ~= nil then
			for i = 1,#entities,1 do
				chests[#chests+1] = entities[i]
				directions[#directions+1] = dir
			end
		end
	end

	check(NORTH)
	check(SOUTH)
	check(EAST)
	check(WEST)

	return chests, directions
end

local function carContents(car)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	local contents = trunk.get_contents()
	for k,v in pairs(car.grid.get_contents()) do
		if game.item_prototypes[k] ~= nil then
			contents[k] = (contents[k] or 0) + v
		end
	end
	-- If filtered trunk slots are in use, send the item shortfall as a negative value.
	-- This allows loading station circuits to look for item < 0.
	if trunk.is_filtered() then
		local reqs = {}
		for i = 1,#trunk,1 do
			local filter = trunk.get_filter(i)
			if filter ~= nil then
				reqs[filter] = (reqs[filter] or 0) + game.item_prototypes[filter].stack_size
			end
		end
		for k,r in pairs(reqs) do
			local c = contents[k] or 0
			if r > c then
				contents[k] = c - r
			end
		end
	end
	return contents
end

local function carFiltersFromSignals(car, items)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	for slot,item in ipairs(items) do
		if slot > #trunk then
			break
		end
		if equipmentGroups[item] == nil then
			trunk.set_filter(slot, item)
		end
	end
	for i = #items+1,#trunk,1 do
		trunk.set_filter(i, nil)
	end
end

local function carGroupFromSignals(car, items)
	local equipment = car.grid.equipment
	for i = 1,#equipment,1 do
		local eq = equipment[i]
		if equipmentGroups[eq.name] ~= nil then
			car.grid.take({ equipment = eq})
		end
	end
	for _,item in ipairs(items) do
		if equipmentGroups[item] ~= nil then
			car.grid.put({ name = item })
		end
	end
end

-- Transfer items from a chest to the cart trunk filtered slots
local function carLoad(car, chest, ops)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	local inventory = chest.get_inventory(defines.inventory.chest)

	-- Refuel first if necessary
	if car.name == CAR_BURNER then
		local burner = car.burner
		local fueltank = burner.inventory
		local item = burner.currently_burning
		if item ~= nil then
			local available = min(ops, inventory.get_item_count(item.name))
			if available > 0 then
				local moved = fueltank.insert({ name = item.name, count = available })
				if moved > 0 then
					inventory.remove({ name = item.name, count = moved })
					ops = ops - moved
				end
			end
		end
	end

	for j = 1,#trunk,1 do
		if ops <= 0 then
			break
		end
		local filter = trunk.get_filter(j)
		if filter ~= nil then
			local stack = trunk[j]
			local count = (stack ~= nil and stack.valid_for_read and stack.count) or 0
			local shortfall = max(0, game.item_prototypes[filter].stack_size - count)
			local moved = min(ops, min(shortfall, inventory.get_item_count(filter)))
			if moved > 0 then
				local tstack = { name = filter, count = moved }
				inventory.remove(tstack)
				if stack ~= nil and stack.valid_for_read and stack.valid then
					stack.count = stack.count + moved
				else
					trunk.insert(tstack)
				end
				ops = ops - moved
			end
		end
	end
	return ops
end

-- Transfer cart filtered slots to a chest.
local function carUnload(car, chest, ops)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	local inventory = chest.get_inventory(defines.inventory.chest)

	for j = 1,#trunk,1 do
		if ops <= 0 then
			break
		end
		if trunk.get_filter(j) ~= nil then
			local stack = trunk[j]
			if stack ~= nil and stack.valid_for_read then
				local name = stack.name
				local count = min(ops, stack.count)
				if count > 0 then
					local moved = inventory.insert({ name = name, count = count })
					if moved > 0 then
						trunk.remove({ name = name, count = moved })
						ops = ops - moved
					end
				end
			end
		end
	end
	return ops
end

-- Transfer items, if available, from cart to chest.
local function carSupply(car, chest, items, ops)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	local inventory = chest.get_inventory(defines.inventory.chest)

	for name,count in pairs(items) do
		if ops <= 0 then
			break
		end
		local moved = min(ops, min(count, trunk.get_item_count(name)))
		if moved > 0 then
			local stack = { name = name, count = moved }
			trunk.remove(stack)
			inventory.insert(stack)
			ops = ops - moved
		end
	end
	return ops
end

-- Fill trunk from chest.
local function carAccept(car, chest, ops)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	local inventory = chest.get_inventory(defines.inventory.chest)

	-- Priority to filtered slots
	ops = carLoad(car, chest, ops)

	-- Fill partial stacks
	if ops > 0 then
		for i = 1,#trunk,1 do
			if ops <= 0 then
				break
			end
			local stack = trunk[i]
			if stack ~= nil and stack.valid_for_read then
				local name = stack.name
				local move = min(ops, inventory.get_item_count(name))
				if move > 0 then
					local moved = trunk.insert({ name = name, count = move })
					if moved > 0 then
						inventory.remove({ name = name, count = moved })
						ops = ops - moved
					end
				end
			end
		end
	end

	-- Fill empty slots
	if ops > 0 then
		for name,count in pairs(inventory.get_contents()) do
			if ops <= 0 then
				break
			end
			local move = min(ops, count)
			local moved = trunk.insert({ name = name, count = move })
			if moved > 0 then
				inventory.remove({ name = name, count = moved })
				ops = ops - moved
			end
		end
	end

	return ops
end

-- Dump unfiltered items to chest.
local function carDump(car, chest, ops)
	local trunk = car.get_inventory(defines.inventory.car_trunk)
	local inventory = chest.get_inventory(defines.inventory.chest)

	for j = 1,#trunk,1 do
		if ops <= 0 then
			break
		end
		if trunk.get_filter(j) == nil then
			local stack = trunk[j]
			if stack ~= nil and stack.valid_for_read then
				local name = stack.name
				local count = min(ops, stack.count)
				if count > 0 then
					local moved = inventory.insert({ name = name, count = count })
					if moved > 0 then
						trunk.remove({ name = name, count = moved })
						ops = ops - moved
					end
				end
			end
		end
	end
	return ops
end

-- A requester or buffer's requests as [name] = count
local function logisticChestRequests(chest)
	local requests = {}
	for i = 1,chest.request_slot_count,1 do
		local request = chest.get_request_slot(i)
		if request ~= nil then
			local count = request.count - chest.get_item_count(request.name)
			if count > 0 then
				requests[request.name] = count
			end
		end
	end
	return requests
end

-- A chest requests as [name] = count
local function chestRequests(chest)
	if chest.prototype.logistic_mode == "requester" or chest.prototype.logistic_mode == "buffer" then
		return logisticChestRequests(chest)
	end
	local requests = {}
	local signals = chest.get_merged_signals()
	if signals ~= nil then
		for _, v in pairs(signals) do
			if v.signal.name ~= nil and v.signal.type == "item" and v.count < 0 then
				requests[v.signal.name] = abs(v.count)
			end
		end
	end
	return requests
end

local function carInteractLogisticChests(car, chests)
	local trunk = car.get_inventory(defines.inventory.car_trunk)

	-- yellow transport belt boosted by inserter-bonus research
	local throughput = car.force.inserter_stack_size_bonus * 14
	local activity = 0

	local supply = function(chest)
		local items = logisticChestRequests(chest)
		local done = carSupply(car, chest, items, throughput)
		activity = activity + (throughput - done)
	end

	local demand = function(chest)
		local done = carLoad(car, chest, throughput)
		activity = activity + (throughput - done)
	end

	local accept = function(chest)
		local done = carAccept(car, chest, throughput)
		activity = activity + (throughput - done)
	end

	local dump = function(chest)
		local done = carDump(car, chest, throughput)
		activity = activity + (throughput - done)
	end

	for i = 1,#chests,1 do
		local chest = chests[i]
		local mode = chest.prototype.logistic_mode

		if mode == "requester" then
			supply(chest)
		elseif mode == "passive-provider" then
			demand(chest)
		elseif mode == "active-provider" then
			demand(chest)
			accept(chest)
		elseif mode == "storage" then
			dump(chest)
			demand(chest)
		elseif mode == "buffer" then
			demand(chest)
		end
	end

	return activity
end

local function carInteractChests(car, chests, cell)

	-- yellow transport belt boosted by inserter-bonus research
	local throughput = car.force.inserter_stack_size_bonus * 14

	if cell.load then
		local ops = throughput
		for _,chest in ipairs(chests) do
			if ops <= 0 then
				break
			end
			ops = carLoad(car, chest, ops)
		end
		return throughput - ops
	end

	if cell.unload then
		local ops = throughput
		for _,chest in ipairs(chests) do
			if ops <= 0 then
				break
			end
			ops = carUnload(car, chest, ops)
		end
		return throughput - ops
	end

	if cell.supply then
		local ops = throughput
		for _,chest in ipairs(chests) do
			if ops <= 0 then
				break
			end
			local reqs = chestRequests(chest)
			ops = carSupply(car, chest, reqs, ops)
		end
		return throughput - ops
	end

	if cell.dump then
		local ops = throughput
		for _,chest in ipairs(chests) do
			if ops <= 0 then
				break
			end
			ops = carDump(car, chest, ops)
		end
		return throughput - ops
	end

	if cell.accept then
		local ops = throughput
		for _,chest in ipairs(chests) do
			if ops <= 0 then
				break
			end
			ops = carAccept(car, chest, ops)
		end
		return throughput - ops
	end

	return 0
end

local function carNeedFuel(car)
	if car.name == CAR_BURNER then
		local total = 0
		local available = 0
		local contents = car.burner.inventory.get_contents()
		for item,count in pairs(contents) do
			local proto = game.item_prototypes[item]
			if proto ~= nil and proto.fuel_category ~= nil then
				total = total + (proto.fuel_value * proto.stack_size)
				available = available + (proto.fuel_value * count)
			end
		end
		return available == 0 or available/total < settings.global["logicarts-fuel-threshold"].value
	end
	return false
end

local function runCar(car)

	local state = mod.carStates[car.unit_number]
	if state == nil then
		state = {}
		mod.carStates[car.unit_number] = state
	end

	-- default action is full stop
	car.speed = 0

	local x = car.position.x
	local y = car.position.y
	local cell = cellGet(x, y, car.surface)

	-- have we strayed off the path, or perhaps had it deconstructed
	-- out from underneath us while we were diligently delivering items?
	if not cell.path and not state.continue then
		cellClaim(cell, car, CAR_TICK_MARGIN)
		return CAR_TICK_BLOCKED
	end

	if cell.gate and not cell.opened then
		cellClaim(cell, car, CAR_TICK_MARGIN)
		return CAR_TICK_BLOCKED
	end

	-- Back on road
	if cell.path and state.continue then
		state.continue = nil
	end

	-- Current direction
	local carDirection = quadrantDirections[floor(car.orientation*4+1)] or NORTH

	-- Direction to exit the tile
	local pathDirection = cell.direction or carDirection

	-- Legitimately off-road
	if state.continue then
		pathDirection = carDirection
	end

	-- Chemical or electric fuel types
	local fueled = false
	local consume = nil

	if car.name == CAR_BURNER then
		local burner = car.burner
		fueled = burner.remaining_burning_fuel > 0

		local fueltank = burner.inventory
		local fuelstoke = burner.currently_burning == nil or burner.remaining_burning_fuel < CAR_CONSUMPTION_BURNER

		-- since we don't use riding_state, manually stoke the burner
		if fuelstoke and not fueltank.is_empty() then
			for item, count in pairs(fueltank.get_contents()) do
				burner.currently_burning = game.item_prototypes[item]
				burner.remaining_burning_fuel = burner.currently_burning.fuel_value
				fueltank.remove({ name = item, count = count > 1 and 1 or count })
				fueled = true
				break
			end
		end

		consume = function()
			burner.remaining_burning_fuel = burner.remaining_burning_fuel - CAR_CONSUMPTION_BURNER
		end
	end

	if car.name == CAR_ELECTRIC then

		fueled = car.grid.available_in_batteries >= CAR_CONSUMPTION_ELECTRIC
		local equipment = car.grid.equipment

		consume = function()
			local energy = CAR_CONSUMPTION_ELECTRIC
			for i = 1,#equipment,1 do
				local battery = equipment[i]

				if battery.prototype.type == "battery-equipment" and battery.energy > 0 then
					local take = min(energy, battery.energy)
					battery.energy = battery.energy - take
					energy = energy - take
				end

				if energy <= 0 then
					break
				end
			end
		end
	end

	if not fueled then
		cellClaim(cell, car, CAR_TICK_STOPPED)
		return CAR_TICK_STOPPED
	end

	-- If on a belt we obviously can't stop, and can therefore skip some checks
	if cell.belt then
		nextOK, nextCell = checkDirection(car, state, carDirection, nil)
		if nextOK then
			-- hope for the best; the added speed may screw up center alignment checks
			car.speed = CAR_ENTITY_SPEED
			cellClaim(nextCell, car, CAR_TICK_MARGIN)
			consume()
		end
		return CAR_TICK_STARTING
	end

	local n = abs(y)
	local d = n - floor(n)
	local yc = d > TILE_CENTER_LOW and d < TILE_CENTER_HIGH

	local n = abs(x)
	local d = n - floor(n)
	local xc = d > TILE_CENTER_LOW and d < TILE_CENTER_HIGH

	local centered = xc and yc

	if not centered then
		-- keep moving
		car.speed = CAR_ENTITY_SPEED
		return CAR_TICK_ARRIVING
	end

	-- Remove any accumulated error
	car.teleport(cellCenterPos(x, y))

	-- Going off road?
	if cell.continue then
		state.continue = true
	end

	-- Constant combinator as sensor
	local adjacentCombinator = nil
	local CCvirtuals = nil -- set of constant combinator virtual signals ([name] = true)
	local CCitems = nil -- set of constant combinator item signals ([name] = count)
	local CCarray = nil -- array of CC items ordered per control parameters

	-- Inventory + grid contents
	local contents = nil
	local signals = nil

	local contentsAndSignals = function()
		contents = carContents(car)
		signals = {
			["signal-C"] = car.unit_number,
			["signal-F"] = car.get_fuel_inventory().get_item_count(),
			["signal-E"] = car.grid.available_in_batteries,
		}
	end

	-- Signals to control a car
	local red = false
	local green = false
	local yield = cell.yield
	local optionalFuel = cell.fuel
	local optionalRoute = cell.optional
	local alternateRoute = cell.alternate

	-- Restrict group paths
	if cell.group ~= nil and (car.grid.get_contents())["logicarts-equipment-"..cell.group] == nil then
		pathDirection = carDirection
	end

	-- Circuit network intraction only happens on paths
	if cell.path then
		adjacentCombinator = getAdjacentCombinator(car.surface, x, y)

		if adjacentCombinator ~= nil then
			CCvirtuals, CCitems, CCarray = getCombinatorSignals(adjacentCombinator)

			green = CCvirtuals["signal-green"] or false
			red = CCvirtuals["signal-red"] or false

			if CCvirtuals["signal-S"] then -- straight
				pathDirection = carDirection

			elseif CCvirtuals["signal-L"] then -- left
				pathDirection = leftDirections[pathDirection] or pathDirection

			elseif CCvirtuals["signal-R"] then -- right
				pathDirection = rightDirections[pathDirection] or pathDirection
			end

			if CCvirtuals["signal-T"] then
				carFiltersFromSignals(car, CCarray)
			end

			if CCvirtuals["signal-G"] and car.force.technolgies["logicarts-tech-groups"].researched then
				carGroupFromSignals(car, CCarray)
			end

			if restrictedVirtuals(CCvirtuals) then
				adjacentCombinator = nil
			end
		end
	end

	local stop = red or (cell.stop and not green)

	if stop then
		contentsAndSignals()

		if cell.load or cell.unload or cell.supply or cell.dump or cell.accept then
			-- Interact with chests according to stop mode
			local chests, chestDirections = getAllChests(x, y, car.surface)
			if #chests > 0 then
				if carInteractChests(car, chests, cell) > 0 then
					car.orientation = directionOrientations[reverseDirections[chestDirections[1] or NORTH]]
					contents = carContents(car)
					state.stopCount = 0
				end
			end
		else
			-- Participate automatically in logistics network
			local chests, chestDirections = getLogisticChests(x, y, car.surface)
			if #chests > 0 then
				if carInteractLogisticChests(car, chests) > 0 then
					car.orientation = directionOrientations[reverseDirections[chestDirections[1] or NORTH]]
					contents = carContents(car)
					state.stopCount = 0
				end
			end
		end

		-- Default is to broadcast our contents. Various signals disable this
		if adjacentCombinator ~= nil then
			setCombinatorSignals(adjacentCombinator, contents, signals)
		end

		if red then
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

	-- clear combinator on departure
	if adjacentCombinator ~= nil then
		adjacentCombinator.get_control_behavior().parameters = nil
	end

	-- centered; claim the cell but figure out what to do next
	cellClaim(cell, car, CAR_TICK_MARGIN)

	local direction = pathDirection
	local nextOK, nextCell = checkDirection(car, state, pathDirection)

	if yield then
		direction = carDirection
		nextOK, nextCell = checkDirection(car, state, carDirection)
	end

	if optionalRoute then
		if not nextOK then
			direction = carDirection
			nextOK, nextCell = checkDirection(car, state, carDirection)
		end
	end

	if alternateRoute then
		local aheadOK, aheadCell = checkDirection(car, state, carDirection)
		if aheadOK then
			nextOK = aheadOK
			nextCell = aheadCell
			direction = carDirection
		end
	end

	if optionalFuel then
		if not nextOK or not carNeedFuel(car) then
			direction = carDirection
			nextOK, nextCell = checkDirection(car, state, carDirection)
		end
	end

	-- animated pivot? UPS...
	car.orientation = directionOrientations[direction]

	if nextOK then

		-- claim the next cell and go!
		car.speed = CAR_ENTITY_SPEED
		cellClaim(nextCell, car, CAR_TICK_MARGIN)
		consume()

		if nextCell.path then
			-- if approaching a combinator, update it in advance to allow circuits to change in time
			local nextCombinator = getAdjacentCombinator(car.surface, nextCell.x, nextCell.y)

			if nextCombinator ~= nil then
				contentsAndSignals()
				local virtuals, _, _ = getCombinatorSignals(nextCombinator)
				if not restrictedVirtuals(virtuals) then
					setCombinatorSignals(nextCombinator, contents, signals)
				end
			end
		end

		return CAR_TICK_STARTING
	end

	return CAR_TICK_BLOCKED
end

-- Updating the positions of a bunch of entities every tick is a
-- recipe for a Factorio UPS crash. We try to be tricksy by using
-- car.speed deterministically and scheduling individual car
-- position checks as infrequently as possible.
local function OnTick(event)
	mod = global

	local queue = mod.queues ~= nil and mod.queues[game.tick]

	if queue == nil then
		return
	end

	State()

	mod.queues[game.tick] = nil

	for i = 1,#queue,1 do
		local en = queue[i]
		queue[i] = nil
		if en.valid then
			if en.name == "logicarts-marker" then
				mod.markers[en.unit_number] = nil
				en.destroy()
			else
				local ticks = runCar(en)
				-- reschedule
				if ticks > 0 then
					carQueue(en, ticks)
				end
			end
		end
	end
end

local function OnDebug(event)
	game.print("debug"..serialize({
		["CAR_SPEED"] = CAR_SPEED,
		["CAR_ENTITY_SPEED"] = CAR_ENTITY_SPEED,
		["CAR_TICK_STARTING"] = CAR_TICK_STARTING,
		["CAR_TICK_ARRIVING"] = CAR_TICK_ARRIVING,
		["CAR_TICK_BLOCKED"] = CAR_TICK_BLOCKED,
	}))
end

script.on_init(function()
	State()
	script.on_event(defines.events.on_tick, OnTick)
	script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, OnEntityCreated)
	script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, OnEntityRemoved)
	script.on_event({defines.events.on_player_driving_changed_state}, OnPlayerDrivingStateChanged)
	script.on_event("logicarts-debug", OnDebug)
end)

script.on_load(function()
	script.on_event(defines.events.on_tick, OnTick)
	script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, OnEntityCreated)
	script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, OnEntityRemoved)
	script.on_event({defines.events.on_player_driving_changed_state}, OnPlayerDrivingStateChanged)
	script.on_event("logicarts-debug", OnDebug)
end)

