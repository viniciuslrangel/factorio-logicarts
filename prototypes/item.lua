local prototypes = {}
local subgroups = {}

local function subgroupSpot(subgroup)
	subgroups[subgroup] = (subgroups[subgroup] or 0) + 1
	return subgroups[subgroup]
end

local function placeableItem(name, stack, subgroup, size, icon)
	prototypes[#prototypes+1] = {
		type = "item",
		name = name,
		icon = icon,
		icon_size = size,
		flags = {},
		place_result = name,
		order = subgroupSpot(subgroup),
		stack_size = stack,
		subgroup = subgroup,
	}
end

local function placeableItemWithEntityData(name, stack, subgroup, size, icon)
	prototypes[#prototypes+1] = {
		type = "item-with-entity-data",
		name = name,
		icon = icon,
		icon_size = size,
		flags = {},
		place_result = name,
		order = subgroupSpot(subgroup),
		stack_size = stack,
		subgroup = subgroup,
	}
end

local function ingredientItem(name, stack, subgroup, size, icon)
	prototypes[#prototypes+1] = {
		type = "item",
		name = name,
		icon = icon,
		icon_size = size,
		flags = {},
		order = subgroupSpot(subgroup),
		stack_size = stack,
		subgroup = subgroup,
	}
end

local function hiddenItem(name, size, icon)
	prototypes[#prototypes+1] = {
		type = "item",
		name = name,
		icon = icon,
		icon_size = size,
		flags = {"hidden"},
		order = "z",
		stack_size = 50,
	}
end

local function invisibleItem(name, size, icon)
	hiddenItem(name, 32, "__logicarts2__/graphics/nothing.png")
end

local function directionItems(name, size, icon)
	return {
		hiddenItem(name.."-north", size, icon),
		hiddenItem(name.."-east", size, icon),
		hiddenItem(name.."-south", size, icon),
		hiddenItem(name.."-west", size, icon),
	}
end

local path_stack_size = 1000

local function pathItem(name, icon)
	placeableItem(name, path_stack_size, "logicarts-subgroup-path", 128, icon)
	directionItems(name, 128, icon)
end

local function stopItem(name, icon)
	placeableItem(name, path_stack_size, "logicarts-subgroup-stop", 128, icon)
	directionItems(name, 128, icon)
end

local function dualItem(name, icon)
	placeableItem(name, path_stack_size, "logicarts-subgroup-dual", 128, icon)
	directionItems(name, 128, icon)
end

invisibleItem("logicarts-marker")
invisibleItem("logicarts-wear")

-- ROW 1
ingredientItem("logicarts-paint", 50, "logicarts-subgroup", 128, "__logicarts2__/graphics/paint-icon.png")
placeableItemWithEntityData("logicarts-car", 10, "logicarts-subgroup", 32, "__logicarts2__/graphics/cart-ico.png")
placeableItemWithEntityData("logicarts-car-electric", 10, "logicarts-subgroup", 32, "__logicarts2__/graphics/e-cart-ico.png")

placeableItem("logicarts-sticker", 1000, "logicarts-subgroup", 32, "__logicarts2__/graphics/sticker-icon.png")
hiddenItem("logicarts-sticker-display", 32, "__logicarts2__/graphics/sticker-icon.png")

-- ROW 2
pathItem("logicarts-path",  "__logicarts2__/graphics/path-icon.png")
pathItem("logicarts-turn",  "__logicarts2__/graphics/turn-icon.png")
pathItem("logicarts-stop",  "__logicarts2__/graphics/stop-icon.png")
pathItem("logicarts-turn-fuel",  "__logicarts2__/graphics/turn-fuel-icon.png")
pathItem("logicarts-turn-blocked",  "__logicarts2__/graphics/turn-blocked-icon.png")
pathItem("logicarts-continue",  "__logicarts2__/graphics/continue-icon.png")

placeableItem("logicarts-yield", path_stack_size, "logicarts-subgroup-path", 128, "__logicarts2__/graphics/yield-icon.png")

-- ROW 3
stopItem("logicarts-stop-load",   "__logicarts2__/graphics/stop-load-icon.png")
stopItem("logicarts-stop-unload", "__logicarts2__/graphics/stop-unload-icon.png")
stopItem("logicarts-stop-supply", "__logicarts2__/graphics/stop-supply-icon.png")
stopItem("logicarts-stop-dump",   "__logicarts2__/graphics/stop-dump-icon.png")
stopItem("logicarts-stop-accept", "__logicarts2__/graphics/stop-accept-icon.png")
stopItem("logicarts-stop-deploy", "__logicarts2__/graphics/stop-deploy-icon.png")
stopItem("logicarts-stop-retire", "__logicarts2__/graphics/stop-retire-icon.png")

-- ROW 4
dualItem("logicarts-path-dual-straight",  "__logicarts2__/graphics/path-dual-straight-icon.png")
dualItem("logicarts-path-dual-turn",  "__logicarts2__/graphics/path-dual-turn-icon.png")
dualItem("logicarts-continue-dual-straight",  "__logicarts2__/graphics/continue-dual-straight-icon.png")
dualItem("logicarts-continue-dual-turn",  "__logicarts2__/graphics/continue-dual-turn-icon.png")

data:extend(prototypes)
