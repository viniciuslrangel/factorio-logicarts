local cc = data.raw["constant-combinator"]["constant-combinator"]
cc.item_slot_count = math.max(36, cc.item_slot_count)

local enableDataItems = {
	"ammo",
	"armor",
	"gun",
	"item",
	"capsule",
	"repair-tool",
	"mining-tool",
	"item-with-entity-data",
	"rail-planner",
	"tool",
	"blueprint",
	"deconstruction-item",
	"blueprint-book",
	"selection-tool",
	"item-with-tags",
	"item-with-label",
	"item-with-inventory",
	"module"
}

local items = {}
local entities = {}

for _, list in ipairs(enableDataItems) do
	if data.raw[list] ~= nil then
		for name, item in pairs(data.raw[list]) do
			if item.icon ~= nil then
				items[#items+1] = {
					type = "item",
					name = "logicarts-item-"..name,
					icon = "__logicarts__/sticker-icon.png",
					icon_size = 32,
					flags = {"hidden"},
					order = "logicarts-z",
					stack_size = 1,
				}
				entities[#entities+1] = {
					type = "simple-entity-with-force",
					name = "logicarts-item-"..name,
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
					picture = {
						filename = item.icon,
						width = item.icon_size,
						height = item.icon_size,
						scale = (32/item.icon_size)*0.3,
						priority = "low",
					},
					render_layer = "higher-object-above",
					tile_width = 1,
					tile_height = 1,
				}
			end
		end
	end
end

data:extend(items)
data:extend(entities)
