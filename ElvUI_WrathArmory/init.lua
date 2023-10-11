local E, L = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local AddOnName, Engine = ...

local module = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')
_G[AddOnName] = Engine

module.Title = GetAddOnMetadata('ElvUI_WrathArmory', 'Title')
module.CleanTitle = GetAddOnMetadata('ElvUI_WrathArmory', 'X-CleanTitle')
module.Version = GetAddOnMetadata('ElvUI_WrathArmory', 'Version')
module.Configs = {}

function module:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff16c3f2Wrath|rArmory ', E.media.hexvaluecolor or '|cff16c3f2', module.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
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
		canEnchant = true,
	},
	Finger0Slot = {
		slotID = 11,
		canEnchant = false, --! true for Character with Enchanting prof with skill of 400 or above
	},
	Finger1Slot = {
		slotID = 12,
		canEnchant = false,
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
		canEnchant = true,
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
		canEnchant = false, --! true for all hunters though
	},
}

local function HandleTabs()
	local lastTab
	for index, tab in next, { _G.CharacterFrameTab1, HasPetUI() and _G.CharacterFrameTab2 or nil, _G.CharacterFrameTab3, _G.CharacterFrameTab4, _G.CharacterFrameTab5 } do
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CharacterFrame.backdrop, 'BOTTOMLEFT', 1, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
		end

		lastTab = tab
	end
end

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	E:AddLib('GetEnchant', 'LibGetEnchant-1.0-WrathArmory')

	module:ToggleItemLevelInfo(true)

	if IsAddOnLoaded('Blizzard_InspectUI') then
		module:SetupInspectPageInfo()
	else
		module:RegisterEvent('ADDON_LOADED')
	end

	_G.CharacterFrameCloseButton:ClearAllPoints()
	_G.CharacterFrameCloseButton:Point('TOPRIGHT', CharacterFrame.backdrop, 0, 2)
	_G.GearManagerToggleButton:Point('TOPRIGHT', _G.PaperDollItemsFrame, 'TOPRIGHT', -8, -35)

	_G.GearManagerDialog:HookScript('OnShow', function(a, b, c)
		GearManagerDialog:ClearAllPoints()
		GearManagerDialog:Point('TOPLEFT', WrathArmory_StatsPane, 'TOPRIGHT', 0, 0)
		-- 'TOPLEFT', PaperDollFrame, 'TOPRIGHT', -30, -12  -- default
	end)
	-- GearManagerDialog:HookScript('OnHide', function(a, b, c)
	-- 	print("Hiding Equipment Manager", a, b, c)
	-- end)
	--[[
	module:UpdateOptions()

	if not ELVUIILVL then
		_G.ELVUIILVL = {}
	end
	]]

	-- Reposition Tabs
	hooksecurefunc('PetPaperDollFrame_UpdateTabs', HandleTabs)
	HandleTabs()
end

E.Libs.EP:HookInitialize(module, module.Initialize)
