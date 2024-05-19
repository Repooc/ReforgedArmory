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
	else
		module:UpdateInspectPageFonts('Character')
		module:UpdateInspectPageFonts('Inspect')
	end
end

module.GearList = {
	HeadSlot = {
		slotID = 1,
		canEnchant = true,
	},
	NeckSlot = {
		slotID = 2,
		canEnchant = false,
	},
	ShoulderSlot = {
		slotID = 3,
		canEnchant = true,
	},
	ChestSlot = {
		slotID = 5,
		canEnchant = true,
	},
	WaistSlot = {
		slotID = 6,
		canEnchant = false,
	},
	LegsSlot = {
		slotID = 7,
		canEnchant = true,
	},
	FeetSlot = {
		slotID = 8,
		canEnchant = true,
	},
	WristSlot = {
		slotID = 9,
		canEnchant = true,
	},
	HandsSlot = {
		slotID = 10,
		canEnchant = false,
	},
	Finger0Slot = {
		slotID = 11,
		canEnchant = true,
	},
	Finger1Slot = {
		slotID = 12,
		canEnchant = true,
	},
	Trinket0Slot = {
		slotID = 13,
		canEnchant = false,
	},
	Trinket1Slot = {
		slotID = 14,
		canEnchant = false,
	},
	BackSlot = {
		slotID = 15,
		canEnchant = false,
	},
	MainHandSlot = {
		slotID = 16,
		canEnchant = true,
	},
	SecondaryHandSlot = {
		slotID = 17,
		canEnchant = true,
	},
	RangedSlot = {
		slotID = 18,
		canEnchant = false,
	},
}

local function DisableElvUIInfo(which, db)
	if E.db.cataarmory[which].enable then
		E.db.general.itemLevel[db] = false
	end
end

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	E:AddLib('GetEnchant', 'LibGetEnchant-1.0-CataArmory')

	DisableElvUIInfo('character', 'displayCharacterInfo')
	DisableElvUIInfo('inspect', 'displayInspectInfo')
	M:ToggleItemLevelInfo()

	module:ToggleItemLevelInfo(true)

	if IsAddOnLoaded('Blizzard_InspectUI') then
		module:SetupInspectPageInfo()
	else
		module:RegisterEvent('ADDON_LOADED')
	end

	module:SecureHook('PaperDollFrame_SetLevel', module.PaperDollFrame_SetLevel)
	module:SecureHook(E, 'UpdateDB', module.UpdateOptions)
end

E.Libs.EP:HookInitialize(module, module.Initialize)
