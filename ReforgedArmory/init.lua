local E, L = unpack(ElvUI)
local EP = E.Libs.EP
local M = E.Misc
local AddOnName, Engine = ...

local DisableAddOn = C_AddOns.DisableAddOn

local module = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')
module.Title = GetAddOnMetadata('ReforgedArmory', 'Title')
module.CleanTitle = GetAddOnMetadata('ReforgedArmory', 'X-CleanTitle')
module.Version = GetAddOnMetadata('ReforgedArmory', 'Version')
module.Configs = {}

Engine.EnchantsTable = {
	UserReplaced = {},
}
Engine.Durability = {
	Bar = {
		OffSets = {
			MIN_BAR_EDGEOFFSET = -15,
			MAX_BAR_EDGEOFFSET = 15,
			MIN_BAR_LENGTHOFFSET = -10,
			MAX_BAR_LENGTHOFFSET = 10,
		},
		Thickness = {
			MIN_BAR_THICKNESS = 2,
			MAX_BAR_THICKNESS = 42
		}
	}
}
Engine.Values = {
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
		}
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
Engine.ScanTooltip = CreateFrame('GameTooltip', 'RA_ScanTooltip', UIParent, 'GameTooltipTemplate')

local TooltipDataType = Enum.TooltipDataType
local AddTooltipPostCall = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem

local oldArmoryNames = {
	'ElvUI_WrathArmory',
	'ElvUI_CataArmory',
}

do
	--* Disable the old versions which were named differently
	for _, addon in next, oldArmoryNames do
		DisableAddOn(addon)
	end
end

function module:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff00FF98Reforged|r|cffA330C9Armory|r ', E.media.hexvaluecolor or '|cff16c3f2', module.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

function module:Clamp(value, min, max)
	return math.min(max, math.max(value, min))
end

local function GetOptions()
	for _, func in pairs(module.Configs) do
		func()
	end
end

function module:UpdateOptions(unit, force)
	if unit then
		module:UpdateInspectPageFonts(unit, force)
		if unit == 'Character' then
			module.PaperDollFrame_SetLevel()
		elseif unit == 'Inspect' then
			module.InspectPaperDollFrame_SetLevel()
		end
	else
		module:UpdateInspectPageFonts('Character', force)
		module.PaperDollFrame_SetLevel()

		module:UpdateInspectPageFonts('Inspect', force)
		module.InspectPaperDollFrame_SetLevel()
	end
end

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

module.GearList = {
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
	},
	SecondaryHandSlot = {
		slotID = 17,
		canEnchant = true,
	},
	RangedSlot = {
		slotID = 18,
		direction = 'LEFT',
	},
}

module.AttachToObjects = {
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

local function DisableElvUIInfo(which, db)
	if E.db.cataarmory[which].enable and E.db.general.itemLevel[db] then
		E.db.general.itemLevel[db] = false

		module:Print(format('ElvUI\'s %sDisplay %s Info|r option was |cffFF3300DISABLED|r automatically to prevent conflict with our module.', E.media.hexvaluecolor or '|cff16c3f2', gsub(which, '^%l', string.upper)))
	end
end

function module:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_InspectUI' then
		module:SetupInspectPageInfo()
		module:SecureHook('InspectPaperDollFrame_SetLevel', module.InspectPaperDollFrame_SetLevel)

		if not module:IsHooked(_G.InspectFrame, 'OnShow') then
			module:SecureHookScript(_G.InspectFrame, 'OnShow', module.InspectFrame_OnShow)
		end
	end
end

function module:GameTooltip_OnTooltipSetItem()
	if (self ~= GameTooltip and self ~= _G.ShoppingTooltip1 and self ~= _G.ShoppingTooltip2) or self:IsForbidden() then return end

	local owner = self:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if not ownerName then return end
	if ownerName and not (strfind(ownerName, 'Character') or strfind(ownerName, 'Inspect')) then return end

	local unit = string.match(ownerName, 'Character') or string.match(ownerName, 'Inspect')
	if not unit then return end
	unit = string.lower(unit)
	if not E.db.cataarmory[unit].enchant.enchantID.enable then return end

	local GetItem = GetDisplayedItem or self.GetItem
	if GetItem then
		local name, link = GetItem(self)
		if not link then return end
		local enchantID = tonumber(string.match(link, 'item:%d+:(%d+):'))
		if not enchantID or (E.db.cataarmory[unit].enchant.enchantID.missingOnly and E.Libs.GetEnchantList.GetEnchant(enchantID)) then return end

		self:AddLine(format('|cFFCA3C3C%s:|r %s', 'Enchant ID', enchantID))
	end
end

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	E:AddLib('GetEnchantList', 'LibGetEnchant-1.0-ReforgedArmory')

	DisableElvUIInfo('character', 'displayCharacterInfo')
	DisableElvUIInfo('inspect', 'displayInspectInfo')
	M:ToggleItemLevelInfo()

	if IsAddOnLoaded('Blizzard_InspectUI') then
		module:SetupInspectPageInfo()
		module:SecureHook('InspectPaperDollFrame_SetLevel', module.InspectPaperDollFrame_SetLevel)
		if not module:IsHooked(_G.InspectFrame, 'OnShow') then
			module:SecureHookScript(_G.InspectFrame, 'OnShow', module.InspectFrame_OnShow)
		end
	else
		module:RegisterEvent('ADDON_LOADED')
	end

	module:ToggleItemLevelInfo(true)

	--* In case I am to make this work for retail and classic/sod
	-- if AddTooltipPostCall and not E.Cata then -- exists but doesn't work atm on Cata
	-- 	AddTooltipPostCall(TooltipDataType.Item, module.GameTooltip_OnTooltipSetItem)
	-- else
		module:SecureHookScript(GameTooltip, 'OnTooltipSetItem', module.GameTooltip_OnTooltipSetItem)
	-- end

	module:SecureHook('PaperDollFrame_SetLevel', module.PaperDollFrame_SetLevel)
	module:SecureHook(E, 'UpdateDB', module.UpdateOptions)
end

E.Libs.EP:HookInitialize(module, module.Initialize)
