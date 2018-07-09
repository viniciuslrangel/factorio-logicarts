-- Commence dodgy hackery!

-- First attempt for path entities was to use ground tiles. Problems were:
-- The paths are meant to be paint so it seemed strange not to be able to
-- spray over concrete or bricks. The placement options also have limited
-- rotation flexibility.
--
-- Second attempt was to use constant combinators with modified sprites.
-- That worked almost entirely and had nice rotation while building, but
-- the CC render_layer is hardcoded and (apparently) can't be put underneath
-- cars.
--
-- Third attempt was to use #2 only for placing and rotating paths, with
-- four simple-entity-with-force that get placed instead via OnEntityCreated.
-- This works mostly intuitively and is blueprintable; only problem is
-- fast_replaceable_group seems to mesh poorly with placeable_by leading
-- to rapid replace cycles and staccato build sound effects. So FRG is
-- currently disabled for paths, unfortunately.

local function logicartsPath(placeable, name, size, scale, sheet, xpos)
	return {
		type = "simple-entity-with-force",
		name = name,
		flags = {
			"player-creation",
		},
		selectable_in_game = true,
		build_sound = nil,
		mined_sound = nil,
		created_smoke = nil,
		minable = {
			mining_time = 1,
			result = placeable,
		},
		collision_mask = {
			"doodad-layer",
		},
		collision_box = {{-0.4,-0.4},{0.4,0.4}},
		selection_box = {{-0.5,-0.5},{0.5,0.5}},
		picture = {
			x = xpos * size,
			filename = sheet,
			width = size,
			height = size,
			scale = scale,
		},
		render_layer = "floor",
		tile_width = 1,
		tile_height = 1,
		placeable_by = {
			item = placeable,
			count = 1,
		}
	}
end

data:extend({logicartsPath("logicarts-path", "logicarts-path-north",
	128, 0.25, "__logicarts__/path.png", 0)})
data:extend({logicartsPath("logicarts-path", "logicarts-path-east",
	128, 0.25, "__logicarts__/path.png", 1)})
data:extend({logicartsPath("logicarts-path", "logicarts-path-south",
	128, 0.25, "__logicarts__/path.png", 2)})
data:extend({logicartsPath("logicarts-path", "logicarts-path-west",
	128, 0.25, "__logicarts__/path.png", 3)})

data:extend({logicartsPath("logicarts-turn", "logicarts-turn-north",
	128, 0.25, "__logicarts__/turn.png", 0)})
data:extend({logicartsPath("logicarts-turn", "logicarts-turn-east",
	128, 0.25, "__logicarts__/turn.png", 1)})
data:extend({logicartsPath("logicarts-turn", "logicarts-turn-south",
	128, 0.25, "__logicarts__/turn.png", 2)})
data:extend({logicartsPath("logicarts-turn", "logicarts-turn-west",
	128, 0.25, "__logicarts__/turn.png", 3)})

data:extend({logicartsPath("logicarts-stop", "logicarts-stop-north",
	128, 0.25, "__logicarts__/stop.png", 0)})
data:extend({logicartsPath("logicarts-stop", "logicarts-stop-east",
	128, 0.25, "__logicarts__/stop.png", 1)})
data:extend({logicartsPath("logicarts-stop", "logicarts-stop-south",
	128, 0.25, "__logicarts__/stop.png", 2)})
data:extend({logicartsPath("logicarts-stop", "logicarts-stop-west",
	128, 0.25, "__logicarts__/stop.png", 3)})

data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-north",
	128, 0.25, "__logicarts__/turn-blocked.png", 0)})
data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-east",
	128, 0.25, "__logicarts__/turn-blocked.png", 1)})
data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-south",
	128, 0.25, "__logicarts__/turn-blocked.png", 2)})
data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-west",
	128, 0.25, "__logicarts__/turn-blocked.png", 3)})

data:extend({logicartsPath("logicarts-yield", "logicarts-yield",
	128, 0.25, "__logicarts__/yield.png", 0)})

-- The placer entity is only used to make path placement with the mouse look normal,
-- and to make blueprints work. It's never actually placed on the ground itself.

local function logicartsPathPlacer(name, size, scale, sheet, n, e, s, w)
	local path = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
	path.name = name
	path.minable.result = name
	path.build_sound = nil
	path.collision_mask = {
		"doodad-layer",
	}
	--path.fast_replaceable_group = "logicarts-path"
	path.sprites.north = {
		x = n * size,
		filename = sheet,
		width = size,
		height = size,
		scale = scale,
	}
	path.sprites.east = {
		x = e * size,
		filename = sheet,
		width = size,
		height = size,
		scale = scale,
	}
	path.sprites.south = {
		x = s * size,
		filename = sheet,
		width = size,
		height = size,
		scale = scale,
	}
	path.sprites.west = {
		x = w * size,
		filename = sheet,
		width = size,
		height = size,
		scale = scale,
	}
	data:extend({ path })
end

logicartsPathPlacer("logicarts-path", 128, 0.25, "__logicarts__/path.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-stop", 128, 0.25, "__logicarts__/stop.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-turn", 128, 0.25, "__logicarts__/turn.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-turn-blocked", 128, 0.25, "__logicarts__/turn-blocked.png", 0, 1, 2, 3)

-- A mini car with sprites that are part 1x1 scaled car and part rail wagon...
-- As direction_count=4, these look terible if you try to drive one around, but
-- it's an easy way of getting carts to be actual vehicles (for on_tick UPS
-- mainly), instead of units or something else animated manually.

local car = table.deepcopy(data.raw.car.car)
car.name = "logicarts-car"
car.minable.result = "logicarts-car"
car.inventory_size = 10
car.guns = nil
car.consumption = "50kW"
car.equipment_grid = "logicarts-equipment-grid"
car.turret_animation = nil
car.flags = {
	"player-creation",
}
car.tile_width = 1
car.tile_height = 1
car.collision_box = {
	{
		-0.4,
		-0.4
	},
	{
		0.4,
		0.4
	}
}
car.selection_box = {
	{
		-0.5,
		-0.5
	},
	{
		0.5,
		0.5
	}
}
car.animation.layers = {
	{
		animation_speed = 0.5,
		direction_count = 4,
		frame_count = 2,
		height = 192,
		max_advance = 0.2,
		priority = "low",
		scale = 0.25,
		shift = {
			0,
			-4/32,
		},
		stripes = {
			{
				filename = "__logicarts__/graphics/cart.png",
				height_in_frames = 4,
				width_in_frames =2,
			},
		},
		width = 192,
	},
	{
		draw_as_shadow = true,
		animation_speed = 0.5,
		direction_count = 4,
		frame_count = 2,
		height = 192,
		max_advance = 0.2,
		priority = "low",
		scale = 0.25,
		shift = {
			0,
			-4/32,
		},
		stripes = {
			{
				filename = "__logicarts__/graphics/shadow.png",
				height_in_frames = 4,
				width_in_frames = 2,
			},
		},
		width = 192,
	}
}

data:extend({ car })


-- A mini car with sprites that are part 1x1 scaled car and part rail wagon...
-- As direction_count=4, these look terible if you try to drive one around, but
-- it's an easy way of getting carts to be actual vehicles (for on_tick UPS
-- mainly), instead of units or something else animated manually.

local car = table.deepcopy(data.raw.car.car)
car.name = "logicarts-car-electric"
car.minable.result = "logicarts-car-electric"
car.inventory_size = 10
car.consumption = "50kW"
car.guns = nil
car.equipment_grid = "logicarts-equipment-grid"
car.turret_animation = nil
car.flags = {
	"player-creation",
}
car.tile_width = 1
car.tile_height = 1
car.collision_box = {
	{
		-0.4,
		-0.4
	},
	{
		0.4,
		0.4
	}
}
car.selection_box = {
	{
		-0.5,
		-0.5
	},
	{
		0.5,
		0.5
	}
}
car.burner = {
  effectivity = 1,
  fuel_inventory_size = 0,
  render_no_power_icon = false,
}
car.sound_no_fuel = nil
car.working_sound = {
  sound = {
    filename = "__base__/sound/electric-furnace.ogg",
    volume = 0.2,
  },
  match_speed_to_activity = true,
}
car.animation.layers = {
	{
		animation_speed = 0.5,
		direction_count = 4,
		frame_count = 2,
		height = 192,
		max_advance = 0.2,
		priority = "low",
		scale = 0.25,
		shift = {
			0,
			-4/32,
		},
		stripes = {
			{
				filename = "__logicarts__/graphics/electric-cart.png",
				height_in_frames = 4,
				width_in_frames =2,
			},
		},
		width = 192,
	},
	{
		draw_as_shadow = true,
		animation_speed = 0.5,
		direction_count = 4,
		frame_count = 2,
		height = 192,
		max_advance = 0.2,
		priority = "low",
		scale = 0.25,
		shift = {
			0,
			-4/32,
		},
		stripes = {
			{
				filename = "__logicarts__/graphics/shadow.png",
				height_in_frames = 4,
				width_in_frames =2,
			},
		},
		width = 192,
	}
}
data:extend({ car })

-- When carts move around, to avoid collision we claim tiles before
-- entering them by creating a temporary invisible entity there.
data:extend({
	{
		type = "simple-entity-with-force",
		name = "logicarts-marker",
		flags = {
			"placeable-neutral",
			"not-rotatable",
			"not-repairable",
			"not-on-map",
			"not-deconstructable",
			"not-blueprintable",
			"not-flammable",
		},
		selectable_in_game = false,
		build_sound = nil,
		mined_sound = nil,
		created_smoke = nil,
		minable = nil,
		collision_mask = {},
		collision_box = {{-0.5,-0.5},{0.5,0.5}},
		selection_box = {{0,0},{0,0}},
		icon = "__logicarts__/nothing.png",
		icon_size = 32,
		picture = {
			x = 0,
			filename = "__logicarts__/nothing.png",
			width = 32,
			height = 32,
		},
		render_layer = "air-object",
		tile_width = 1,
		tile_height = 1,
	}
})