local E, L = unpack(ElvUI)
local EP = E.Libs.EP
local M = E.Misc
local AddOnName, Engine = ...

local module = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')
_G[AddOnName] = Engine

module.Title = GetAddOnMetadata('ElvUI_CataArmory', 'Title')
module.CleanTitle = GetAddOnMetadata('ElvUI_CataArmory', 'X-CleanTitle')
module.Version = GetAddOnMetadata('ElvUI_CataArmory', 'Version')
module.Configs = {}

do
	--* Disable the old version which was named WrathArmory
	local DisableAddOn = (C_AddOns and C_AddOns.DisableAddOn) or DisableAddOn
	DisableAddOn('ElvUI_WrathArmory')
end

function module:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff00FF98Cata|r |cffA330C9Armory|r ', E.media.hexvaluecolor or '|cff16c3f2', module.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
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
		module:UpdateInspectPageFonts('Character')
		module.PaperDollFrame_SetLevel()

		module:UpdateInspectPageFonts('Inspect')
		module.InspectPaperDollFrame_SetLevel()
	end
end

module.GearList = {
	HeadSlot = {
		slotID = 1,
		canEnchant = true,
		direction = 'LEFT',
	},
	NeckSlot = {
		slotID = 2,
		canEnchant = false,
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
		ignored = true,
		direction = 'LEFT',
	},
	TabardSlot = {
		ignored = true,
		direction = 'LEFT',
	},
	WaistSlot = {
		slotID = 6,
		canEnchant = false,
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
		canEnchant = false,
		direction = 'RIGHT',
	},
	Finger0Slot = {
		slotID = 11,
		canEnchant = true,
		direction = 'RIGHT',
	},
	Finger1Slot = {
		slotID = 12,
		canEnchant = true,
		direction = 'RIGHT',
	},
	Trinket0Slot = {
		slotID = 13,
		canEnchant = false,
		direction = 'RIGHT',
	},
	Trinket1Slot = {
		slotID = 14,
		canEnchant = false,
		direction = 'RIGHT',
	},
	BackSlot = {
		slotID = 15,
		canEnchant = false,
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
		canEnchant = false,
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

		module:Print(format('ElvUI\'s %sDisplay %s Info|r option was |cffFF3300DISABLED|r automatically to prevent conflict with our module.', E.media.hexvaluecolor or '|cff16c3f2', gsub(which, "^%l", string.upper)))
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

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	E:AddLib('GetEnchant', 'LibGetEnchant-1.0-CataArmory')

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

	module:SecureHook('PaperDollFrame_SetLevel', module.PaperDollFrame_SetLevel)
	module:SecureHook(E, 'UpdateDB', module.UpdateOptions)
end

E.Libs.EP:HookInitialize(module, module.Initialize)
