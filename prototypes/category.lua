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
		icon = "__logicarts__/graphics/cart-tech.png",
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
		name = "logicarts-subgroup-path",
		group = "logicarts-group",
		order = "b"
	},
	{
		type = "item-subgroup",
		name = "logicarts-subgroup-stop",
		group = "logicarts-group",
		order = "c"
	},
	{
		type = "item-subgroup",
		name = "logicarts-subgroup-signal",
		group = "logicarts-group",
		order = "d"
	},
	{
		type = "item-subgroup",
		name = "logicarts-subgroup-signal-path",
		group = "logicarts-group",
		order = "e"
	},
	{
		type = "item-subgroup",
		name = "logicarts-subgroup-signal-turn",
		group = "logicarts-group",
		order = "f"
	},
})
