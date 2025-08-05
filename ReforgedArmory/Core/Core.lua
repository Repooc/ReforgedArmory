local E, L = unpack(ElvUI)
local _, Engine = ...
local module = E:GetModule('ReforgedArmory')
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM

local GetItemQualityColor = C_Item and C_Item.GetItemQualityColor

local GradientTexture = [[Interface\AddOns\ReforgedArmory\Media\Gradient]]
local ReversedGradientTexture = [[Interface\AddOns\ReforgedArmory\Media\Gradient-Reversed]]
local WarningTexture = [[Interface\AddOns\ElvUI\Core\Media\Textures\Minimalist]]

local DurabilityConstants = Engine.Durability
local DurabilityBarOffsets = DurabilityConstants.Bar.OffSets
local MIN_BAR_LENGTHOFFSET, MAX_BAR_LENGTHOFFSET = DurabilityBarOffsets.MIN_BAR_LENGTHOFFSET, DurabilityBarOffsets.MAX_BAR_LENGTHOFFSET
local MIN_BAR_THICKNESS, MAX_BAR_THICKNESS = DurabilityConstants.Bar.Thickness.MIN_BAR_THICKNESS, DurabilityConstants.Bar.Thickness.MAX_BAR_THICKNESS

local whileOpenEvents = {
	UPDATE_INVENTORY_DURABILITY = true,
}

local function SetDurabilityColor(bar, percent)
	if not bar then return end
	local text = bar.Text
	local db = E.db.cataarmory.character.durability

	percent = math.min(math.max(percent * 0.01, 0), 1)

	-- RGB gradient: green → yellow → red
	local r, g, b = E:ColorGradient(percent, 1, 0.1, 0.1, 1, 1, 0.1, 0.1, 1, 0.1)
	bar:SetStatusBarColor(r, g, b)

	if text then
		if not db.text.useCustomColor then
			text:SetTextColor(r, g, b)
		else
			local customColor = db.text.customColor
			text:SetTextColor(customColor.r, customColor.g, customColor.b)
		end
	end
end

local function UpdateSlotDurabilityBar(bar, db, slotInfo)
	if not bar then return end

	local text = bar.Text
	local durability = slotInfo.durability
	local current, max, percent = durability.current, durability.max, durability.percent

	bar.current = current
	bar.max = max
	bar.percent = percent

	if current and max and max > 0 then
		text:SetFormattedText('%d%%', percent)

		bar:SetMinMaxValues(0, max)
		bar:SetValue(current)
		SetDurabilityColor(bar, percent)
		bar:SetAlpha(db.mouseover and 0 or 1)
	else
		if text then
			text:SetText('')
		end

		bar:SetValue(0)
		bar:SetAlpha(0)
	end
	bar:SetShown(db.enable)
end

local function GetDurabilityBarSlotDB(slotID)
	if not slotID then module:Print('GetDurabilityBarSlotDB: No slotID provided') return end
	if slotID <= 5 or (slotID == 9 or slotID == 15) or (slotID >= 6 and slotID <= 8) or (slotID >= 10 and slotID <= 14) then --* Left & Right Side
		return E.db.cataarmory.character.durability
	elseif slotID == 16 then																			--* MainHandSlot
		return E.db.cataarmory.character.durability.MainHandSlot
	elseif slotID == 17 then																			--* SecondaryHandSlot
		return E.db.cataarmory.character.durability.SecondaryHandSlot
	else																								--* RangedSlot
		return E.db.cataarmory.character.durability.RangedSlot
	end
end

local function CreateDurabilityBar(which, slot)
	if which and string.lower(which) ~= 'character' then return end
	if not slot or slot.RA_DurabilityBar then return end

	local slotName = slot:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = Engine.GearList[slotName]

	local bar = CreateFrame('StatusBar', '$parent.RA_DurabilityBar', slot)
	slot.RA_DurabilityBar = bar
	bar:Hide()

	bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	bar:SetFrameStrata('HIGH')
    bar:SetFrameLevel(5)
	bar:CreateBackdrop('Transparent', nil, true)

	--! Disabled for now
	bar.Text = bar:CreateFontString(nil, 'OVERLAY')
	bar.Text:FontTemplate(LSM:Fetch('font', 'PT Sans Narrow'), 9, 'OUTLINE')
	bar.Text:SetPoint('CENTER')
	bar.Text:SetText('')

	local holder = CreateFrame('Frame', nil, bar)
	bar.Holder = holder
	bar.Holder:Point('TOPLEFT', slot, 'TOPLEFT', 0, 0 - (E.Border * 2))
	bar.Holder:Point('BOTTOMLEFT', slot, 'BOTTOMLEFT', 0, 0 + (E.Border * 2))
	bar.Holder:Point('RIGHT', slot, 'LEFT', 5, 0)
	bar:SetOrientation('VERTICAL')

	bar:SetAllPoints(bar.Holder)

	local function OnEnter()
		if bar.max and bar.max > 0 then
			bar:SetAlpha(1)
		end
	end

	local function OnLeave()
		if E.db.cataarmory.character.durability.mouseover and not bar:IsMouseOver() and not slot:IsMouseOver() then
			bar:SetAlpha(0)
		end
	end

	slot:HookScript('OnEnter', OnEnter)
    slot:HookScript('OnLeave', OnLeave)

    bar:HookScript('OnEnter', OnEnter)
    bar:HookScript('OnLeave', OnLeave)
end

function module:ConfigDurabilityBar(which, slot)
	if which and string.lower(which) ~= 'character' then return end
	if not slot or not slot.RA_DurabilityBar then return end

	local db = E.db.cataarmory.character.durability
	local slotName = slot:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = Engine.GearList[slotName]
	local bar = slot.RA_DurabilityBar
	local barDB = GetDurabilityBarSlotDB(info.slotID)
	local direction = info.direction

	--! Attached to slot
	local barThickness = module:Clamp(barDB.thickness or MIN_BAR_THICKNESS, MIN_BAR_THICKNESS, MAX_BAR_THICKNESS)
	local lengthOffset = module:Clamp(barDB.lengthOffset or 0, MIN_BAR_LENGTHOFFSET, MAX_BAR_LENGTHOFFSET)
	local myX, myY = barDB.xOffset, barDB.yOffset

	bar:SetFrameStrata(db.frameStrata)
    bar:SetFrameLevel(db.frameLevel)

	bar.Holder:ClearAllPoints()
	if barDB.anchorPoint == 'LEFT' then
		--* All Slots
		--* Vertical Bar on LEFT
		bar.Holder:Point('TOPLEFT', slot, 'TOPLEFT', 0 + E.Border + myX, 0 - E.Border + myY + lengthOffset)
		bar.Holder:Point('BOTTOMLEFT', slot, 'BOTTOMLEFT', 0 + E.Border + myX, 0 + E.Border + myY - lengthOffset)
		bar.Holder:Point('RIGHT', slot, 'LEFT', barThickness + myX, 0 + myY)
	elseif barDB.anchorPoint == 'RIGHT' then
		--* All Slots
		--* Vertical Bar on RIGHT
		bar.Holder:Point('TOPRIGHT', slot, 'TOPRIGHT', 0 - E.Border + myX, 0 - E.Border + myY + lengthOffset)
		bar.Holder:Point('BOTTOMRIGHT', slot, 'BOTTOMRIGHT', 0 - E.Border + myX, 0 + E.Border + myY - lengthOffset)
		bar.Holder:Point('LEFT', slot, 'RIGHT', - barThickness + myX, 0 + myY)
	elseif barDB.anchorPoint == 'TOP' then
		--* All Slots
		--* Horizontal Bar on TOP
		bar.Holder:Point('TOPLEFT', slot, 'TOPLEFT', 0 + E.Border + myX - lengthOffset, 0 - E.Border + myY)
		bar.Holder:Point('TOPRIGHT', slot, 'TOPRIGHT', 0 - E.Border + myX + lengthOffset, 0 - E.Border + myY)
		bar.Holder:Point('BOTTOM', slot, 'TOP', 0 + myX, - barThickness + myY)
	elseif barDB.anchorPoint == 'BOTTOM' then
		--* All Slots
		--* Horizontal Bar on BOTTOM
		bar.Holder:Point('BOTTOMLEFT', slot, 'BOTTOMLEFT', 0 + E.Border + myX - lengthOffset, 0 + E.Border + myY)
		bar.Holder:Point('BOTTOMRIGHT', slot, 'BOTTOMRIGHT', 0 - E.Border + myX + lengthOffset, 0 + E.Border + myY)
		bar.Holder:Point('TOP', slot, 'BOTTOM', 0 + myX, barThickness + myY)
	elseif barDB.anchorPoint == 'INSIDE' then
		--* Side Slots Only
		--* Vertical Bar on INSIDE
		if slot.IsLeftSide then
			--* Left Slots (Vertical Bar on RIGHT Side)
			bar.Holder:Point('TOPRIGHT', slot, 'TOPRIGHT', 0 - E.Border + myX, 0 - E.Border + myY + lengthOffset)
			bar.Holder:Point('BOTTOMRIGHT', slot, 'BOTTOMRIGHT', 0 - E.Border + myX, 0 + E.Border + myY - lengthOffset)
			bar.Holder:Point('LEFT', slot, 'RIGHT', - barThickness + myX, 0 + myY)
		else
			--* Right Slots (Vertical Bar on LEFT Side)
			bar.Holder:Point('TOPLEFT', slot, 'TOPLEFT', 0 + E.Border - myX, 0 - E.Border + myY + lengthOffset)
			bar.Holder:Point('BOTTOMLEFT', slot, 'BOTTOMLEFT', 0 + E.Border - myX, 0 + E.Border + myY - lengthOffset)
			bar.Holder:Point('RIGHT', slot, 'LEFT', barThickness - myX, 0 + myY)
		end
	elseif barDB.anchorPoint == 'OUTSIDE' then
		--* Side Slots Only
		--* Vertical Bar on OUTSIDE
		if slot.IsLeftSide then
			--* Left Slots (Vertical Bar on LEFT Side)
			bar.Holder:Point('TOPLEFT', slot, 'TOPLEFT', 0 + E.Border + myX, 0 - E.Border + myY + lengthOffset)
			bar.Holder:Point('BOTTOMLEFT', slot, 'BOTTOMLEFT', 0 + E.Border + myX, 0 + E.Border + myY - lengthOffset)
			bar.Holder:Point('RIGHT', slot, 'LEFT', barThickness + myX, 0 + myY)
		else
			--* Right Slots (Vertical Bar on RIGHT Side)
			bar.Holder:Point('TOPRIGHT', slot, 'TOPRIGHT', 0 - E.Border - myX, 0 - E.Border + myY + lengthOffset)
			bar.Holder:Point('BOTTOMRIGHT', slot, 'BOTTOMRIGHT', 0 - E.Border - myX, 0 + E.Border + myY - lengthOffset)
			bar.Holder:Point('LEFT', slot, 'RIGHT', - barThickness - myX, 0 + myY)
		end
	else
		--* Fallback if invalid anchorPoint
		bar.Holder:Point('TOPLEFT', slot, 'TOPLEFT', 0 + E.Border, 0 - E.Border + lengthOffset)
		bar.Holder:Point('BOTTOMLEFT', slot, 'BOTTOMLEFT', 0 + E.Border, 0 + E.Border - lengthOffset)
		bar.Holder:Point('RIGHT', slot, 'LEFT', barThickness, 0)
	end

	local isBarHorizontal = barDB.anchorPoint == 'TOP' or barDB.anchorPoint == 'BOTTOM'
	bar:SetOrientation(isBarHorizontal and 'HORIZONTAL' or 'VERTICAL')

	bar.Text:FontTemplate(LSM:Fetch('font', barDB.text.font), barDB.text.fontSize, barDB.text.fontOutline)

	bar.Text:SetShown(barDB.text.enable)
	bar:SetShown(db.enable)
end

function module:UpdateAvgItemLevel(which)
	if not which then return end
	local frame = _G[which..'Frame']
	if not frame then return end

	local isCharPage = which == 'Character'
	local db = E.db.cataarmory[string.lower(which)]
	local textOptions, frameOptions = db.avgItemLevel.text, db.avgItemLevel.frame

	frame.ReforgedArmory.AvgItemLevel:ClearAllPoints()
	if isCharPage then
		frame.ReforgedArmory.AvgItemLevel:SetPoint((frameOptions.attachTo == 'CharacterLevelText' or frameOptions.attachTo == 'PaperDollFrame') and 'TOP' or 'BOTTOM', frameOptions.attachTo, (frameOptions.attachTo == 'CharacterLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	else
		frame.ReforgedArmory.AvgItemLevel:SetPoint('TOP', frameOptions.attachTo, (frameOptions.attachTo == 'InspectLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	end
	frame.ReforgedArmory.AvgItemLevel:SetHeight(textOptions.fontSize + 6)
	frame.ReforgedArmory.AvgItemLevel:SetShown(db.avgItemLevel.enable)

	frame.ReforgedArmory.AvgItemLevel.Background:SetShown(frameOptions.showBGTexture)
	frame.ReforgedArmory.AvgItemLevel.BottomLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	frame.ReforgedArmory.AvgItemLevel.BottomLine:SetShown(frameOptions.showLines)
	frame.ReforgedArmory.AvgItemLevel.TopLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	frame.ReforgedArmory.AvgItemLevel.TopLine:SetShown(frameOptions.showLines)

	frame.ReforgedArmory.AvgItemLevel.Text:FontTemplate(LSM:Fetch('font', textOptions.font), textOptions.fontSize, textOptions.fontOutline)
	frame.ReforgedArmory.AvgItemLevel.Text:ClearAllPoints()
	frame.ReforgedArmory.AvgItemLevel.Text:SetPoint('CENTER', frame.ReforgedArmory.AvgItemLevel, 'CENTER', textOptions.xOffset, textOptions.yOffset)
end

function module:UpdateSlotBackground(which, slot)
	if not which or not slot.ReforgedArmory.SlotBackground then return end

	local db = E.db.cataarmory[string.lower(which)]
	local slotName = slot:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = Engine.GearList[slotName]
	local direction = info.direction
	local color = db.slotBackground.color

	local point, relativePoint, x, y = module:GetSlotBackgroundPoints(info.slotID, db)
	if direction then
		slot.ReforgedArmory.SlotBackground:ClearAllPoints()
		slot.ReforgedArmory.SlotBackground:SetPoint(point, slot, relativePoint, x, y)
		slot.ReforgedArmory.SlotBackground:Size(132, 41)
		slot.ReforgedArmory.SlotBackground:SetTexture(GradientTexture)
		slot.ReforgedArmory.SlotBackground:SetVertexColor(color.r, color.g, color.b)
		if direction == 'LEFT' then
			slot.ReforgedArmory.SlotBackground:SetTexCoord(0, 1, 0, 1)
		else
			slot.ReforgedArmory.SlotBackground:SetTexCoord(1, 0, 0, 1)
		end

		slot.ReforgedArmory.SlotBackground:SetShown(db.slotBackground.enable)
	end
end

function module:UpdateItemLevelText(which, slot)
	if not which or not slot.ReforgedArmory.ItemLevelText then return end

	local db = E.db.cataarmory[string.lower(which)]

	slot.ReforgedArmory.ItemLevelText:ClearAllPoints()
	slot.ReforgedArmory.ItemLevelText:SetPoint('BOTTOM', slot, db.itemLevel.xOffset, db.itemLevel.yOffset)
	slot.ReforgedArmory.ItemLevelText:FontTemplate(LSM:Fetch('font', db.itemLevel.font), db.itemLevel.fontSize, db.itemLevel.fontOutline)
	slot.ReforgedArmory.ItemLevelText:SetShown(db.itemLevel.enable)
end

function module:CreateGemTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	texture:SetPoint(point, (gemStep == 1 and slot) or slot['RA_GemSlot'..prevGem], relativePoint, (gemStep == 1 and x) or spacing, (gemStep == 1 and x) or y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, (gemStep == 1 and slot) or slot['RA_GemSlot'..prevGem..'Backdrop'])
	backdrop:SetTemplate(nil, nil, true)
	backdrop:SetBackdropColor(0,0,0,0)
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function module:GetEnchantPoints(id, db)
	if not id or not db then return end
	local x, y = db.enchant.xOffset, db.enchant.yOffset
	local spacing = db.enchant.spacing or 0

	local MainHandSlot = db.enchant.MainHandSlot
	local SecondaryHandSlot = db.enchant.SecondaryHandSlot
	local RangedSlot = db.enchant.RangedSlot

	if id <= 5 or (id == 9 or id == 15) then						--* Left Side
		return Engine.Values.SIDE_SLOTS_DIRECTION_TO_POINT['LEFT'][db.enchant.growthDirection], Engine.Values.SIDE_SLOTS_ANCHORPOINTS[db.enchant.anchorPoint], x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then	--* Right Side
		return Engine.Values.SIDE_SLOTS_DIRECTION_TO_POINT['RIGHT'][db.enchant.growthDirection], Engine.Values.MIRROR_ANCHORPOINT[Engine.Values.SIDE_SLOTS_ANCHORPOINTS[db.enchant.anchorPoint]], -x, y, -spacing
	elseif id == 16 then											--* MainHandSlot
		return Engine.Values.DIRECTION_TO_POINT[MainHandSlot.growthDirection], MainHandSlot.anchorPoint, MainHandSlot.xOffset, MainHandSlot.yOffset, -spacing
	elseif id == 17 then											--* SecondaryHandSlot
		return Engine.Values.DIRECTION_TO_POINT[SecondaryHandSlot.growthDirection], SecondaryHandSlot.anchorPoint, SecondaryHandSlot.xOffset, SecondaryHandSlot.yOffset, -spacing
	else															--* RangedSlot
		return Engine.Values.DIRECTION_TO_POINT[RangedSlot.growthDirection], RangedSlot.anchorPoint, RangedSlot.xOffset, RangedSlot.yOffset, spacing
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

	if frame.ReforgedArmory.AvgItemLevel then
		frame.ReforgedArmory.AvgItemLevel:Hide()
		frame.ReforgedArmory.AvgItemLevel.Text:SetText('')
	end

	for slotName, info in pairs(Engine.GearList) do
		local slot = _G[which..slotName]

		if not info.ignored then
			slot.ReforgedArmory.EnchantText:SetText('')
			slot.ReforgedArmory.ItemLevelText:SetText('')
			slot.ReforgedArmory.Warning:Hide()

			for y = 1, 5 do
				slot['RA_GemSlot'..y]:SetTexture()
				slot['RA_GemSlot'..y..'Backdrop']:Hide()
			end
		end
		if slot.ReforgedArmory.SlotBackground then
			slot.ReforgedArmory.SlotBackground:Hide()
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
	local info = Engine.GearList[slotName]
	local canEnchant = (which == 'Character' and info.isCharProf) or info.canEnchant
	local direction = info.direction
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.inpsect

	--* Slot Background
	if direction then
		if not inspectItem.ReforgedArmory.SlotBackground then
			inspectItem.ReforgedArmory.SlotBackground = inspectItem:CreateTexture(nil, 'BACKGROUND')
		end
		module:UpdateSlotBackground(which, inspectItem)
	end

	if not info.ignored then
		do
			local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
			inspectItem.ReforgedArmory.EnchantText:ClearAllPoints()
			inspectItem.ReforgedArmory.EnchantText:SetPoint(point, inspectItem, relativePoint, x, y)
			inspectItem.ReforgedArmory.EnchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)

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
				inspectItem.ReforgedArmory.Warning.Reason = warningMsg
			end

			local showWarning = missingEnchant or missingGem or missingBuckle or false
			if direction and inspectItem.ReforgedArmory.SlotBackground then
				local warnColor = (showWarning and db.slotBackground.warning.enable) and db.slotBackground.warning.color or db.slotBackground.color
				inspectItem.ReforgedArmory.SlotBackground:SetVertexColor(warnColor.r, warnColor.g, warnColor.b)
			end
			inspectItem.ReforgedArmory.Warning:SetShown(db.warningIndicator.enable and showWarning)

			inspectItem.ReforgedArmory.EnchantText:SetText(slotInfo.enchantText)
			inspectItem.ReforgedArmory.EnchantText:SetShown(db.enchant.enable)
			local enchantTextColor = (db.enchant.qualityColor and slotInfo.itemQualityColors) or db.enchant.color
			if enchantTextColor and next(enchantTextColor) then
				inspectItem.ReforgedArmory.EnchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
			end
		end
	end

	module:UpdateItemLevelText(which, inspectItem)
	local iLvlTextColor = (db.itemLevel.qualityColor and slotInfo.itemQualityColors) or db.itemLevel.color
	if iLvlTextColor and next(iLvlTextColor) then
		inspectItem.ReforgedArmory.ItemLevelText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
	end
	inspectItem.ReforgedArmory.ItemLevelText:SetText(slotInfo.itemLevel)

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

		--* Durability
		UpdateSlotDurabilityBar(inspectItem.RA_DurabilityBar, db.durability, slotInfo)
	end

	do
		local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
		local gemStep = 1
		for index = 1, 5 do
			local texture = inspectItem['RA_GemSlot'..index]
			texture:Size(db.gems.size)
			texture:ClearAllPoints()
			texture:SetPoint(point, (index == 1 and inspectItem) or inspectItem['RA_GemSlot'..(index-1)], relativePoint, index == 1 and x or spacing, index == 1 and y or 0)

			local backdrop = inspectItem['RA_GemSlot'..index..'Backdrop']
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
		frame.ReforgedArmory.AvgItemLevel.Text:SetText(avgItemLevel)
		frame.ReforgedArmory.AvgItemLevel.Text:SetTextColor(textOptions.color.r, textOptions.color.g, textOptions.color.b)
	else
		frame.ReforgedArmory.AvgItemLevel.Text:SetText('')
	end

	frame.ReforgedArmory.AvgItemLevel:SetHeight(textOptions.fontSize + 6)
	frame.ReforgedArmory.AvgItemLevel:SetShown(db.avgItemLevel.enable)
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
		for slotName, info in pairs(Engine.GearList) do
			local slot = _G[which..slotName]
			if not info.ignored then
				slot.ReforgedArmory.EnchantText:SetText('')
				slot.ReforgedArmory.ItemLevelText:SetText('')

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

	local textFrame = CreateFrame('Frame', 'ReforgedArmory.'..which..'_AvgItemLevel', (isCharPage and PaperDollFrame) or InspectPaperDollFrame)
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

	frame.ReforgedArmory.AvgItemLevel = textFrame
	frame.ReforgedArmory.AvgItemLevel.Text = text

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
	local itemLevel, enchant = db.itemLevel, db.enchant
	frame.ReforgedArmory = frame.ReforgedArmory or {}

	CreateAvgItemLevel(frame, which)

	for slotName, info in pairs(Engine.GearList) do
		local slot = _G[which..slotName]
		slot.ReforgedArmory = slot.ReforgedArmory or {}

		if not info.ignored then
			--* Item Level
			if not slot.ReforgedArmory.ItemLevelText then
				slot.ReforgedArmory.ItemLevelText = slot:CreateFontString(nil, 'OVERLAY')
			end
			module:UpdateItemLevelText(which, slot)

			--* Warning
			if not slot.ReforgedArmory.Warning then
				slot.ReforgedArmory.Warning = CreateFrame('Frame', nil, slot)
			end

			do
				local point1, relativePoint1, point2, relativePoint2, size, x1, y1, x2, y2, spacing = module:GetWarningPoints(info.slotID, db)
				slot.ReforgedArmory.Warning:SetPoint(point1, slot, relativePoint1, x1, y1)
				slot.ReforgedArmory.Warning:SetPoint(point2, slot, relativePoint2, x2, y2)
				slot.ReforgedArmory.Warning:Size(size)
				slot.ReforgedArmory.Warning.texture = slot.ReforgedArmory.Warning:CreateTexture(nil, 'BACKGROUND')
				slot.ReforgedArmory.Warning.texture:SetInside()
				slot.ReforgedArmory.Warning.texture:SetTexture(WarningTexture)
				slot.ReforgedArmory.Warning.texture:SetVertexColor(1, 0, 0, 1)
				slot.ReforgedArmory.Warning:SetFrameLevel(3)
				slot.ReforgedArmory.Warning:SetScript('OnEnter', Warning_OnEnter)
				slot.ReforgedArmory.Warning:SetScript('OnLeave', Warning_OnLeave)
				slot.ReforgedArmory.Warning:Hide()
			end

			--* Enchant Text
			if not slot.ReforgedArmory.EnchantText then
				slot.ReforgedArmory.EnchantText = slot:CreateFontString(nil, 'OVERLAY')
			end
			slot.ReforgedArmory.EnchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)

			do
				local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
				slot.ReforgedArmory.EnchantText:ClearAllPoints()
				slot.ReforgedArmory.EnchantText:SetPoint(point, slot, relativePoint, x, y)
			end

			do
				local point, relativePoint, x, y, spacing = module:GetGemPoints(info.slotID, db)
				for u = 1, 5 do
					slot['RA_GemSlot'..u], slot['RA_GemSlot'..u..'Backdrop'] = module:CreateGemTexture(slot, point, relativePoint, x, y, u, spacing)
				end
			end

			if which == 'Character' then
				--* Durability Bar
				CreateDurabilityBar(which, slot)
				module:ConfigDurabilityBar(which, slot)
			end
		end

		--* Slot Background
		if info.direction then
			if not slot.ReforgedArmory.SlotBackground then
				slot.ReforgedArmory.SlotBackground = slot:CreateTexture(nil, 'BACKGROUND')
			end
			module:UpdateSlotBackground(which, slot)
		end
	end
end

function module:InspectFrame_OnShow()
	local frame = _G.InspectFrame
	if not frame or frame.InspectInfoHooked then return end
	local isSkinned = E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect

	--* Move Rotate Buttons on InspectFrame
	if isSkinned then
		_G.InspectModelFrameRotateLeftButton:ClearAllPoints()
		_G.InspectModelFrameRotateLeftButton:SetPoint('TOPLEFT', _G.InspectFrame, 'TOPLEFT', 3, -3)
		_G.InspectModelFrameRotateLeftButton:Show()
		_G.InspectModelFrameRotateRightButton:ClearAllPoints()
		_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)
		_G.InspectModelFrameRotateRightButton:Show()

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
	local itemLevel, enchant, durability = db.itemLevel, db.enchant, db.durability

	module:UpdateAvgItemLevel(which)
	if isCharPage then
		local controlsDisplayMode = db.model.controlsDisplayMode
		if controlsDisplayMode == 'SHOW' then
			_G.CharacterModelScene.ControlFrame:Show()
		else
			_G.CharacterModelScene.ControlFrame:Hide()
		end
	end

	local slot, quality, iLvlTextColor, enchantTextColor
	local qualityColor = {}
	for slotName, info in pairs(Engine.GearList) do
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
					slot.ReforgedArmory.ItemLevelText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
				end

				do
					local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
					slot.ReforgedArmory.EnchantText:ClearAllPoints()
					slot.ReforgedArmory.EnchantText:SetPoint(point, slot, relativePoint, x, y)
				end

				slot.ReforgedArmory.EnchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
				enchantTextColor = (enchant.qualityColor and qualityColor) or enchant.color
				if enchantTextColor and next(enchantTextColor) then
					slot.ReforgedArmory.EnchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
				end
				slot.ReforgedArmory.EnchantText:SetShown(enchant.enable)
			end

			if force then
				module:UpdateSlotBackground(which, slot)
				module:ConfigDurabilityBar(which, slot)
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

local githubURL = 'https://github.com/Repooc/ReforgedArmory/issues'
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
	slotInfo.durability = {}

	local enchantID

	if itemLink then
		if UnitLevel(unit) >= 70 and slot == 6 and (#slotInfo.filledSockets + #slotInfo.emptySockets <= slotInfo.baseSocketCount) then
			slotInfo.missingBeltBuckle = true
		end

		--* Get Item Quality Info
		local quality = GetInventoryItemQuality(unit, slot)
		if quality then
			slotInfo.itemQualityColors.r, slotInfo.itemQualityColors.g, slotInfo.itemQualityColors.b = GetItemQualityColor(quality)
		end

		--* Get Item Level Info
		local itemLevel = GetDetailedItemLevelInfo(itemLink)
		slotInfo.itemLevel = tonumber(itemLevel)
		enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))

		do
			--* Get Durability Info
			local current, max = GetInventoryItemDurability(slot)
			if current and max and max > 0 then
				local percent = current / max * 100
				slotInfo.durability.current = current
				slotInfo.durability.max = max
				slotInfo.durability.percent = percent
			else
				slotInfo.durability.current = 0
				slotInfo.durability.max = 0
				slotInfo.durability.percent = 0
			end
		end
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

local function ControlFrame_OnShow(frame)
	local db = E.db.cataarmory.character.model
	local controlsDisplayMode = db.controlsDisplayMode
	if controlsDisplayMode == 'SHOW' then
		frame:Show()
	elseif controlsDisplayMode == 'HIDE' then
		frame:Hide()
	end
end

local function ControlFrame_OnEnter(frame)
	local db = E.db.cataarmory.character.model
	local controlsDisplayMode = db.controlsDisplayMode
	if controlsDisplayMode == 'HIDE' then
		frame:Hide()
	end

end

local function ControlFrame_OnLeave()
	local db = E.db.cataarmory.character.model
	local controlsDisplayMode = db.controlsDisplayMode
	if controlsDisplayMode == 'SHOW' then
		_G.CharacterModelScene.ControlFrame:Show()
	end
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

		if not frame.ReforgedArmory_Hooked then
			_G.CharacterModelScene.BackgroundTopLeft:Hide()
			_G.CharacterModelScene.BackgroundTopRight:Hide()
			_G.CharacterModelScene.BackgroundBotLeft:Hide()
			_G.CharacterModelScene.BackgroundBotRight:Hide()
			_G.CharacterModelScene.backdrop:Hide()
			_G.CharacterModelScene.BackgroundOverlay:Hide() --! Maybe use this over background images?
			_G.CharacterModelScene.ControlFrame:HookScript('OnEnter', ControlFrame_OnEnter)
			_G.CharacterModelScene.ControlFrame:HookScript('OnLeave', ControlFrame_OnLeave)
			_G.CharacterModelScene.ControlFrame:HookScript('OnShow', ControlFrame_OnShow)
			_G.CharacterModelScene:HookScript('OnLeave', ControlFrame_OnLeave)
		end

		local controlsDisplayMode = E.db.cataarmory.character.model.controlsDisplayMode
		if controlsDisplayMode == 'SHOW' then
			_G.CharacterModelScene.ControlFrame:Show()
		else
			_G.CharacterModelScene.ControlFrame:Hide()
		end

		frame.BottomLeftCorner:ClearAllPoints()
		frame.BottomLeftCorner:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, -26)
		frame.BottomRightCorner:ClearAllPoints()
		frame.BottomRightCorner:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -26)

		frame.ReforgedArmory_Hooked = true
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
