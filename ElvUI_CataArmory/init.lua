local E, L = unpack(ElvUI)
local M = E.Misc
local EP = LibStub('LibElvUIPlugin-1.0')
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
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff16c3f2Cata|rArmory ', E.media.hexvaluecolor or '|cff16c3f2', module.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
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
		-- module:UpdateInspectPageFonts('Inspect')
	end
end

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	E:AddLib('GetEnchant', 'LibGetEnchant-1.0-CataArmory')

	if IsAddOnLoaded('Blizzard_InspectUI') then
		module:ADDON_LOADED(nil, 'Blizzard_InspectUI')
	else
		module:RegisterEvent('ADDON_LOADED')
	end

	module:ToggleItemLevelInfo(true)

	module:SecureHook(M, 'SetupInspectPageInfo', module.SetupInspectPageInfo)
	module:SecureHook(M, 'ToggleItemLevelInfo', module.ToggleItemLevelInfo)
	module:SecureHook(M, 'UpdateAverageString', module.UpdateAverageString)
	module:SecureHook(M, 'UpdateInspectPageFonts', module.UpdateInspectPageFonts)
	module:SecureHook(M, 'UpdatePageStrings', module.UpdatePageStrings)

	module:SecureHook('PaperDollFrame_SetLevel', module.PaperDollFrame_SetLevel)
end

E.Libs.EP:HookInitialize(module, module.Initialize)
