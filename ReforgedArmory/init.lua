local IsHardcoreActive = C_GameRules and C_GameRules.IsHardcoreActive
local IsEngravingEnabled = C_Engraving and C_Engraving.IsEngravingEnabled
local DisableAddOn = (C_AddOns and C_AddOns.DisableAddOn) or DisableAddOn
local GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local TooltipDataType = Enum.TooltipDataType
local AddTooltipPostCall = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem

local AddOnName, Engine = ...
local RA = _G.LibStub('AceAddon-3.0'):NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0')
RA.Defaults = {profile = {}, global = {}}

Engine[1] = RA -- RA
Engine[2] = {} -- L
Engine[3] = RA.Defaults.profile -- P
Engine[4] = RA.Defaults.global -- G
_G.ReforgedArmory = Engine

RA.Libs = {
	AceDB = _G.LibStub('AceDB-3.0'),
	ACH = _G.LibStub('LibAceConfigHelper-Reforged'),
	EP = _G.LibStub('LibElvUIPlugin-1.0', true),
	ACL = _G.LibStub('AceLocale-3.0-ElvUI', true) or _G.LibStub('AceLocale-3.0'),
	GUI = _G.LibStub('AceGUI-3.0'),
	AC = _G.LibStub('AceConfig-3.0'),
	ACD = _G.LibStub('AceConfigDialog-3.0-ElvUI', true) or _G.LibStub('AceConfigDialog-3.0'),
	ACR = _G.LibStub('AceConfigRegistry-3.0'),
	ADBO = _G.LibStub('AceDBOptions-3.0'),
	LSM = _G.LibStub('LibSharedMedia-3.0'),
	GetEnchantList = _G.LibStub('LibGetEnchant-1.0-CataArmory')
}

RA.Title = GetAddOnMetadata('ReforgedArmory', 'Title')
RA.Version = GetAddOnMetadata('ReforgedArmory', 'Version')
RA.myName = UnitName('player')
RA.Configs = {}

RA.locale = GetLocale()
do -- this is different from E.locale because we need to convert for ace locale files
	local convert = { enGB = 'enUS', esES = 'esMX', itIT = 'enUS' }
	local gameLocale = convert[RA.locale] or RA.locale or 'enUS'

	function RA:GetLocale()
		return gameLocale
	end
end

do
	--* Disable the old version which was named WrathArmory
	DisableAddOn('ElvUI_WrathArmory')
end

-- Expansions
RA.Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
RA.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
RA.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
RA.ClassicHC = IsHardcoreActive and IsHardcoreActive()
RA.ClassicSOD = IsEngravingEnabled and IsEngravingEnabled()

function RA:OnEnable()
	RA:Initialize()
end

function RA:GameTooltip_OnTooltipSetItem(data)
	if (self ~= GameTooltip and self ~= _G.ShoppingTooltip1 and self ~= _G.ShoppingTooltip2) or self:IsForbidden() then return end

	local GetItem = GetDisplayedItem or self.GetItem
	if GetItem then
		local name, itemLink = GetItem(self)

		if not itemLink then return end
		local enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))

		if not enchantID or (RA.db.general.tooltip.missingOnly and RA.Libs.GetEnchantList.LibGetEnchantDB[enchantID]) then
			return
		end

		self:AddLine(format('|cFFCA3C3C%s:|r %s', 'Enchant ID', enchantID))
	end
end

function RA:OnInitialize()
	-- ElvUI[1]:Dump({['a'] = 1, ['b'] = 2}, true)

	RA.db = RA:CopyTable({}, RA.Defaults.profile)
	RA.global = RA:CopyTable({}, RA.Defaults.global)

	if RADB then
		if RADB.global then
			RA:CopyTable(RA.global, RADB.global)
		end

		local key = RADB.profileKeys and RADB.profileKeys[RA.myNameRealm]
		if key and RADB.profiles and RADB.profiles[key] then
			RA:CopyTable(RA.db, RADB.profiles[key])
		end
	end

	if AddTooltipPostCall and not RA.Cata then -- exists but doesn't work atm on Cata
		print('test')
		AddTooltipPostCall(TooltipDataType.Item, RA.GameTooltip_OnTooltipSetItem)
	else
		RA:SecureHookScript(GameTooltip, 'OnTooltipSetItem', RA.GameTooltip_OnTooltipSetItem)
	end

	RA.ScanTooltip = CreateFrame('GameTooltip', 'ReforgedArmory_ScanTooltip', UIParent, 'GameTooltipTemplate')
	RA.ScanTooltip.GetEnchantInfo = RA.ScanTooltip_EnchantInfo

	RA:RegisterChatCommand('ra', 'ToggleOptions')
	RA:RegisterChatCommand('reforgedarmory', 'ToggleOptions')
end
-- --!------------------------------------------------

-- local E, L = unpack(ElvUI)
-- local EP = E.Libs.EP
-- local M = E.Misc
-- local module = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')

-- Engine.EnchantsTable = {
-- 	UserReplaced = {},
-- }

-- local TooltipDataType = Enum.TooltipDataType
-- local AddTooltipPostCall = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
-- local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem


-- function module:Print(...)
-- 	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff00FF98Cata|r |cffA330C9Armory|r ', E.media.hexvaluecolor or '|cff16c3f2', module.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
-- end

-- local function GetOptions()
-- 	for _, func in pairs(module.Configs) do
-- 		func()
-- 	end
-- end

-- function module:UpdateOptions(unit, force)
-- 	if unit then
-- 		module:UpdateInspectPageFonts(unit, force)
-- 		if unit == 'Character' then
-- 			module.PaperDollFrame_SetLevel()
-- 		elseif unit == 'Inspect' then
-- 			module.InspectPaperDollFrame_SetLevel()
-- 		end
-- 	else
-- 		module:UpdateInspectPageFonts('Character', force)
-- 		module.PaperDollFrame_SetLevel()

-- 		module:UpdateInspectPageFonts('Inspect', force)
-- 		module.InspectPaperDollFrame_SetLevel()
-- 	end
-- end

-- local ProfessionIDs = {
-- 	Blacksmithing = 164,
-- 	Enchanting = 333,
-- 	Engineering = 202,
-- }

-- local function CheckProf(profession)
-- 	local profID = ProfessionIDs[profession]
-- 	if not profID then return false end

-- 	local prof1Name, prof1ID, prof2Name, prof2ID
-- 	local prof1, prof2 = GetProfessions()

-- 	if prof1 then
-- 		prof1Name, _, _, _, _, _, prof1ID = GetProfessionInfo(prof1)
-- 	end
-- 	if prof2 then
-- 		prof2Name, _, _, _, _, _, prof2ID = GetProfessionInfo(prof2)
-- 	end

-- 	return ((prof1ID and prof1ID == profID) and prof1Name) or ((prof2ID and prof2ID == profID) and prof2Name) or false
-- 	-- -- if prof1ID and prof1ID == profID then
-- 	-- -- 	return prof1Name
-- 	-- -- end

-- 	-- if prof2 then
-- 	-- 	prof2Name, _, _, _, _, _, prof2ID = GetProfessionInfo(prof2)
-- 	-- end
-- 	-- if prof2ID and prof2ID == profID then
-- 	-- 	return prof2Name
-- 	-- end

-- 	-- return false
-- end
-- -- function module:CheckProf(prof)

-- -- end

-- module.GearList = {
-- 	HeadSlot = {
-- 		slotID = 1,
-- 		canEnchant = true,
-- 		direction = 'LEFT',
-- 	},
-- 	NeckSlot = {
-- 		slotID = 2,
-- 		direction = 'LEFT',
-- 	},
-- 	ShoulderSlot = {
-- 		slotID = 3,
-- 		canEnchant = true,
-- 		direction = 'LEFT',
-- 	},
-- 	ChestSlot = {
-- 		slotID = 5,
-- 		canEnchant = true,
-- 		direction = 'LEFT',
-- 	},
-- 	ShirtSlot = {
-- 		slotID = 4,
-- 		ignored = true,
-- 		direction = 'LEFT',
-- 	},
-- 	TabardSlot = {
-- 		slotID = 19,
-- 		ignored = true,
-- 		direction = 'LEFT',
-- 	},
-- 	WaistSlot = {
-- 		slotID = 6,
-- 		direction = 'RIGHT',
-- 	},
-- 	LegsSlot = {
-- 		slotID = 7,
-- 		canEnchant = true,
-- 		direction = 'RIGHT',
-- 	},
-- 	FeetSlot = {
-- 		slotID = 8,
-- 		canEnchant = true,
-- 		direction = 'RIGHT',
-- 	},
-- 	WristSlot = {
-- 		slotID = 9,
-- 		canEnchant = true,
-- 		direction = 'LEFT',
-- 	},
-- 	HandsSlot = {
-- 		slotID = 10,
-- 		canEnchant = true,
-- 		direction = 'RIGHT',
-- 	},
-- 	Finger0Slot = {
-- 		slotID = 11,
-- 		canEnchant = CheckProf,
-- 		direction = 'RIGHT',
-- 	},
-- 	Finger1Slot = {
-- 		slotID = 12,
-- 		canEnchant = CheckProf,
-- 		direction = 'RIGHT',
-- 	},
-- 	Trinket0Slot = {
-- 		slotID = 13,
-- 		direction = 'RIGHT',
-- 	},
-- 	Trinket1Slot = {
-- 		slotID = 14,
-- 		direction = 'RIGHT',
-- 	},
-- 	BackSlot = {
-- 		slotID = 15,
-- 		canEnchant = true,
-- 		direction = 'LEFT',
-- 	},
-- 	MainHandSlot = {
-- 		slotID = 16,
-- 		canEnchant = true,
-- 		direction = 'RIGHT',
-- 	},
-- 	SecondaryHandSlot = {
-- 		slotID = 17,
-- 		canEnchant = true,
-- 	},
-- 	RangedSlot = {
-- 		slotID = 18,
-- 		direction = 'LEFT',
-- 	},
-- }

-- module.AttachToObjects = {
-- 	Character = {
-- 		PaperDollFrame = 'PaperDollFrame',
-- 		CharacterFrameInset = 'CharacterFrameInset',
-- 		CharacterLevelText = 'CharacterLevelText',
-- 	},
-- 	Inspect = {
-- 		InspectPaperDollFrame = 'InspectPaperDollFrame',
-- 		InspectLevelText = 'InspectLevelText',
-- 	},
-- }

-- local function DisableElvUIInfo(which, db)
-- 	if E.db.cataarmory[which].enable and E.db.general.itemLevel[db] then
-- 		E.db.general.itemLevel[db] = false

-- 		module:Print(format('ElvUI\'s %sDisplay %s Info|r option was |cffFF3300DISABLED|r automatically to prevent conflict with our module.', E.media.hexvaluecolor or '|cff16c3f2', gsub(which, "^%l", string.upper)))
-- 	end
-- end

-- function module:ADDON_LOADED(_, addon)
-- 	if addon == 'Blizzard_InspectUI' then
-- 		module:SetupInspectPageInfo()
-- 		module:SecureHook('InspectPaperDollFrame_SetLevel', module.InspectPaperDollFrame_SetLevel)

-- 		if not module:IsHooked(_G.InspectFrame, 'OnShow') then
-- 			module:SecureHookScript(_G.InspectFrame, 'OnShow', module.InspectFrame_OnShow)
-- 		end
-- 	end
-- end

-- function module:GameTooltip_OnTooltipSetItem()
-- 	if (self ~= GameTooltip and self ~= _G.ShoppingTooltip1 and self ~= _G.ShoppingTooltip2) or self:IsForbidden() then return end

-- 	local owner = self:GetOwner()
-- 	local ownerName = owner and owner.GetName and owner:GetName()
-- 	if not ownerName then return end
-- 	if ownerName and not (strfind(ownerName, 'Character') or strfind(ownerName, 'Inspect')) then return end

-- 	local unit = string.match(ownerName, 'Character') or string.match(ownerName, 'Inspect')
-- 	if not unit then return end
-- 	unit = string.lower(unit)
-- 	if not E.db.cataarmory[unit].enchant.enchantID.enable then return end

-- 	local GetItem = GetDisplayedItem or self.GetItem
-- 	if GetItem then
-- 		local name, link = GetItem(self)
-- 		if not link then return end
-- 		local enchantID = tonumber(string.match(link, 'item:%d+:(%d+):'))
-- 		if not enchantID or (E.db.cataarmory[unit].enchant.enchantID.missingOnly and E.Libs.GetEnchantList.GetEnchant(enchantID)) then return end

-- 		self:AddLine(format('|cFFCA3C3C%s:|r %s', 'Enchant ID', enchantID))
-- 	end
-- end

-- function module:Initialize()
-- 	EP:RegisterPlugin(AddOnName, GetOptions)
-- 	E:AddLib('GetEnchantList', 'LibGetEnchant-1.0-CataArmory')

-- 	DisableElvUIInfo('character', 'displayCharacterInfo')
-- 	DisableElvUIInfo('inspect', 'displayInspectInfo')
-- 	M:ToggleItemLevelInfo()

-- 	if IsAddOnLoaded('Blizzard_InspectUI') then
-- 		module:SetupInspectPageInfo()
-- 		module:SecureHook('InspectPaperDollFrame_SetLevel', module.InspectPaperDollFrame_SetLevel)
-- 		if not module:IsHooked(_G.InspectFrame, 'OnShow') then
-- 			module:SecureHookScript(_G.InspectFrame, 'OnShow', module.InspectFrame_OnShow)
-- 		end
-- 	else
-- 		module:RegisterEvent('ADDON_LOADED')
-- 	end

-- 	module:ToggleItemLevelInfo(true)

-- 	--* In case I am to make this work for retail and classic/sod
-- 	-- if AddTooltipPostCall and not E.Cata then -- exists but doesn't work atm on Cata
-- 	-- 	AddTooltipPostCall(TooltipDataType.Item, module.GameTooltip_OnTooltipSetItem)
-- 	-- else
-- 		module:SecureHookScript(GameTooltip, 'OnTooltipSetItem', module.GameTooltip_OnTooltipSetItem)
-- 	-- end

-- 	module:SecureHook('PaperDollFrame_SetLevel', module.PaperDollFrame_SetLevel)
-- 	module:SecureHook(E, 'UpdateDB', module.UpdateOptions)
-- end

-- E.Libs.EP:HookInitialize(module, module.Initialize)
