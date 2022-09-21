local _, _, _, P = unpack(ElvUI)

local SharedOptions = {
	enable = true,
	font = 'PT Sans Narrow',
	fontSize = 15,
	fontOutline = 'OUTLINE',
	xOffset = 0,
	yOffset = 0,
	color = {r = 0.99, g = 0.81, b = 0},
	qualityColor = false,
}

P.wratharmory = {
	character = {
		enable = true,
		avgItemLevel = CopyTable(SharedOptions),
		enchant = CopyTable(SharedOptions),
		itemLevel = CopyTable(SharedOptions),
		gems = { --! NYI
			enable = true,
			size = 14,
			xOffset = 0,
			yOffset = 0,
		},
	},
	inspect = {
		enable = true,
		avgItemLevel = CopyTable(SharedOptions),
		itemLevel = CopyTable(SharedOptions),
		enchant = CopyTable(SharedOptions),
		gems = { --! NYI
			enable = true,
			xOffset = 0,
			yOffset = 0,
		},
	},
}

--* Character
-- Unit Avg Item Level
P.wratharmory.character.avgItemLevel.background = {
	spacing = 0,
	color = {r = 0.99, g = 0.81, b = 0},
}
P.wratharmory.inspect.avgItemLevel.background = {
	spacing = 0,
	color = {r = 0.99, g = 0.81, b = 0},
}
P.wratharmory.character.avgItemLevel.fontSize = 25
P.wratharmory.character.avgItemLevel.yOffset = -35

-- Enchant
P.wratharmory.character.enchant.color = {r = 0, g = 0.99, b = 0}
P.wratharmory.character.enchant.mouseover = false --! NYI
P.wratharmory.character.enchant.qualityColor = false
P.wratharmory.character.enchant.xOffset = 2

-- Item Level
P.wratharmory.character.itemLevel.qualityColor = true

--* Inspect
-- Unit Avg Item Level
P.wratharmory.inspect.avgItemLevel.fontSize = 15
P.wratharmory.inspect.avgItemLevel.yOffset = -50

-- Enchant
P.wratharmory.inspect.enchant.mouseover = false --! NYI
P.wratharmory.inspect.enchant.qualityColor = false

-- Item Level
P.wratharmory.inspect.itemLevel.qualityColor = true
