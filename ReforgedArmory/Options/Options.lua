local RA, L, P = unpack(ReforgedArmory)
local ACH = RA.Libs.ACH

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

local Config = {
	Values = {
		GrowthDirection = {
			DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
			DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
			UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
			UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
			RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
			RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
			LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
			LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
		},
		FontFlags = ACH.FontValues,
		FontSize = { min = 8, max = 64, step = 1 },
		Roman = { 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX' }, -- 1 to 20
		AllPositions = { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' },
		EdgePositions = { LEFT = 'LEFT', RIGHT = 'RIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM' },
		SidePositions = { LEFT = 'LEFT', RIGHT = 'RIGHT' },
		TextPositions = { BOTTOMRIGHT = 'BOTTOMRIGHT', BOTTOMLEFT = 'BOTTOMLEFT', TOPRIGHT = 'TOPRIGHT', TOPLEFT = 'TOPLEFT', BOTTOM = 'BOTTOM', TOP = 'TOP' },
		AllPoints = { TOPLEFT = 'TOPLEFT', LEFT = 'LEFT', BOTTOMLEFT = 'BOTTOMLEFT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM', CENTER = 'CENTER' },
		Anchors = { TOPLEFT = 'TOPLEFT', LEFT = 'LEFT', BOTTOMLEFT = 'BOTTOMLEFT', RIGHT = 'RIGHT', TOPRIGHT = 'TOPRIGHT', BOTTOMRIGHT = 'BOTTOMRIGHT', TOP = 'TOP', BOTTOM = 'BOTTOM' },
		Strata = { BACKGROUND = 'BACKGROUND', LOW = 'LOW', MEDIUM = 'MEDIUM', HIGH = 'HIGH', DIALOG = 'DIALOG', TOOLTIP = 'TOOLTIP' },
		SmartAuraPositions = {
			DISABLED = L["Disable"],
			BUFFS_ON_DEBUFFS = L["Buffs on Debuffs"],
			DEBUFFS_ON_BUFFS = L["Debuffs on Buffs"],
			FLUID_BUFFS_ON_DEBUFFS = L["Fluid Buffs on Debuffs"],
			FLUID_DEBUFFS_ON_BUFFS = L["Fluid Debuffs on Buffs"],
		}
	}
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
	local force = groupName == 'gems' or groupName == 'warningIndicator' or groupName == 'avgItemLevel' or groupName == 'slotBackground'
	if info.type == 'color' then
		local color = RA.db[which][groupName][info[#info]]
		local r, g, b, a = ...
		if r then
			color.r, color.g, color.b, color.a = r, g, b, a
		else
			local d = P[which][groupName][info[#info]]
			return color.r, color.g, color.b, color.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if value ~= nil then
			RA.db[which][groupName][info[#info]] = value
		else
			return RA.db[which][groupName][info[#info]]
		end
	end

	local unit = which:gsub("^%l", string.upper)
	--! Temp disabled
	print('temp disabled call to UpdateOptions(unit, force)')
	-- module:UpdateOptions(unit, force)
end

local function actionSubGroup(info, which, groupName, subGroup, ...)
	local force = groupName == 'gems' or groupName == 'warningIndicator' or groupName == 'slotBackground'
	if info.type == 'color' then
		local color = RA.db[which][groupName][subGroup][info[#info]]
		local r, g, b, a = ...
		if r then
			color.r, color.g, color.b, color.a = r, g, b, a
		else
			local d = P[which][groupName][subGroup][info[#info]]
			return color.r, color.g, color.b, color.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if value ~= nil then
			RA.db[which][groupName][subGroup][info[#info]] = value
		else
			return RA.db[which][groupName][subGroup][info[#info]]
		end
	end

	local unit = which:gsub("^%l", string.upper)
	--! Temp disabled
	print('temp disabled call to UpdateOptions(unit, force)')
	-- module:UpdateOptions(unit, force)
end

local function disableCheck(info, which, groupName) if info and info[#info] == groupName then return false else return not RA.db[which][groupName].enable or not RA.db[which].enable end end

local function GetOptionsTable_AvgItemLevelGroup(which, groupName)
	local config = ACH:Group(L["Average Item Level"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end, function(info) return disableCheck(info, which, groupName) end)
	local unit = which:gsub('^%l', string.upper)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, function() return not RA.db[which].enable end)
	config.args.spacer1 = ACH:Spacer(1, 'full')

	config.args.text = ACH:Group(L["Text Options"], nil, 5, nil, function(info) print(actionSubGroup(info, which, groupName, 'text')) return actionSubGroup(info, which, groupName, 'text') end, function(info, ...) actionSubGroup(info, which, groupName, 'text', ...) end)
	config.args.text.inline = true
	config.args.text.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.text.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.text.args.fontSize = ACH:Range(L["Font Size"], nil, 4, Config.Values.FontSize)
	config.args.text.args.spacer = ACH:Spacer(5, 'full')
	config.args.text.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -5, max = 5, step = 1 })
	config.args.text.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -5, max = 5, step = 1 })
	config.args.text.args.color = ACH:Color(L["Color"], nil, 8)

	config.args.frame = ACH:Group(L["Frame Options"], nil, 11, nil, function(info) if info[#info] == 'attachTo' then print(actionSubGroup(info, which, groupName, 'frame')) DevTools_Dump(RA.AttachToObjects[unit]) end return actionSubGroup(info, which, groupName, 'frame') end, function(info, ...) actionSubGroup(info, which, groupName, 'frame', ...) end)
	config.args.frame.inline = true
	config.args.frame.args.attachTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 11, RA.AttachToObjects[which])
	config.args.frame.args.xOffset = ACH:Range(L["X-Offset"], nil, 12, { min = -300, max = 300, step = 1 })
	config.args.frame.args.yOffset = ACH:Range(L["Y-Offset"], nil, 13, { min = -300, max = 300, step = 1 })
	config.args.frame.args.spacer = ACH:Spacer(15, 'full')
	config.args.frame.args.showBGTexture = ACH:Toggle(L["Show Background"], nil, 16)
	config.args.frame.args.showLines = ACH:Toggle(L["Show Lines"], nil, 17)
	config.args.frame.args.color = ACH:Color(L["Color"], L["This sets the color of the lines.\n\n|cffFF3300Warning:|r |cffFFD100Colors will not be 1 to 1 from the color wheel to the texture as the texture has color itself. This may not be the case for future textures if added as options.|r"], 18)

	return config
end

local function GetOptionsTable_EnchantGroup(which, groupName)
	local config = ACH:Group(L["Enchants"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end, function(info) return disableCheck(info, which, groupName) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.enable.disabled = function() return not RA.db[which].enable end
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, Config.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 6, AllPoints) --! Change terminology to reference slot instead of frame?
	config.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 7, SideSlotGrowthDirection)
	config.args.spacer3 = ACH:Spacer(8, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 9, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 10, { min = -300, max = 300, step = 1 })
	config.args.spacer4 = ACH:Spacer(11, 'full')
	config.args.qualityColor = ACH:Toggle(L["Quality Color"], L["Use the same color as the quality color of the equipped item."], 12)
	config.args.color = ACH:Color(L["Color"], nil, 13, nil, nil, nil, nil, function() return RA.db[which][groupName].qualityColor end)

	--TODO: Move to a general section
	local EnchantID = ACH:Group(L["EnchantID Tooltip Info"], 'test', 20, nil, function(info) return actionSubGroup(info, which, groupName, 'enchantID') end, function(info, ...) actionSubGroup(info, which, groupName, 'enchantID', ...) end)
	config.args.enchantID = EnchantID
	EnchantID.inline = true
	EnchantID.args.enable = ACH:Toggle(L["Enable"], L["Displays the enchant id in the tooltip of gear that has an enchant id in the itemlink."], 0)
	EnchantID.args.missingOnly = ACH:Toggle(L["Missing Only"], L["Only show the enchant id if it is missing from the addon database."], 1, nil, nil, nil, nil, nil, function() return not RA.db[which][groupName].enchantID.enable or not RA.db[which][groupName].enable end)

	--* Main Hand Slot
	local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 30, nil, function(info) return actionSubGroup(info, which, groupName, 'MainHandSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'MainHandSlot', ...) end)
	config.args.MainHandSlot = MainHandSlot
	MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, Config.Values.GrowthDirection)
	MainHandSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, Config.Values.Anchors) --! Change terminology to reference slot instead of frame?

	--* Secondary Hand Slot
	local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 31, nil, function(info) return actionSubGroup(info, which, groupName, 'SecondaryHandSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'SecondaryHandSlot', ...) end)
	config.args.SecondaryHandSlot = SecondaryHandSlot
	SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, Config.Values.GrowthDirection)
	SecondaryHandSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, Config.Values.Anchors) --! Change terminology to reference slot instead of frame?

	--* Ranged Slot
	local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 32, nil, function(info) return actionSubGroup(info, which, groupName, 'RangedSlot') end, function(info, ...) actionSubGroup(info, which, groupName, 'RangedSlot', ...) end)
	config.args.RangedSlot = RangedSlot
	RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	RangedSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, Config.Values.GrowthDirection)
	RangedSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, Config.Values.Anchors) --! Change terminology to reference slot instead of frame?

	return config
end

local function GetOptionsTable_ExpandButton(which, groupName)
	local config = ACH:Group(L["Expand Button"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args.hide = ACH:Toggle(L["Hide"], nil, 0)
	config.args.autoExpand = ACH:Toggle(L["Auto Expand"], nil, 1)

	return config
end

local function GetOptionsTable_Gems(which, groupName)
	local config = ACH:Group(L["Gems"], nil, 10, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.size = ACH:Range(L["Size"], nil, 2, {min = 8, softMax = 75, max = 50, step = 1 })
	config.args.spacing = ACH:Range(L["Spacing"], nil, 3, {min = 0, softMax = 15, max = 100, step = 1 })
	config.args.spacer2 = ACH:Spacer(4, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

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
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, Config.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	config.args.spacer2 = ACH:Spacer(8, 'full')
	config.args.qualityColor = ACH:Toggle(L["Quality Color"], L["Use the same color as the quality color of the equipped item."], 10)
	config.args.color = ACH:Color(L["Color"], nil, 11, nil, nil, nil, nil, function() return RA.db[which][groupName].qualityColor end)

	return config
end

local function GetOptionsTable_LevelText(which, groupName)
	local config = ACH:Group(L["Level Text"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_FlyoutText(which, groupName)
	local config = ACH:Group(L["Flyout Text"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer1 = ACH:Spacer(1, 'full')
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, Config.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_NameText(which, groupName)
	local config = ACH:Group(L["Name Text"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	--TODO: Add option for font settings?

	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_SlotBackground(which, groupName)
	local config = ACH:Group(L["Slot Background"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end, nil, RA.Classic)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer = ACH:Spacer(1, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -25, max = 25, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -25, max = 25, step = 1 })
	config.args.warning = ACH:Group(L["Warning"], nil, 10, nil, function(info) return actionSubGroup(info, which, groupName, 'warning') end, function(info, ...) actionSubGroup(info, which, groupName, 'warning', ...) end, function() return not RA.db[which][groupName].enable end)
	config.args.warning.inline = true
	config.args.warning.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.warning.args.color = ACH:Color(L["Color"], nil, 5, nil, nil, nil, nil, function() return not RA.db[which][groupName].enable or not RA.db[which][groupName].warning.enable end)

	return config
end

local function GetOptionsTable_WarningIndicator(which, groupName)
	local config = ACH:Group(L["Warning Indicator"], nil, 5, 'tab', function(info) return actionGroup(info, which, groupName) end, function(info, ...) actionGroup(info, which, groupName, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)

	return config
end

local EnchantIDSelected = ''

local function HandleReplacement(value)
	local default = RA.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)]

	if (value and value ~= '') and default ~= value then
		RA.global.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] = value
	else
		RA.global.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] = nil
	end

	module:UpdateOptions(nil, true)
end

--* ReforgedArmory Options
local Options = ACH:Group(RA.Title, nil, 6, 'tab')
Options.args.logo = ACH:Description(nil, 0, nil, [[Interface\AddOns\ReforgedArmory\Media\Logos\ConfigLogo]], nil, 384, 192)
Options.args.version = ACH:Header(RA.Version, 1)

--* Character Frame
local Character = ACH:Group(L["Character"], nil, 0)
Options.args.character = Character
Character.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return RA.db.character.enable end, function(info, value) RA.db.character.enable = value --[[module:ToggleItemLevelInfo()]] end)
Character.args.avgItemLevel = GetOptionsTable_AvgItemLevelGroup('character', 'avgItemLevel')
Character.args.enchant = GetOptionsTable_EnchantGroup('character', 'enchant')
Character.args.expandButton = GetOptionsTable_ExpandButton('character', 'expandButton')
Character.args.gems = GetOptionsTable_Gems('character', 'gems')
Character.args.itemLevel = GetOptionsTable_ItemLevelGroup('character', 'itemLevel')
Character.args.nameText = GetOptionsTable_NameText('character', 'nameText')
Character.args.levelText = GetOptionsTable_LevelText('character', 'levelText')
Character.args.flyoutText = GetOptionsTable_FlyoutText('character', 'flyoutText')
Character.args.slotBackground = GetOptionsTable_SlotBackground('character', 'slotBackground')
Character.args.warningIndicator = GetOptionsTable_WarningIndicator('character', 'warningIndicator')

--* Inspect Frame
local Inspect = ACH:Group(L["Inspect"], nil, 1)
Options.args.inspect = Inspect
Inspect.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return RA.db.inspect.enable end, function(info, value) RA.db.inspect.enable = value --[[module:ToggleItemLevelInfo()]] end)
Inspect.args.avgItemLevel = GetOptionsTable_AvgItemLevelGroup('inspect', 'avgItemLevel')
Inspect.args.enchant = GetOptionsTable_EnchantGroup('inspect', 'enchant')
Inspect.args.gems = GetOptionsTable_Gems('inspect', 'gems')
Inspect.args.itemLevel = GetOptionsTable_ItemLevelGroup('inspect', 'itemLevel')
Inspect.args.levelText = GetOptionsTable_LevelText('inspect', 'levelText')
Inspect.args.slotBackground = GetOptionsTable_SlotBackground('inspect', 'slotBackground')
Inspect.args.warningIndicator = GetOptionsTable_WarningIndicator('inspect', 'warningIndicator')

--* Enchant String Replacement
-- ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden, func)
local StringReplacement = ACH:Group(L["Enchant Strings"], nil, 2, nil, nil, nil, nil, RA.Retail)
Options.args.stringReplacement = StringReplacement
StringReplacement.args.header = ACH:Header(L["Direct Enchant String Replacement"], 21)
StringReplacement.args.desc = ACH:Description(L["This is the |cff00fc00recommended|r method to keep performance impact to a minimum.\nEnter the |cffFFD100EnchantID|r in the |cffFFD100EnchantID|r input box below. You can obtain the |cffFFD100EnchantID|r in the tooltip of the item."], 22, 'medium')
StringReplacement.args.selectID = ACH:Input(L["EnchantID"], L["Mouseover an item that has an enchant to view the id in the tooltip. \n|cffFFD100Hint:|r If you do not see it listed, make sure you have the option enabled and that the item even has the enchant on it."], 23, nil, nil, function() return EnchantIDSelected--[[get]] end, function(info, value) EnchantIDSelected = value  --[[set func]] end, nil, nil, --[[function(_, value) if value and E.Libs.GetEnchantList.LibGetEnchantDB[tonumber(value)] then return true else return false end end]] nil)
StringReplacement.args.string = ACH:Input(function() return EnchantIDSelected and EnchantIDSelected ~= '' and (RA.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)] and format(L["|cFFCA3C3CDefault String|r: |cff00fc00%s|r"], RA.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)]) or format('|cffFF3300%s|r', L["Enchant Not Found!"])) or L["No EnchantID Selected"] end, function() return EnchantIDSelected and EnchantIDSelected ~= '' and format(L["|cFFCA3C3CEnchantID:|r |cffFFD100%s|r|n|cFFCA3C3CModified String:|r |cff00fc00%s|r"], EnchantIDSelected, RA.global.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] or L["Not Modified"]) or '' end, 24, nil, 'full', function() return EnchantIDSelected and EnchantIDSelected ~= '' and (RA.global.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] or RA.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)]) or nil end, function(_, value) HandleReplacement(value) end, function() if not EnchantIDSelected or EnchantIDSelected == '' or not RA.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)] then return true end return false end, nil, nil)

RA.Options = Options

function RA:GetOptions()
	if RA:IsAddOnEnabled('ElvUI') then
		local E = unpack(ElvUI)
		LibStub('RepoocReforged-1.0'):LoadMainCategory()

		--* Repooc Reforged Plugin section
		local rrp = E.Options.args.rrp
		if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end

		E.Options.args.rrp.args.reforgedarmory = RA.Options
		--* Maybe implement this for stuff that may need a reload.
		-- hooksecurefunc(JI.Libs.ACD, 'CloseAll', function()
		-- 	if JI.NeedReload then
		-- 		_G.ElvUI[1]:StaticPopup_Show('PRIVATE_RL')
		-- 	end
		-- end)
	end
end
