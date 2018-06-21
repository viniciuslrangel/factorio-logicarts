data:extend({
	{
		type = "recipe-category",
		name = "logicarts",
	},
	{
		type = "item-group",
		name = "logicarts-group",
		order = "z",
		inventory_order = "z",
		icon = "__logicarts__/tech1.png",
		icon_size = 128,
	},
	{
		type = "item-subgroup",
		name = "logicarts-subgroup",
		group = "logicarts-group",
		order = "a"
	},
	{
		type = "item-subgroup",
		name = "logicarts-subgroup-signal",
		group = "logicarts-group",
		order = "b"
	},
})
