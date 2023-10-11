local E, L = unpack(ElvUI)
local module = E:GetModule('ElvUI_WrathArmory')
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM
local LCS = E.Libs.LCS

local values = {
	SIDE_SLOTS_ANCHORPOINTS = {
		BOTTOM = 'BOTTOM',
		BOTTOMOUTSIDE = 'BOTTOMLEFT',
		BOTTOMINSIDE = 'BOTTOMRIGHT',
		CENTER = 'CENTER',
		OUTSIDE = 'LEFT',
		INSIDE = 'RIGHT',
		TOP = 'TOP',
		TOPOUTSIDE = 'TOPLEFT',
		TOPINSIDE = 'TOPRIGHT',
	},
	MIRROR_ANCHORPOINT = {
		BOTTOM = 'BOTTOM',
		BOTTOMLEFT = 'BOTTOMRIGHT',
		BOTTOMRIGHT = 'BOTTOMLEFT',
		CENTER = 'CENTER',
		LEFT = 'RIGHT',
		RIGHT = 'LEFT',
		TOP = 'TOP',
		TOPLEFT = 'TOPRIGHT',
		TOPRIGHT = 'TOPLEFT',
	},
	SIDE_SLOTS_DIRECTION_TO_POINT = {
		LEFT = {
			DOWN_INSIDE = 'TOPLEFT',
			DOWN_OUTSIDE = 'TOPRIGHT',
			UP_INSIDE = 'BOTTOMLEFT',
			UP_OUTSIDE = 'BOTTOMRIGHT',
			INSIDE_DOWN = 'TOPLEFT',
			INSIDE_UP = 'BOTTOMLEFT',
			OUTSIDE_DOWN = 'TOPRIGHT',
			OUTSIDE_UP = 'BOTTOMRIGHT',
		},
		RIGHT = {
			DOWN_INSIDE = 'TOPRIGHT',
			DOWN_OUTSIDE = 'TOPLEFT',
			UP_INSIDE = 'BOTTOMRIGHT',
			UP_OUTSIDE = 'BOTTOMLEFT',
			INSIDE_DOWN = 'TOPRIGHT',
			INSIDE_UP = 'BOTTOMRIGHT',
			OUTSIDE_DOWN = 'TOPLEFT',
			OUTSIDE_UP = 'BOTTOMLEFT',
		}
	},
	DIRECTION_TO_POINT = {
		DOWN_RIGHT = 'TOPLEFT',
		DOWN_LEFT = 'TOPRIGHT',
		UP_RIGHT = 'BOTTOMLEFT',
		UP_LEFT = 'BOTTOMRIGHT',
		RIGHT_DOWN = 'TOPLEFT',
		RIGHT_UP = 'BOTTOMLEFT',
		LEFT_DOWN = 'TOPRIGHT',
		LEFT_UP = 'BOTTOMRIGHT',
	}
}



local whileOpenEvents = {
	UPDATE_INVENTORY_DURABILITY = true,
}

function module:CreateGemTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	texture:Point(point, (gemStep == 1 and slot) or slot['textureSlot'..prevGem], relativePoint, (gemStep == 1 and x) or spacing, (gemStep == 1 and x) or y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, (gemStep == 1 and slot) or slot['textureSlotBackdrop'..prevGem])
	backdrop:SetTemplate(nil, nil, true)
	backdrop:SetBackdropColor(0,0,0,0)
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function module:GetGemPoints(id, db)
	if not id or not db then return end
	local x, y, spacing = db.gems.xOffset, db.gems.yOffset, db.gems.spacing
	local mhX, mhY = db.gems.MainHandSlot.xOffset, db.gems.MainHandSlot.yOffset
	local ohX, ohY = db.gems.SecondaryHandSlot.xOffset, db.gems.SecondaryHandSlot.yOffset
	local rX, rY = db.gems.RangedSlot.xOffset, db.gems.RangedSlot.yOffset

	if id <= 5 or (id == 9 or id == 15) then						--* Left Side
		return 'BOTTOMLEFT', 'BOTTOMRIGHT', x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then	--* Right Side
		return 'BOTTOMRIGHT', 'BOTTOMLEFT', -x, y, -spacing
	elseif id == 16 then											--* MainHandSlot
		return 'BOTTOMRIGHT', 'BOTTOMLEFT', mhX, mhY, -spacing
	elseif id == 17 then											--* SecondaryHandSlot
		return 'BOTTOMRIGHT', 'TOPRIGHT', ohX, ohY, -spacing
	else															--* RangedSlot
		return 'BOTTOMLEFT', 'BOTTOMRIGHT', rX, rY, spacing
	end
end

function module:GetWarningPoints(id, db)
	if not id or not db then return end
	if id <= 5 or (id == 9 or id == 15) then						--* Left Side
		return 'TOPRIGHT', 'TOPLEFT', 'BOTTOMRIGHT', 'BOTTOMLEFT', 8, 0, E.Border, 0, -E.Border, 0
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then	--* Right Side
		return 'TOPLEFT', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOMRIGHT', 8, 0, E.Border, 0, -E.Border, 0
	elseif id == 16 then											--* MainHandSlot
		return 'TOPLEFT', 'BOTTOMLEFT', 'TOPRIGHT', 'BOTTOMRIGHT', 8, 0, 0, 0, 0, 0
	elseif id == 17 then											--* SecondaryHandSlot
		return 'TOPLEFT', 'BOTTOMLEFT', 'TOPRIGHT', 'BOTTOMRIGHT', 8, 0, 0, 0, 0, 0
	else															--* RangedSlot
		return 'TOPLEFT', 'BOTTOMLEFT', 'TOPRIGHT', 'BOTTOMRIGHT', 8, 0, 0, 0, 0, 0
	end
end

function module:GetEnchantPoints(id, db)
	if not id or not db then return end
	local x, y = db.enchant.xOffset, db.enchant.yOffset
	local spacing = db.enchant.spacing or 0

	local MainHandSlot = db.enchant.MainHandSlot
	local SecondaryHandSlot = db.enchant.SecondaryHandSlot
	local RangedSlot = db.enchant.RangedSlot

	if id <= 5 or (id == 9 or id == 15) then						--* Left Side
		return values.SIDE_SLOTS_DIRECTION_TO_POINT['LEFT'][db.enchant.growthDirection], values.SIDE_SLOTS_ANCHORPOINTS[db.enchant.anchorPoint], x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then	--* Right Side
		return values.SIDE_SLOTS_DIRECTION_TO_POINT['RIGHT'][db.enchant.growthDirection], values.MIRROR_ANCHORPOINT[values.SIDE_SLOTS_ANCHORPOINTS[db.enchant.anchorPoint]], -x, y, -spacing
	elseif id == 16 then											--* MainHandSlot
		return values.DIRECTION_TO_POINT[MainHandSlot.growthDirection], MainHandSlot.anchorPoint, MainHandSlot.xOffset, MainHandSlot.yOffset, -spacing
	elseif id == 17 then											--* SecondaryHandSlot
		return values.DIRECTION_TO_POINT[SecondaryHandSlot.growthDirection], SecondaryHandSlot.anchorPoint, SecondaryHandSlot.xOffset, SecondaryHandSlot.yOffset, -spacing
	else															--* RangedSlot
		return values.DIRECTION_TO_POINT[RangedSlot.growthDirection], RangedSlot.anchorPoint, RangedSlot.xOffset, RangedSlot.yOffset, spacing
	end
end

function module:UpdateInspectInfo(_, arg1)
	E:Delay(0.75, function()
		if _G.InspectFrame and _G.InspectFrame:IsVisible() then
			module:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
		end
	end)
	module:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
	if _G.InspectFrame and _G.InspectFrame.ItemLevelText then
		_G.InspectFrame.ItemLevelText:FontTemplate(LSM:Fetch('font', E.db.wratharmory.inspect.avgItemLevel.font), E.db.wratharmory.inspect.avgItemLevel.fontSize, E.db.wratharmory.inspect.avgItemLevel.fontOutline)
	end
end

function module:UpdateCharacterInfo(event)
	if (not E.db.wratharmory.character.enable)
	or (whileOpenEvents[event] and not _G.CharacterFrame:IsShown()) then return end

	module:UpdatePageInfo(_G.CharacterFrame, 'Character')
end

function module:UpdateCharacterItemLevel()
	module:UpdateAverageString(_G.CharacterFrame, 'Character')
end

function module:ClearPageInfo(frame, which)
	if not frame or not which then return end
	frame.ItemLevelText:SetText('')

	for slot in pairs(module.GearList) do
		local inspectItem = _G[which..slot]

		inspectItem.enchantText:SetText('')
		inspectItem.iLvlText:SetText('')

		for y = 1, 10 do
		inspectItem['textureSlot'..y]:SetTexture()
		inspectItem['textureSlotBackdrop'..y]:Hide()
		end
	end
end

function module:ToggleItemLevelInfo(setupCharacterPage)
	if setupCharacterPage then
		module:CreateSlotStrings(_G.CharacterFrame, 'Character')
	end

	if E.db.wratharmory.character.enable then
		module:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'UpdateCharacterInfo')
		module:RegisterEvent('UPDATE_INVENTORY_DURABILITY', 'UpdateCharacterInfo')
		module:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE', 'UpdateCharacterItemLevel')

		if not _G.CharacterFrame.CharacterInfoHooked then
			_G.CharacterFrame:HookScript('OnShow', function()
				module.UpdateCharacterInfo()
			end)

			_G.CharacterFrame.CharacterInfoHooked = true
		end

		if not setupCharacterPage then
			module:UpdateCharacterInfo()
		end
	else
		module:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
		module:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
		module:UnregisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')

		module:ClearPageInfo(_G.CharacterFrame, 'Character')
	end

	if E.db.wratharmory.inspect.enable then
		module:RegisterEvent('INSPECT_READY', 'UpdateInspectInfo')
	else
		module:UnregisterEvent('INSPECT_READY')
		module:ClearPageInfo(_G.InspectFrame, 'Inspect')
	end
end

function module:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
	iLevelDB[i] = slotInfo.iLvl
	local frame = _G[which..'Frame']
	local unit = (which == 'Character' and 'player') or frame.unit

	local itemLink = GetInventoryItemLink(unit, i)
	local db = E.db.wratharmory[string.lower(which)]
	local missingBuckle, missingGem, missingEnchant, warningMsg = false, false, false, ''
	local slotName = inspectItem:GetName():gsub('Character', ''):gsub('Inspect', '')
	local canEnchant = module.GearList[slotName].canEnchant
	do
		local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
		inspectItem.enchantText:ClearAllPoints()
		inspectItem.enchantText:Point(point, inspectItem, relativePoint, x, y)
		inspectItem.enchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)

		local text = slotInfo.enchantTextShort
		if itemLink then
			if text == '' and canEnchant then
				missingEnchant = true
				warningMsg = strjoin('', warningMsg, '|cffff0000', L["Not Enchanted"], '|r\n')
			end

			if #slotInfo.emptySockets > 0 then
				missingGem = true
				warningMsg = strjoin('', warningMsg, '|cffff0000', L["Not Fully Gemmed"], '|r\n')
			end
			if slotInfo.missingBeltBuckle then
				missingBuckle = true
				warningMsg = strjoin('', warningMsg, '|cffff0000', L["Missing Belt Buckle"], '|r\n')
			end
			inspectItem.WrathArmory_Warning.Reason = warningMsg
		end
		inspectItem.WrathArmory_Warning:SetShown(db.warningIndicator.enable and (missingEnchant or missingGem or missingBuckle))
		inspectItem.enchantText:SetText(text)
		inspectItem.enchantText:SetShown(db.enchant.enable)
		local enchantTextColor = (db.enchant.qualityColor and slotInfo.itemQualityColors) or db.enchant.color
		if enchantTextColor and next(enchantTextColor) then
			inspectItem.enchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
		end
	end

	inspectItem.iLvlText:ClearAllPoints()
	inspectItem.iLvlText:Point('BOTTOM', inspectItem, db.itemLevel.xOffset, db.itemLevel.yOffset)
	inspectItem.iLvlText:FontTemplate(LSM:Fetch('font', db.itemLevel.font), db.itemLevel.fontSize, db.itemLevel.fontOutline)
	inspectItem.iLvlText:SetText(slotInfo.iLvl)
	inspectItem.iLvlText:SetShown(db.itemLevel.enable)
	local iLvlTextColor = (db.itemLevel.qualityColor and slotInfo.itemQualityColors) or db.itemLevel.color
	if iLvlTextColor and next(iLvlTextColor) then
		inspectItem.iLvlText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
	end

	if which == 'Inspect' and unit then
		local quality = GetInventoryItemQuality(unit, i)
		if quality and quality > 1 then
			local r, g, b = GetItemQualityColor(quality)
			inspectItem.backdrop:SetBackdropBorderColor(r, g, b, 1)
		else
			inspectItem.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	do
		local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
		local gemStep = 1
		for index = 1, 5 do
			local texture = inspectItem['textureSlot'..index]
			texture:Size(db.gems.size)
			texture:ClearAllPoints()
			texture:Point(point, (index == 1 and inspectItem) or inspectItem['textureSlot'..(index-1)], relativePoint, index == 1 and x or spacing, index == 1 and y or 0)

			local backdrop = inspectItem['textureSlotBackdrop'..index]
			local gem = slotInfo.gems and slotInfo.gems[gemStep]
			if gem then
				texture:SetTexture(gem)
				backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				backdrop:Show()

				texture:SetShown(db.gems.enable)
				backdrop:SetShown(db.gems.enable)

				gemStep = gemStep + 1
			else
				texture:SetTexture()
				backdrop:Hide()
			end
		end
	end
end

local ARMOR_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
function module:CalculateAverageItemLevel(iLevelDB, unit)
	--* From ElvUI, needs some tlc and be adpated a bit better
	local spec = LCS.GetSpecialization()

	local isOK, total, link = true, 0

	if not spec or spec == 0 then
		isOK = false
	end

	-- Armor
	for _, id in next, ARMOR_SLOTS do
		link = GetInventoryItemLink(unit, id)
		if link then
			local cur = iLevelDB[id]
			if cur and cur > 0 then
				total = total + cur
			end
		elseif GetInventoryItemTexture(unit, id) then
			isOK = false
		end
	end

	-- Main hand
	local mainItemLevel, mainQuality, mainItemSubClass, _ = 0
	link = GetInventoryItemLink(unit, 16)
	if link then
		mainItemLevel = iLevelDB[16]
		_, _, mainQuality, _, _, _, _, _, _, _, _, _, mainItemSubClass = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 16) then
		isOK = false
	end

	-- Off hand
	local offItemLevel, offEquipLoc = 0
	link = GetInventoryItemLink(unit, 17)
	if link then
		offItemLevel = iLevelDB[17]
		_, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 17) then
		isOK = false
	end

	if mainItemLevel and offItemLevel then
		if mainQuality == 6 or (not offEquipLoc ~= mainItemSubClass and spec ~= 72) then
			mainItemLevel = max(mainItemLevel, offItemLevel)
			total = total + mainItemLevel * 2
		else
			total = total + mainItemLevel + offItemLevel
		end
	end

	-- at the beginning of an arena match no info might be available,
	-- so despite having equipped gear a person may appear naked
	if total == 0 then
		isOK = false
	end

	return format('%0.2f', E:Round(total / 16, 2))
end

function module:UpdateAverageString(frame, which, iLevelDB)
	if not iLevelDB then return end

	local db = E.db.wratharmory[string.lower(which)].avgItemLevel
	local isCharPage = which == 'Character'
	local AvgItemLevel = module:CalculateAverageItemLevel(iLevelDB, isCharPage and 'player' or frame.unit)

	if AvgItemLevel then
		if isCharPage then
			frame.ItemLevelText:SetText(AvgItemLevel)
			frame.ItemLevelText:SetTextColor(db.color.r, db.color.g, db.color.b)
		else
			frame.ItemLevelText:SetText(AvgItemLevel)
			frame.ItemLevelText:SetTextColor(db.color.r, db.color.g, db.color.b)
			frame.ItemLevelText:ClearAllPoints()
			frame.ItemLevelText:Point('CENTER', _G['WrathArmory_'..which..'AvgItemLevel'], 0, -2)
			-- WrathArmory_ItemLevelText.ItemLevelText:SetFormattedText(L["Item level: %.2f"], AvgItemLevel) --* Remember to remove this and remove if not needed
		end
	else
		frame.ItemLevelText:SetText('')
	end

	local avgItemLevelFame = _G['WrathArmory_'..which ..'AvgItemLevel']
	avgItemLevelFame:SetHeight(db.fontSize + 6)
	avgItemLevelFame:SetShown(db.enable)
end

function module:TryGearAgain(frame, which, i, iLevelDB, inspectItem)
	E:Delay(0.05, function()
		if which == 'Inspect' and (not frame or not frame.unit) then return end

		local unit = (which == 'Character' and 'player') or frame.unit
		local slotInfo = module:GetGearSlotInfo(unit, i)
		if slotInfo == 'tooSoon' then return end

		module:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
	end)
end

do
	local iLevelDB = {}
	function module:UpdatePageInfo(frame, which, guid)
		-- if not (which and frame and frame.ItemLevelText) then return end --for avgilvlstats window
		if not which or not frame then return end
		if which == 'Inspect' and (not frame or not frame.unit or (guid and guid ~= 'target' and frame:IsShown() and UnitGUID(frame.unit) ~= guid)) then return end

		wipe(iLevelDB)

		local waitForItems
		for slot, info in pairs(module.GearList) do
			local inspectItem = _G[which..slot]
			inspectItem.enchantText:SetText('')
			inspectItem.iLvlText:SetText('')

			local unit = (which == 'Character' and 'player') or frame.unit
			local slotInfo = module:GetGearSlotInfo(unit, info.slotID)
			if slotInfo == 'tooSoon' then
				if not waitForItems then waitForItems = true end
				module:TryGearAgain(frame, which, info.slotID, iLevelDB, inspectItem)
			else
				module:UpdatePageStrings(info.slotID, iLevelDB, inspectItem, slotInfo, which)
			end
		end

		if waitForItems then
			E:Delay(0.10, module.UpdateAverageString, module, frame, which, iLevelDB)
		else
			module:UpdateAverageString(frame, which, iLevelDB)
		end
	end
end

local function CreateItemLevel(frame, which)
	if not frame or not which then return end

	local db = E.db.wratharmory[string.lower(which)].avgItemLevel
	local isCharPage = which == 'Character'

	local textFrame = CreateFrame('Frame', 'WrathArmory_'..which ..'AvgItemLevel', (isCharPage and module.Stats) or InspectPaperDollFrame)
	textFrame:Size(170, 30)
	textFrame:Point('TOP', db.xOffset, db.yOffset)

	if not textFrame.bg then
		textFrame.bg = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.bg:ClearAllPoints()
	textFrame.bg:SetPoint('CENTER')
	textFrame.bg:Point('TOPLEFT', textFrame)
	textFrame.bg:Point('BOTTOMRIGHT', textFrame)
	textFrame.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	textFrame.bg:SetVertexColor(1, 1, 1, 0.7)

	if not textFrame.lineTop then
		textFrame.lineTop = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.lineTop:SetDrawLayer('BACKGROUND', 2)
	textFrame.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.lineTop:ClearAllPoints()
	textFrame.lineTop:SetPoint('TOP', textFrame.bg, 0, 4)
	textFrame.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	textFrame.lineTop:Size(textFrame:GetWidth(), 7)

	if not textFrame.lineBottom then
		textFrame.lineBottom = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.lineBottom:SetDrawLayer('BACKGROUND', 2)
	textFrame.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.lineBottom:ClearAllPoints()
	textFrame.lineBottom:SetPoint('BOTTOM', textFrame.bg, 0, 0)
	textFrame.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	textFrame.lineBottom:Size(textFrame:GetWidth(), 7)

	local text = textFrame:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
	text:SetText('')
	text:SetPoint('CENTER', 0, -2)
	text:SetTextColor(db.color.r, db.color.g, db.color.b)
	frame.ItemLevelText = text

	module[string.lower(which)] = {}
	module[string.lower(which)].ItemLevelText = text
end

function module:CreateStatsPane()
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.character

	--* Move Rotate Buttons
	CharacterModelFrameRotateLeftButton:ClearAllPoints()
	CharacterModelFrameRotateLeftButton:Point('TOPLEFT', isSkinned and CharacterFrame.backdrop.Center or CharacterFrame, 'TOPLEFT', 3, -3)

	--* Create Stats Frame
	local statsFrame = CreateFrame('Frame', 'WrathArmory_StatsPane', _G.PaperDollItemsFrame, not isSkinned and 'BasicFrameTemplateWithInset')
	statsFrame:SetFrameLevel(_G.CharacterFrame:GetFrameLevel()-1)
	statsFrame:Point('TOPLEFT', CharacterFrame.backdrop or CharacterFrameCloseButton, 'TOPRIGHT', -1, isSkinned and 0 or -5)
	statsFrame:Point('BOTTOMRIGHT', CharacterFrame.backdrop or CharacterFrame, 'BOTTOMRIGHT', 180, isSkinned and 0 or 77)
	module.Stats = statsFrame

	local title = CreateFrame('Frame', nil, statsFrame)
	title:SetWidth(isSkinned and 170 or statsFrame.TitleBg:GetWidth())
	title:SetHeight(isSkinned and 20 or statsFrame.TitleBg:GetHeight())

	if isSkinned then
		--* Adjust CharacterFrame backdrop to be further down and adjust the tabs
		S:HandleFrame(CharacterFrame, true, nil, 11, -12, 0, 65)

		CharacterHandsSlot:ClearAllPoints()
		CharacterHandsSlot:Point('TOPRIGHT', PaperDollItemsFrame, 'TOPRIGHT', -11, -74)
		CharacterModelFrame:ClearAllPoints()
		CharacterModelFrame:Point('TOP', 0, -78)
		CharacterMainHandSlot:ClearAllPoints()
		CharacterMainHandSlot:Point('TOPLEFT', PaperDollItemsFrame, 'BOTTOMLEFT', 139, 127)

		statsFrame:SetTemplate('Transparent')
		title:SetTemplate('NoBackdrop')
		title:Point('TOP', statsFrame, 'TOP', 0, -5)

		--* Move Character Model Down
		CharacterModelFrame:ClearAllPoints()
		CharacterModelFrame:Point('TOPLEFT', PaperDollFrame, 'TOPLEFT', 65, -108)
	else
		title:Point('CENTER', statsFrame.TitleBg, 'CENTER', 0, 0)
	end

	local t = title:CreateFontString(nil, 'OVERLAY', 'GameTooltipText')
	t:SetPoint('CENTER', 0, 0)
	t:SetText('|cFF16C3F2Wrath|rArmory')
	title:SetScript('OnMouseDown', function (self, button)
		-- if button=='LeftButton' then
			-- LoadAddOn('Blizzard_WeeklyRewards');
			-- WeeklyRewardsFrame:Show()
		-- end
		print('Coming Soon™')
	end)
	statsFrame.title = title

	--* Create Avg Item Level
	CreateItemLevel(CharacterFrame, 'Character')

	--* Organize Resistances and anchor below Character AvgItemLevel Text
	MagicResFrame3:ClearAllPoints()
	MagicResFrame3:Point('TOP', 'WrathArmory_CharacterAvgItemLevel', 'BOTTOM', 0, -15)
	MagicResFrame2:ClearAllPoints()
	MagicResFrame2:Point('RIGHT', MagicResFrame3, 'LEFT', -0.83, 0)
	MagicResFrame1:ClearAllPoints()
	MagicResFrame1:Point('RIGHT', MagicResFrame2, 'LEFT', -0.83, 0)
	MagicResFrame4:ClearAllPoints()
	MagicResFrame4:Point('LEFT', MagicResFrame3, 'RIGHT', 0.83, 0)
	MagicResFrame5:ClearAllPoints()
	MagicResFrame5:Point('LEFT', MagicResFrame4, 'RIGHT', 0.83, 0)

	--* Left Stats Group anchors below MagicResFrame3
	PlayerStatFrameLeftDropDown:ClearAllPoints()
	PlayerStatFrameLeftDropDown:Point('TOP', MagicResFrame3, 'BOTTOM', isSkinned and -5 or 0, -15)
	UIDropDownMenu_SetWidth(PlayerStatFrameLeftDropDown, isSkinned and 140 or 170)
	PlayerStatLeftTop:ClearAllPoints()
	PlayerStatLeftTop:Point('TOP', PlayerStatFrameLeftDropDown, 'BOTTOM', 0, 8)
	PlayerStatLeftTop:Width(isSkinned and 150 or 180)
	PlayerStatLeftMiddle:Width(isSkinned and 150 or 180)
	PlayerStatLeftBottom:Width(isSkinned and 150 or 180)
	PlayerStatFrameLeft1:ClearAllPoints()
	PlayerStatFrameLeft1:Point('TOPLEFT', PlayerStatLeftTop, 'TOPLEFT', 6, -3)

	--* Right Stats Group anchors below Left Stats Group
	PlayerStatFrameRightDropDown:ClearAllPoints()
	PlayerStatFrameRightDropDown:Point('CENTER', PlayerStatLeftBottom, 'CENTER', 0, -35)
	UIDropDownMenu_SetWidth(PlayerStatFrameRightDropDown, isSkinned and 140 or 170)
	PlayerStatRightTop:ClearAllPoints()
	PlayerStatRightTop:Point('TOP', PlayerStatFrameRightDropDown, 'BOTTOM', 0, 8)
	PlayerStatRightTop:Width(isSkinned and 150 or 180)
	PlayerStatRightMiddle:Width(isSkinned and 150 or 180)
	PlayerStatRightBottom:Width(isSkinned and 150 or 180)

	for i = 1, 6 do
		_G['PlayerStatFrameLeft'..i]:Width(isSkinned and 150 or 170)
		_G['PlayerStatFrameRight'..i]:Width(isSkinned and 150 or 170)
	end
end

local function Warning_OnEnter(frame)
	if frame.Reason then
		_G.GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
		_G.GameTooltip:AddLine(frame.Reason, 1, 1, 1)
		_G.GameTooltip:Show()
	end
end

local function Warning_OnLeave()
	_G.GameTooltip:Hide()
end

local WarningTexture = [[Interface\AddOns\ElvUI\Core\Media\Textures\Minimalist]]
function module:CreateSlotStrings(frame, which)
	if not frame or not which then return end

	local db = E.db.wratharmory[string.lower(which)]
	local itemLevel = db.itemLevel
	local enchant = db.enchant

	if which == 'Inspect' then
		CreateItemLevel(frame, which)
		InspectFrameTab1:ClearAllPoints()
		InspectFrameTab1:Point('CENTER', InspectFrame, 'BOTTOMLEFT', 60, 51)
	else
		module:CreateStatsPane()
	end
	for slotName, info in pairs(module.GearList) do
		local slot = _G[which..slotName]
		slot.iLvlText = slot:CreateFontString(nil, 'OVERLAY')
		slot.iLvlText:FontTemplate(LSM:Fetch('font', itemLevel.font), itemLevel.fontSize, itemLevel.fontOutline)
		slot.iLvlText:Point('BOTTOM', slot, itemLevel.xOffset, itemLevel.yOffset)

		--* Warning
		slot.WrathArmory_Warning = CreateFrame('Frame', nil, slot)
		do
			-- local point, relativePoint, x, y = module:GetWarningPoints(info.slotID, db)
			local point1, relativePoint1, point2, relativePoint2, size, x1, y1, x2, y2, spacing = module:GetWarningPoints(info.slotID, db)
			slot.WrathArmory_Warning:Point(point1, slot, relativePoint1, x1, y1)
			slot.WrathArmory_Warning:Point(point2, slot, relativePoint2, x2, y2)
			slot.WrathArmory_Warning:Size(size)
			slot.WrathArmory_Warning.texture = slot.WrathArmory_Warning:CreateTexture(nil, 'BACKGROUND')
			slot.WrathArmory_Warning.texture:SetInside()
			slot.WrathArmory_Warning.texture:SetTexture(WarningTexture)
			slot.WrathArmory_Warning.texture:SetVertexColor(1, 0, 0, 1)
			slot.WrathArmory_Warning:SetFrameLevel(3)
			slot.WrathArmory_Warning:SetScript('OnEnter', Warning_OnEnter)
			slot.WrathArmory_Warning:SetScript('OnLeave', Warning_OnLeave)
			slot.WrathArmory_Warning:Hide()
		end

		--* Enchant Text
		slot.enchantText = slot:CreateFontString(nil, 'OVERLAY')
		slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)

		do
			local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
			slot.enchantText:ClearAllPoints()
			slot.enchantText:Point(point, slot, relativePoint, x, y)
		end

		do
			local point, relativePoint, x, y, spacing = module:GetGemPoints(info.slotID, db)
			for u = 1, 5 do
				slot['textureSlot'..u], slot['textureSlotBackdrop'..u] = module:CreateGemTexture(slot, point, relativePoint, x, y, u, spacing)
			end
		end
	end
end

function module:SetupInspectPageInfo()
	module:CreateSlotStrings(_G.InspectFrame, 'Inspect')
end

function module:UpdateInspectPageFonts(which, force)
	if not which then return end

	local frame = _G[which..'Frame']
	if not frame then return end

	local unit = (which == 'Character' and 'player') or frame.unit
	local db = E.db.wratharmory[string.lower(which)]
	local itemLevel, enchant, avgItemLevel = db.itemLevel, db.enchant, db.avgItemLevel

	frame.ItemLevelText:FontTemplate(LSM:Fetch('font', avgItemLevel.font), avgItemLevel.fontSize, avgItemLevel.fontOutline)

	local avgItemLevelFame = _G['WrathArmory_'..which ..'AvgItemLevel']
	avgItemLevelFame:SetHeight(avgItemLevel.fontSize + 6)
	avgItemLevelFame:ClearAllPoints()
	avgItemLevelFame:Point('TOP', avgItemLevel.xOffset, avgItemLevel.yOffset)
	avgItemLevelFame:SetShown(avgItemLevel.enable)

	local slot, quality, iLvlTextColor, enchantTextColor
	local qualityColor = {}
	for slotName, info in pairs(module.GearList) do
		slot = _G[which..slotName]
		if slot then
			quality = GetInventoryItemQuality(unit, info.slotID)
			if quality then
				qualityColor.r, qualityColor.g, qualityColor.b = GetItemQualityColor(quality)
			end

			slot.iLvlText:ClearAllPoints()
			slot.iLvlText:Point('BOTTOM', slot, itemLevel.xOffset, itemLevel.yOffset)
			slot.iLvlText:FontTemplate(LSM:Fetch('font', itemLevel.font), itemLevel.fontSize, itemLevel.fontOutline)
			iLvlTextColor = (itemLevel.qualityColor and qualityColor) or itemLevel.color
			if iLvlTextColor and next(iLvlTextColor) then
				slot.iLvlText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
			end
			slot.iLvlText:SetShown(itemLevel.enable)

			do
				local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
				slot.enchantText:ClearAllPoints()
				slot.enchantText:Point(point, slot, relativePoint, x, y)
			end

			slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
			enchantTextColor = (enchant.qualityColor and qualityColor) or enchant.color
			if enchantTextColor and next(enchantTextColor) then
				slot.enchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
			end
			slot.enchantText:SetShown(enchant.enable)
		end
	end

	if force then
		module:UpdatePageInfo(frame, which, unit)
	end
end

--* Makes a table with Blizzards locale of the empty gem sockets which is used to help determine if missing a socket from a belt buckle
local socketNames, socketTypes = {}, { EMPTY_SOCKET_META, EMPTY_SOCKET_BLUE, EMPTY_SOCKET_RED, EMPTY_SOCKET_YELLOW, EMPTY_SOCKET_NO_COLOR, EMPTY_SOCKET_PRISMATIC, EMPTY_SOCKET_COGWHEEL, EMPTY_SOCKET_HYDRAULIC }
for _, socketName in pairs(socketTypes) do
	socketNames[socketName] = true
end

local temp = {}
temp.gems, temp.emptySockets, temp.filledSockets, temp.baseSocketCount = {}, {}, {}, 0
function module:AcquireGemInfo(itemLink)
	wipe(temp.gems)
	wipe(temp.emptySockets)
	wipe(temp.filledSockets)
	temp.baseSocketCount = 0

	local tt = E.ScanTooltip
	for x = 1, tt:NumLines() do
		local line = _G['ElvUI_ScanTooltipTextLeft'..x]
		if line then
			local lineText = line:GetText()
			if x == 1 and lineText == RETRIEVING_ITEM_INFO then break end
			if socketNames[lineText] then
				temp.baseSocketCount = temp.baseSocketCount + 1
				tinsert(temp.emptySockets, lineText)
			end
		end
	end

	for i = 1, 4 do
		local tex = _G['ElvUI_ScanTooltipTexture'..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture then temp.gems[i] = texture end
		if itemLink then
			local gemName, gemLink = GetItemGem(itemLink, i)
			if gemName then tinsert(temp.filledSockets, gemLink) end
		end
	end

	return temp.gems, temp.emptySockets, temp.filledSockets, temp.baseSocketCount
end

local githubURL = 'https://github.com/Repooc/ElvUI_WrathArmory/issues'
function module:GetGearSlotInfo(unit, slot)
	local tt = E.ScanTooltip
	tt:SetOwner(_G.UIParent, 'ANCHOR_NONE')
	tt:SetInventoryItem(unit, slot)
	tt:Show()

	local slotInfo = {}
	local itemLink = GetInventoryItemLink(unit, slot)
	slotInfo.gems, slotInfo.emptySockets, slotInfo.filledSockets, slotInfo.baseSocketCount = module:AcquireGemInfo(itemLink)
	slotInfo.itemQualityColors = {}
	slotInfo.missingBeltBuckle = false
	local enchantID

	if itemLink then
		if UnitLevel(unit) >= 70 and slot == 6 and (#slotInfo.filledSockets + #slotInfo.emptySockets <= slotInfo.baseSocketCount) then
			slotInfo.missingBeltBuckle = true
		end

		local quality = GetInventoryItemQuality(unit, slot)
		if quality then
			slotInfo.itemQualityColors.r, slotInfo.itemQualityColors.g, slotInfo.itemQualityColors.b = GetItemQualityColor(quality)
		end

		local itemLevel = GetDetailedItemLevelInfo(itemLink)
		slotInfo.iLvl = tonumber(itemLevel)
		enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))
	end

	local enchantTextShort = E.Libs.GetEnchant.GetEnchant(enchantID)
	if enchantID and not enchantTextShort then
		local msg = format('The enchant id, *%s|r, seems to be missing from our database. Please open a ticket at |cff16c3f2[|r*|Hurl:'..githubURL..'|h'..githubURL..'|h|r|cff16c3f2]|r with the missing id and name of the enchant that found on %s. |cffFF0000If you do not provide the info or post a duplicate ticket, it will be closed without a response.|r', enchantID, itemLink):gsub('*', E.InfoColor)
		module:Print(msg)
	end
	slotInfo.enchantTextShort = enchantTextShort or ''

	tt:Hide()

	return slotInfo
end

function module:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_InspectUI' then
		if not _G.InspectFrame.InspectInfoHooked then
			_G.InspectFrame:HookScript('OnShow', function()
				--* Move Rotate Buttons on InspectFrame
				S:HandleFrame(InspectFrame, true, nil, 11, -12, -5, 65)
				local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.character
				InspectModelFrameRotateLeftButton:ClearAllPoints()
				InspectModelFrameRotateLeftButton:Point('TOPLEFT', (isSkinned and InspectFrame.backdrop.Center) or InspectFrame, 'TOPLEFT', 3, -3)

				-- _G.InspectFrame:Width(410)
				InspectHandsSlot:ClearAllPoints()
				InspectHandsSlot:Point('TOPRIGHT', (isSkinned and InspectFrame.backdrop.Center) or InspectPaperDollItemsFrame, 'TOPRIGHT', -10, -56)

				InspectModelFrame:ClearAllPoints()
				InspectModelFrame:Point('TOP', 0, -78)

				InspectSecondaryHandSlot:ClearAllPoints()
				InspectSecondaryHandSlot:Point('BOTTOM', (isSkinned and InspectFrame.backdrop.Center) or InspectPaperDollItemsFrame, 'BOTTOM', 0, 20)
				InspectMainHandSlot:ClearAllPoints()
				InspectMainHandSlot:Point('TOPRIGHT', (isSkinned and InspectSecondaryHandSlot) or InspectPaperDollItemsFrame, 'TOPLEFT', -5, 0)

				_G.InspectFrame.InspectInfoHooked = true
			end)
		end
		module:SetupInspectPageInfo()
	end
end
