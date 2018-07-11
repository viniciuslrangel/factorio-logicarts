data:extend({
	{
		type = "equipment-grid",
		name = "logicarts-equipment-grid",
		width = 4,
		height = 4,
		equipment_categories = {"armor"}
	},
})
local function signalEquipment(n)
	local name = "logicarts-equipment-"..n
	local icon = "__logicarts__/icon-G"..n..".png"
	data:extend({
		{
			type = "item",
			name = name,
			icon = icon,
			icon_size = 128,
			flags = {"goes-to-main-inventory"},
			placed_as_equipment_result = name,
			order = "logicarts-b-"..n,
			stack_size = 200,
		},
		{
			name = name,
			type = "battery-equipment",
			categories = {
				"armor"
			},
			energy_source = {
				buffer_capacity = "1J",
				input_flow_limit = "1W",
				output_flow_limit = "1W",
				type = "electric",
				usage_priority = "terciary"
			},
			shape = {
				type = "full",
				height = 1,
				width = 1
			},
			sprite = {
				filename = icon,
				priority = "medium",
				height = 128,
				width = 128,
			},
		},
		{
			type = "recipe",
			name = name,
			category = "crafting",
			subgroup = "logicarts-subgroup-signal",
			enabled = false,
			icon = icon,
			icon_size = 128,
			ingredients = {
				{ type = "item", name = "iron-plate", amount = 1 },
			},
			results = {
				{ type = "item", name = name, amount = 1 },
			},
			hidden = false,
			energy_required = 1.0,
			order = "logicarts-c-"..n,
		},
	})
end

signalEquipment(1)
signalEquipment(2)
signalEquipment(3)
signalEquipment(4)
signalEquipment(5)
