local RA = unpack(ReforgedArmory)
local AddOnName, Engine = ...

--* Most of the API is from ElvUI/Simpy to maintain backwards compatibility if ElvUI is disabled
local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local C_AddOns_GetAddOnEnableState = C_AddOns and C_AddOns.GetAddOnEnableState
local GetAddOnEnableState = GetAddOnEnableState -- eventually this will be on C_AddOns and args swap
local utf8len, utf8sub, modf = string.utf8len, string.utf8sub, math.modf

local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')

function RA:Print(...)
	(ElvUI and ElvUI[1].db and _G[ElvUI[1].db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff00FF98Reforged|r |cffA330C9Armory|r ', ElvUI and ElvUI[1].media.hexvaluecolor or '|cff16c3f2', RA.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

function RA.ScanTooltip_EnchantInfo(_, unit, slot)
	if not unit or not slot then return end
	if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
		local tt = RA.ScanTooltip
		tt:SetOwner(UIParent, 'ANCHOR_NONE')
		local hasItem = tt:SetInventoryItem(unit, slot)
		tt:Show()

		local info = hasItem and tt:GetTooltipData()
		if info then
			for i, line in next, info.lines do
				local text = line and line.leftText
				if i == 1 and text == RETRIEVING_ITEM_INFO then
					print('tooSoon yo')
				else
					local enchant = strmatch(text, MATCH_ENCHANT)
					if enchant then
						local color1, color2 = strmatch(enchant, '(|cn.-:).-(|r)')
						local formattedText = gsub(gsub(enchant, '%s?|A.-|a', ''), '|cn.-:(.-)|r', '%1')
						local enchantText = format('%s%s%s', color1 or '', formattedText, color2 or '')
						local enchantTextShort = format('%s%s%s', color1 or '', utf8sub(formattedText, 1, 18), color2 or '')

						return enchantText, enchantTextShort, enchant
					end
				end
			end

		end
		tt:Show()
	end
end

--* Credits to ElvUI
function RA:CopyTable(current, default, merge)
	if type(current) ~= 'table' then
		current = {}
	end

	if type(default) == 'table' then
		for option, value in pairs(default) do
			local isTable = type(value) == 'table'
			if not merge or (isTable or current[option] == nil) then
				current[option] = (isTable and RA:CopyTable(current[option], value, merge)) or value
			end
		end
	end

	return current
end

function RA:ADDON_LOADED(event, addon)
	if event == 'FAKE_LOGIN_EVENT' and not IsAddOnLoaded('Blizzard_InspectUI') then
		RA:RegisterEvent('ADDON_LOADED')
	elseif addon == 'Blizzard_InspectUI' then
		if RA.Retail then
			_G.InspectFrame:SetHeight(PANEL_DEFAULT_HEIGHT + 35)
			_G.InspectFrame:SetWidth(PANEL_DEFAULT_WIDTH + 45)
		end

		RA:UpdateInspectLayout()
		-- 	RA:UpdateAverageString(_G.InspectFrame, _G.InspectFrame.unit or 'target')

		if not RA:IsHooked('InspectPaperDollItemSlotButton_Update') then
			RA:SecureHook('InspectPaperDollItemSlotButton_Update', function(button)
				RA:UpdateItemSlot(button, _G.InspectFrame.unit or 'target')
			end)
		end

		if not RA:IsHooked('InspectPaperDollFrame_SetLevel') then
			RA:SecureHook('InspectPaperDollFrame_SetLevel', 'InspectPaperDollFrame_SetLevel')
		end

		if not RA:IsHooked(_G.InspectFrame, 'OnShow') then
			RA:SecureHookScript(_G.InspectFrame, 'OnShow', 'InspectFrame_OnShow')
		end
		RA:UnregisterEvent('ADDON_LOADED')
	end
end

function RA:GetAddOnEnableState(addon, character)
	if C_AddOns_GetAddOnEnableState then
		return C_AddOns_GetAddOnEnableState(addon, character)
	else
		return GetAddOnEnableState(character, addon)
	end
end

function RA:IsAddOnEnabled(addon)
	return RA:GetAddOnEnableState(addon, RA.myName) == 2
end

function RA:BuildOptions()
	if RA.Libs.EP and RA:IsAddOnEnabled('ElvUI') then
		RA.Libs.EP:RegisterPlugin(AddOnName, RA.GetOptions)
	else
		RA.Libs.AC:RegisterOptionsTable(AddOnName, RA.Options)
		RA.Libs.ACD:AddToBlizOptions(AddOnName, RA.Title)
		RA.Libs.ACD:SetDefaultSize(AddOnName, 900, 650)
	end
	RA.Options.args.profiles = RA.Libs.ADBO:GetOptionsTable(RA.data, true)
	RA.Options.args.profiles.order = -2
end

function RA:ToggleOptions()
	if RA:IsAddOnEnabled('ElvUI') then
		if InCombatLockdown() then return end
		_G.ElvUI[1]:ToggleOptions()
		RA.Libs.ACD:SelectGroup('ElvUI', 'rrp', 'reforgedarmory')
	else
		if _G.SettingsPanel:IsShown() then
			_G.SettingsPanel:ExitWithCommit(true)
			return
		end

		local ConfigOpen = RA.Libs.ACD.OpenFrames and RA.Libs.ACD.OpenFrames.ReforgedArmory
		if ConfigOpen and ConfigOpen.frame then
			RA.Libs.ACD:Close('ReforgedArmory')
		else
			RA.Libs.ACD:Open('ReforgedArmory')
		end
	end
end

RA.GearList = {
	HeadSlot = {
		slotID = 1,
		canEnchant = true,
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
		direction = RA.Retail and 'LEFT' or nil,
	},
	RangedSlot = {
		slotID = 18,
		direction = 'LEFT',
	},
}

--!------------------------------
--Prob not needed below this

function RA:BuildProfile()
	-- local Defaults = {
	-- 	profile = {
	-- 		blizzard = {
	-- 			player = sharedDefaultValues,
	-- 			target = sharedDefaultValues,
	-- 			targettarget = sharedDefaultValues,
	-- 			focus = sharedDefaultValues,
	-- 			focustarget = sharedDefaultValues,
	-- 			party = sharedDefaultValues,
	-- 			-- raid = {
	-- 			-- 	icon = sharedDefaultValues.icon,
	-- 			-- },
	-- 		},
	-- 		elvui = {},
	-- 		suf = {},
	-- 	},
	-- }
	-- for unit in pairs(elvuiUnitList) do
	-- 	Defaults.profile.elvui[unit] = {
	-- 		portrait = {
	-- 			enable = false,
	-- 			style = 'fabled',
	-- 		},
	-- 	}
	-- end

	-- for _, unit in pairs(sufUnitList) do
	-- 	Defaults.profile.suf[unit] = {
	-- 		portrait = {
	-- 			enable = false,
	-- 			style = 'fabled',
	-- 		},
	-- 		icon = {
	-- 			enable = false,
	-- 			style = 'fabled',
	-- 			size = 32,
	-- 			anchorPoint = 'RIGHT',
	-- 			xOffset = 0,
	-- 			yOffset = 0,
	-- 		},
	-- 	}
	-- end

	-- RA.data = RA.Libs.ADB:New('JiberishIconsDB', Defaults)
	-- RA.data.RegisterCallback(RA, 'OnProfileChanged', 'SetupProfile')
	-- RA.data.RegisterCallback(RA, 'OnProfileCopied', 'SetupProfile')
	-- RA.data.RegisterCallback(RA, 'OnProfileReset', 'SetupProfile')

	-- RA.db = RA.data.profile
end


-- local function Round(num, idp)
--     if type(num) ~= 'number' then
--         return num, idp
--     end

--     if idp and idp > 0 then
--         local mult = 10 ^ idp
--         return math.floor(num * mult + 0.5) / mult
--     end

--     return math.floor(num + 0.5)
-- end
