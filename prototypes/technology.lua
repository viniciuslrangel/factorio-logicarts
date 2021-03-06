data:extend({
	{
		type = "technology",
		name = "logicarts-tech1",
		icon = "__logicarts2__/graphics/cart-tech.png",
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
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech2",
		icon = "__logicarts2__/graphics/e-cart-tech.png",
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
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"production-science-pack", 1},
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech-stops",
		icon = "__logicarts2__/graphics/tech-stops.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-stop-load" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-unload" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-supply" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-dump" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-accept" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-deploy" },
			{ type = "unlock-recipe", recipe = "logicarts-stop-retire" },
		},
		prerequisites = {
			"logicarts-tech1",
		},
		unit = {
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech-stickers",
		icon = "__logicarts2__/graphics/tech-stickers.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-sticker" },
		},
		prerequisites = {
			"logicarts-tech1",
		},
		unit = {
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech-groups",
		icon = "__logicarts2__/graphics/tech-groups.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-equipment-1" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-2" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-3" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-4" },
			{ type = "unlock-recipe", recipe = "logicarts-equipment-5" },
		},
		prerequisites = {
			"logicarts-tech1",
		},
		unit = {
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
	{
		type = "technology",
		name = "logicarts-tech-dual",
		icon = "__logicarts2__/graphics/tech-dual.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-path-dual-straight" },
			{ type = "unlock-recipe", recipe = "logicarts-path-dual-turn" },
			{ type = "unlock-recipe", recipe = "logicarts-continue-dual-straight" },
			{ type = "unlock-recipe", recipe = "logicarts-continue-dual-turn" },
		},
		prerequisites = {
			"logicarts-tech1",
		},
		unit = {
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
		order = "c-o-a",
	},
})
