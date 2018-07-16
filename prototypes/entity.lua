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

data:extend({logicartsPath("logicarts-stop-load", "logicarts-stop-load-north",
	128, 0.25, "__logicarts__/stop-load.png", 0)})
data:extend({logicartsPath("logicarts-stop-load", "logicarts-stop-load-east",
	128, 0.25, "__logicarts__/stop-load.png", 1)})
data:extend({logicartsPath("logicarts-stop-load", "logicarts-stop-load-south",
	128, 0.25, "__logicarts__/stop-load.png", 2)})
data:extend({logicartsPath("logicarts-stop-load", "logicarts-stop-load-west",
	128, 0.25, "__logicarts__/stop-load.png", 3)})

data:extend({logicartsPath("logicarts-stop-unload", "logicarts-stop-unload-north",
	128, 0.25, "__logicarts__/stop-unload.png", 0)})
data:extend({logicartsPath("logicarts-stop-unload", "logicarts-stop-unload-east",
	128, 0.25, "__logicarts__/stop-unload.png", 1)})
data:extend({logicartsPath("logicarts-stop-unload", "logicarts-stop-unload-south",
	128, 0.25, "__logicarts__/stop-unload.png", 2)})
data:extend({logicartsPath("logicarts-stop-unload", "logicarts-stop-unload-west",
	128, 0.25, "__logicarts__/stop-unload.png", 3)})

data:extend({logicartsPath("logicarts-stop-supply", "logicarts-stop-supply-north",
	128, 0.25, "__logicarts__/stop-supply.png", 0)})
data:extend({logicartsPath("logicarts-stop-supply", "logicarts-stop-supply-east",
	128, 0.25, "__logicarts__/stop-supply.png", 1)})
data:extend({logicartsPath("logicarts-stop-supply", "logicarts-stop-supply-south",
	128, 0.25, "__logicarts__/stop-supply.png", 2)})
data:extend({logicartsPath("logicarts-stop-supply", "logicarts-stop-supply-west",
	128, 0.25, "__logicarts__/stop-supply.png", 3)})

data:extend({logicartsPath("logicarts-stop-dump", "logicarts-stop-dump-north",
	128, 0.25, "__logicarts__/stop-dump.png", 0)})
data:extend({logicartsPath("logicarts-stop-dump", "logicarts-stop-dump-east",
	128, 0.25, "__logicarts__/stop-dump.png", 1)})
data:extend({logicartsPath("logicarts-stop-dump", "logicarts-stop-dump-south",
	128, 0.25, "__logicarts__/stop-dump.png", 2)})
data:extend({logicartsPath("logicarts-stop-dump", "logicarts-stop-dump-west",
	128, 0.25, "__logicarts__/stop-dump.png", 3)})

data:extend({logicartsPath("logicarts-stop-accept", "logicarts-stop-accept-north",
	128, 0.25, "__logicarts__/stop-accept.png", 0)})
data:extend({logicartsPath("logicarts-stop-accept", "logicarts-stop-accept-east",
	128, 0.25, "__logicarts__/stop-accept.png", 1)})
data:extend({logicartsPath("logicarts-stop-accept", "logicarts-stop-accept-south",
	128, 0.25, "__logicarts__/stop-accept.png", 2)})
data:extend({logicartsPath("logicarts-stop-accept", "logicarts-stop-accept-west",
	128, 0.25, "__logicarts__/stop-accept.png", 3)})

data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-north",
	128, 0.25, "__logicarts__/turn-blocked.png", 0)})
data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-east",
	128, 0.25, "__logicarts__/turn-blocked.png", 1)})
data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-south",
	128, 0.25, "__logicarts__/turn-blocked.png", 2)})
data:extend({logicartsPath("logicarts-turn-blocked", "logicarts-turn-blocked-west",
	128, 0.25, "__logicarts__/turn-blocked.png", 3)})

data:extend({logicartsPath("logicarts-continue", "logicarts-continue-north",
	128, 0.25, "__logicarts__/continue.png", 0)})
data:extend({logicartsPath("logicarts-continue", "logicarts-continue-east",
	128, 0.25, "__logicarts__/continue.png", 1)})
data:extend({logicartsPath("logicarts-continue", "logicarts-continue-south",
	128, 0.25, "__logicarts__/continue.png", 2)})
data:extend({logicartsPath("logicarts-continue", "logicarts-continue-west",
	128, 0.25, "__logicarts__/continue.png", 3)})

data:extend({logicartsPath("logicarts-turn-fuel", "logicarts-turn-fuel-north",
	128, 0.25, "__logicarts__/turn-fuel.png", 0)})
data:extend({logicartsPath("logicarts-turn-fuel", "logicarts-turn-fuel-east",
	128, 0.25, "__logicarts__/turn-fuel.png", 1)})
data:extend({logicartsPath("logicarts-turn-fuel", "logicarts-turn-fuel-south",
	128, 0.25, "__logicarts__/turn-fuel.png", 2)})
data:extend({logicartsPath("logicarts-turn-fuel", "logicarts-turn-fuel-west",
	128, 0.25, "__logicarts__/turn-fuel.png", 3)})

data:extend({logicartsPath("logicarts-path-dual-straight", "logicarts-path-dual-straight-north",
	128, 0.25, "__logicarts__/path-dual-straight.png", 0)})
data:extend({logicartsPath("logicarts-path-dual-straight", "logicarts-path-dual-straight-east",
	128, 0.25, "__logicarts__/path-dual-straight.png", 1)})
data:extend({logicartsPath("logicarts-path-dual-straight", "logicarts-path-dual-straight-south",
	128, 0.25, "__logicarts__/path-dual-straight.png", 2)})
data:extend({logicartsPath("logicarts-path-dual-straight", "logicarts-path-dual-straight-west",
	128, 0.25, "__logicarts__/path-dual-straight.png", 3)})

data:extend({logicartsPath("logicarts-path-dual-turn", "logicarts-path-dual-turn-north",
	128, 0.25, "__logicarts__/path-dual-turn.png", 0)})
data:extend({logicartsPath("logicarts-path-dual-turn", "logicarts-path-dual-turn-east",
	128, 0.25, "__logicarts__/path-dual-turn.png", 1)})
data:extend({logicartsPath("logicarts-path-dual-turn", "logicarts-path-dual-turn-south",
	128, 0.25, "__logicarts__/path-dual-turn.png", 2)})
data:extend({logicartsPath("logicarts-path-dual-turn", "logicarts-path-dual-turn-west",
	128, 0.25, "__logicarts__/path-dual-turn.png", 3)})

data:extend({logicartsPath("logicarts-continue-dual-straight", "logicarts-continue-dual-straight-north",
	128, 0.25, "__logicarts__/continue-dual-straight.png", 0)})
data:extend({logicartsPath("logicarts-continue-dual-straight", "logicarts-continue-dual-straight-east",
	128, 0.25, "__logicarts__/continue-dual-straight.png", 1)})
data:extend({logicartsPath("logicarts-continue-dual-straight", "logicarts-continue-dual-straight-south",
	128, 0.25, "__logicarts__/continue-dual-straight.png", 2)})
data:extend({logicartsPath("logicarts-continue-dual-straight", "logicarts-continue-dual-straight-west",
	128, 0.25, "__logicarts__/continue-dual-straight.png", 3)})

data:extend({logicartsPath("logicarts-continue-dual-turn", "logicarts-continue-dual-turn-north",
	128, 0.25, "__logicarts__/continue-dual-turn.png", 0)})
data:extend({logicartsPath("logicarts-continue-dual-turn", "logicarts-continue-dual-turn-east",
	128, 0.25, "__logicarts__/continue-dual-turn.png", 1)})
data:extend({logicartsPath("logicarts-continue-dual-turn", "logicarts-continue-dual-turn-south",
	128, 0.25, "__logicarts__/continue-dual-turn.png", 2)})
data:extend({logicartsPath("logicarts-continue-dual-turn", "logicarts-continue-dual-turn-west",
	128, 0.25, "__logicarts__/continue-dual-turn.png", 3)})

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
logicartsPathPlacer("logicarts-stop-load", 128, 0.25, "__logicarts__/stop-load.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-stop-unload", 128, 0.25, "__logicarts__/stop-unload.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-stop-supply", 128, 0.25, "__logicarts__/stop-supply.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-stop-dump", 128, 0.25, "__logicarts__/stop-dump.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-stop-accept", 128, 0.25, "__logicarts__/stop-accept.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-turn", 128, 0.25, "__logicarts__/turn.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-turn-blocked", 128, 0.25, "__logicarts__/turn-blocked.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-continue", 128, 0.25, "__logicarts__/continue.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-turn-fuel", 128, 0.25, "__logicarts__/turn-fuel.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-path-dual-straight", 128, 0.25, "__logicarts__/path-dual-straight.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-path-dual-turn", 128, 0.25, "__logicarts__/path-dual-turn.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-continue-dual-straight", 128, 0.25, "__logicarts__/continue-dual-straight.png", 0, 1, 2, 3)
logicartsPathPlacer("logicarts-continue-dual-turn", 128, 0.25, "__logicarts__/continue-dual-turn.png", 0, 1, 2, 3)

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
		priority = "medium",
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
		priority = "medium",
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
		priority = "medium",
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
		priority = "medium",
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
		order = "z",
	}
})

-- Wearign of grass to dirt.
data:extend({
	{
		type = "simple-entity",
		name = "logicarts-wear",
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
		order = "z",
	}
})

-- Experimental path stickers.

-- A "sticker" is placed on a path tile to add meaning to the basic turn signal.
-- Stickers are invisible constant combinators with a single signal slot. The
-- visible bit is a simple-entity-with-force created by setting the CC signal
-- to an item. See data-updates for how the latter are created.

-- The reason for using a CC is to make stickers blue-printable including the
-- signal. The drawback is that, since the CC is transparent, it's hard to place
-- with the mouse :) Can only see the item count text beside the mouse cursor....

local cc = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])

data:extend({
	{
		type = "simple-entity-with-force",
		name = "logicarts-sticker-display",
		flags = {
			"player-creation",
			"not-rotatable",
			"not-flammable",
			"not-blueprintable",
			"placeable-off-grid",
		},
		selectable_in_game = false,
		build_sound = nil,
		mined_sound = nil,
		created_smoke = nil,
		minable = nil,
		collision_mask = {"layer-14"},
		collision_box = {{-0.4,-0.4},{0.4,0.4}},
		selection_box = {{-0.25,-0.25},{0.25,0.25}},
		icon = "__logicarts__/sticker-icon.png",
		icon_size = 32,
		pictures = variations,
		render_layer = "higher-object-above",
		tile_width = 1,
		tile_height = 1,
		picture = {
			filename = "__logicarts__/sticker-icon.png",
			width = 32,
			height = 32,
			scale = 0.25,
		}
	},
	{
		type = "constant-combinator",
		name = "logicarts-sticker",
		flags = {
			"player-creation",
			"not-flammable",
			"not-rotatable",
		},
		selectable_in_game = true,
		build_sound = nil,
		mined_sound = nil,
		created_smoke = nil,
		minable = {
			mining_time = 1,
			result = "logicarts-sticker",
		},
		collision_mask = {"layer-15"},
		collision_box = {{-0.25,-0.25},{0.25,0.25}},
		--selection_box = {{-0.25,-0.25},{0.25,0.25}},
		selection_box = {{0.1,0.1},{0.6,0.6}},
		icon = "__logicarts__/sticker-icon.png",
		icon_size = 32,
		tile_width = 1,
		tile_height = 1,
		item_slot_count = 1,
		sprites = {
			north = {
				filename = "__logicarts__/sticker.png",
				width = 128,
				height = 128,
				priority = "medium",
				scale = 0.25,
			},
			south = {
				filename = "__logicarts__/sticker.png",
				width = 128,
				height = 128,
				priority = "medium",
				scale = 0.25,
			},
			east = {
				filename = "__logicarts__/sticker.png",
				width = 128,
				height = 128,
				priority = "medium",
				scale = 0.25,
			},
			west = {
				filename = "__logicarts__/sticker.png",
				width = 128,
				height = 128,
				priority = "medium",
				scale = 0.25,
			},
		},
		activity_led_sprites = cc.activity_led_sprites,
    activity_led_light = { intensity = 0.8, size = 1 },
    activity_led_light_offsets = cc.activity_led_light_offsets,
    circuit_wire_connection_points = cc.circuit_wire_connection_points,
	},
})