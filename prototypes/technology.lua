data:extend({
	{
		type = "technology",
		name = "logicarts-tech1",
		icon = "__logicarts__/graphics/cart-tech.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-paint" },
			{ type = "unlock-recipe", recipe = "logicarts-car" },
			{ type = "unlock-recipe", recipe = "logicarts-path" },
			{ type = "unlock-recipe", recipe = "logicarts-stop" },
			{ type = "unlock-recipe", recipe = "logicarts-turn" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-fuel" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-blocked" },
			{ type = "unlock-recipe", recipe = "logicarts-continue" },
			{ type = "unlock-recipe", recipe = "logicarts-yield" },
		},
		prerequisites = {
			"engine",
			"logistics",
		},
		unit = {
			count = 100,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech2",
		icon = "__logicarts__/graphics/e-cart-tech.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-car-electric" },
		},
		prerequisites = {
			"electric-engine",
			"advanced-electronics",
			"logicarts-tech1",
		},
		unit = {
			count = 200,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
				{"science-pack-3", 1},
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech-stops",
		icon = "__logicarts__/tech-stops.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-stop-load" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-unload" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-supply" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-dump" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-accept" },
		},
		prerequisites = {
			"logicarts-tech1",
		},
		unit = {
			count = 150,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech-groups",
		icon = "__logicarts__/tech-groups.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-equipment-1" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-2" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-3" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-4" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-5" },
			{ type = "unlock-recipe", recipe = "logicarts-path-G1" },
			{ type = "unlock-recipe", recipe = "logicarts-path-G2" },
			{ type = "unlock-recipe", recipe = "logicarts-path-G3" },
			{ type = "unlock-recipe", recipe = "logicarts-path-G4" },
			{ type = "unlock-recipe", recipe = "logicarts-path-G5" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-G1" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-G2" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-G3" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-G4" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-G5" },
		},
		prerequisites = {
			"logicarts-tech1",
		},
		unit = {
			count = 150,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
})
