data:extend({
	{
		type = "technology",
		name = "logicarts-tech1",
		icon = "__logicarts__/tech1.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "logicarts-path" },
			{ type = "unlock-recipe", recipe = "logicarts-turn" },
			{ type = "unlock-recipe", recipe = "logicarts-stop" },
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
})
