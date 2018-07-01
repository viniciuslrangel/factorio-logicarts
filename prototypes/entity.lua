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

local function logicartsPath(placeable, name, png, xpos)
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
		--collision_box = nil,
		collision_box = {
			{
				-0.4,
				-0.4
			},
			{
				0.4,
				0.4
			}
		},
		selection_box = {
			{
				-0.5,
				-0.5
			},
			{
				0.5,
				0.5
			}
		},
		picture = {
			x = xpos,
			filename = png,
			width = 128,
			height = 128,
			scale = 0.25,
		},
		render_layer = "floor",
		tile_width = 1,
		tile_height = 1,
		--fast_replaceable_group = "logicarts-path",
		placeable_by = {
			item = placeable,
			count = 1,
		}
	}
end

data:extend({logicartsPath("logicarts-path", "logicarts-path-north", "__logicarts__/path.png", 0)})
data:extend({logicartsPath("logicarts-path", "logicarts-path-east", "__logicarts__/path.png", 128)})
data:extend({logicartsPath("logicarts-path", "logicarts-path-south", "__logicarts__/path.png", 256)})
data:extend({logicartsPath("logicarts-path", "logicarts-path-west", "__logicarts__/path.png", 384)})

data:extend({logicartsPath("logicarts-turn", "logicarts-turn-north", "__logicarts__/turn.png", 0)})
data:extend({logicartsPath("logicarts-turn", "logicarts-turn-east", "__logicarts__/turn.png", 128)})
data:extend({logicartsPath("logicarts-turn", "logicarts-turn-south", "__logicarts__/turn.png", 256)})
data:extend({logicartsPath("logicarts-turn", "logicarts-turn-west", "__logicarts__/turn.png", 384)})

data:extend({logicartsPath("logicarts-stop", "logicarts-stop-north", "__logicarts__/stop.png", 0)})
data:extend({logicartsPath("logicarts-stop", "logicarts-stop-east", "__logicarts__/stop.png", 128)})
data:extend({logicartsPath("logicarts-stop", "logicarts-stop-south", "__logicarts__/stop.png", 256)})
data:extend({logicartsPath("logicarts-stop", "logicarts-stop-west", "__logicarts__/stop.png", 384)})

data:extend({
	{
		type = "simple-entity-with-force",
		name = "logicarts-yield",
		flags = {
			"player-creation",
		},
		selectable_in_game = true,
		mined_sound = nil,
		minable = {
			mining_time = 1,
			result = "logicarts-yield",
		},
		collision_mask = {
			"doodad-layer",
		},
		--collision_box = nil,
		collision_box = {
			{
				-0.4,
				-0.4
			},
			{
				0.4,
				0.4
			}
		},
		selection_box = {
			{
				-0.5,
				-0.5
			},
			{
				0.5,
				0.5
			}
		},
		picture = {
			x = 512,
			filename = "__logicarts__/path.png",
			width = 128,
			height = 128,
			shift = {
				0,
				0,
			},
			scale = 0.25,
		},
		render_layer = "floor",
		tile_width = 1,
		tile_height = 1,
		--fast_replaceable_group = "logicarts-path",
		placeable_by = {
			item = "logicarts-yield",
			count = 1,
		},
	},
})

-- The logicarts-path entity is only used to make path placement with the mouse
-- look normal, and to make blueprints work. It's never actually placed on the ground itself.

local path = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
path.name = "logicarts-path"
path.minable.result = "logicarts-path"
path.build_sound = nil
path.collision_mask = {
	"doodad-layer",
}
--path.fast_replaceable_group = "logicarts-path"
path.sprites.north = {
	x = 0,
	filename = "__logicarts__/path.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
path.sprites.east = {
	x = 128,
	filename = "__logicarts__/path.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
path.sprites.south = {
	x = 256,
	filename = "__logicarts__/path.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
path.sprites.west = {
	x = 384,
	filename = "__logicarts__/path.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
data:extend({ path })

-- The logicarts-stop entity is only used to make path stop placement with the mouse
-- look normal, and to make blueprints work. It's never actually placed on the ground itself.

local stop = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
stop.name = "logicarts-stop"
stop.minable.result = "logicarts-stop"
stop.build_sound = nil
stop.collision_mask = {
	"doodad-layer",
}
--stop.fast_replaceable_group = "logicarts-stop"
stop.sprites.north = {
	x = 0,
	filename = "__logicarts__/stop.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
stop.sprites.east = {
	x = 128,
	filename = "__logicarts__/stop.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
stop.sprites.south = {
	x = 256,
	filename = "__logicarts__/stop.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
stop.sprites.west = {
	x = 384,
	filename = "__logicarts__/stop.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
data:extend({ stop })

-- The logicarts-turn entity is only used to make path turn placement with the mouse
-- look normal, and to make blueprints work. It's never actually placed on the ground itself.

local turn = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
turn.name = "logicarts-turn"
turn.minable.result = "logicarts-turn"
turn.build_sound = nil
turn.collision_mask = {
	"doodad-layer",
}
--turn.fast_replaceable_group = "logicarts-turn"
turn.sprites.north = {
	x = 0,
	filename = "__logicarts__/turn.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
turn.sprites.east = {
	x = 128,
	filename = "__logicarts__/turn.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
turn.sprites.south = {
	x = 256,
	filename = "__logicarts__/turn.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
turn.sprites.west = {
	x = 384,
	filename = "__logicarts__/turn.png",
	width = 128,
	height = 128,
	scale = 0.25,
}
data:extend({ turn })

-- A mini car with sprites that are part 1x1 scaled car and part rail wagon...
-- As direction_count=4, these look terible if you try to drive one around, but
-- it's an easy way of getting carts to be actual vehicles (for on_tick UPS
-- mainly), instead of units or something else animated manually.

local car = table.deepcopy(data.raw.car.car)
car.name = "logicarts-car"
car.minable.result = "logicarts-car"
car.inventory_size = 10
car.guns = nil
car.equipment_grid = "logicarts-equipment-grid"
car.animation.layers[1].scale = 0.5
car.animation.layers[1].shift[2] = 0
car.animation.layers[1].hr_version.scale = 0.25
car.animation.layers[1].hr_version.shift[2] = 0
car.animation.layers[2].scale = 0.5
car.animation.layers[1].shift[2] = 0
car.animation.layers[2].hr_version.scale = 0.25
car.animation.layers[2].hr_version.shift[2] = 0
car.animation.layers[3].scale = 0.5
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
car.consumption = "50kW"
car.animation.layers = {
	{
		animation_speed = 1,
		direction_count = 4,
		frame_count = 1,
		height = 169,
		max_advance = 0.2,
		priority = "low",
		scale = 0.25,
		shift = {
			0,
			0,
		},
		stripes = {
			{
				filename = "__logicarts__/car.png",
				height_in_frames = 1,
				width_in_frames = 4,
			},
		},
		width = 180,
	},
	{
		draw_as_shadow = true,
		animation_speed = 1,
		direction_count = 4,
		frame_count = 1,
		height = 72,
		max_advance = 0.2,
		priority = "low",
		scale = 0.44,
		shift = {
			0.2,
			0.2,
		},
		stripes = {
			{
				filename = "__logicarts__/car-shadow.png",
				height_in_frames = 1,
				width_in_frames = 4,
			},
		},
		width = 100,
	},
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
car.guns = nil
car.equipment_grid = "logicarts-equipment-grid"
car.animation.layers[1].scale = 0.5
car.animation.layers[1].shift[2] = 0
car.animation.layers[1].hr_version.scale = 0.25
car.animation.layers[1].hr_version.shift[2] = 0
car.animation.layers[2].scale = 0.5
car.animation.layers[1].shift[2] = 0
car.animation.layers[2].hr_version.scale = 0.25
car.animation.layers[2].hr_version.shift[2] = 0
car.animation.layers[3].scale = 0.5
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
car.consumption = "50kW"
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
		animation_speed = 1,
		direction_count = 4,
		frame_count = 1,
		height = 169,
		max_advance = 0.2,
		priority = "low",
		scale = 0.25,
		shift = {
			0,
			0,
		},
		stripes = {
			{
				filename = "__logicarts__/car-electric.png",
				height_in_frames = 1,
				width_in_frames = 4,
			},
		},
		width = 180,
	},
	{
		draw_as_shadow = true,
		animation_speed = 1,
		direction_count = 4,
		frame_count = 1,
		height = 72,
		max_advance = 0.2,
		priority = "low",
		scale = 0.44,
		shift = {
			0.2,
			0.2,
		},
		stripes = {
			{
				filename = "__logicarts__/car-shadow.png",
				height_in_frames = 1,
				width_in_frames = 4,
			},
		},
		width = 100,
	},
}

data:extend({ car })
