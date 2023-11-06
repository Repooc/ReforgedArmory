local E, L, _, P = unpack(ElvUI)
local module = E:GetModule('ElvUI_WrathArmory')
local ACH = E.Libs.ACH
local C

local AllPoints = {
	BOTTOM = 'BOTTOM',
	BOTTOMOUTSIDE = 'BOTTOMOUTSIDE',
	BOTTOMINSIDE = 'BOTTOMINSIDE',
	CENTER = 'CENTER',
	OUTSIDE = 'LEFT',
	INSIDE = 'RIGHT',
	TOP = 'TOP',
	TOPOUTSIDE = 'TOPOUTSIDE',
	TOPINSIDE = 'TOPINSIDE',
}
local SideSlotGrowthDirection = {
	DOWN_INSIDE = format(L["%s and then %s"], L["Down"], L["Inside"]),
	DOWN_OUTSIDE = format(L["%s and then %s"], L["Down"], L["Outside"]),
	UP_INSIDE = format(L["%s and then %s"], L["Up"], L["Inside"]),
	UP_OUTSIDE = format(L["%s and then %s"], L["Up"], L["Outside"]),
	INSIDE_DOWN = format(L["%s and then %s"], L["Inside"], L["Down"]),
	INSIDE_UP = format(L["%s and then %s"], L["Inside"], L["Up"]),
	OUTSIDE_DOWN = format(L["%s and then %s"], L["Outside"], L["Down"]),
	OUTSIDE_UP = format(L["%s and then %s"], L["Outside"], L["Up"]),
}

local function actionGroup(info, which, groupName, ...)
	local force = groupName == 'gems' or groupName == 'warningIndicator' or groupName == 'avgItemLevel'
	if info.type == 'color' then
		local color = E.db.wratharmory[which][groupName][info[#info]]
		local r, g, b, a = ...
		if r then
			color.r, color.g, color.b, color.a = r, g, b, a
		else
			local d = P.wratharmory[which][groupName][info[#info]]
			return color.r, color.g, color.b, color.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if value ~= nil then
			E.db.wratharmory[which][groupName][info[#info]] = value
		else
			return E.db.wratharmory[which][groupName][info[#info]]
		end
	end

	local unit = which:gsub("^%l", string.upper)
	module:UpdateOptions(unit, force)
end

local function actionSubGroup(info, which, groupName, subGroup, ...)
	local force = groupName == 'gems' or groupName == 'warningIndicator'
	if info.type == 'color' then
		local color = E.db.wratharmory[which][groupName][subGroup][info[#info]]
		local r, g, b, a = ...
		if r then
			color.r, color.g, color.b, color.a = r, g, b, a
		else
			local d = P.wratharmory[which][groupName][subGroup][info[#info]]
			return color.r, color.g, color.b, color.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if value ~= nil then
			E.db.wratharmory[which][groupName][subGroup][info[#info]] = value
		else
			return E.db.wratharmory[which][groupName][subGroup][info[#info]]
		end
	end

	local unit = which:gsub("^%l", string.upper)
	module:UpdateOptions(unit, force)
end
local SharedOptions = {
	enable = ACH:Toggle(L["Enable"], nil, 0),
	spacer1 = ACH:Spacer(1, 'full'),
	xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 }),
	yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
}

local function GetOptionsTable_AvgItemLevelGroup(which, groupName)
	local config = ACH:Group(L["Average Item Level"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args = CopyTable(SharedOptions)
	config.args.gearScore = ACH:Toggle(L["Show GearScore"], nil, 0)
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.color = ACH:Color(L["Color"], nil, 11)

	return config
end

local function GetOptionsTable_EnchantGroup(which, groupName)
	local config = ACH:Group(L["Enchants"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args = CopyTable(SharedOptions)
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, SideSlotGrowthDirection)
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, AllPoints) --! Change terminology to reference slot instead of frame?
	config.args.qualityColor = ACH:Toggle(L["Quality Color"], L["Use the same color as the quality color of the equipped item."], 10)
	config.args.color = ACH:Color(L["Color"], nil, 11, nil, nil, nil, nil, function() return E.db.wratharmory[which][groupName].qualityColor end)

	--* Main Hand Slot
	local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 10, nil, function(info) return actionSubGroup(info, which, groupName, 'MainHandSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'MainHandSlot', ...) end)
	config.args.MainHandSlot = MainHandSlot
	MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, C.Values.GrowthDirection)
	MainHandSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, C.Values.Anchors) --! Change terminology to reference slot instead of frame?

	--* Secondary Hand Slot
	local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 11, nil, function(info) return actionSubGroup(info, which, groupName, 'SecondaryHandSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'SecondaryHandSlot', ...) end)
	config.args.SecondaryHandSlot = SecondaryHandSlot
	SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, C.Values.GrowthDirection)
	SecondaryHandSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, C.Values.Anchors) --! Change terminology to reference slot instead of frame?

	--* Ranged Slot
	local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 12, nil, function(info) return actionSubGroup(info, which, groupName, 'RangedSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'RangedSlot', ...) end)
	config.args.RangedSlot = RangedSlot
	RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	RangedSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, C.Values.GrowthDirection)
	RangedSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, C.Values.Anchors) --! Change terminology to reference slot instead of frame?

	return config
end

local function GetOptionsTable_Gems(which, groupName)
	local config = ACH:Group(L["Gems"], nil, 10, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args = CopyTable(SharedOptions)
	config.args.size = ACH:Range(L["Size"], nil, 2, {min = 8, softMax = 75, max = 50, step = 1 })
	config.args.spacing = ACH:Range(L["Spacing"], nil, 3, {min = 0, softMax = 15, max = 100, step = 1 })

	--* Main Hand Slot
	local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 10, nil, function(info) return actionSubGroup(info, which, groupName, 'MainHandSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'MainHandSlot', ...) end)
	config.args.MainHandSlot = MainHandSlot
	MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	--* Secondary Hand Slot
	local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 11, nil, function(info) return actionSubGroup(info, which, groupName, 'SecondaryHandSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'SecondaryHandSlot', ...) end)
	config.args.SecondaryHandSlot = SecondaryHandSlot
	SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	--* Ranged Slot
	local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 12, nil, function(info) return actionSubGroup(info, which, groupName, 'RangedSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'RangedSlot', ...) end)
	config.args.RangedSlot = RangedSlot
	RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ItemLevelGroup(which, groupName)
	local config = ACH:Group(L["Equipment Item Levels"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args = CopyTable(SharedOptions)
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.qualityColor = ACH:Toggle(L["Quality Color"], L["Use the same color as the quality color of the equipped item."], 10)
	config.args.color = ACH:Color(L["Color"], nil, 11, nil, nil, nil, nil, function() return E.db.wratharmory[which][groupName].qualityColor end)

	return config
end

local function GetOptionsTable_WarningIndicator(which, groupName)
	local config = ACH:Group(L["Warning Indicator"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)

	return config
end

local function configTable()
	C = unpack(E.Config)
	local Armory = ACH:Group('|cFF16C3F2Wrath|rArmory', nil, 6, 'tab')
	E.Options.args.wratharmory = Armory

	--* Character Frame
	local Character = ACH:Group(L["Character"], nil, 0)
	Armory.args.character = Character
	Character.args.avgItemLevel = GetOptionsTable_AvgItemLevelGroup('character', 'avgItemLevel')
	Character.args.enchant = GetOptionsTable_EnchantGroup('character', 'enchant')
	Character.args.itemLevel = GetOptionsTable_ItemLevelGroup('character', 'itemLevel')
	Character.args.gems = GetOptionsTable_Gems('character', 'gems')
	Character.args.warningIndicator = GetOptionsTable_WarningIndicator('character', 'warningIndicator')

	--* Inspect Frame
    local Inspect = ACH:Group(L["Inspect"], nil, 1)
	Armory.args.inspect = Inspect
	Inspect.args.avgItemLevel = GetOptionsTable_AvgItemLevelGroup('inspect', 'avgItemLevel')
	Inspect.args.enchant = GetOptionsTable_EnchantGroup('inspect', 'enchant')
	Inspect.args.itemLevel = GetOptionsTable_ItemLevelGroup('inspect', 'itemLevel')
	Inspect.args.gems = GetOptionsTable_Gems('inspect', 'gems')
	Inspect.args.warningIndicator = GetOptionsTable_WarningIndicator('inspect', 'warningIndicator')
end

tinsert(module.Configs, configTable)
