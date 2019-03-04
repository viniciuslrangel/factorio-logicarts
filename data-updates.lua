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
			local icon = item.icon
			local icon_size = item.icon_size
			-- can't handle barrels and tints yet
			if string.sub(item.name, -string.len("-barrel")) == "-barrel" then
				icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png"
				icon_size = 32
			end
			if icon ~= nil then
				items[#items+1] = {
					type = "item",
					name = "logicarts-item-"..name,
					icon = "__logicarts__/graphics/sticker-icon.png",
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
					icon = "__logicarts__/graphics/sticker-icon.png",
					icon_size = 32,
					picture = {
						filename = icon,
						width = icon_size,
						height = icon_size,
						scale = (32/icon_size)*0.3,
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
