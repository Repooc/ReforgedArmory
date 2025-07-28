local E, L, _, P = unpack(ElvUI)
local module = E:GetModule('ElvUI_CataArmory')
local RRP = LibStub('RepoocReforged-1.0'):LoadMainCategory()
local ACH = E.Libs.ACH
local C

local MIN_EDGE_OFFSET = -10
local MAX_EDGE_OFFSET = 10
local MIN_BAR_OFFSET = -15
local MAX_BAR_OFFSET = 15

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

local function actionPath(info, which, groupName, subPath, ...)
	local force = groupName == 'gems' or groupName == 'warningIndicator' or groupName == 'avgItemLevel' or groupName == 'slotBackground' or groupName == 'durability'

	-- Split the path into keys
	local path = {strsplit(',', subPath or '')}
	local db = E.db.cataarmory[which][groupName]
	local defaultDB = P.cataarmory[which][groupName]

	-- Drill down into the DB using the subPath
	if path and path ~= '' then
		for i = 1, #path do
			if path[i] ~= '' then
				db = db[path[i]]
				defaultDB = defaultDB[path[i]]
			end
		end
	end

	local key = info[#info]

	if info.type == 'color' then
		local color = db[key]
		local r, g, b, a = ...
		if r then
			color.r, color.g, color.b, color.a = r, g, b, a
		else
			local d = defaultDB[key]
			return color.r, color.g, color.b, color.a, d.r, d.g, d.b, d.a
		end
	else
		local value = ...
		if value ~= nil then
			db[key] = value
		else
			return db[key]
		end
	end

	local unit = which:gsub('^%l', string.upper)
	module:UpdateOptions(unit, force)
end

local SharedOptions = {
	enable = ACH:Toggle(L["Enable"], nil, 0),
	spacer1 = ACH:Spacer(1, 'full'),
	xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 }),
	yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
}

local function disableCheck(info, which, groupName) if info and info[#info] == groupName then return false else return not E.db.cataarmory[which][groupName].enable or not E.db.cataarmory[which].enable end end

local function GetOptionsTable_AvgItemLevelGroup(which, groupName)

	local config = ACH:Group(L["Average Item Level"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end, function(info) return disableCheck(info, which, groupName) end)
	local unit = which:gsub('^%l', string.upper)

	config.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, nil, nil, function() return not E.db.cataarmory[which].enable end)
	config.args.spacer1 = ACH:Spacer(1, 'full')

	config.args.text = ACH:Group(L["Text Options"], nil, 5, nil, function(info) return actionPath(info, which, groupName, 'text') end, function(info, ...) actionPath(info, which, groupName, 'text', ...) end)
	config.args.text.inline = true
	config.args.text.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.text.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.text.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.text.args.spacer = ACH:Spacer(5, 'full')
	config.args.text.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -5, max = 5, step = 1 })
	config.args.text.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -5, max = 5, step = 1 })
	config.args.text.args.color = ACH:Color(L["Color"], nil, 8)

	config.args.frame = ACH:Group(L["Frame Options"], nil, 11, nil, function(info) return actionPath(info, which, groupName, 'frame') end, function(info, ...) actionPath(info, which, groupName, 'frame', ...) end)
	config.args.frame.inline = true
	config.args.frame.args.attachTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 11, module.AttachToObjects[unit])
	config.args.frame.args.xOffset = ACH:Range(L["X-Offset"], nil, 12, { min = -300, max = 300, step = 1 })
	config.args.frame.args.yOffset = ACH:Range(L["Y-Offset"], nil, 13, { min = -300, max = 300, step = 1 })
	config.args.frame.args.spacer = ACH:Spacer(15, 'full')
	config.args.frame.args.showBGTexture = ACH:Toggle(L["Show Background"], nil, 16)
	config.args.frame.args.showLines = ACH:Toggle(L["Show Lines"], nil, 17)
	config.args.frame.args.color = ACH:Color(L["Color"], L["This sets the color of the lines.\n\n|cffFF3300Warning:|r |cffFFD100Colors will not be 1 to 1 from the color wheel to the texture as the texture has color itself. This may not be the case for future textures if added as options.|r"], 18)

	return config
end

local function GetOptionsTable_EnchantGroup(which, groupName)
	local config = ACH:Group(L["Enchants"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end, function(info) return disableCheck(info, which, groupName) end)
	config.args = CopyTable(SharedOptions)
	config.args.enable.disabled = function() return not E.db.cataarmory[which].enable end
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, SideSlotGrowthDirection)
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, AllPoints) --! Change terminology to reference slot instead of frame?
	config.args.qualityColor = ACH:Toggle(L["Quality Color"], L["Use the same color as the quality color of the equipped item."], 10)
	config.args.color = ACH:Color(L["Color"], nil, 11, nil, nil, nil, nil, function() return E.db.cataarmory[which][groupName].qualityColor end)

	local EnchantID = ACH:Group(L["EnchantID Tooltip Info"], 'test', 20, nil, function(info) return actionPath(info, which, groupName, 'enchantID') end, function(info, ...) actionPath(info, which, groupName, 'enchantID', ...) end)
	config.args.enchantID = EnchantID
	EnchantID.inline = true
	EnchantID.args.enable = ACH:Toggle(L["Enable"], L["Displays the enchant id in the tooltip of gear that has an enchant id in the itemlink."], 0)
	EnchantID.args.missingOnly = ACH:Toggle(L["Missing Only"], L["Only show the enchant id if it is missing from the addon database."], 1, nil, nil, nil, nil, nil, function() return not E.db.cataarmory[which][groupName].enchantID.enable or not E.db.cataarmory[which][groupName].enable end)

	--* Main Hand Slot
	local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 30, nil, function(info) return actionPath(info, which, groupName, 'MainHandSlot') end, function(info, ...) actionPath(info, which, groupName, 'MainHandSlot', ...) end)
	config.args.MainHandSlot = MainHandSlot
	MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, C.Values.GrowthDirection)
	MainHandSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, C.Values.Anchors) --! Change terminology to reference slot instead of frame?

	--* Secondary Hand Slot
	local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 31, nil, function(info) return actionPath(info, which, groupName, 'SecondaryHandSlot') end, function(info, ...) actionPath(info, which, groupName, 'SecondaryHandSlot', ...) end)
	config.args.SecondaryHandSlot = SecondaryHandSlot
	SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, C.Values.GrowthDirection)
	SecondaryHandSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, C.Values.Anchors) --! Change terminology to reference slot instead of frame?

	--* Ranged Slot
	local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 32, nil, function(info) return actionPath(info, which, groupName, 'RangedSlot') end, function(info, ...) actionPath(info, which, groupName, 'RangedSlot', ...) end)
	config.args.RangedSlot = RangedSlot
	RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })
	RangedSlot.args.growthDirection = ACH:Select(L["Growth Direction"], nil, 8, C.Values.GrowthDirection)
	RangedSlot.args.anchorPoint = ACH:Select(L["Anchor Point"], L["What point to anchor to the frame you set to attach to."], 9, C.Values.Anchors) --! Change terminology to reference slot instead of frame?

	return config
end

local function GetOptionsTable_ExpandButton(which, groupName)
	local config = ACH:Group(L["Expand Button"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args.hide = ACH:Toggle(L["Hide"], nil, 0)
	config.args.autoExpand = ACH:Toggle(L["Auto Expand"], nil, 1)

	return config
end

local function GetOptionsTable_Gems(which, groupName)
	local config = ACH:Group(L["Gems"], nil, 10, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args = CopyTable(SharedOptions)
	config.args.size = ACH:Range(L["Size"], nil, 2, {min = 8, softMax = 75, max = 50, step = 1 })
	config.args.spacing = ACH:Range(L["Spacing"], nil, 3, {min = 0, softMax = 15, max = 100, step = 1 })

	--* Main Hand Slot
	local MainHandSlot = ACH:Group(L["Main Hand Slot"], nil, 10, nil, function(info) return actionPath(info, which, groupName, 'MainHandSlot') end, function(info, ...) actionPath(info, which, groupName, 'MainHandSlot', ...) end)
	config.args.MainHandSlot = MainHandSlot
	MainHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	MainHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	--* Secondary Hand Slot
	local SecondaryHandSlot = ACH:Group(L["Secondary Hand Slot"], nil, 11, nil, function(info) return actionPath(info, which, groupName, 'SecondaryHandSlot') end, function(info, ...) actionPath(info, which, groupName, 'SecondaryHandSlot', ...) end)
	config.args.SecondaryHandSlot = SecondaryHandSlot
	SecondaryHandSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	SecondaryHandSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	--* Ranged Slot
	local RangedSlot = ACH:Group(L["Ranged Slot"], nil, 12, nil, function(info) return actionPath(info, which, groupName, 'RangedSlot') end, function(info, ...) actionPath(info, which, groupName, 'RangedSlot', ...) end)
	config.args.RangedSlot = RangedSlot
	RangedSlot.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	RangedSlot.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function GetOptionsTable_ItemLevelGroup(which, groupName)
	local config = ACH:Group(L["Item Level"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args = CopyTable(SharedOptions)
	config.args.font = ACH:SharedMediaFont(L["Font"], nil, 2)
	config.args.fontOutline = ACH:FontFlags(L["Font Outline"], nil, 3)
	config.args.fontSize = ACH:Range(L["Font Size"], nil, 4, C.Values.FontSize)
	config.args.spacer2 = ACH:Spacer(5, 'full')
	config.args.qualityColor = ACH:Toggle(L["Quality Color"], L["Use the same color as the quality color of the equipped item."], 10)
	config.args.color = ACH:Color(L["Color"], nil, 11, nil, nil, nil, nil, function() return E.db.cataarmory[which][groupName].qualityColor end)

	return config
end

local function GetOptionsTable_LevelText(which, groupName)
	local config = ACH:Group(L["Level Text"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args = CopyTable(SharedOptions)

	return config
end

local function GetOptionsTable_SlotBackground(which, groupName)
	local config = ACH:Group(L["Slot Background"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.spacer = ACH:Spacer(1, 'full')
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 2, { min = -25, max = 25, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 3, { min = -25, max = 25, step = 1 })
	config.args.warning = ACH:Group(L["Warning"], nil, 10, nil, function(info) return actionPath(info, which, groupName, 'warning') end, function(info, ...) actionPath(info, which, groupName, 'warning', ...) end, function() return not E.db.cataarmory[which][groupName].enable end)
	config.args.warning.inline = true
	config.args.warning.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.warning.args.color = ACH:Color(L["Color"], nil, 5, nil, nil, nil, nil, function() return not E.db.cataarmory[which][groupName].enable or not E.db.cataarmory[which][groupName].warning.enable end)

	return config
end

local function GetOptionsTable_DurabilityGroup(which, groupName)
	local config = ACH:Group(L["Durability"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)

	local bar = ACH:Group(L["Bar"], nil, 5, nil, function(info) return actionPath(info, which, groupName, 'bar') end, function(info, ...) actionPath(info, which, groupName, 'bar', ...) end, function() return not E.db.cataarmory[which][groupName].enable end)
	config.args.bar = bar
	bar.args.position = ACH:Select(L["Position"], nil, 1, C.Values.EdgePositions)
	bar.args.mouseover = ACH:Toggle(L["Mouseover"], nil, 1)
	bar.args.edgeOffset = ACH:Range(L["Edge Offset"], L["This will allow you to slightly adjust the length of the durability bar to line up better with your layout."], 1, { min = MIN_EDGE_OFFSET, max = MAX_EDGE_OFFSET, step = 1 })
	bar.args.offset = ACH:Range(L["Offset"], L["This will allow you to slightly adjust the placement of the durability bar along the equipment slot."], 1, { min = MIN_BAR_OFFSET, max = MAX_BAR_OFFSET, step = 1 })

	-- ACH:Range(name, desc, order, values, width, get, set, disabled, hidden)

	local text = ACH:Group(L["Text"], nil, 5, nil, function(info) return actionPath(info, which, groupName, 'text') end, function(info, ...) actionPath(info, which, groupName, 'text', ...) end, function() return not E.db.cataarmory[which][groupName].enable end)
	config.args.text = text

	return config
end

local function GetOptionsTable_WarningIndicator(which, groupName)
	local config = ACH:Group(L["Warning Indicator"], nil, 5, 'tab', function(info) return actionPath(info, which, groupName) end, function(info, ...) actionPath(info, which, groupName, nil, ...) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)

	return config
end

local EnchantIDSelected = ''

local function HandleReplacement(value)
	local default = E.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)]

	if (value and value ~= '') and default ~= value then
		E.global.cataarmory.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] = value
	else
		E.global.cataarmory.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] = nil
	end

	module:UpdateOptions(nil, true)
end

local function configTable()
	C = unpack(E.Config)
	--* Repooc Reforged Plugin section
	local rrp = E.Options.args.rrp
	if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end

	local Armory = ACH:Group(module.Title, nil, 6, 'tab')
	rrp.args.cataarmory = Armory

	--* Character Frame
	local Character = ACH:Group(L["Character"], nil, 0)
	Armory.args.character = Character
	Character.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return E.db.cataarmory.character.enable end, function(info, value) E.db.cataarmory.character.enable = value module:ToggleItemLevelInfo() end)
	Character.args.avgItemLevel = GetOptionsTable_AvgItemLevelGroup('character', 'avgItemLevel')
	Character.args.durability = GetOptionsTable_DurabilityGroup('character', 'durability')
	Character.args.enchant = GetOptionsTable_EnchantGroup('character', 'enchant')
	Character.args.expandButton = GetOptionsTable_ExpandButton('character', 'expandButton')
	Character.args.gems = GetOptionsTable_Gems('character', 'gems')
	Character.args.itemLevel = GetOptionsTable_ItemLevelGroup('character', 'itemLevel')
	Character.args.levelText = GetOptionsTable_LevelText('character', 'levelText')
	Character.args.slotBackground = GetOptionsTable_SlotBackground('character', 'slotBackground')
	Character.args.warningIndicator = GetOptionsTable_WarningIndicator('character', 'warningIndicator')

	--* Inspect Frame
    local Inspect = ACH:Group(L["Inspect"], nil, 1)
	Armory.args.inspect = Inspect
	Inspect.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return E.db.cataarmory.inspect.enable end, function(info, value) E.db.cataarmory.inspect.enable = value module:ToggleItemLevelInfo() end)
	Inspect.args.avgItemLevel = GetOptionsTable_AvgItemLevelGroup('inspect', 'avgItemLevel')
	Inspect.args.enchant = GetOptionsTable_EnchantGroup('inspect', 'enchant')
	Inspect.args.gems = GetOptionsTable_Gems('inspect', 'gems')
	Inspect.args.itemLevel = GetOptionsTable_ItemLevelGroup('inspect', 'itemLevel')
	Inspect.args.levelText = GetOptionsTable_LevelText('inspect', 'levelText')
	Inspect.args.slotBackground = GetOptionsTable_SlotBackground('inspect', 'slotBackground')
	Inspect.args.warningIndicator = GetOptionsTable_WarningIndicator('inspect', 'warningIndicator')

	--* Enchant String Replacement
	local StringReplacement = ACH:Group(L["Enchant Strings"], nil, 2)
	Armory.args.stringReplacement = StringReplacement
	StringReplacement.args.header3 = ACH:Header(L["Direct Enchant String Replacement"], 21)
	StringReplacement.args.desc = ACH:Description(L["This is the |cff00fc00recommended|r method to keep performance impact to a minimum.\nEnter the |cffFFD100EnchantID|r in the |cffFFD100EnchantID|r input box below. You can obtain the |cffFFD100EnchantID|r in the tooltip of the item."], 22, 'medium')
	StringReplacement.args.selectID = ACH:Input(L["EnchantID"], L["Mouseover an item that has an enchant to view the id in the tooltip. \n|cffFFD100Hint:|r If you do not see it listed, make sure you have the option enabled and that the item even has the enchant on it."], 23, nil, nil, function() return EnchantIDSelected--[[get]] end, function(info, value) EnchantIDSelected = value  --[[set func]] end, nil, nil, --[[function(_, value) if value and E.Libs.GetEnchantList.LibGetEnchantDB[tonumber(value)] then return true else return false end end]] nil)
	StringReplacement.args.string = ACH:Input(function() return EnchantIDSelected and EnchantIDSelected ~= '' and format(L["|cFFCA3C3CDefault String|r: |cff00fc00%s|r"], E.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)]) or L["No EnchantID Selected"] end, function() return EnchantIDSelected and EnchantIDSelected ~= '' and format(L["|cFFCA3C3CEnchantID:|r |cffFFD100%s|r|n|cFFCA3C3CModified String:|r |cff00fc00%s|r"], EnchantIDSelected, E.global.cataarmory.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] or L["Not Modified"]) or '' end, 24, nil, 'full', function() return EnchantIDSelected and EnchantIDSelected ~= '' and (E.global.cataarmory.enchantStrings.UserReplaced[tonumber(EnchantIDSelected)] or E.Libs.GetEnchantList.LibGetEnchantDB[tonumber(EnchantIDSelected)]) or nil end, function(_, value) HandleReplacement(value) end, function() if not EnchantIDSelected or EnchantIDSelected == '' then return true end return false end, nil, nil)
end

tinsert(module.Configs, configTable)
