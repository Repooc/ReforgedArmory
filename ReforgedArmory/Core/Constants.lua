local E, L = unpack(ElvUI)
local _, Engine = ...

Engine.Durability = {
	Bar = {
		Length = {
			MIN_BAR_LENGTH = 10,
			MAX_BAR_LENGTH = 120,
		},
		OffSets = {
			MIN_BAR_LENGTHOFFSET = -10,
			MAX_BAR_LENGTHOFFSET = 10,
		},
		Thickness = {
			MIN_BAR_THICKNESS = 2,
			MAX_BAR_THICKNESS = 42
		},
		SideSlotsValidAnchorPoints = {
			SLOT = {
				TOP				= 'TOP',
				BOTTOM			= 'BOTTOM',
				LEFT			= 'LEFT',
				RIGHT			= 'RIGHT',
				INSIDE			= 'INSIDE',
				OUTSIDE			= 'OUTSIDE',
			},
		},
		MHOHRangedSlotsValidAnchorPoints = {
			SLOT = {
				TOP				= 'TOP',
				BOTTOM			= 'BOTTOM',
				LEFT			= 'LEFT',
				RIGHT			= 'RIGHT',
			},
		},
	}
}

Engine.Values = {
	AllPoints = {
		BOTTOM = 'BOTTOM',
		BOTTOMOUTSIDE = 'BOTTOMOUTSIDE',
		BOTTOMINSIDE = 'BOTTOMINSIDE',
		CENTER = 'CENTER',
		OUTSIDE = 'LEFT',
		INSIDE = 'RIGHT',
		TOP = 'TOP',
		TOPOUTSIDE = 'TOPOUTSIDE',
		TOPINSIDE = 'TOPINSIDE',
	},
	SIDE_SLOTS_ANCHORPOINTS = {
		BOTTOM = 'BOTTOM',
		BOTTOMOUTSIDE = 'BOTTOMLEFT',
		BOTTOMINSIDE = 'BOTTOMRIGHT',
		CENTER = 'CENTER',
		OUTSIDE = 'LEFT',
		INSIDE = 'RIGHT',
		TOP = 'TOP',
		TOPOUTSIDE = 'TOPLEFT',
		TOPINSIDE = 'TOPRIGHT',
	},
	MIRROR_ANCHORPOINT = {
		BOTTOM = 'BOTTOM',
		BOTTOMLEFT = 'BOTTOMRIGHT',
		BOTTOMRIGHT = 'BOTTOMLEFT',
		CENTER = 'CENTER',
		LEFT = 'RIGHT',
		RIGHT = 'LEFT',
		TOP = 'TOP',
		TOPLEFT = 'TOPRIGHT',
		TOPRIGHT = 'TOPLEFT',
	},
	SIDE_SLOTS_DIRECTION_TO_POINT = {
		LEFT = {
			DOWN_INSIDE = 'TOPLEFT',
			DOWN_OUTSIDE = 'TOPRIGHT',
			UP_INSIDE = 'BOTTOMLEFT',
			UP_OUTSIDE = 'BOTTOMRIGHT',
			INSIDE_DOWN = 'TOPLEFT',
			INSIDE_UP = 'BOTTOMLEFT',
			OUTSIDE_DOWN = 'TOPRIGHT',
			OUTSIDE_UP = 'BOTTOMRIGHT',
		},
		RIGHT = {
			DOWN_INSIDE = 'TOPRIGHT',
			DOWN_OUTSIDE = 'TOPLEFT',
			UP_INSIDE = 'BOTTOMRIGHT',
			UP_OUTSIDE = 'BOTTOMLEFT',
			INSIDE_DOWN = 'TOPRIGHT',
			INSIDE_UP = 'BOTTOMRIGHT',
			OUTSIDE_DOWN = 'TOPLEFT',
			OUTSIDE_UP = 'BOTTOMLEFT',
		},
	},
	SideSlotGrowthDirection = {
		DOWN_INSIDE = format(L["%s and then %s"], L["Down"], L["Inside"]),
		DOWN_OUTSIDE = format(L["%s and then %s"], L["Down"], L["Outside"]),
		UP_INSIDE = format(L["%s and then %s"], L["Up"], L["Inside"]),
		UP_OUTSIDE = format(L["%s and then %s"], L["Up"], L["Outside"]),
		INSIDE_DOWN = format(L["%s and then %s"], L["Inside"], L["Down"]),
		INSIDE_UP = format(L["%s and then %s"], L["Inside"], L["Up"]),
		OUTSIDE_DOWN = format(L["%s and then %s"], L["Outside"], L["Down"]),
		OUTSIDE_UP = format(L["%s and then %s"], L["Outside"], L["Up"]),
	},
	DIRECTION_TO_POINT = {
		DOWN_RIGHT = 'TOPLEFT',
		DOWN_LEFT = 'TOPRIGHT',
		UP_RIGHT = 'BOTTOMLEFT',
		UP_LEFT = 'BOTTOMRIGHT',
		RIGHT_DOWN = 'TOPLEFT',
		RIGHT_UP = 'BOTTOMLEFT',
		LEFT_DOWN = 'TOPRIGHT',
		LEFT_UP = 'BOTTOMRIGHT',
	}
}

local ProfessionIDs = {
	Blacksmithing = 164,
	Enchanting = 333,
	Engineering = 202,
}

local function CheckProf(profession)
	local profID = ProfessionIDs[profession]
	if not profID then return false end

	local prof1, prof2 = GetProfessions()
	if not prof1 and not prof2 then return false end

	local prof1Name, _, _, _, _, _, prof1ID = prof1 and GetProfessionInfo(prof1)
	local prof2Name, _, _, _, _, _, prof2ID = prof2 and GetProfessionInfo(prof2)

	if prof1ID == profID then
		return prof1Name
	elseif prof2ID == profID then
		return prof2Name
	end

	return false
end

Engine.GearList = {
	HeadSlot = {
		slotID = 1,
		canEnchant = false,
		direction = 'LEFT',
	},
	NeckSlot = {
		slotID = 2,
		direction = 'LEFT',
	},
	ShoulderSlot = {
		slotID = 3,
		canEnchant = true,
		direction = 'LEFT',
	},
	ChestSlot = {
		slotID = 5,
		canEnchant = true,
		direction = 'LEFT',
	},
	ShirtSlot = {
		slotID = 4,
		ignored = true,
		direction = 'LEFT',
	},
	TabardSlot = {
		slotID = 19,
		ignored = true,
		direction = 'LEFT',
	},
	WaistSlot = {
		slotID = 6,
		direction = 'RIGHT',
	},
	LegsSlot = {
		slotID = 7,
		canEnchant = true,
		direction = 'RIGHT',
	},
	FeetSlot = {
		slotID = 8,
		canEnchant = true,
		direction = 'RIGHT',
	},
	WristSlot = {
		slotID = 9,
		canEnchant = true,
		direction = 'LEFT',
	},
	HandsSlot = {
		slotID = 10,
		canEnchant = true,
		direction = 'RIGHT',
	},
	Finger0Slot = {
		slotID = 11,
		canEnchant = CheckProf,
		direction = 'RIGHT',
	},
	Finger1Slot = {
		slotID = 12,
		canEnchant = CheckProf,
		direction = 'RIGHT',
	},
	Trinket0Slot = {
		slotID = 13,
		direction = 'RIGHT',
	},
	Trinket1Slot = {
		slotID = 14,
		direction = 'RIGHT',
	},
	BackSlot = {
		slotID = 15,
		canEnchant = true,
		direction = 'LEFT',
	},
	MainHandSlot = {
		slotID = 16,
		canEnchant = true,
		direction = 'RIGHT',
		isBottomSlot = true,
	},
	SecondaryHandSlot = {
		slotID = 17,
		canEnchant = true,
		isBottomSlot = true,
	},
	RangedSlot = {
		slotID = 18,
		direction = 'LEFT',
		isBottomSlot = true,
	},
}

Engine.AttachToObjects = {
	Character = {
		PaperDollFrame = 'PaperDollFrame',
		CharacterFrameInset = 'CharacterFrameInset',
		CharacterLevelText = 'CharacterLevelText',
	},
	Inspect = {
		InspectPaperDollFrame = 'InspectPaperDollFrame',
		InspectLevelText = 'InspectLevelText',
	},
}
