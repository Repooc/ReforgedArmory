local _, _, _, P = unpack(ElvUI)

local SharedFontOptions = {
	enable = true,
	font = 'PT Sans Narrow',
	fontSize = 15,
	fontOutline = 'OUTLINE',
	xOffset = 0,
	yOffset = 0,
	color = {r = 0.99, g = 0.81, b = 0},
	qualityColor = false,
}

local SharedGemOptions = {
	enable = true,
	size = 14,
	xOffset = 3,
	yOffset = 0,
	spacing = 2,
	MainHandSlot = {
		xOffset = -2,
		yOffset = 0,
	},
	SecondaryHandSlot = {
		xOffset = 0,
		yOffset = 2,
	},
	RangedSlot = {
		xOffset = 2,
		yOffset = 0,
	},
}

P.wratharmory = {
	character = {
		enable = true,
		avgItemLevel = CopyTable(SharedFontOptions),
		enchant = CopyTable(SharedFontOptions),
		gems = CopyTable(SharedGemOptions),
		itemLevel = CopyTable(SharedFontOptions),
		warningIndicator = {
			enable = false,
		},
	},
	inspect = {
		enable = true,
		avgItemLevel = CopyTable(SharedFontOptions),
		enchant = CopyTable(SharedFontOptions),
		gems = CopyTable(SharedGemOptions),
		itemLevel = CopyTable(SharedFontOptions),
		warningIndicator = {
			enable = false,
		},
	},
}

--! Character
--* Unit Avg Item Level
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

--* Enchant
P.wratharmory.character.enchant.mouseover = false --! NYI
P.wratharmory.character.enchant.color = {r = 0, g = 0.99, b = 0}
P.wratharmory.character.enchant.qualityColor = false
P.wratharmory.character.enchant.fontSize = 13
P.wratharmory.character.enchant.xOffset = 1
P.wratharmory.character.enchant.yOffset = -2
P.wratharmory.character.enchant.growthDirection = 'INSIDE_DOWN'
P.wratharmory.character.enchant.anchorPoint = 'TOPINSIDE'
P.wratharmory.character.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -2,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'DOWN_LEFT',
}
P.wratharmory.character.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
	anchorPoint = 'BOTTOMLEFT',
	growthDirection = 'DOWN_RIGHT',
}
P.wratharmory.character.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'UP_RIGHT',
}

--* Item Level
P.wratharmory.character.itemLevel.qualityColor = true

--! Inspect
--* Unit Avg Item Level
P.wratharmory.inspect.avgItemLevel.fontSize = 15
P.wratharmory.inspect.avgItemLevel.yOffset = -50

--* Enchant
P.wratharmory.inspect.enchant.mouseover = false --! NYI
P.wratharmory.inspect.enchant.color = {r = 0, g = 0.99, b = 0}
P.wratharmory.inspect.enchant.qualityColor = false
P.wratharmory.inspect.enchant.fontSize = 13
P.wratharmory.inspect.enchant.xOffset = 1
P.wratharmory.inspect.enchant.yOffset = -2
P.wratharmory.inspect.enchant.growthDirection = 'INSIDE_DOWN'
P.wratharmory.inspect.enchant.anchorPoint = 'TOPINSIDE'
P.wratharmory.inspect.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -2,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'DOWN_LEFT',
}
P.wratharmory.inspect.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
	anchorPoint = 'BOTTOMLEFT',
	growthDirection = 'DOWN_RIGHT',
}
P.wratharmory.inspect.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'UP_RIGHT',
}

--* Item Level
P.wratharmory.inspect.itemLevel.qualityColor = true
