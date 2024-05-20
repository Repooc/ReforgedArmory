local E, L = unpack(ElvUI)
local module = E:GetModule('ElvUI_CataArmory')
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM

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

local GradientTexture = [[Interface\AddOns\ElvUI_CataArmory\Media\Gradient]]
local WarningTexture = [[Interface\AddOns\ElvUI\Core\Media\Textures\Minimalist]]

local whileOpenEvents = {
	UPDATE_INVENTORY_DURABILITY = true,
}

function module:UpdateSlotBackground(slot, db)
	if not slot then return end
	local slotName = slot:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = module.GearList[slotName] or module.IgnoredGearList[slotName]
	local direction = info.direction

	if direction then
		slot.CataArmory_Background:ClearAllPoints()
		slot.CataArmory_Background:Point(direction, slot, direction, 0, 0)
		slot.CataArmory_Background:Size(132, 41)
		slot.CataArmory_Background:SetTexture(GradientTexture)
		slot.CataArmory_Background:SetVertexColor(unpack(db.slotBackground.color))
		if direction == 'LEFT' then
			slot.CataArmory_Background:SetTexCoord(0, 1, 0, 1)
		else
			slot.CataArmory_Background:SetTexCoord(1, 0, 0, 1)
		end
		-- slot.CataArmory_Background:Hide()
		slot.CataArmory_Background:Show()
	end
end

function module:CreateGemTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	texture:Point(point, (gemStep == 1 and slot) or slot['CA_textureSlot'..prevGem], relativePoint, (gemStep == 1 and x) or spacing, (gemStep == 1 and x) or y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, (gemStep == 1 and slot) or slot['CA_textureSlotBackdrop'..prevGem])
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
	if not _G.InspectFrame then return end

	E:Delay(0.75, function()
		if _G.InspectFrame and _G.InspectFrame:IsVisible() then
			module:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
		end
	end)
	module:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
	if _G.InspectFrame and _G.InspectFrame.CataArmory_AvgItemLevel and _G.InspectFrame.CataArmory_AvgItemLevel.Text then
		_G.InspectFrame.CataArmory_AvgItemLevel.Text:FontTemplate(LSM:Fetch('font', E.db.cataarmory.inspect.avgItemLevel.font), E.db.cataarmory.inspect.avgItemLevel.fontSize, E.db.cataarmory.inspect.avgItemLevel.fontOutline)
	end
end

function module:UpdateCharacterInfo(event)
	if (not E.db.cataarmory.character.enable)
	or (whileOpenEvents[event] and not _G.CharacterFrame:IsShown()) then return end

	module:UpdatePageInfo(_G.CharacterFrame, 'Character')
end

function module:UpdateCharacterItemLevel()
	module:UpdateAverageString(_G.CharacterFrame, 'Character')
end

function module:ClearPageInfo(frame, which)
	if not frame or not which then return end

	if frame.CataArmory_AvgItemLevel then
		frame.CataArmory_AvgItemLevel:Hide()
		frame.CataArmory_AvgItemLevel.Text:SetText('')
	end

	for slot in pairs(module.GearList) do
		local inspectItem = _G[which..slot]

		inspectItem.CataArmory_EnchantText:SetText('')
		inspectItem.iLvlText:SetText('')
		inspectItem.CataArmory_Warning:Hide()

		for y = 1, 5 do
			inspectItem['CA_textureSlot'..y]:SetTexture()
			inspectItem['CA_textureSlotBackdrop'..y]:Hide()
		end
	end
end

function module:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
	iLevelDB[i] = slotInfo.iLvl
	local frame = _G[which..'Frame']
	local unit = (which == 'Character' and 'player') or frame.unit or 'target'

	local itemLink = GetInventoryItemLink(unit, i)
	local db = E.db.cataarmory[string.lower(which)]
	local missingBuckle, missingGem, missingEnchant, warningMsg = false, false, false, ''
	local slotName = inspectItem:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = module.GearList[slotName] or module.IgnoredGearList[slotName]
	local canEnchant = info.canEnchant
	local direction = info.direction
	do
		local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
		inspectItem.CataArmory_EnchantText:ClearAllPoints()
		inspectItem.CataArmory_EnchantText:Point(point, inspectItem, relativePoint, x, y)
		inspectItem.CataArmory_EnchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)

		if itemLink then
			if slotInfo.enchantText == '' and canEnchant then
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
			inspectItem.CataArmory_Warning.Reason = warningMsg
		end
		inspectItem.CataArmory_Warning:SetShown(db.warningIndicator.enable and (missingEnchant or missingGem or missingBuckle))
		inspectItem.CataArmory_EnchantText:SetText(slotInfo.enchantText)
		inspectItem.CataArmory_EnchantText:SetShown(db.enchant.enable)
		local enchantTextColor = (db.enchant.qualityColor and slotInfo.itemQualityColors) or db.enchant.color
		if enchantTextColor and next(enchantTextColor) then
			inspectItem.CataArmory_EnchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
		end
	end

	--* Slot Background
	if direction then
		if not inspectItem.CataArmory_Background then
			inspectItem.CataArmory_Background = inspectItem:CreateTexture(nil, 'BACKGROUND')
		end
		module:UpdateSlotBackground(inspectItem, db)
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
			local texture = inspectItem['CA_textureSlot'..index]
			texture:Size(db.gems.size)
			texture:ClearAllPoints()
			texture:Point(point, (index == 1 and inspectItem) or inspectItem['CA_textureSlot'..(index-1)], relativePoint, index == 1 and x or spacing, index == 1 and y or 0)

			local backdrop = inspectItem['CA_textureSlotBackdrop'..index]
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

function module:UpdateAverageString(frame, which, iLevelDB)
	if not iLevelDB or not frame then return end

	local db = E.db.cataarmory[string.lower(which)].avgItemLevel
	local isCharPage, avgItemLevel, avgTotal = which == 'Character'

	if isCharPage then
		--* Option to show one or the other or both?
		avgTotal, avgItemLevel = E:GetPlayerItemLevel() -- rounded average, rounded equipped
	else
		avgItemLevel = E:CalculateAverageItemLevel(iLevelDB, frame.unit or 'target')
	end

	if avgItemLevel then
		if isCharPage then
			frame.CataArmory_AvgItemLevel.Text:SetText(avgItemLevel)
			frame.CataArmory_AvgItemLevel.Text:SetTextColor(db.color.r, db.color.g, db.color.b)
		else
			frame.CataArmory_AvgItemLevel.Text:SetText(avgItemLevel)
			frame.CataArmory_AvgItemLevel.Text:SetTextColor(db.color.r, db.color.g, db.color.b)
			frame.CataArmory_AvgItemLevel.Text:ClearAllPoints()
			frame.CataArmory_AvgItemLevel.Text:Point('CENTER', frame.CataArmory_AvgItemLevel, 0, -2)
			-- CataArmory_ItemLevelText.ItemLevelText:SetFormattedText(L["Item level: %.2f"], AvgItemLevel) --* Remember to remove this and remove if not needed
		end
	else
		frame.CataArmory_AvgItemLevel.Text:SetText('')
	end

	local avgItemLevelFame = _G['CataArmory_'..which..'_AvgItemLevel'] or CreateFrame('Frame', 'CataArmory_'..which..'_AvgItemLevel', (isCharPage and PaperDollFrame) or InspectPaperDollFrame)
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
			inspectItem.CataArmory_EnchantText:SetText('')
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

local function CreateAvgItemLevel(frame, which)
	if not frame or not which then return end

	local db = E.db.cataarmory[string.lower(which)].avgItemLevel
	local isCharPage = which == 'Character'

	local textFrame = CreateFrame('Frame', 'CataArmory_'..which..'_AvgItemLevel', (isCharPage and PaperDollFrame) or InspectPaperDollFrame)
	textFrame:Size(170, 30)
	textFrame:Point('TOP', db.xOffset, db.yOffset)

	if not textFrame.Background then
		textFrame.Background = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.Background:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.Background:ClearAllPoints()
	textFrame.Background:SetPoint('CENTER')
	textFrame.Background:Point('TOPLEFT', textFrame)
	textFrame.Background:Point('BOTTOMRIGHT', textFrame)
	textFrame.Background:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	textFrame.Background:SetVertexColor(1, 1, 1, 0.7)

	if not textFrame.TopLine then
		textFrame.TopLine = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.TopLine:SetDrawLayer('BACKGROUND', 2)
	textFrame.TopLine:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.TopLine:ClearAllPoints()
	textFrame.TopLine:SetPoint('TOP', textFrame.Background, 0, 4)
	textFrame.TopLine:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	textFrame.TopLine:Size(textFrame:GetWidth(), 7)

	if not textFrame.BottomLine then
		textFrame.BottomLine = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.BottomLine:SetDrawLayer('BACKGROUND', 2)
	textFrame.BottomLine:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.BottomLine:ClearAllPoints()
	textFrame.BottomLine:SetPoint('BOTTOM', textFrame.Background, 0, 0)
	textFrame.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	textFrame.BottomLine:Size(textFrame:GetWidth(), 7)

	local text = textFrame:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
	text:SetText('')
	text:SetPoint('CENTER', 0, -2)
	text:SetTextColor(db.color.r, db.color.g, db.color.b)

	frame.CataArmory_AvgItemLevel = textFrame
	frame.CataArmory_AvgItemLevel.Text = text

	textFrame:Hide()
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

function module:PaperDollFrame_SetLevel()
	local db = E.db.cataarmory.character.levelText
	if not db.enable then return end

	CharacterLevelText:ClearAllPoints()
	CharacterLevelText:Point('TOP', CharacterFrameTitleText, 'BOTTOM', db.xOffset, db.yOffset)
end

function module:InspectPaperDollFrame_SetLevel()
	local db = E.db.cataarmory.inspect.levelText
	if not db.enable or not InspectLevelText then return end

	InspectLevelText:ClearAllPoints()
	InspectLevelText:Point('TOP', InspectNameText, 'BOTTOM', db.xOffset, db.yOffset)
end

function module:CreateSlotStrings(frame, which)
	if not frame or not which then return end

	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel = db.itemLevel
	local enchant = db.enchant

	CreateAvgItemLevel(frame, which)

	for slotName, info in pairs(module.IgnoredGearList) do
		local slot = _G[which..slotName]
		--* Slot Background
		if info.direction then
			if not slot.CataArmory_Background then
				slot.CataArmory_Background = slot:CreateTexture(nil, 'BACKGROUND')
			end
			module:UpdateSlotBackground(slot, db)
		end
	end

	for slotName, info in pairs(module.GearList) do
		local slot = _G[which..slotName]
		if not slot.iLvlText then
			slot.iLvlText = slot:CreateFontString(nil, 'OVERLAY')
		end
		slot.iLvlText:FontTemplate(LSM:Fetch('font', itemLevel.font), itemLevel.fontSize, itemLevel.fontOutline)
		slot.iLvlText:Point('BOTTOM', slot, itemLevel.xOffset, itemLevel.yOffset)

		--* Slot Background
		if info.direction then
			if not slot.CataArmory_Background then
				slot.CataArmory_Background = slot:CreateTexture(nil, 'BACKGROUND')
			end
			module:UpdateSlotBackground(slot, db)
		end

		--* Warning
		if not slot.CataArmory_Warning then
			slot.CataArmory_Warning = CreateFrame('Frame', nil, slot)
		end
		do
			-- local point, relativePoint, x, y = module:GetWarningPoints(info.slotID, db)
			local point1, relativePoint1, point2, relativePoint2, size, x1, y1, x2, y2, spacing = module:GetWarningPoints(info.slotID, db)
			slot.CataArmory_Warning:Point(point1, slot, relativePoint1, x1, y1)
			slot.CataArmory_Warning:Point(point2, slot, relativePoint2, x2, y2)
			slot.CataArmory_Warning:Size(size)
			slot.CataArmory_Warning.texture = slot.CataArmory_Warning:CreateTexture(nil, 'BACKGROUND')
			slot.CataArmory_Warning.texture:SetInside()
			slot.CataArmory_Warning.texture:SetTexture(WarningTexture)
			slot.CataArmory_Warning.texture:SetVertexColor(1, 0, 0, 1)
			slot.CataArmory_Warning:SetFrameLevel(3)
			slot.CataArmory_Warning:SetScript('OnEnter', Warning_OnEnter)
			slot.CataArmory_Warning:SetScript('OnLeave', Warning_OnLeave)
			slot.CataArmory_Warning:Hide()
		end

		--* Enchant Text
		if not slot.CataArmory_EnchantText then
			slot.CataArmory_EnchantText = slot:CreateFontString(nil, 'OVERLAY')
		end
		slot.CataArmory_EnchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)

		do
			local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
			slot.CataArmory_EnchantText:ClearAllPoints()
			slot.CataArmory_EnchantText:Point(point, slot, relativePoint, x, y)
		end

		do
			local point, relativePoint, x, y, spacing = module:GetGemPoints(info.slotID, db)
			for u = 1, 5 do
				slot['CA_textureSlot'..u], slot['CA_textureSlotBackdrop'..u] = module:CreateGemTexture(slot, point, relativePoint, x, y, u, spacing)
			end
		end
	end
end

function module:InspectFrame_OnShow()
	local frame = _G.InspectFrame
	if not frame or frame.InspectInfoHooked then return end
	-- if frame.InspectInfoHooked then return end

	--* Move Rotate Buttons on InspectFrame
	-- S:HandleFrame(InspectFrame, true, nil, 11, -12, -5, 65)
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.character
	InspectModelFrameRotateLeftButton:ClearAllPoints()
	InspectModelFrameRotateLeftButton:Point('TOPLEFT', (isSkinned and frame.backdrop.Center) or frame, 'TOPLEFT', 3, -3)

	InspectModelFrame:ClearAllPoints()
	InspectModelFrame:Point('TOP', 0, -78)

	InspectSecondaryHandSlot:ClearAllPoints()
	InspectSecondaryHandSlot:Point('BOTTOM', (isSkinned and frame.backdrop.Center) or InspectPaperDollItemsFrame, 'BOTTOM', 0, 20)
	InspectMainHandSlot:ClearAllPoints()
	InspectMainHandSlot:Point('TOPRIGHT', (isSkinned and InspectSecondaryHandSlot) or InspectPaperDollItemsFrame, 'TOPLEFT', -5, 0)

	_G.InspectFrameCloseButton:ClearAllPoints()
	_G.InspectFrameCloseButton:Point('TOPRIGHT', (isSkinned and frame.backdrop.Center) or frame, 'TOPRIGHT', -4, -4)

	if isSkinned and frame.backdrop then
		InspectModelFrame:ClearAllPoints()
		InspectModelFrame:Point('TOP', InspectPaperDollFrame, 'TOP', -5, -88)

		frame.backdrop:ClearAllPoints()
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 11, -12)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -32, 50)

		InspectFrameTab1:ClearAllPoints(); InspectFrameTab1:Point('TOPLEFT', frame, 'BOTTOMLEFT', 1, 26)
		InspectFrameTab1:Point('TOPLEFT', InspectFrame, 'BOTTOMLEFT', 1, 52)
	end

	frame.InspectInfoHooked = true
end

function module:SetupInspectPageInfo()
	local frame = _G.InspectFrame
	if frame then
		module:CreateSlotStrings(frame, 'Inspect')
	end
end

function module:UpdateInspectPageFonts(which, force)
	if not which then return end

	local frame = _G[which..'Frame']
	if not frame then return end

	local unit = (which == 'Character' and 'player') or frame.unit
	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel, enchant, avgItemLevel = db.itemLevel, db.enchant, db.avgItemLevel

	frame.CataArmory_AvgItemLevel.Text:FontTemplate(LSM:Fetch('font', avgItemLevel.font), avgItemLevel.fontSize, avgItemLevel.fontOutline)

	frame.CataArmory_AvgItemLevel:ClearAllPoints()
	frame.CataArmory_AvgItemLevel:Point('TOP', avgItemLevel.xOffset, avgItemLevel.yOffset)

	frame.CataArmory_AvgItemLevel:SetHeight(avgItemLevel.fontSize + 6)
	frame.CataArmory_AvgItemLevel:SetShown(avgItemLevel.enable)

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
				slot.CataArmory_EnchantText:ClearAllPoints()
				slot.CataArmory_EnchantText:Point(point, slot, relativePoint, x, y)
			end

			slot.CataArmory_EnchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
			enchantTextColor = (enchant.qualityColor and qualityColor) or enchant.color
			if enchantTextColor and next(enchantTextColor) then
				slot.CataArmory_EnchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
			end
			slot.CataArmory_EnchantText:SetShown(enchant.enable)
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

local githubURL = 'https://github.com/Repooc/ElvUI_CataArmory/issues'
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

	local enchantText = E.Libs.GetEnchant.GetEnchant(enchantID)
	if enchantID and not enchantText then
		local msg = format('The enchant id, *%s|r, seems to be missing from our database. Please open a ticket at |cff16c3f2[|r*|Hurl:'..githubURL..'|h'..githubURL..'|h|r|cff16c3f2]|r with the missing id and name of the enchant that found on %s. |cffFF0000If you do not provide the info or post a duplicate ticket, it will be closed without a response.|r', enchantID, itemLink):gsub('*', E.InfoColor)
		module:Print(msg)
	end
	slotInfo.enchantText = enchantText or ''

	tt:Hide()

	return slotInfo
end

local function CharacterFrame_OnShow()
	module.UpdateCharacterInfo()
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.character

	local frame = _G.CharacterFrame
	if isSkinned then
		CharacterMainHandSlot:ClearAllPoints()
		CharacterMainHandSlot:Point('BOTTOMLEFT', _G.PaperDollItemsFrame, 'BOTTOMLEFT', 106, -5)

		if frame.BottomRightCorner then
			frame.BottomRightCorner:ClearAllPoints()
			frame.BottomRightCorner:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -20)
		end
		if frame.BottomLeftCorner then
			frame.BottomLeftCorner:ClearAllPoints()
			frame.BottomLeftCorner:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, -20)
		end
		CharacterFrameTab1:ClearAllPoints()
		CharacterFrameTab1:Point('TOPLEFT', frame, 'BOTTOMLEFT', -10, -18)
	end
end

function module:ToggleItemLevelInfo(setupCharacterPage)
	if setupCharacterPage then
		module:CreateSlotStrings(_G.CharacterFrame, 'Character')
	end

	if E.db.cataarmory.character.enable then
		module:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'UpdateCharacterInfo')
		module:RegisterEvent('UPDATE_INVENTORY_DURABILITY', 'UpdateCharacterInfo')
		module:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE', 'UpdateCharacterItemLevel')

		if not module:IsHooked(_G.CharacterFrame, 'OnShow') then
			module:SecureHookScript(_G.CharacterFrame, 'OnShow', CharacterFrame_OnShow)
		end

		if not setupCharacterPage then
			module:UpdateCharacterInfo()
		end
	else
		module:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
		module:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
		module:UnregisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')
		if module:IsHooked(_G.CharacterFrame, 'OnShow') then
			module:Unhook(_G.CharacterFrame, 'OnShow')
		end

		module:ClearPageInfo(_G.CharacterFrame, 'Character')
	end

	if E.db.cataarmory.inspect.enable then
		module:RegisterEvent('INSPECT_READY', 'UpdateInspectInfo')
		if IsAddOnLoaded('Blizzard_InspectUI') and not module:IsHooked(_G.InspectFrame, 'OnShow') then
			module:SecureHookScript(_G.InspectFrame, 'OnShow', module.InspectFrame_OnShow)
		end
		module:UpdateInspectInfo()
	else
		module:UnregisterEvent('INSPECT_READY')
		if IsAddOnLoaded('Blizzard_InspectUI') and module:IsHooked(_G.InspectFrame, 'OnShow') then
			module:Unhook(_G.InspectFrame, 'OnShow')
		end
		module:ClearPageInfo(_G.InspectFrame, 'Inspect')
	end
end
