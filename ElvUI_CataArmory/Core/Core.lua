local E, L = unpack(ElvUI)
local module = E:GetModule('ElvUI_CataArmory')
local M = E.Misc
local S = E:GetModule('Skins')
local LSM = E.Libs.LSM
-- local LCS = E.Libs.LCS
-- local LibGearScore = LibStub:GetLibrary("LibGearScore.1000", true)

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

local InspectItems = {
	HeadSlot = {
		slotID = 1,
		canEnchant = true,
	},
	NeckSlot = {
		slotID = 2,
		canEnchant = false,
	},
	ShoulderSlot = {
		slotID = 3,
		canEnchant = true,
	},
	ChestSlot = {
		slotID = 5,
		canEnchant = true,
	},
	WaistSlot = {
		slotID = 6,
		canEnchant = false,
	},
	LegsSlot = {
		slotID = 7,
		canEnchant = true,
	},
	FeetSlot = {
		slotID = 8,
		canEnchant = true,
	},
	WristSlot = {
		slotID = 9,
		canEnchant = true,
	},
	HandsSlot = {
		slotID = 10,
		canEnchant = true,
	},
	Finger0Slot = {
		slotID = 11,
		canEnchant = false,
	},
	Finger1Slot = {
		slotID = 12,
		canEnchant = false,
	},
	Trinket0Slot = {
		slotID = 13,
		canEnchant = false,
	},
	Trinket1Slot = {
		slotID = 14,
		canEnchant = false,
	},
	BackSlot = {
		slotID = 15,
		canEnchant = true,
	},
	MainHandSlot = {
		slotID = 16,
		canEnchant = true,
	},
	SecondaryHandSlot = {
		slotID = 17,
		canEnchant = true,
	},
	RangedSlot = {
		slotID = 18,
		canEnchant = false,
	},
}

local function CreateItemLevel(frame, which)
	if not frame or not which then return end

	local db = E.db.cataarmory[string.lower(which)].avgItemLevel
	local isCharPage = which == 'Character'

	-- --* Create Stats Frame
	-- local statsFrame = CreateFrame('Frame', 'WrathArmory_StatsPane', _G.PaperDollItemsFrame, not isSkinned and 'BasicFrameTemplateWithInset')
	-- statsFrame:SetFrameLevel(_G.CharacterFrame:GetFrameLevel()-1)
	-- statsFrame:Point('TOPLEFT', CharacterFrame.backdrop or CharacterFrameCloseButton, 'TOPRIGHT', -1, isSkinned and 0 or -5)
	-- statsFrame:Point('BOTTOMRIGHT', CharacterFrame.backdrop or CharacterFrame, 'BOTTOMRIGHT', 180, isSkinned and 0 or 77)

	-- local avgItemLevelFrame = CreateFrame('Frame', 'CataArmory_'..which..'_AvgItemLevel', (isCharPage and module.Stats) or InspectPaperDollFrame)
	local avgItemLevelFrame = _G['CataArmory_'..which..'_AvgItemLevel'] or CreateFrame('Frame', 'CataArmory_'..which..'_AvgItemLevel', (isCharPage and _G.PaperDollFrame) or InspectPaperDollFrame)
	avgItemLevelFrame:Size(170, 30)
	-- avgItemLevelFrame:Point('TOP', db.xOffset, db.yOffset)
	-- avgItemLevelFrame:ClearAllPoints()
	avgItemLevelFrame:SetFrameLevel(isCharPage and _G.CharacterModelScene:GetFrameLevel()+1 or InspectModelFrame:GetFrameLevel()+1)
	avgItemLevelFrame:Point('TOP', db.xOffset, db.yOffset)

	if not avgItemLevelFrame.bg then
		avgItemLevelFrame.bg = avgItemLevelFrame:CreateTexture(nil, 'BACKGROUND')
	end
	avgItemLevelFrame.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	avgItemLevelFrame.bg:ClearAllPoints()
	avgItemLevelFrame.bg:SetPoint('CENTER')
	avgItemLevelFrame.bg:Point('TOPLEFT', avgItemLevelFrame)
	avgItemLevelFrame.bg:Point('BOTTOMRIGHT', avgItemLevelFrame)
	avgItemLevelFrame.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	avgItemLevelFrame.bg:SetVertexColor(1, 1, 1, 0.7)

	if not avgItemLevelFrame.lineTop then
		avgItemLevelFrame.lineTop = avgItemLevelFrame:CreateTexture(nil, 'BACKGROUND')
	end
	avgItemLevelFrame.lineTop:SetDrawLayer('BACKGROUND', 2)
	avgItemLevelFrame.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	avgItemLevelFrame.lineTop:ClearAllPoints()
	avgItemLevelFrame.lineTop:SetPoint('TOP', avgItemLevelFrame.bg, 0, 4)
	avgItemLevelFrame.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	avgItemLevelFrame.lineTop:Size(avgItemLevelFrame:GetWidth(), 7)

	if not avgItemLevelFrame.lineBottom then
		avgItemLevelFrame.lineBottom = avgItemLevelFrame:CreateTexture(nil, 'BACKGROUND')
	end
	avgItemLevelFrame.lineBottom:SetDrawLayer('BACKGROUND', 2)
	avgItemLevelFrame.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	avgItemLevelFrame.lineBottom:ClearAllPoints()
	avgItemLevelFrame.lineBottom:SetPoint('BOTTOM', avgItemLevelFrame.bg, 0, 0)
	avgItemLevelFrame.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	avgItemLevelFrame.lineBottom:Size(avgItemLevelFrame:GetWidth(), 7)

	local text = avgItemLevelFrame:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
	text:SetText('')
	text:SetPoint('CENTER', 0, -2)
	text:SetTextColor(db.color.r, db.color.g, db.color.b)
	frame.CataArmory_ItemLevelText = text

	module[string.lower(which)] = {}
	module[string.lower(which)].CataArmory_ItemLevelText = text
end

function module:CreateGemTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	texture:Point(point, (gemStep == 1 and slot) or slot['CataArmory_textureSlot'..prevGem], relativePoint, (gemStep == 1 and x) or spacing, (gemStep == 1 and x) or y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, (gemStep == 1 and slot) or slot['CataArmory_textureSlotBackdrop'..prevGem])
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


-- function module:ClearPageInfo(frame, which)
-- 	if not frame or not which then return end
-- 	frame.CataArmory_ItemLevelText:SetText('')

-- 	for slot in pairs(module.GearList) do
-- 		local inspectItem = _G[which..slot]

-- 		inspectItem.enchantText:SetText('')
-- 		inspectItem.iLvlText:SetText('')

-- 		for y = 1, 10 do
-- 		inspectItem['CataArmory_textureSlot'..y]:SetTexture()
-- 		inspectItem['CataArmory_textureSlotBackdrop'..y]:Hide()
-- 		end
-- 	end
-- end

local function Gem_OnEnter(frame)
	-- if E.db.sle.armory[frame.frame].enable and frame.Link then --Only do stuff if armory is enabled or the gem is present
		_G.GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
		_G.GameTooltip:SetHyperlink(frame.Link)
		_G.GameTooltip:Show()
	-- end
end

local function Gem_OnLeave()
	_G.GameTooltip:Hide()
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
local function CreateSlotStrings(frame, which)
	if not (frame and which) then return end

	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel = db.itemLevel
	local enchant = db.enchant

	if which == 'Inspect' then
		CreateItemLevel(frame, which)
	-- 	InspectFrameTab1:ClearAllPoints()
	-- 	InspectFrameTab1:Point('CENTER', InspectFrame, 'BOTTOMLEFT', 60, 51)
	else
	-- 	module:CreateStatsPane()
		CreateItemLevel(CharacterFrame, 'Character')
	end

	for slotName, info in pairs(InspectItems) do
		local slot = _G[which..slotName]
		-- slot.iLvlText = slot:CreateFontString(nil, 'OVERLAY')
		-- if slot.iLvlText then
			-- slot.iLvlText:FontTemplate(LSM:Fetch('font', itemLevel.font), itemLevel.fontSize, itemLevel.fontOutline)
			-- slot.iLvlText:Point('BOTTOM', slot, itemLevel.xOffset, itemLevel.yOffset)
		-- end
		--* Warning
		slot.CataArmory_Warning = CreateFrame('Frame', nil, slot)
		-- local point, relativePoint, x, y = module:GetWarningPoints(info.slotID, db)
		do
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

		-- --* Enchant Text
		-- slot.enchantText = slot:CreateFontString(nil, 'OVERLAY')
		if slot.enchantText then
			-- slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
		end
		-- slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)

		do
			-- local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
			-- slot.enchantText:ClearAllPoints()
			-- slot.enchantText:Point(point, slot, relativePoint, x, y)
		end

		do
			local point, relativePoint, x, y, spacing = module:GetGemPoints(info.slotID, db)
			for u = 1, 5 do
				slot['CataArmory_textureSlot'..u], slot['CataArmory_textureSlotBackdrop'..u] = module:CreateGemTexture(slot, point, relativePoint, x, y, u, spacing)
				slot['CataArmory_GemFrame'..u] = CreateFrame('Frame', nil, slot)
				slot['CataArmory_GemFrame'..u]:SetPoint('TOPLEFT', slot['CataArmory_textureSlot'..u])
				slot['CataArmory_GemFrame'..u]:SetPoint('BOTTOMRIGHT', slot['CataArmory_textureSlot'..u])
				slot['CataArmory_GemFrame'..u]:SetScript('OnEnter', Gem_OnEnter)
				slot['CataArmory_GemFrame'..u]:SetScript('OnLeave', Gem_OnLeave)
			end
		end
	end
end

function module:ToggleItemLevelInfo(setupCharacterPage)
	if setupCharacterPage then
		CreateSlotStrings(_G.CharacterFrame, 'Character')
	end

-- 	if E.db.cataarmory.character.enable then
		-- if not _G.CharacterFrame.CataArmoryHooked then
		-- 	_G.CharacterFrame:HookScript('OnShow', function()
		-- 		module.UpdateCharacterInfo()
		-- 	end)

		-- 	_G.CharacterFrame.CataArmoryHooked = true
		-- end

-- 		if not setupCharacterPage then
-- 			module:UpdateCharacterInfo()
-- 		end
-- 	else
-- 		module:ClearPageInfo(_G.CharacterFrame, 'Character')
-- 	end

-- 	if E.db.cataarmory.inspect.enable then
-- 		module:RegisterEvent('INSPECT_READY', 'UpdateInspectInfo')
-- 	else
-- 		module:UnregisterEvent('INSPECT_READY')
-- 		module:ClearPageInfo(_G.InspectFrame, 'Inspect')
-- 	end
end

function module:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
	local frame = _G[which..'Frame']
	local unit = (which == 'Character' and 'player') or frame.unit or 'target'

	local itemLink = GetInventoryItemLink(unit, i)
	local db = E.db.cataarmory[string.lower(which)]
	local missingBuckle, missingGem, missingEnchant, warningMsg = false, false, false, ''
	local slotName = inspectItem:GetName():gsub('Character', ''):gsub('Inspect', '')
	local canEnchant = InspectItems[slotName].canEnchant
	do
		-- local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
		-- inspectItem.enchantText:ClearAllPoints()
		-- inspectItem.enchantText:Point(point, inspectItem, relativePoint, x, y)
		-- inspectItem.enchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)

		-- local text = slotInfo.enchantTextShort
		if itemLink then
			if i == 1 then
				E:Dump(itemLink)
			end
			-- if text == '' and canEnchant then
			-- 	missingEnchant = true
			-- 	warningMsg = strjoin('', warningMsg, '|cffff0000', L["Not Enchanted"], '|r\n')
			-- end

			-- if #slotInfo.emptySockets > 0 then
			-- 	missingGem = true
			-- 	warningMsg = strjoin('', warningMsg, '|cffff0000', L["Not Fully Gemmed"], '|r\n')
			-- end
			-- if slotInfo.missingBeltBuckle then
			-- 	missingBuckle = true
			-- 	warningMsg = strjoin('', warningMsg, '|cffff0000', L["Missing Belt Buckle"], '|r\n')
			-- end
			-- if inspectItem.CataArmory_Warning then inspectItem.CataArmory_Warning.Reason = warningMsg end
			local enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))
			-- print('text', enchantID)
			if enchantID then
				local text = E.Libs.GetEnchant.GetEnchant(enchantID)
				-- local text = GetSpellInfo(spellID)
				inspectItem.enchantText:SetText(text)
				-- E:Dump(GetSpellInfo(enchantID))
			end
		end
		if inspectItem.CataArmory_Warning then
			-- inspectItem.CataArmory_Warning:SetShown(db.warningIndicator.enable and (missingEnchant or missingGem or missingBuckle))
			inspectItem.CataArmory_Warning:SetShown(true)
		end
		-- inspectItem.enchantText:SetShown(db.enchant.enable)
		inspectItem.enchantText:SetShown(true)
		local enchantTextColor = (db.enchant.qualityColor and slotInfo.itemQualityColors) or db.enchant.color
		if enchantTextColor and next(enchantTextColor) then
			inspectItem.enchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
		end
	end

	inspectItem.iLvlText:ClearAllPoints()
	inspectItem.iLvlText:Point('BOTTOM', inspectItem, db.itemLevel.xOffset, db.itemLevel.yOffset)
	inspectItem.iLvlText:FontTemplate(LSM:Fetch('font', db.itemLevel.font), db.itemLevel.fontSize, db.itemLevel.fontOutline)
	-- inspectItem.iLvlText:SetText(slotInfo.iLvl)
	inspectItem.iLvlText:SetShown(db.itemLevel.enable)
	local iLvlTextColor = (db.itemLevel.qualityColor and slotInfo.itemLevelColors) or db.itemLevel.color
	if iLvlTextColor and iLvlTextColor.r then
		-- print('UpdatePageStrings', iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
		inspectItem.iLvlText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
	end

	-- if which == 'Inspect' and unit then
	-- 	local quality = GetInventoryItemQuality(unit, i)
	-- 	if quality and quality > 1 then
	-- 		local r, g, b = GetItemQualityColor(quality)
	-- 		inspectItem.backdrop:SetBackdropBorderColor(r, g, b, 1)
	-- 	else
	-- 		inspectItem.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	-- 	end
	-- end

	do
		local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
		local gemStep = 1
		for index = 1, 5 do
			local texture = inspectItem['CataArmory_textureSlot'..index]
			texture:Size(db.gems.size)
			texture:ClearAllPoints()
			texture:Point(point, (index == 1 and inspectItem) or inspectItem['CataArmory_textureSlot'..(index-1)], relativePoint, index == 1 and x or spacing, index == 1 and y or 0)

			local backdrop = inspectItem['CataArmory_textureSlotBackdrop'..index]
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

--* Called in M:UpdatePageInfo
function module:UpdateAverageString(frame, which, iLevelDB)
	-- if not iLevelDB then return end

	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel, enchant, avgItemLevel = db.itemLevel, db.enchant, db.avgItemLevel
	local isCharPage, avgItemLevel, avgTotal = which == 'Character'

	if isCharPage then
		--* Option to show one or the other or both?
		avgTotal, avgItemLevel = E:GetPlayerItemLevel() -- rounded average, rounded equipped
	elseif frame.unit and iLevelDB then
		avgItemLevel = E:CalculateAverageItemLevel(iLevelDB, frame.unit)
	end

	local avgItemLevelFrame = _G['CataArmory_'..which..'_AvgItemLevel']
	avgItemLevelFrame:SetHeight(db.avgItemLevel.fontSize + 6)
	avgItemLevelFrame:SetShown(db.avgItemLevel.enable)

	if avgItemLevel then
		frame.CataArmory_ItemLevelText:SetText(avgItemLevel)

		-- for slotName, info in pairs(InspectItems) do
		-- 	local slot = _G[which..slotName]
		-- 	local ilvl = iLevelDB[i]
		-- 	if ilvl then
		-- 		local iLvlTextColor = (itemLevel.qualityColor and qualityColor) or itemLevel.color
		-- 		if iLvlTextColor and next(iLvlTextColor) then
		-- 			print('UpdateAverageString', iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
		-- 			slot.iLvlText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
		-- 		end
		-- 	end
		-- end
	else
		frame.CataArmory_ItemLevelText:SetText('')
	end

	frame.CataArmory_ItemLevelText:SetTextColor(db.avgItemLevel.color.r, db.avgItemLevel.color.g, db.avgItemLevel.color.b)

	-- if isCharPage then
	-- 	avgTotal, avgItemLevel = E:GetPlayerItemLevel() -- rounded average, rounded equipped
	-- elseif frame.unit then
	-- 	avgItemLevel = E:CalculateAverageItemLevel(iLevelDB, frame.unit)
	-- end

	-- if avgItemLevel then
	-- 	if isCharPage then
	-- 		frame.ItemLevelText:SetText(avgItemLevel)

	-- 		if E.Retail then
	-- 			frame.ItemLevelText:SetTextColor(_G.CharacterStatsPane.ItemLevelFrame.Value:GetTextColor())
	-- 		end
	-- 	else
	-- 		frame.ItemLevelText:SetText(avgItemLevel)
	-- 	end

	-- 	-- we have to wait to do this on inspect so handle it in here
	-- 	if not E.db.general.itemLevel.itemLevelRarity then
	-- 		for i = 1, numInspectItems do
	-- 			if i ~= 4 then
	-- 				local ilvl = iLevelDB[i]
	-- 				if ilvl then
	-- 					local inspectItem = _G[which..InspectItems[i]]
	-- 					local r, g, b = E:ColorizeItemLevel(ilvl - (avgTotal or avgItemLevel))
	-- 					inspectItem.iLvlText:SetTextColor(r, g, b)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- else
	-- 	frame.ItemLevelText:SetText('')
	-- end
end

function module:PaperDollFrame_SetLevel()
	local characterLevelText = E.db.cataarmory.character.characterLevelText
	CharacterLevelText:ClearAllPoints()
	CharacterLevelText:Point('TOP', CharacterFrameTitleText, 'BOTTOM', characterLevelText.xOffset, characterLevelText.yOffset)
end

function module:SetupInspectPageInfo()
	CreateSlotStrings(_G.InspectFrame, 'Inspect')
end

--* Only fires in Options section in elvui
function module:UpdateInspectPageFonts(which, force)
	if not which then return end

	local frame = _G[which..'Frame']
	if not frame then return end
	local isCharPage = which == 'Character'
	local unit = (which == 'Character' and 'player') or frame.unit
	local db = E.db.cataarmory[string.lower(which)]
	local itemLevel, enchant, avgItemLevel = db.itemLevel, db.enchant, db.avgItemLevel

	-- 	-- frame.ItemLevelText:FontTemplate(LSM:Fetch('font', avgItemLevel.font), avgItemLevel.fontSize, avgItemLevel.fontOutline)
	frame.CataArmory_ItemLevelText:FontTemplate(LSM:Fetch('font', avgItemLevel.font), avgItemLevel.fontSize, avgItemLevel.fontOutline)

	local avgItemLevelFrame = _G['CataArmory_'..which..'_AvgItemLevel']
	avgItemLevelFrame:SetHeight(avgItemLevel.fontSize + 6)
	avgItemLevelFrame:ClearAllPoints()
	avgItemLevelFrame:Point('TOP', avgItemLevel.xOffset, avgItemLevel.yOffset)
	-- avgItemLevelFrame:Point('TOPLEFT', isCharPage and CharacterFrameTitleText or InspectNameFrame, 'BOTTOMLEFT', avgItemLevel.xOffset, avgItemLevel.yOffset)
	avgItemLevelFrame:SetShown(avgItemLevel.enable)

	local qualityColor = {}
	for slotName, info in pairs(InspectItems) do
		local slot = _G[which..slotName]
		if slot then
			local quality = GetInventoryItemQuality(unit, info.slotID)
			if quality then
				qualityColor.r, qualityColor.g, qualityColor.b = GetItemQualityColor(quality)
			end

			slot.iLvlText:ClearAllPoints()
			slot.iLvlText:Point('BOTTOM', slot, itemLevel.xOffset, itemLevel.yOffset)
			slot.iLvlText:FontTemplate(LSM:Fetch('font', itemLevel.font), itemLevel.fontSize, itemLevel.fontOutline)
			local iLvlTextColor = (itemLevel.qualityColor and qualityColor) or itemLevel.color
			if iLvlTextColor and next(iLvlTextColor) then
				-- print('UpdateInspectPageFonts', iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
				slot.iLvlText:SetTextColor(iLvlTextColor.r, iLvlTextColor.g, iLvlTextColor.b)
			end
			slot.iLvlText:SetShown(itemLevel.enable)

			-- do
			-- 	local point, relativePoint, x, y = module:GetEnchantPoints(info.slotID, db)
			-- 	slot.enchantText:ClearAllPoints()
			-- 	slot.enchantText:Point(point, slot, relativePoint, x, y)
			-- end

			-- slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
			-- local enchantTextColor = (enchant.qualityColor and qualityColor) or enchant.color
			-- if enchantTextColor and next(enchantTextColor) then
			-- 	slot.enchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
			-- end
			-- slot.enchantText:SetShown(enchant.enable)
		end
	end

	if force then
-- 		module:UpdatePageInfo(frame, which, unit)
		M:UpdatePageInfo(frame, which, unit)
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
	-- wipe(temp.gems)
	-- wipe(temp.emptySockets)
	-- wipe(temp.filledSockets)
	-- temp.baseSocketCount = 0

	-- local tt = E.ScanTooltip
	-- for x = 1, tt:NumLines() do
	-- 	local line = _G['ElvUI_ScanTooltipTextLeft'..x]
	-- 	if line then
	-- 		local lineText = line:GetText()
	-- 		if x == 1 and lineText == RETRIEVING_ITEM_INFO then break end
	-- 		if socketNames[lineText] then
	-- 			temp.baseSocketCount = temp.baseSocketCount + 1
	-- 			tinsert(temp.emptySockets, lineText)
	-- 		end
	-- 	end
	-- end

	-- for i = 1, 4 do
	-- 	local tex = _G['ElvUI_ScanTooltipTexture'..i]
	-- 	local texture = tex and tex:IsShown() and tex:GetTexture()
	-- 	if texture then temp.gems[i] = texture end
	-- 	if itemLink then
	-- 		local gemName, gemLink = GetItemGem(itemLink, i)
	-- 		if gemName then tinsert(temp.filledSockets, gemLink) end
	-- 	end
	-- end

	-- return temp.gems, temp.emptySockets, temp.filledSockets, temp.baseSocketCount
end

function module:ADDON_LOADED(_, addon)
	if addon ~= 'Blizzard_InspectUI' then return end
	if _G.InspectFrame.InspectInfoHooked then return end

	_G.InspectFrame:HookScript('OnShow', function(frame)
		--* Option to toggle ElvUI Avg Item Level
		if frame.ItemLevelText then
			frame.ItemLevelText:Hide()
		end
		_G.InspectFrame.InspectInfoHooked = true
	end)
end
