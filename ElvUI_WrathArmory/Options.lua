local E, L, _, P = unpack(ElvUI)
local module = E:GetModule('ElvUI_WrathArmory')
local ACH = E.Libs.ACH
local C

local function actionSubGroup(info, ...)
	local which = (info[#info-2] == 'character' or info[#info-2] == 'inspect') and info[#info-2] or info[#info-3]
	local updateGems = (info[#info-1] == 'gems' or info[#info-1] == 'enchant') or (info[#info-2] == 'gems' or info[#info-2] == 'enchant')

	if info.type == 'color' then
		local color = E.db.wratharmory[info[#info-2]][info[#info-1]][info[#info]]
		local r, g, b, a = ...
		if r then
			color.r, color.g, color.b, color.a = r, g, b, a
		else
			local d = P.wratharmory[info[#info-2]][info[#info-1]][info[#info]]
			return color.r, color.g, color.b, color.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if info[#info-2] == 'character' or info[#info-2] == 'inspect' then
			if value ~= nil then
				-- print('Set', info[#info-2], info[#info-1], info[#info], value)
				E.db.wratharmory[info[#info-2]][info[#info-1]][info[#info]] = value
			else
				-- print('Get', info[#info-2], info[#info-1], info[#info])
				return E.db.wratharmory[info[#info-2]][info[#info-1]][info[#info]]
			end
		elseif info[#info-3] == 'character' or info[#info-3] == 'inspect' then
			if value ~= nil then
				-- print('Set', info[#info-3], info[#info-2], info[#info-1], info[#info], value)
				E.db.wratharmory[info[#info-3]][info[#info-2]][info[#info-1]][info[#info]] = value
			else
				-- print('Get', info[#info-3], info[#info-2], info[#info-1], info[#info])
				return E.db.wratharmory[info[#info-3]][info[#info-2]][info[#info-1]][info[#info]]
			end
		end
	end

	local unit = which:gsub("^%l", string.upper)
	module:UpdateOptions(unit, updateGems)
end

local function GetOptionsTable_FontGroup(name, groupName)
	local config = ACH:Group(name, nil, 5, 'tab', actionSubGroup, actionSubGroup)
	-- config.inline = true

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil)
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 3, C.Values.FontSize)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 4)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	config.args.qualityColor = ACH:Toggle(L["Quality Color"], nil, 10, nil, nil, nil)
	config.args.color = ACH:Color(L["Color"], nil, 11)

	if groupName == 'enchant' then
		local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 10, nil)
		config.args.MainHandSlot = MainHandSlot
		MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
		MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

		local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 11, nil, actionSubGroup, actionSubGroup)
		config.args.SecondaryHandSlot = SecondaryHandSlot
		SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
		SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

		local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 12, nil, actionSubGroup, actionSubGroup)
		config.args.RangedSlot = RangedSlot
		RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
		RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	end

	return config
end

local function GetOptionsTable_Gems()
	local config = ACH:Group(L["Gems"], nil, 10, 'tab', actionSubGroup, actionSubGroup)
	-- config.inline = true

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.size = ACH:Range(L["Size"], nil, 2, {min = 8, softMax = 75, max = 50, step = 1 })
	config.args.spacing = ACH:Range(L["Spacing"], nil, 3, {min = 0, softMax = 15, max = 100, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 10, nil)
	config.args.MainHandSlot = MainHandSlot
	MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 11, nil, actionSubGroup, actionSubGroup)
	config.args.SecondaryHandSlot = SecondaryHandSlot
	SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 12, nil, actionSubGroup, actionSubGroup)
	config.args.RangedSlot = RangedSlot
	RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function configTable()
	C = unpack(E.OptionsUI)
	local Armory = ACH:Group('|cFF16C3F2Wrath|rArmory', nil, 6, 'tab', nil, nil, nil)
	E.Options.args.wratharmory = Armory

    local Character = ACH:Group(L["Character"], nil, 0, nil, nil, nil)
	Armory.args.character = Character
	-- Character.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return E.db.wratharmory[info[#info-1]][info[#info]] end, function(info, value) E.db.wratharmory[info[#info-1]][info[#info]] = value module:ToggleItemLevelInfo() end, false)
	Character.args.avgItemLevel = GetOptionsTable_FontGroup(L["Average Item Level"])
	Character.args.enchant = GetOptionsTable_FontGroup(L["Enchants"], 'enchant')
	Character.args.itemLevel = GetOptionsTable_FontGroup(L["Equipment Item Levels"], 'itemLevel')
	Character.args.gems = GetOptionsTable_Gems()

    local Inspect = ACH:Group(L["Inspect"], nil, 1, nil, nil, nil)
	Armory.args.inspect = Inspect
	-- Inspect.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return E.db.wratharmory.inspect[info[#info]] end, function(info, value) E.db.wratharmory.inspect[info[#info]] = value module:ToggleItemLevelInfo() end, false)
	Inspect.args.avgItemLevel = GetOptionsTable_FontGroup(L["Average Item Level"])
	Inspect.args.enchant = GetOptionsTable_FontGroup(L["Enchants"], 'enchant')
	Inspect.args.itemLevel = GetOptionsTable_FontGroup(L["Equipment Item Levels"])
	Inspect.args.gems = GetOptionsTable_Gems()
end

tinsert(module.Configs, configTable)
