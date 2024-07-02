-- local _, _, _, P = unpack(ElvUI)
local RA, _, P = unpack(ReforgedArmory)

local AvgItemLevel = {
	enable = true,
	text = {
		color = {r = 0.99, g = 0.81, b = 0},
		font = 'Arial Narrow',
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
	font = 'Arial Narrow',
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
	font = 'Arial Narrow',
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

P.general = {
	showLoginMsg = true,
	tooltip = {
		missingOnly = false
	}
}

--! Character
--* Setup Character Defaults
P.character = {
	blizzText = {
		name = {
			xOffset = 0,
			yOffset = 0,
		},
		level = {
			xOffset = 0,
			yOffset = 0,
		}
	},
	enable = true,
	nameText = {
		xOffset = 0,
		yOffset = 0,
	},
	levelText = {
		enable = true,
		xOffset = 0,
		yOffset = 2,
	},
	flyoutText = {
		enable = true,
		xOffset = 0,
		yOffset = 0,
		font = 'Arial Narrow',
		fontSize = 15,
		fontOutline = 'OUTLINE',
	},
	avgItemLevel = CopyTable(AvgItemLevel),
	enchant = CopyTable(Enchant),
	expandButton = {
		hide = true,
		autoExpand = true,
	},
	gems = CopyTable(SharedGemOptions),
	itemLevel = CopyTable(ItemLevel),
	slotBackground = {
		enable = false,
		color = {r = 0.41, g = 0.83, b = 1},
		xOffset = 0,
		yOffset = 0,
		width = 120,
		topOffset = 0,
		bottomOffset = 0,
		warning = {
			enable = true,
			color = {r = 1, g = 0.33, b = 0},
		},
	},
	warningIndicator = {
		enable = true,
	},
}

--* Character Avg Item Level Defaults
if ElvUI and (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.character) then
	if RA.Retail then

	elseif RA.Cata then
		P.character.avgItemLevel.frame.attachTo = 'CharacterFrameInsetRight'
		P.character.avgItemLevel.frame.yOffset = -5
	else
		P.character.avgItemLevel.frame.attachTo = 'CharacterLevelText'
	end
else
	if RA.Retail then

	elseif RA.Cata then
		P.character.avgItemLevel.frame.attachTo = 'CharacterFrameInsetRight'
		P.character.avgItemLevel.frame.yOffset = -10
	else
		P.character.avgItemLevel.frame.attachTo = 'CharacterLevelText'
	end
end

-- P.character.avgItemLevel.frame.attachTo = 'CharacterLevelText'

--* Enchant
P.character.enchant.mouseover = false --! NYI
P.character.enchant.color = {r = 0, g = 0.99, b = 0}
P.character.enchant.qualityColor = false
P.character.enchant.fontSize = 13
P.character.enchant.xOffset = 1
P.character.enchant.yOffset = -2
P.character.enchant.growthDirection = 'INSIDE_DOWN'
P.character.enchant.anchorPoint = 'TOPINSIDE'
P.character.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -2,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'DOWN_LEFT',
}
P.character.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
	anchorPoint = 'BOTTOMLEFT',
	growthDirection = 'DOWN_RIGHT',
}
P.character.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'UP_RIGHT',
}

--* Item Level
P.character.itemLevel.qualityColor = true

--! Inspect
--* Setup Inspect Defaults
P.inspect = {
	enable = true,
	nameText = {
		xOffset = 0,
		yOffset = 0,
	},
	levelText = {
		enable = true,
		xOffset = 0,
		yOffset = 0,
	},
	avgItemLevel = CopyTable(AvgItemLevel),
	enchant = CopyTable(Enchant),
	gems = CopyTable(SharedGemOptions),
	itemLevel = CopyTable(ItemLevel),
	slotBackground = {
		enable = false,
		color = {r = 0.41, g = 0.83, b = 1},
		xOffset = 1,
		yOffset = 0,
		width = 120,
		topOffset = -1,
		bottomOffset = -1,
		warning = {
			enable = true,
			color = {r = 1, g = 0.33, b = 0},
		},
	},
	warningIndicator = {
		enable = true,
	},
}

--* Unit Avg Item Level
P.inspect.avgItemLevel.frame.attachTo = 'InspectLevelText'

--* Enchant
P.inspect.enchant.mouseover = false --! NYI
P.inspect.enchant.color = {r = 0, g = 0.99, b = 0}
P.inspect.enchant.qualityColor = false
P.inspect.enchant.fontSize = 13
P.inspect.enchant.xOffset = 1
P.inspect.enchant.yOffset = -2
P.inspect.enchant.growthDirection = 'INSIDE_DOWN'
P.inspect.enchant.anchorPoint = 'TOPINSIDE'
P.inspect.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -2,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'DOWN_LEFT',
}
P.inspect.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
	anchorPoint = 'BOTTOMLEFT',
	growthDirection = 'DOWN_RIGHT',
}
P.inspect.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
	anchorPoint = 'BOTTOMRIGHT',
	growthDirection = 'UP_RIGHT',
}

--* Item Level
P.inspect.itemLevel.qualityColor = true
