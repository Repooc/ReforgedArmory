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

Engine.ScanTooltip = CreateFrame('GameTooltip', 'RA_ScanTooltip', UIParent, 'GameTooltipTemplate')

local TooltipDataType = Enum.TooltipDataType
local AddTooltipPostCall = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem


do
	--* Disable the old versions which were named differently
	local oldArmoryNames = {
		'ElvUI_WrathArmory',
		'ElvUI_CataArmory',
	}

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

local function DisableElvUIInfo(which, db)
	if E.db.cataarmory[which].enable and E.db.general.itemLevel[db] then
		E.db.general.itemLevel[db] = false

		module:Print(format('ElvUI\'s %sDisplay %s Info|r option was |cffFF3300DISABLED|r automatically to prevent conflict with our module.', E.media.hexvaluecolor or '|cff16c3f2', gsub(which, '^%l', string.upper)))
	end
end
local function HandleTabs()
	--* Using ElvUI function with offsets adjusted
	local lastTab
	for index, tab in next, { _G.CharacterFrameTab1, HasPetUI() and _G.CharacterFrameTab2 or nil, _G.CharacterFrameTab3, _G.CharacterFrameTab4, _G.CharacterFrameTab5 } do
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -10, -25)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
		end

		lastTab = tab
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
	-- if AddTooltipPostCall and not E.Mists then
	-- 	AddTooltipPostCall(TooltipDataType.Item, module.GameTooltip_OnTooltipSetItem)
	-- else
		module:SecureHookScript(GameTooltip, 'OnTooltipSetItem', module.GameTooltip_OnTooltipSetItem)
	-- end

	module:SecureHook('PaperDollFrame_SetLevel', module.PaperDollFrame_SetLevel)
	module:SecureHook(CharacterFrame, 'UpdateTabBounds', function()
		if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.character then return end
		if not E.db.cataarmory.character.enable then return end
		HandleTabs()
	end)
	module:SecureHook(E, 'UpdateDB', module.UpdateOptions)
end

E.Libs.EP:HookInitialize(module, module.Initialize)
