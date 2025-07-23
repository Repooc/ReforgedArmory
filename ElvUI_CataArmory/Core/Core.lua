local E, L = unpack(ElvUI)
local module = E:GetModule('ElvUI_CataArmory')
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM
local GetItemQualityColor = C_Item and C_Item.GetItemQualityColor

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

function module:UpdateAvgItemLevel(which)
	if not which then return end
	local frame = _G[which..'Frame']
	if not frame then return end

	local isCharPage = which == 'Character'
	local db = E.db.cataarmory[string.lower(which)]
	local textOptions, frameOptions = db.avgItemLevel.text, db.avgItemLevel.frame

	frame.CataArmory_AvgItemLevel:ClearAllPoints()
	if isCharPage then
		frame.CataArmory_AvgItemLevel:SetPoint((frameOptions.attachTo == 'CharacterLevelText' or frameOptions.attachTo == 'PaperDollFrame') and 'TOP' or 'BOTTOM', frameOptions.attachTo, (frameOptions.attachTo == 'CharacterLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	else
		frame.CataArmory_AvgItemLevel:SetPoint('TOP', frameOptions.attachTo, (frameOptions.attachTo == 'InspectLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	end
	frame.CataArmory_AvgItemLevel:SetHeight(textOptions.fontSize + 6)
	frame.CataArmory_AvgItemLevel:SetShown(db.avgItemLevel.enable)

	frame.CataArmory_AvgItemLevel.Background:SetShown(frameOptions.showBGTexture)
	frame.CataArmory_AvgItemLevel.BottomLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	frame.CataArmory_AvgItemLevel.BottomLine:SetShown(frameOptions.showLines)
	frame.CataArmory_AvgItemLevel.TopLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	frame.CataArmory_AvgItemLevel.TopLine:SetShown(frameOptions.showLines)

	frame.CataArmory_AvgItemLevel.Text:FontTemplate(LSM:Fetch('font', textOptions.font), textOptions.fontSize, textOptions.fontOutline)
	frame.CataArmory_AvgItemLevel.Text:ClearAllPoints()
	frame.CataArmory_AvgItemLevel.Text:SetPoint('CENTER', frame.CataArmory_AvgItemLevel, 'CENTER', textOptions.xOffset, textOptions.yOffset)
end

function module:UpdateSlotBackground(which, slot)
	if not which or not slot.CataArmory_SlotBackground then return end

	local db = E.db.cataarmory[string.lower(which)]
	local slotName = slot:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = module.GearList[slotName]
	local direction = info.direction
	local color = db.slotBackground.color

	local point, relativePoint, x, y = module:GetSlotBackgroundPoints(info.slotID, db)
	if direction then
		slot.CataArmory_SlotBackground:ClearAllPoints()
		slot.CataArmory_SlotBackground:SetPoint(point, slot, relativePoint, x, y)
		slot.CataArmory_SlotBackground:Size(132, 41)
		slot.CataArmory_SlotBackground:SetTexture(GradientTexture)
		slot.CataArmory_SlotBackground:SetVertexColor(color.r, color.g, color.b)
		if direction == 'LEFT' then
			slot.CataArmory_SlotBackground:SetTexCoord(0, 1, 0, 1)
		else
			slot.CataArmory_SlotBackground:SetTexCoord(1, 0, 0, 1)
		end

		slot.CataArmory_SlotBackground:SetShown(db.slotBackground.enable)
	end
end

function module:UpdateItemLevelText(which, slot)
	if not which or not slot.CataArmory_ItemLevelText then return end

	local db = E.db.cataarmory[string.lower(which)]

	slot.CataArmory_ItemLevelText:ClearAllPoints()
	slot.CataArmory_ItemLevelText:SetPoint('BOTTOM', slot, db.itemLevel.xOffset, db.itemLevel.yOffset)
	slot.CataArmory_ItemLevelText:FontTemplate(LSM:Fetch('font', db.itemLevel.font), db.itemLevel.fontSize, db.itemLevel.fontOutline)
	slot.CataArmory_ItemLevelText:SetShown(db.itemLevel.enable)
end

function module:CreateGemTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	texture:SetPoint(point, (gemStep == 1 and slot) or slot['CataArmory_GemSlot'..prevGem], relativePoint, (gemStep == 1 and x) or spacing, (gemStep == 1 and x) or y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, (gemStep == 1 and slot) or slot['CataArmory_GemSlotBackdrop'..prevGem])
	backdrop:SetTemplate(nil, nil, true)
	backdrop:SetBackdropColor(0,0,0,0)
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function module:GetSlotBackgroundPoints(id, db)
	if not id or not db then return end
	local x, y = db.slotBackground.xOffset, db.slotBackground.yOffset

	if id <= 5 or (id == 9 or id == 15) then --* Left Side
		return 'LEFT', 'LEFT', x, y
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) or id == 16 then	--* Right Side
		return 'RIGHT', 'RIGHT', -x, y
	else									 --* Left Side (RangedSlot)
		return 'LEFT', 'LEFT', x, y
	end
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

	for slotName, info in pairs(module.GearList) do
		local slot = _G[which..slotName]

		if not info.ignored then
			slot.CataArmory_EnchantText:SetText('')
			slot.CataArmory_ItemLevelText:SetText('')
			slot.CataArmory_Warning:Hide()

			for y = 1, 5 do
				slot['CataArmory_GemSlot'..y]:SetTexture()
				slot['CataArmory_GemSlotBackdrop'..y]:Hide()
			end
		end
		if slot.CataArmory_SlotBackground then
			slot.CataArmory_SlotBackground:Hide()
		end
	end
end

function module:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
	iLevelDB[i] = slotInfo.itemLevel
	local frame = _G[which..'Frame']
	local unit = (which == 'Character' and 'player') or frame.unit or 'target'

	local itemLink = GetInventoryItemLink(unit, i)
	local db = E.db.cataarmory[string.lower(which)]
	local missingBuckle, missingGem, missingEnchant, warningMsg = false, false, false, ''
	local slotName = inspectItem:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = module.GearList[slotName]
	local canEnchant, direction = info.canEnchant, info.direction
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.inpsect

	--* Slot Background
	if direction then
		if not inspectItem.CataArmory_SlotBackground then
			inspectItem.CataArmory_SlotBackground = inspectItem:CreateTexture(nil, 'BACKGROUND')
		end
		module:UpdateSlotBackground(which, inspectItem)
	end

	if not info.ignored then
		do
			local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
			inspectItem.CataArmory_EnchantText:ClearAllPoints()
			inspectItem.CataArmory_EnchantText:SetPoint(point, inspectItem, relativePoint, x, y)
			inspectItem.CataArmory_EnchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)

			if itemLink then
				if slotInfo.enchantText == '' and (canEnchant and (canEnchant == true or canEnchant('Enchanting'))) then
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

			local showWarning = missingEnchant or missingGem or missingBuckle or false
			if direction and inspectItem.CataArmory_SlotBackground then
				local warnColor = (showWarning and db.slotBackground.warning.enable) and db.slotBackground.warning.color or db.slotBackground.color
				inspectItem.CataArmory_SlotBackground:SetVertexColor(warnColor.r, warnColor.g, warnColor.b)
			end
			inspectItem.CataArmory_Warning:SetShown(db.warningIndicator.enable and showWarning)

			inspectItem.CataArmory_EnchantText:SetText(slotInfo.enchantText)
			inspectItem.CataArmory_EnchantText:SetShown(db.enchant.enable)
			local enchantTextColor = (db.enchant.qualityColor and slotInfo.itemQualityColors) or db.enchant.color
			if enchantTextColor and next(enchantTextColor) then
				inspectItem.CataArmory_EnchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
			end
		end
	end

	module:UpdateItemLevelText(which, inspectItem)
	local iLvlTextColor = (db.itemLevel.qualityColor and slotInfo.itemQualityColors) or db.itemLevel.color
	if iLvlTextColor and next(iLvlTextColor) then
		inspectItem.CataArmory_ItemLevelText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
	end
	inspectItem.CataArmory_ItemLevelText:SetText(slotInfo.itemLevel)

	local quality = GetInventoryItemQuality(unit, i)
	local r, g, b

	if which == 'Inspect' and isSkinned then
		if quality and quality > 1 then
			r, g, b = GetItemQualityColor(quality)
			inspectItem.backdrop:SetBackdropBorderColor(r, g, b, 1)
		else
			inspectItem.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	else
		if quality and quality > 1 then
			r, g, b = GetItemQualityColor(quality)
			inspectItem.IconBorder:SetVertexColor(r, g, b)
			inspectItem.IconBorder:Show()
		else
			inspectItem.IconBorder:SetVertexColor(1, 1, 1)
			inspectItem.IconBorder:SetShown(itemLink and true or false)
		end
	end

	do
		local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
		local gemStep = 1
		for index = 1, 5 do
			local texture = inspectItem['CataArmory_GemSlot'..index]
			texture:Size(db.gems.size)
			texture:ClearAllPoints()
			texture:SetPoint(point, (index == 1 and inspectItem) or inspectItem['CataArmory_GemSlot'..(index-1)], relativePoint, index == 1 and x or spacing, index == 1 and y or 0)

			local backdrop = inspectItem['CataArmory_GemSlotBackdrop'..index]
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

	local db = E.db.cataarmory[string.lower(which)]
	local textOptions, frameOptions = db.avgItemLevel.text, db.avgItemLevel.frame
	local isCharPage, avgItemLevel, avgTotal = which == 'Character'

	if isCharPage then
		--* Option to show one or the other or both?
		avgTotal, avgItemLevel = E:GetPlayerItemLevel() -- rounded average, rounded equipped
	else
		avgItemLevel = E:CalculateAverageItemLevel(iLevelDB, frame.unit or 'target')
	end

	if avgItemLevel then
		frame.CataArmory_AvgItemLevel.Text:SetText(avgItemLevel)
		frame.CataArmory_AvgItemLevel.Text:SetTextColor(textOptions.color.r, textOptions.color.g, textOptions.color.b)
	else
		frame.CataArmory_AvgItemLevel.Text:SetText('')
	end

	frame.CataArmory_AvgItemLevel:SetHeight(textOptions.fontSize + 6)
	frame.CataArmory_AvgItemLevel:SetShown(db.avgItemLevel.enable)
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
		if not which or not frame then return end
		if which == 'Inspect' and (not frame or not frame.unit or (guid and guid ~= 'target' and frame:IsShown() and UnitGUID(frame.unit) ~= guid)) then return end

		wipe(iLevelDB)

		local waitForItems
		for slotName, info in pairs(module.GearList) do
			local slot = _G[which..slotName]
			if not info.ignored then
				slot.CataArmory_EnchantText:SetText('')
				slot.CataArmory_ItemLevelText:SetText('')

				local unit = (which == 'Character' and 'player') or frame.unit
				local slotInfo = module:GetGearSlotInfo(unit, info.slotID)
				if slotInfo == 'tooSoon' then
					if not waitForItems then waitForItems = true end
					module:TryGearAgain(frame, which, info.slotID, iLevelDB, slot)
				else
					module:UpdatePageStrings(info.slotID, iLevelDB, slot, slotInfo, which)
				end
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

	local db = E.db.cataarmory[string.lower(which)]
	local textOptions, frameOptions = db.avgItemLevel.text, db.avgItemLevel.frame
	local isCharPage = which == 'Character'

	local textFrame = CreateFrame('Frame', 'CataArmory_'..which..'_AvgItemLevel', (isCharPage and PaperDollFrame) or InspectPaperDollFrame)
	textFrame:Size(170, 30)
	textFrame:ClearAllPoints()
	if isCharPage then
		textFrame:SetPoint((frameOptions.attachTo == 'CharacterLevelText' or frameOptions.attachTo == 'PaperDollFrame') and 'TOP' or 'BOTTOM', frameOptions.attachTo, (frameOptions.attachTo == 'CharacterLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	else
		textFrame:SetPoint('TOP', frameOptions.attachTo, (frameOptions.attachTo == 'InspectLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	end

	if not textFrame.Background then
		textFrame.Background = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.Background:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.Background:ClearAllPoints()
	textFrame.Background:SetPoint('CENTER')
	textFrame.Background:SetPoint('TOPLEFT', textFrame)
	textFrame.Background:SetPoint('BOTTOMRIGHT', textFrame)
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
	textFrame.TopLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	textFrame.TopLine:Size(textFrame:GetWidth(), 7)

	if not textFrame.BottomLine then
		textFrame.BottomLine = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.BottomLine:SetDrawLayer('BACKGROUND', 2)
	textFrame.BottomLine:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.BottomLine:ClearAllPoints()
	textFrame.BottomLine:SetPoint('BOTTOM', textFrame.Background, 0, 0)
	textFrame.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	textFrame.BottomLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	textFrame.BottomLine:Size(textFrame:GetWidth(), 7)

	local text = textFrame:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate(LSM:Fetch('font', textOptions.font), textOptions.fontSize, textOptions.fontOutline)
	text:SetText('')
	text:SetPoint('CENTER', textOptions.xOffset, textOptions.yOffset)
	text:SetTextColor(textOptions.color.r, textOptions.color.g, textOptions.color.b)

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

	_G.CharacterLevelText:ClearAllPoints()
	_G.CharacterLevelText:SetPoint('TOP', _G.CharacterFrameTitleText, 'BOTTOM', db.xOffset, db.yOffset)
end

function module:InspectPaperDollFrame_SetLevel()
	local db = E.db.cataarmory.inspect.levelText
	if not db.enable or not InspectLevelText then return end

	_G.InspectLevelText:ClearAllPoints()
	_G.InspectLevelText:SetPoint('TOP', _G.InspectNameText, 'BOTTOM', db.xOffset, db.yOffset)
end

function module:CreateSlotStrings(frame, which)
	if not frame or not which then return end

	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel = db.itemLevel
	local enchant = db.enchant

	CreateAvgItemLevel(frame, which)

	for slotName, info in pairs(module.GearList) do
		local slot = _G[which..slotName]

		if not info.ignored then
			--* Item Level
			if not slot.CataArmory_ItemLevelText then
				slot.CataArmory_ItemLevelText = slot:CreateFontString(nil, 'OVERLAY')
			end
			module:UpdateItemLevelText(which, slot)

			--* Warning
			if not slot.CataArmory_Warning then
				slot.CataArmory_Warning = CreateFrame('Frame', nil, slot)
			end

			do
				local point1, relativePoint1, point2, relativePoint2, size, x1, y1, x2, y2, spacing = module:GetWarningPoints(info.slotID, db)
				slot.CataArmory_Warning:SetPoint(point1, slot, relativePoint1, x1, y1)
				slot.CataArmory_Warning:SetPoint(point2, slot, relativePoint2, x2, y2)
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
				slot.CataArmory_EnchantText:SetPoint(point, slot, relativePoint, x, y)
			end

			do
				local point, relativePoint, x, y, spacing = module:GetGemPoints(info.slotID, db)
				for u = 1, 5 do
					slot['CataArmory_GemSlot'..u], slot['CataArmory_GemSlotBackdrop'..u] = module:CreateGemTexture(slot, point, relativePoint, x, y, u, spacing)
				end
			end
		end

		--* Slot Background
		if info.direction then
			if not slot.CataArmory_SlotBackground then
				slot.CataArmory_SlotBackground = slot:CreateTexture(nil, 'BACKGROUND')
			end
			module:UpdateSlotBackground(which, slot)
		end
	end
end

function module:InspectFrame_OnShow()
	local frame = _G.InspectFrame
	if not frame or frame.InspectInfoHooked then return end
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.character

	--* Move Rotate Buttons on InspectFrame
	if isSkinned then
		_G.InspectModelFrameRotateLeftButton:ClearAllPoints()
		_G.InspectModelFrameRotateLeftButton:SetPoint('TOPLEFT', frame, 'TOPLEFT', 3, -3)

		_G.InspectModelFrame:ClearAllPoints()
		_G.InspectModelFrame:SetPoint('TOP', 0, -78)

		_G.InspectSecondaryHandSlot:ClearAllPoints()
		_G.InspectSecondaryHandSlot:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 20)
		_G.InspectMainHandSlot:ClearAllPoints()
		_G.InspectMainHandSlot:SetPoint('TOPRIGHT', _G.InspectSecondaryHandSlot, 'TOPLEFT', -5, 0)

		_G.InspectFrameCloseButton:ClearAllPoints()
		_G.InspectFrameCloseButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -4, -4)

		if frame.backdrop then
			_G.InspectModelFrame:ClearAllPoints()
			_G.InspectModelFrame:SetPoint('TOP', _G.InspectPaperDollFrame, 'TOP', -5, -88)

			frame.backdrop:ClearAllPoints()
			frame.backdrop:SetPoint('TOPLEFT', frame, 'TOPLEFT', 11, -12)
			frame.backdrop:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, 50)

			_G.InspectFrameTab1:ClearAllPoints(); _G.InspectFrameTab1:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 1, 26)
			_G.InspectFrameTab1:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 1, 52)

			_G.InspectHeadSlot:ClearAllPoints()
			_G.InspectHeadSlot:SetPoint('TOPLEFT', _G.InspectPaperDollItemsFrame, 'TOPLEFT', 26, -74)
			_G.InspectHandsSlot:ClearAllPoints()
			_G.InspectHandsSlot:SetPoint('TOPRIGHT', _G.InspectPaperDollItemsFrame, 'TOPRIGHT', -15, -74)
		end
	else
		_G.InspectModelFrameRotateLeftButton:ClearAllPoints()
		_G.InspectModelFrameRotateLeftButton:SetPoint('BOTTOMLEFT', _G.InspectModelFrame, 'TOPLEFT', 0, -1)
		_G.InspectModelFrameRotateRightButton:ClearAllPoints()
		_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', -6, 0)
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
	if not frame:IsShown() then return end

	local unit = (which == 'Character' and 'player') or frame.unit
	local isCharPage = which == 'Character'
	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel, enchant = db.itemLevel, db.enchant

	module:UpdateAvgItemLevel(which)

	local slot, quality, iLvlTextColor, enchantTextColor
	local qualityColor = {}
	for slotName, info in pairs(module.GearList) do
		slot = _G[which..slotName]
		if slot then
			if not info.ignored then
				quality = GetInventoryItemQuality(unit, info.slotID)
				if quality then
					qualityColor.r, qualityColor.g, qualityColor.b = GetItemQualityColor(quality)
				end

				module:UpdateItemLevelText(which, slot)
				iLvlTextColor = (itemLevel.qualityColor and qualityColor) or itemLevel.color
				if iLvlTextColor and next(iLvlTextColor) then
					slot.CataArmory_ItemLevelText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
				end

				do
					local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
					slot.CataArmory_EnchantText:ClearAllPoints()
					slot.CataArmory_EnchantText:SetPoint(point, slot, relativePoint, x, y)
				end

				slot.CataArmory_EnchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
				enchantTextColor = (enchant.qualityColor and qualityColor) or enchant.color
				if enchantTextColor and next(enchantTextColor) then
					slot.CataArmory_EnchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
				end
				slot.CataArmory_EnchantText:SetShown(enchant.enable)
			end

			if force then
				module:UpdateSlotBackground(which, slot)
			end
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
local missingIDs = {}
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
		slotInfo.itemLevel = tonumber(itemLevel)
		enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))
	end

	local enchantText = E.global.cataarmory.enchantStrings.UserReplaced[enchantID] or E.Libs.GetEnchantList.GetEnchant(enchantID)
	if enchantID and not enchantText and not missingIDs[enchantID] then
		local msg = format('The enchant id, *%s|r, seems to be missing from our database. Please open a ticket at |cff16c3f2[|r*|Hurl:'..githubURL..'|h'..githubURL..'|h|r|cff16c3f2]|r with the missing id and name of the enchant and/or provide screenshot mousing over the item with enchant that was found on %s. |cffFF0000If you do not provide the info or post a duplicate ticket, it will be closed without a response.|r', enchantID, itemLink):gsub('*', E.InfoColor)
		module:Print(msg)
		missingIDs[enchantID] = true
	end
	slotInfo.enchantText = enchantText or ''

	tt:Hide()

	return slotInfo
end

local function HandleCharacterFrameExpand()
	local frame = _G.CharacterFrame
	local showStatus = E.db.cataarmory.character.expandButton.autoExpand
	if _G.PaperDollFrame:IsVisible() or _G.PetPaperDollFrame:IsVisible() then
		if _G.CharacterStatsPane:IsShown() ~= showStatus then
			_G.CharacterFrameExpandButton:Click()
		end
	end
	_G.CharacterFrameExpandButton:SetShown(not E.db.cataarmory.character.expandButton.hide)
end

local function CharacterFrame_OnShow()
	module.UpdateCharacterInfo()
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.character

	local frame = _G.CharacterFrame
	if isSkinned then
		CharacterMainHandSlot:ClearAllPoints()
		CharacterMainHandSlot:SetPoint('BOTTOMLEFT', _G.PaperDollItemsFrame, 'BOTTOMLEFT', 106, -5)

		if frame.BottomRightCorner then
			frame.BottomRightCorner:ClearAllPoints()
			frame.BottomRightCorner:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -20)
		end
		if frame.BottomLeftCorner then
			frame.BottomLeftCorner:ClearAllPoints()
			frame.BottomLeftCorner:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, -20)
		end
		CharacterFrameTab1:ClearAllPoints()
		CharacterFrameTab1:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', -10, -24)

		if not frame.CataArmory_Hooked then
			_G.CharacterModelScene.BackgroundTopLeft:Hide()
			_G.CharacterModelScene.BackgroundTopRight:Hide()
			_G.CharacterModelScene.BackgroundBotLeft:Hide()
			_G.CharacterModelScene.BackgroundBotRight:Hide()
			_G.CharacterModelScene.backdrop:Hide()
			_G.CharacterModelScene.BackgroundOverlay:Hide() --! Maybe use this over background images?
		end

		frame.BottomLeftCorner:ClearAllPoints()
		frame.BottomLeftCorner:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, -26)
		frame.BottomRightCorner:ClearAllPoints()
		frame.BottomRightCorner:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -26)

		frame.CataArmory_Hooked = true
	end

	HandleCharacterFrameExpand()
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
		if not module:IsHooked(_G.CharacterFrame, 'ShowSubFrame') then
			module:SecureHook(_G.CharacterFrame, 'ShowSubFrame', HandleCharacterFrameExpand)
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
		if not module:IsHooked(_G.CharacterFrame, 'ShowSubFrame') then
			module:Unhook(_G.CharacterFrame, 'ShowSubFrame')
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
