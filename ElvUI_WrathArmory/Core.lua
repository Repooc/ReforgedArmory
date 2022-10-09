local E = unpack(ElvUI)
local S = E:GetModule('Skins')
local EP = LibStub('LibElvUIPlugin-1.0')
local LSM = E.Libs.LSM
local LCS = E.Libs.LCS
local AddOnName, Engine = ...

local module = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')
_G[AddOnName] = Engine

module.Title = GetAddOnMetadata('ElvUI_WrathArmory', 'Title')
module.CleanTitle = GetAddOnMetadata('ElvUI_WrathArmory', 'X-CleanTitle')
module.Version = GetAddOnMetadata('ElvUI_WrathArmory', 'Version')
module.Configs = {}
local githubURL = 'https://github.com/Repooc/ElvUI_WrathArmory/issues'

-- local texturePath = 'Interface\\Addons\\ElvUI_WrathArmory\\Textures\\'

function module:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', '|cff16c3f2Wrath|rArmory ', E.media.hexvaluecolor or '|cff16c3f2', module.Version, ':|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

local function GetOptions()
	for _, func in pairs(module.Configs) do
		func()
	end
end

function module:UpdateOptions(unit, updateGems)
	if unit then
		module:UpdateInspectPageFonts(unit, updateGems)
	else
		module:UpdateInspectPageFonts('Character')
		module:UpdateInspectPageFonts('Inspect')
	end
end

local InspectItems = {
	'HeadSlot',			--1L
	'NeckSlot',			--2L
	'ShoulderSlot',		--3L
	'',					--4
	'ChestSlot',		--5L
	'WaistSlot',		--6R
	'LegsSlot',			--7R
	'FeetSlot',			--8R
	'WristSlot',		--9L
	'HandsSlot',		--10R
	'Finger0Slot',		--11R
	'Finger1Slot',		--12R
	'Trinket0Slot',		--13R
	'Trinket1Slot',		--14R
	'BackSlot',			--15L
	'MainHandSlot',		--16
	'SecondaryHandSlot',--17
	'RangedSlot',		--18
}

local whileOpenEvents = {
	UPDATE_INVENTORY_DURABILITY = true,
}

function module:CreateInspectTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	-- texture:Point(point, (gemStep == 1 and slot) or slot['textureSlot'..(prevGem)], relativePoint, gemStep == 1 and x or 25, y)
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
	local x, y = db.gems.xOffset, db.gems.yOffset
	local mhX, mhY = db.gems.MainHandSlot.xOffset, db.gems.MainHandSlot.yOffset
	local ohX, ohY = db.gems.SecondaryHandSlot.xOffset, db.gems.SecondaryHandSlot.yOffset
	local rX, rY = db.gems.RangedSlot.xOffset, db.gems.RangedSlot.yOffset
	local spacing = db.gems.spacing
	-- Returns point, relativeFrame, relativePoint, x, y

	if id <= 5 or (id == 9 or id == 15) then --* Left Side
		return 'BOTTOMLEFT', 'BOTTOMRIGHT', x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then --* Right Side
		return 'BOTTOMRIGHT', 'BOTTOMLEFT', -x, y, -spacing
	elseif id == 16 then --* MainHandSlot
		return 'BOTTOMRIGHT', 'BOTTOMLEFT', mhX, mhY, -spacing
	elseif id == 17 then --* SecondaryHandSlot
		return 'BOTTOMRIGHT', 'TOPRIGHT', ohX, ohY, -spacing
	else --* RangedSlot
		return 'BOTTOMLEFT', 'BOTTOMRIGHT', rX, rY, spacing
	end
end

function module:GetEnchantPoints(id, db)
	if not id or not db then return end
	local x, y = db.enchant.xOffset, db.enchant.yOffset
	local mhX, mhY = db.enchant.MainHandSlot.xOffset, db.enchant.MainHandSlot.yOffset
	local ohX, ohY = db.enchant.SecondaryHandSlot.xOffset, db.enchant.SecondaryHandSlot.yOffset
	local rX, rY = db.enchant.RangedSlot.xOffset, db.enchant.RangedSlot.yOffset
	local spacing = db.enchant.spacing or 0
	-- Returns point, relativeFrame, relativePoint, x, y

	if id <= 5 or (id == 9 or id == 15) then --* Left Side
		return 'TOPLEFT', 'TOPRIGHT', x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then --* Right Side
		return 'TOPRIGHT', 'TOPLEFT', -x, y, -spacing
	elseif id == 16 then --* MainHandSlot
		return 'TOPRIGHT', 'TOPLEFT', mhX, mhY, -spacing
	elseif id == 17 then --* SecondaryHandSlot
		return 'TOP', 'BOTTOM', ohX, ohY, -spacing
	else --* RangedSlot
		return 'TOPLEFT', 'TOPRIGHT', rX, rY, spacing
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

	for i = 1, 18 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText('')
			inspectItem.iLvlText:SetText('')

			for y = 1, 10 do
				inspectItem['textureSlot'..y]:SetTexture()
				inspectItem['textureSlotBackdrop'..y]:Hide()
			end
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
	local db = E.db.wratharmory[string.lower(which)]

	do
		local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
		inspectItem.enchantText:ClearAllPoints()
		inspectItem.enchantText:Point(point, slot, relativePoint, x, y)
		inspectItem.enchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)
		inspectItem.enchantText:SetText(slotInfo.enchantTextShort)
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

	if which == 'Inspect' then
		local unit = _G.InspectFrame.unit or 'target'
		if unit then
			local quality = GetInventoryItemQuality(unit, i)
			if quality and quality > 1 then
				inspectItem.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				inspectItem.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
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
		-- print('1')
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
			-- print('2')
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
		-- print('3')
	end

	-- Off hand
	local offItemLevel, offEquipLoc = 0
	link = GetInventoryItemLink(unit, 17)
	if link then
		offItemLevel = iLevelDB[17]
		_, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 17) then
		isOK = false
		-- print('4')
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
		for i = 1, 18 do
			if i ~= 4 then
				local inspectItem = _G[which..InspectItems[i]]
				inspectItem.enchantText:SetText('')
				inspectItem.iLvlText:SetText('')

				local unit = (which == 'Character' and 'player') or frame.unit
				local slotInfo = module:GetGearSlotInfo(unit, i)
				if slotInfo == 'tooSoon' then
					if not waitForItems then waitForItems = true end
					module:TryGearAgain(frame, which, i, iLevelDB, inspectItem)
				else
					module:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
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
		CharacterFrameTab1:ClearAllPoints()
		CharacterFrameTab1:Point('CENTER', CharacterFrame, 'BOTTOMLEFT', 60, 51)

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

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]

			slot.iLvlText = slot:CreateFontString(nil, 'OVERLAY')
			slot.iLvlText:FontTemplate(LSM:Fetch('font', itemLevel.font), itemLevel.fontSize, itemLevel.fontOutline)
			slot.iLvlText:Point('BOTTOM', slot, itemLevel.xOffset, itemLevel.yOffset)

			slot.enchantText = slot:CreateFontString(nil, 'OVERLAY')
			slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
			do
				local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
				slot.enchantText:ClearAllPoints()
				slot.enchantText:Point(point, slot, relativePoint, x, y)
			end

			do
				local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
				for u = 1, 5 do
					slot['textureSlot'..u], slot['textureSlotBackdrop'..u] = module:CreateInspectTexture(slot, point, relativePoint, x, y, u, spacing)
				end
			end
		end
	end
end

function module:SetupInspectPageInfo()
	module:CreateSlotStrings(_G.InspectFrame, 'Inspect')
end

function module:UpdateInspectPageFonts(which, gems)
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
	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			slot = _G[which..s]
			if slot then
				quality = GetInventoryItemQuality(unit, i)
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
					local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
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
	end

	if gems then
		module:UpdatePageInfo(frame, which, unit)
	end
end

function module:ScanTooltipTextures()
	local tt = E.ScanTooltip

	if not tt.gems then
		tt.gems = {}
	else
		wipe(tt.gems)
	end

	for i = 1, 5 do
		local tex = _G['ElvUI_ScanTooltipTexture'..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture then
			tt.gems[i] = texture
		end
	end

	return tt.gems
end

function module:GetGearSlotInfo(unit, slot)
	local tt = E.ScanTooltip
	tt:SetOwner(_G.UIParent, 'ANCHOR_NONE')
	tt:SetInventoryItem(unit, slot)
	tt:Show()

	if not tt.SlotInfo then tt.SlotInfo = {} else wipe(tt.SlotInfo) end
	local slotInfo = tt.SlotInfo

	slotInfo.gems = module:ScanTooltipTextures()
	-- print('1', tt.itemQualityColors)
	-- if not tt.itemQualityColors then tt.itemQualityColors = {} else wipe(tt.itemQualityColors) end
	-- print('2', tt.itemQualityColors)

	-- slotInfo.itemQualityColors = tt.itemQualityColors
	slotInfo.itemQualityColors = slotInfo.itemQualityColors or {}

	for x = 1, tt:NumLines() do
		local line = _G['ElvUI_ScanTooltipTextLeft'..x]
		if line then
			local lineText = line:GetText()
			if x == 1 and lineText == RETRIEVING_ITEM_INFO then
				return 'tooSoon'
			end
		end
	end

	local itemLink = GetInventoryItemLink(unit, slot)
	if itemLink then
		local quality = GetInventoryItemQuality(unit, slot)
		slotInfo.itemQualityColors.r, slotInfo.itemQualityColors.g, slotInfo.itemQualityColors.b = GetItemQualityColor(quality)

		local itemLevel = GetDetailedItemLevelInfo(itemLink)
		slotInfo.iLvl = tonumber(itemLevel)

		local enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))
		local enchantTextShort = E.Libs.GetEnchant.GetEnchant(enchantID)

		if enchantID and not enchantTextShort then
			local msg = format('The enchant id, *%s|r, seems to be missing from our database and the enchant won\'t be displayed properly.  Please open a ticket at |cff16c3f2[|r*|Hurl:'..githubURL..'|h'..githubURL..'|h|r|cff16c3f2]|r with the missing id and name of the enchant that found on %s.', enchantID, itemLink):gsub('*', E.InfoColor)
			module:Print(msg)
		end

		slotInfo.enchantTextShort = enchantTextShort or ''
	end

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

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	E:AddLib('GetEnchant', 'LibGetEnchant-1.0-WrathArmory')

	module:ToggleItemLevelInfo(true)

	if IsAddOnLoaded('Blizzard_InspectUI') then
		module:SetupInspectPageInfo()
	else
		module:RegisterEvent('ADDON_LOADED')
	end

	_G.CharacterFrameCloseButton:ClearAllPoints()
	_G.CharacterFrameCloseButton:Point('TOPRIGHT', CharacterFrame.backdrop, 0, 2)
	_G.GearManagerToggleButton:Point('TOPRIGHT', _G.PaperDollItemsFrame, 'TOPRIGHT', -8, -35)

	_G.GearManagerDialog:HookScript('OnShow', function(a, b, c)
		GearManagerDialog:ClearAllPoints()
		GearManagerDialog:Point('TOPLEFT', WrathArmory_StatsPane, 'TOPRIGHT', 0, 0)
		-- 'TOPLEFT', PaperDollFrame, 'TOPRIGHT', -30, -12  -- default
	end)
	-- GearManagerDialog:HookScript('OnHide', function(a, b, c)
	-- 	print("Hiding Equipment Manager", a, b, c)
	-- end)
	--[[
	module:UpdateOptions()

	if not ELVUIILVL then
		_G.ELVUIILVL = {}
	end
	]]
end

E.Libs.EP:HookInitialize(module, module.Initialize)
