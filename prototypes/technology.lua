data:extend({
	{
		type = "technology",
		name = "logicarts-tech1",
		icon = "__logicarts__/graphics/cart-tech.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-path" },
			{ type = "unlock-recipe", recipe = "logicarts-turn" },
			{ type = "unlock-recipe", recipe = "logicarts-stop" },
			{ type = "unlock-recipe", recipe = "logicarts-turn-blocked" },
			{ type = "unlock-recipe", recipe = "logicarts-yield" },
			{ type = "unlock-recipe", recipe = "logicarts-car" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-1" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-2" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-3" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-4" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-5" },
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
			count = 100,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
				{"science-pack-3", 1},
			},
			time = 30
		},
		order = "c-o-a",
	},
})
