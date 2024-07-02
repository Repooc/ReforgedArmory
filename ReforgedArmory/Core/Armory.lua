local RA, L, P, G = unpack(ReforgedArmory)

local utf8sub = string.utf8sub
local githubURL = 'https://github.com/Repooc/ReforgedArmory/issues'

function RA:CreateAvgItemLevel(frame, which)
	if not frame or not which then return end

	local db = RA.db[which]
	local textOptions, frameOptions = db.avgItemLevel.text, db.avgItemLevel.frame
	local isCharPage = which == 'character'

	local textFrame = CreateFrame('Frame', nil, isCharPage and (RA.Cata and _G.CharacterStatsPane or _G.PaperDollFrame) or _G.InspectPaperDollFrame)
	textFrame:SetSize(170, 30)
	textFrame:ClearAllPoints()

	if isCharPage then
		print('frameOptions', frameOptions.attachTo)
		textFrame:SetPoint((frameOptions.attachTo == 'CharacterFrameInsetRight' or frameOptions.attachTo == 'CharacterLevelText' or frameOptions.attachTo == 'PaperDollFrame') and 'TOP' or 'BOTTOM', frameOptions.attachTo, (frameOptions.attachTo == 'CharacterLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	else
		textFrame:SetPoint('TOP', frameOptions.attachTo, (frameOptions.attachTo == 'InspectLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	end

	if not textFrame.Background then
		textFrame.Background = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.Background:SetTexture([[Interface\LevelUp\LevelUpTex]])
	-- textFrame.Background:SetTexture(1400895)
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
	textFrame.TopLine:SetSize(textFrame:GetWidth(), 7)

	if not textFrame.BottomLine then
		textFrame.BottomLine = textFrame:CreateTexture(nil, 'BACKGROUND')
	end
	textFrame.BottomLine:SetDrawLayer('BACKGROUND', 2)
	textFrame.BottomLine:SetTexture([[Interface\LevelUp\LevelUpTex]])
	textFrame.BottomLine:ClearAllPoints()
	textFrame.BottomLine:SetPoint('BOTTOM', textFrame.Background, 0, 0)
	textFrame.BottomLine:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	textFrame.BottomLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	textFrame.BottomLine:SetSize(textFrame:GetWidth(), 7)

	local text = textFrame:CreateFontString(nil, 'OVERLAY')
	text:SetFont(RA.Libs.LSM:Fetch('font', textOptions.font), textOptions.fontSize, textOptions.fontOutline)
	-- text:SetText('')
	text:SetText('0')
	text:SetPoint('CENTER', textOptions.xOffset, textOptions.yOffset)
	text:SetTextColor(textOptions.color.r, textOptions.color.g, textOptions.color.b)

	frame.RA_AvgItemLevel = textFrame
	frame.RA_AvgItemLevel.Text = text

	-- textFrame:Hide()
	textFrame:Show()
end

-- maybe pass frame (or both frame & which) instead? depends on where this is called
function RA:UpdateAvgItemLevel(frame, unit)
	if not unit then return end
	local which = unit == 'player' and 'Character' or 'Inspect'
	local frame = _G[which..'Frame']
	if not frame then return end

	local isCharPage = which == 'Character'
	local db = RA.db[strlower(which)]
	local textOptions, frameOptions = db.avgItemLevel.text, db.avgItemLevel.frame

	frame.RA_AvgItemLevel:ClearAllPoints()
	if isCharPage then
		frame.RA_AvgItemLevel:SetPoint((frameOptions.attachTo == 'CharacterFrameInsetRight' or frameOptions.attachTo == 'CharacterLevelText' or frameOptions.attachTo == 'PaperDollFrame') and 'TOP' or 'BOTTOM', frameOptions.attachTo, (frameOptions.attachTo == 'CharacterLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
		print('yOffset', frameOptions.yOffset)
	else
		frame.RA_AvgItemLevel:SetPoint('TOP', frameOptions.attachTo, (frameOptions.attachTo == 'InspectLevelText') and 'BOTTOM' or 'TOP', frameOptions.xOffset, frameOptions.yOffset)
	end
	frame.RA_AvgItemLevel:SetHeight(textOptions.fontSize + 6)
	frame.RA_AvgItemLevel:SetShown(db.avgItemLevel.enable)

	frame.RA_AvgItemLevel.Background:SetShown(frameOptions.showBGTexture)
	frame.RA_AvgItemLevel.BottomLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	frame.RA_AvgItemLevel.BottomLine:SetShown(frameOptions.showLines)
	frame.RA_AvgItemLevel.TopLine:SetVertexColor(frameOptions.color.r, frameOptions.color.g, frameOptions.color.b, frameOptions.color.a)
	frame.RA_AvgItemLevel.TopLine:SetShown(frameOptions.showLines)

	frame.RA_AvgItemLevel.Text:SetFont(RA.Libs.LSM:Fetch('font', textOptions.font), textOptions.fontSize, textOptions.fontOutline)
	frame.RA_AvgItemLevel.Text:ClearAllPoints()
	frame.RA_AvgItemLevel.Text:SetPoint('CENTER', frame.RA_AvgItemLevel, 'CENTER', textOptions.xOffset, textOptions.yOffset)
end

local container
function RA:UpdateAverageString(frame, unit)
	local mainhandEquipLoc, offhandEquipLoc
  	local items = {}
	if not container then container = ContinuableContainer:Create() end
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
			local itemID = GetInventoryItemID(unit, slot)
			local itemLink = GetInventoryItemLink(unit, slot)

			if itemLink or itemID then
				local item = itemLink and Item:CreateFromItemLink(itemLink) or Item:CreateFromItemID(itemID)
				container:AddContinuable(item)
				tinsert(items, item)

				local equipLoc = select(4, C_Item.GetItemInfoInstant(itemLink or itemID))
				if slot == INVSLOT_MAINHAND then mainhandEquipLoc = equipLoc end
				if slot == INVSLOT_OFFHAND then offhandEquipLoc = equipLoc end
			end
		end
	end
	local numSlots
	if mainhandEquipLoc and offhandEquipLoc then
		numSlots = 16
	else
		local isFuryWarrior = select(2, UnitClass(unit)) == 'WARRIOR'

		if unit == 'player' then
			isFuryWarrior = isFuryWarrior and IsSpellKnown(46917) -- knows titan's grip
		else
			isFuryWarrior = isFuryWarrior and _G.GetInspectSpecialization and GetInspectSpecialization(unit) == 72
			if RA.Cata then
				local tabCount = GetNumTalentTabs(true)
				local specInfo = {}
				local tempName, tempPointsSpent, _ = '', 0
				local name, pointsSpent, highestTab = '', 0, 0

				for tab = 1, tabCount do
					_, tempName, _, _, tempPointsSpent = GetTalentTabInfo(tab, true, nil, 1)

					if (tempPointsSpent > pointsSpent) then
						name = tempName
						pointsSpent = tempPointsSpent
						highestTab = tab
					end
				end

				isFuryWarrior = highestTab == 1
			end
		end
		-- unit is holding a one-handed weapon, a main-handed weapon, or a 2h weapon while Fury: 16 slots
		-- otherwise 15 slots
		local equippedLocation = mainhandEquipLoc or offhandEquipLoc
		numSlots = (equippedLocation == 'INVTYPE_WEAPON' or equippedLocation == 'INVTYPE_WEAPONMAINHAND' or (equippedLocation == 'INVTYPE_2HWEAPON' and isFuryWarrior)) and 16 or 15
	end
	if RA.Classic then numSlots = numSlots + 1 end -- ranged slot exists in classic
	container:ContinueOnLoad(function()
		local totalLevel = 0
		for _, item in ipairs(items) do
			totalLevel = totalLevel + item:GetCurrentItemLevel()
		end
		-- print(totalLevel, totalLevel / numSlots)
		-- fontstring:SetFormattedText(ITEM_LEVEL, totalLevel / numSlots)
		frame.RA_AvgItemLevel.Text:SetText(totalLevel / numSlots)
		-- fontstring:Show()
	end)
end

local function UpdateBorderQualityColor(button, slotInfo, which)
	if not button or not which then return end
	slotInfo = slotInfo or {}
	local qualityColor = slotInfo.qualityColor
	local quality = slotInfo.quality
	local isSkinned = ElvUI and (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.inspect)
	local isCharPage = which == 'character'

	-- if which == 'character' then
	-- 	if quality and quality >= 0 then
	-- 		if isSkinned then
	-- 			button:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b)
	-- 		else
	-- 			button.IconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
	-- 			button.IconBorder:Show()
	-- 		end
	-- 	else
	-- 		if isSkinned then
	-- 			button:SetBackdropBorderColor(unpack(ElvUI[1].media.bordercolor))
	-- 		else
	-- 			button.IconBorder:SetVertexColor(1, 1, 1)
	-- 			button.IconBorder:SetShown(quality and true or false)
	-- 		end
	-- 	end
	-- elseif which == 'inspect' then
	-- 	if quality and quality >= 0 then
	-- 		if isSkinned then
	-- 			button.backdrop:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b)
	-- 		else
	-- 			button.IconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
	-- 			button.IconBorder:Show()
	-- 		end
	-- 	else
	-- 		-- if RA.Cata and isSkinned then
	-- 		if isSkinned then
	-- 			button.backdrop:SetBackdropBorderColor(unpack(ElvUI[1].media.bordercolor))
	-- 		else
	-- 			button.IconBorder:SetVertexColor(1, 1, 1)
	-- 			button.IconBorder:SetShown(quality and true or false)
	-- 		end
	-- 	end
	-- end

	if quality and quality >= 0 then
		if isSkinned then
			if isCharPage then
				button:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b)
			else
				if RA.Cata or RA.Classic then
					button.backdrop:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b)
				elseif RA.Retail then
					button.IconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				end
			end
		else
			button.IconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
			button.IconBorder:SetShown(quality and true or false)
		end
	else
		if isSkinned then
			if isCharPage then
				button:SetBackdropBorderColor(unpack(ElvUI[1].media.bordercolor))
			else
				button.backdrop:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b)
			end
		else
			button.IconBorder:SetVertexColor(1, 1, 1)
			button.IconBorder:SetShown(quality and true or false)
		end
	end
end

local GradientTexture = [[Interface\AddOns\ReforgedArmory\Media\Gradient]]
local WarningTexture = [[Interface\AddOns\ElvUI\Core\Media\Textures\Minimalist]]

local function SetupButtonObjects(slot, which)
	if not slot or not which then return end
	local db = RA.db[which]
	local slotName = slot:GetName():gsub('Character', ''):gsub('Inspect', '')
	local info = RA.GearList[slotName]

	if info and not slot.RA_BGFrame then
		slot.RA_BGFrame = CreateFrame('Frame', nil, slot)
		slot.RA_BGFrame:SetFrameLevel(slot:GetFrameLevel() - 1)

		slot.RA_SlotBackground = slot.RA_BGFrame:CreateTexture(nil, 'BACKGROUND', nil, 1)

		local color = db.slotBackground.color
		-- local point, relativePoint, x, y = RA:GetSlotBackgroundPoints(info.slotID, RA.db[which])
		local point1, relativePoint1, point2, relativePoint2, xOffset, yOffset, topOffset, bottomOffset, width = RA:GetSlotBackgroundPoints(info.slotID, RA.db[which])
		if info.direction then
			-- slot.RA_SlotBackground:ClearAllPoints()
			slot.RA_BGFrame:ClearAllPoints()
			-- -- slot.RA_SlotBackground:SetPoint(point, slot, relativePoint, x, y)
			-- slot.RA_SlotBackground:SetPoint(point1, slot, relativePoint1, xOffset, topOffset)
			-- slot.RA_SlotBackground:SetPoint(point2, slot, relativePoint2, width, bottomOffset)
			slot.RA_BGFrame:SetPoint(point1, slot, relativePoint1, xOffset, topOffset)
			slot.RA_BGFrame:SetPoint(point2, slot, relativePoint2, width, bottomOffset == 0 and 0 or bottomOffset)
			slot.RA_SlotBackground:SetAllPoints(slot.RA_BGFrame)
			-- -- slot.RA_SlotBackground:SetSize(132, slot:GetHeight())
			slot.RA_SlotBackground:SetTexture(GradientTexture)
			slot.RA_SlotBackground:SetVertexColor(color.r, color.g, color.b)
			if info.direction == 'LEFT' then
				slot.RA_SlotBackground:SetTexCoord(0, 1, 0, 1)
			else
				slot.RA_SlotBackground:SetTexCoord(1, 0, 0, 1)
			end
		end
	end

	if info then
		if not slot.RA_EnchantText then
			slot.RA_EnchantText = slot:CreateFontString(nil, 'OVERLAY')
			slot.RA_EnchantText:SetPoint('BOTTOM', slot, db.enchant.xOffset, db.enchant.yOffset)
			slot.RA_EnchantText:SetFont(RA.Libs.LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)
			slot.RA_EnchantText:SetShown(db.enchant.enable)
		end
		if not slot.RA_ItemLevelText then
			slot.RA_ItemLevelText = slot:CreateFontString(nil, 'OVERLAY')
			slot.RA_ItemLevelText:SetPoint('BOTTOM', slot, db.itemLevel.xOffset, db.itemLevel.yOffset)
			-- slot.RA_ItemLevelText:SetPoint('BOTTOM', slot, db.itemLevel.xOffset, db.itemLevel.yOffset)
			slot.RA_ItemLevelText:SetFont(RA.Libs.LSM:Fetch('font', db.itemLevel.font), db.itemLevel.fontSize, db.itemLevel.fontOutline)
			slot.RA_ItemLevelText:SetShown(db.itemLevel.enable)
			-- slot.RA_ItemLevelText:SetShown(true)
		end
	elseif not slot.RA_ItemLevelText and string.match(slotName, 'EquipmentFlyoutFrameButton') then
		slot.RA_ItemLevelText = slot:CreateFontString(nil, 'OVERLAY')
		slot.RA_ItemLevelText:SetPoint('BOTTOM', slot, db.flyoutText.xOffset, db.flyoutText.yOffset)
		slot.RA_ItemLevelText:SetFont(RA.Libs.LSM:Fetch('font', db.flyoutText.font), db.flyoutText.fontSize, db.flyoutText.fontOutline)
		slot.RA_ItemLevelText:SetShown(db.flyoutText.enable)
		slot.isFlyout = true
	end

	if slot.RA_SlotBackground then
		slot.RA_SlotBackground:SetShown(not RA.Classic and db.slotBackground.enable or false)
		-- slot.RA_SlotBackground:SetShown(true)
	end
end

--* Cache MissingIDs from our database
local InfoColor = '|cff1784d1' -- blue
local InfoColor2 = '|cff9b9b9b' -- silver
local missingIDs = {}
local function GetSlotInfo(slot, item, unit)
	if not item or item:IsItemEmpty() then return end
	local which = unit == 'player' and 'Character' or 'Inspect'

	local itemLevel = item:GetCurrentItemLevel() or ''
	if slot == _G[which..'TabardSlot'] then itemLevel = '' end

	local quality = item:GetItemQuality()
	local qualityColor = item:GetItemQualityColor()
	local itemLink = item:GetItemLink()
	local enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))
	local enchantText, enchantTextShort, enchantTextReal
	-- DevTools_Dump(item)
	if enchantID then
		local userReplacedText = RA.global.enchantStrings.UserReplaced[enchantID] or RA.global.enchantStrings.UserAdded[enchantID]

		if userReplacedText then
			enchantText = userReplacedText
			enchantTextShort = utf8sub(userReplacedText, 1, 18) or userReplacedText
			enchantTextReal = userReplacedText
		else
			enchantText = RA.Libs.GetEnchantList.LibGetEnchantDB[enchantID]
			enchantTextShort = enchantText and utf8sub(enchantText, 1, 18)
			enchantTextReal = enchantText

			if RA.Retail and not enchantText then
				enchantText, enchantTextShort, enchantTextReal = RA.ScanTooltip:GetEnchantInfo(unit, item.itemLocation and item.itemLocation.equipmentSlotIndex or slot:GetID())
			end

			if not RA.Libs.GetEnchantList.LibGetEnchantDB[enchantID] and not missingIDs[enchantID] then
				local msg = format('|rPlease open a ticket at |cff16c3f2[|r*|Hurl:'..githubURL..'|h'..githubURL..'|h|r|cff16c3f2]|r|n|cff16c3f2[|r*Click|r|cff16c3f2/|r*Mouseover|r|cff16c3f2]|r item to show the tooltip. Take a screenshot showing the tooltip with the enchant text AND id so it can be added to our database.|n*Missing EnchantID|r: |cff16c3f2%s|r|n*Equipment|r: %s|n*Missing String|r: |cff16c3f2%s|r|n|n|cffFF0000If you do not provide the needed info or post a duplicate ticket, it will be closed without a response. If you realized your mistake and have the correct info, feel free to open the ticket with the proper info.|r', enchantID, itemLink, RA.Retail and enchantText or 'N/A'):gsub('*', InfoColor)
				-- if not userReplacedText then
				-- 	msg = msg .. '|n|cffFF3300You can now add any missing enchant id manually while you wait for me to update the database.|nYou can use |cff9b9b9b/ra|r to open the config and navigate to the Enchant Strings settings.'
				-- end

				RA:Print(msg)
				missingIDs[enchantID] = true
			end
		end
	else
		enchantText, enchantTextShort, enchantTextReal = '', '', ''
	end

	return {
		itemLevel = itemLevel,
		quality = quality,
		qualityColor = qualityColor,
		itemLink = itemLink,
		enchantID = enchantID,
		enchantText = enchantText,
		enchantTextShort = enchantTextShort,
		enchantTextReal = enchantTextReal,
		-- missingGems = ns.ItemHasEmptySlots(itemLink),
		-- missingEnchants = ns.ItemIsMissingEnchants(itemLink),
		-- upgrade = ItemIsUpgrade(item),
	}
end

local function UpdateItemLevel(slot, slotInfo)
	-- print('UpdateItemLevel', slotInfo.itemLevel)
	if not slot or not slotInfo then return end
	local db = slot.isFlyout and RA.db[slotInfo.dbKey].flyoutText or RA.db[slotInfo.dbKey].itemLevel

	slot.RA_ItemLevelText:SetText(slotInfo.itemLevel)
	slot.RA_ItemLevelText:SetShown(db.enable)
end

local function UpdateEnchantText(slot, slotInfo)
	if not slot or not slotInfo then return end
	local db = RA.db[slotInfo.dbKey].enchant
	-- print('update', slotInfo.enchantID, slotInfo.enchantText, slotInfo.enchantTextShort, slotInfo.enchantTextReal)


	slot.RA_EnchantText:SetText(slotInfo.enchantText)
	slot.RA_EnchantText:SetShown(db.enable)
end

local function UpdateButtonFromItem(slot, item, which, suppress)
	local slotInfo = {}
	SetupButtonObjects(slot, which)
	if not item then return end
	if item:IsItemEmpty() then UpdateBorderQualityColor(slot, slotInfo, which) return end
	item:ContinueOnItemLoad(function()
		-- if not ShouldShowOnItem(item) then return end
		--* Update Objects Items
		-- if slot:GetName() == 'InspectWaistSlot' then
		-- 	print('Before GetSlotInfoCall', slotInfo and slotInfo.itemLevel)
		-- end
		local unit = which == 'character' and 'player' or 'target'
		slotInfo = GetSlotInfo(slot, item, unit)

		-- print('UpdateButtonFromItem', RA.ScanTooltip:GetEnchantInfo(unit or 'player', slot:GetID()))

		-- slotInfo.enchantText, slotInfo.enchantTextShort, slotInfo.enchantTextReal = RA.ScanTooltip:GetEnchantInfo(unit, slot:GetID())

		slotInfo.dbKey = which
		slotInfo.name = slot:GetName()

		UpdateBorderQualityColor(slot, slotInfo, which)
		UpdateItemLevel(slot, slotInfo)
		UpdateEnchantText(slot, slotInfo)
		-- local details = DetailsFromItem(item)
		-- if not suppress.level then AddLevelToButton(button, details) end
		-- if not suppress.upgrade then AddUpgradeToButton(button, details) end
		-- if not suppress.bound then AddBoundToButton(button, details) end
		-- if (which == "character" or which == "inspect" or not db.missingcharacter) then
		--     if not suppress.missing then AddMissingToButton(button, details) end
		-- end
	end)
end

local function CleanUpItemSlot(slot)
	if not slot then return end

	if slot.RA_ItemLevelText then slot.RA_ItemLevelText:SetText('') end
end

-- RA.Slots = {}
function RA:UpdateItemSlot(slot, unit)
	if not slot or not unit then return end
	CleanUpItemSlot(slot)
	local which = unit == 'player' and 'character' or 'inspect'
	-- print(which, item)

	if not RA.db[which] then return end

	local slotID = slot:GetID()

	-- RA.Slots[slotID] = slot:GetName()
	if (slotID >= INVSLOT_FIRST_EQUIPPED and slotID <= INVSLOT_LAST_EQUIPPED) then
		local item
		if unit == 'player' then
			item = Item:CreateFromEquipmentSlot(slotID)
		else
			local itemID = GetInventoryItemID(unit, slotID)
			local itemLink = GetInventoryItemLink(unit, slotID)

			if itemLink or itemID then
				item = itemLink and Item:CreateFromItemLink(itemLink) or Item:CreateFromItemID(itemID)
			end
		end

		UpdateButtonFromItem(slot, item, which)
	end
end

function RA:GetSlotBackgroundPoints(slotID, db)
	if not slotID or not db then return end
	local xOffset, yOffset = db.slotBackground.xOffset, db.slotBackground.yOffset
	local width = db.slotBackground.width
	local topOffset, bottomOffset = db.slotBackground.topOffset, db.slotBackground.bottomOffset

	if slotID <= 5 or (slotID == 9 or slotID == 15) then --* Left Side
		-- return 'LEFT', 'LEFT', x, y
		return 'TOPLEFT', 'TOPLEFT', 'BOTTOMRIGHT', 'BOTTOMRIGHT', xOffset, yOffset, topOffset, -bottomOffset, xOffset+width
	elseif (slotID >= 6 and slotID <= 8) or (slotID >= 10 and slotID <= 14) or slotID == 16 then	--* Right Side
		-- return 'RIGHT', 'RIGHT', -x, y
		return 'TOPRIGHT', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOMLEFT', -xOffset, -yOffset, topOffset, -bottomOffset, -(width+xOffset)
	else									 --* Left Side (RangedSlot)
		return 'TOPLEFT', 'TOPLEFT', 'BOTTOMRIGHT', 'BOTTOMRIGHT', xOffset, yOffset, topOffset, -bottomOffset, xOffset+width
	end
end

--* Flyout Helpers
local FLYOUT_LOCATIONS = {
	[0xFFFFFFFF] = 'PLACEINBAGS',
	-- [0xFFFFFFFE] = 'IGNORESLOT',
	-- [0xFFFFFFFD] = 'UNIGNORESLOT'
}

-- --* Test
-- local function EquipmentDisplayButton(button)
-- 	if not button.isHooked then
-- 		button:SetNormalTexture(E.ClearTexture)
-- 		button:SetPushedTexture(E.ClearTexture)
-- 		button:SetTemplate()
-- 		button:StyleButton()

-- 		button.icon:SetInside()
-- 		button.icon:SetTexCoord(unpack(E.TexCoords))

-- 		button.isHooked = true
-- 	end

-- 	if FLYOUT_LOCATIONS[button.location] then -- special slots
-- 		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
-- 	end
-- end

-- --* Test
-- local function EquipmentUpdateItems()
-- 	local frame = _G.EquipmentFlyoutFrame.buttonFrame
-- 	if not frame.template then
-- 		frame:StripTextures()
-- 		frame:SetTemplate('Transparent')
-- 	end

-- 	local width, height = frame:GetSize()
-- 	frame:Size(width+3, height)

-- 	for _, button in next, _G.EquipmentFlyoutFrame.buttons do
-- 		EquipmentDisplayButton(button)
-- 	end
-- end

local function ItemFromEquipmentFlyoutDisplayButton(button)
	local flyoutFrameParent = _G.EquipmentFlyoutFrame.button:GetParent()
	local flyoutSettings = flyoutFrameParent.flyoutSettings
	if flyoutSettings.useItemLocation then
		local itemLocation = button:GetItemLocation()
		if itemLocation then
			return Item:CreateFromItemLocation(itemLocation)
		end
	else
		local location = button.location
		-- if not location then return end
		if not location or location >= _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then return end
		local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
		if type(voidStorage) ~= "boolean" then
		-- 	-- classic compatibility: no voidStorage returns, so shuffle everything down by one
		-- 	-- returns either `player, bank, bags (true), slot, bag` or `player, bank, bags (false), location`
			print('shit broke, voidStorage', voidStorage)
			--TODO May just return nil here
			slot, bag = voidStorage, slot
		end
		if bags then
			return Item:CreateFromBagAndSlot(bag, slot)
		elseif not voidStorage then -- player or bank
			return Item:CreateFromEquipmentSlot(slot)
		else
			local itemID = EquipmentManager_GetItemInfoByLocation(location)
			if itemID then
				return Item:CreateFromItemID(itemID)
			end
		end
	end
end

function RA:EquipmentFlyout_UpdateItems()
	local flyoutFrameParent = _G.EquipmentFlyoutFrame.button:GetParent()
	local flyoutSettings = flyoutFrameParent.flyoutSettings
	local db = RA.db.character.flyoutText

	for i, button in ipairs(_G.EquipmentFlyoutFrame.buttons) do
		CleanUpItemSlot(button)
		if db.enable and button:IsShown() then
			local item = ItemFromEquipmentFlyoutDisplayButton(button)
			if item then
				UpdateButtonFromItem(button, item, 'character')
			end
		end
	end
end

function RA:InspectGearSlot(line, lineText, slotInfo)
	local enchant = strmatch(lineText, MATCH_ENCHANT)
	if enchant then
		local color1, color2 = strmatch(enchant, '(|cn.-:).-(|r)')
		local text = gsub(gsub(enchant, '%s?|A.-|a', ''), '|cn.-:(.-)|r', '%1')
		slotInfo.enchantText = format('%s%s%s', color1 or '', text, color2 or '')
		slotInfo.enchantTextShort = format('%s%s%s', color1 or '', utf8sub(text, 1, 18), color2 or '')
		slotInfo.enchantTextReal = enchant -- unchanged, contains Atlas and color

		local r, g, b = line:GetTextColor()
		slotInfo.enchantColors[1] = r
		slotInfo.enchantColors[2] = g
		slotInfo.enchantColors[3] = b
	end

	local itemLevel = lineText and (strmatch(lineText, MATCH_ITEM_LEVEL_ALT) or strmatch(lineText, MATCH_ITEM_LEVEL))
	if itemLevel then
		slotInfo.iLvl = tonumber(itemLevel)

		local r, g, b = _G.ElvUI_ScanTooltipTextLeft1:GetTextColor()
		slotInfo.itemLevelColors[1] = r
		slotInfo.itemLevelColors[2] = g
		slotInfo.itemLevelColors[3] = b
	end
end
