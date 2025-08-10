local _, _, _, P = unpack(ElvUI)

local AvgItemLevel = {
	enable = true,
	text = {
		color = {r = 0.99, g = 0.81, b = 0},
		font = 'PT Sans Narrow',
		fontOutline = 'OUTLINE',
		fontSize = 15,
		xOffset = 0,
		yOffset = -2,
	},
	frame = {
		color = {r = 1, g = 1, b = 1, a = 1},
		showBGTexture = true,
		showLines = true,
		xOffset = 0,
		yOffset = 0,
	},
	qualityColor = false,
}

local Enchant = {
	enable = true,
	font = 'PT Sans Narrow',
	fontSize = 15,
	fontOutline = 'OUTLINE',
	xOffset = 0,
	yOffset = 0,
	color = {r = 0.99, g = 0.81, b = 0},
	qualityColor = false,
	enchantID = {
		enable = true,
		missingOnly = false,
	},
}

local ItemLevel = {
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

local SharedDurabilityTextOptions = {
	enable = true,
	font = 'PT Sans Narrow',
	fontSize = 9,
	fontOutline = 'OUTLINE',
	color = { r = 1, g = 1, b = 1 },
	useCustomColor = false, --* Text shows as the color of durability if true, color settings if false
	format = 'PERCENT', --* Valid options PERCENT, FULL, BOTH
	rotation = 45,
}

P.cataarmory = {
	enchant = {
		abbreviate = true,
	},
	character = {
		enable = true,
		levelText = {
			enable = true,
			xOffset = 0,
			yOffset = 2,
		},
		avgItemLevel = CopyTable(AvgItemLevel),
		durability = {
			enable = true,
			mouseover = true,
			frameStrata = 'HIGH',	--! NYI
			frameLevel = '5', 		--! NYI
			anchorPoint = 'INSIDE',
			lengthOffset = 0,
			xOffset = 0,
			yOffset = 0,
			thickness = 5,
			text = CopyTable(SharedDurabilityTextOptions),
			MainHandSlot = {
				anchorPoint = 'LEFT',
				lengthOffset = 0,
				xOffset = 0,
				yOffset = 0,
				thickness = 5,
				text = CopyTable(SharedDurabilityTextOptions),
			},
			SecondaryHandSlot = {
				anchorPoint = 'LEFT',
				lengthOffset = 0,
				xOffset = 0,
				yOffset = 0,
				thickness = 5,
				text = CopyTable(SharedDurabilityTextOptions),
			},
			RangedSlot = {
				anchorPoint = 'LEFT',
				lengthOffset = 0,
				xOffset = 0,
				yOffset = 0,
				thickness = 5,
				text = CopyTable(SharedDurabilityTextOptions),
			},
		},
		enchant = CopyTable(Enchant),
		expandButton = {
			hide = true,
			autoExpand = true,
		},
		gems = CopyTable(SharedGemOptions),
		model = {
			controlsDisplayMode = 'MOUSEOVER',
		},
		itemLevel = CopyTable(ItemLevel),
		slotBackground = {
			enable = false,
			color = {r = 0.41, g = 0.83, b = 1},
			xOffset = -1,
			yOffset = 0,
			warning = {
				enable = true,
				color = {r = 1, g = 0.33, b = 0},
			},
		},
		warningIndicator = {
			enable = true,
		},
	},
	inspect = {
		enable = true,
		levelText = {
			enable = true,
			xOffset = 0,
			yOffset = -3,
		},
		avgItemLevel = CopyTable(AvgItemLevel),
		enchant = CopyTable(Enchant),
		gems = CopyTable(SharedGemOptions),
		itemLevel = CopyTable(ItemLevel),
		slotBackground = {
			enable = false,
			color = {r = 0.41, g = 0.83, b = 1},
			xOffset = -1,
			yOffset = 0,
			warning = {
				enable = true,
				color = {r = 1, g = 0.33, b = 0},
			},
		},
		warningIndicator = {
			enable = true,
		},
	},
}

--! Character
--* Unit Avg Item Level
P.cataarmory.character.avgItemLevel.frame.attachTo = 'CharacterLevelText'
P.cataarmory.character.avgItemLevel.frame.yOffset = 2

--* Enchant
P.cataarmory.character.enchant.mouseover = false --! NYI
P.cataarmory.character.enchant.color = {r = 0, g = 0.99, b = 0}
P.cataarmory.character.enchant.qualityColor = false
P.cataarmory.character.enchant.fontSize = 13
P.cataarmory.character.enchant.xOffset = 1
P.cataarmory.character.enchant.yOffset = -2
P.cataarmory.character.enchant.growthDirection = 'INSIDE_DOWN'
P.cataarmory.character.enchant.anchorPoint = 'TOPINSIDE'
P.cataarmory.character.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -2,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'DOWN_LEFT',
}
P.cataarmory.character.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
	anchorPoint = 'BOTTOMLEFT',
	growthDirection = 'DOWN_RIGHT',
}
P.cataarmory.character.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'UP_RIGHT',
}

--* Item Level
P.cataarmory.character.itemLevel.qualityColor = true

--! Inspect
--* Unit Avg Item Level
P.cataarmory.inspect.avgItemLevel.frame.attachTo = 'InspectLevelText'

--* Enchant
P.cataarmory.inspect.enchant.mouseover = false --! NYI
P.cataarmory.inspect.enchant.color = {r = 0, g = 0.99, b = 0}
P.cataarmory.inspect.enchant.qualityColor = false
P.cataarmory.inspect.enchant.fontSize = 13
P.cataarmory.inspect.enchant.xOffset = 1
P.cataarmory.inspect.enchant.yOffset = -2
P.cataarmory.inspect.enchant.growthDirection = 'INSIDE_DOWN'
P.cataarmory.inspect.enchant.anchorPoint = 'TOPINSIDE'
P.cataarmory.inspect.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -2,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'DOWN_LEFT',
}
P.cataarmory.inspect.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
	anchorPoint = 'BOTTOMLEFT',
	growthDirection = 'DOWN_RIGHT',
}
P.cataarmory.inspect.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'UP_RIGHT',
}

--* Item Level
P.cataarmory.inspect.itemLevel.qualityColor = true
