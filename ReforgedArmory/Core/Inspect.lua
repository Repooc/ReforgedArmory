local RA = unpack(ReforgedArmory)

function RA:UpdateInspectLayout()
	if not _G.InspectFrame or _G.InspectFrame.RA_Hooked then return end

	if not ElvUI or not (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.inspect) then
		--! Edit Blizzard Skinned InspectFrame
		if RA.Retail then
			_G.InspectModelFrameBackgroundBotLeft:Hide()
			_G.InspectModelFrameBackgroundBotRight:Hide()
			_G.InspectModelFrameBackgroundTopLeft:Hide()
			_G.InspectModelFrameBackgroundTopRight:Hide()

			--* Resize InspectModelFrame
			_G.InspectModelFrame:ClearAllPoints()
			_G.InspectModelFrame:SetPoint('TOPLEFT', _G.InspectHeadSlot, 0, 5)
			_G.InspectModelFrame:SetPoint('RIGHT', _G.InspectHandsSlot)
			_G.InspectModelFrame:SetPoint('BOTTOM', _G.InspectMainHandSlot)

			--* Attach MH to OH and center the 3 slots based off the oh
			_G.InspectMainHandSlot:ClearAllPoints()
			_G.InspectMainHandSlot:SetPoint('BOTTOMRIGHT', _G.InspectPaperDollItemsFrame, 'BOTTOM', -5, 22)
			-- _G.InspectSecondaryHandSlot:ClearAllPoints()
			-- _G.InspectSecondaryHandSlot:SetPoint('TOP', _G.InspectModelFrame, 'BOTTOM', 0, 22)

			--* Move Dressing Room Button & Change Text
			_G.InspectPaperDollFrameText:SetText('D')
			_G.InspectPaperDollFrame.ViewButton:FitToText()
			_G.InspectPaperDollFrame.ViewButton:ClearAllPoints()
			_G.InspectPaperDollFrame.ViewButton:SetPoint('RIGHT', _G.InspectFrameCloseButton, 'LEFT', -3, 0)
		elseif RA.Cata then
			--* Move Model Rotation Buttons
			_G.InspectModelFrameRotateLeftButton:ClearAllPoints()
			_G.InspectModelFrameRotateLeftButton:SetPoint('BOTTOMLEFT', _G.InspectModelFrame, 'TOPLEFT', 0, -1)
			_G.InspectModelFrameRotateRightButton:ClearAllPoints()
			_G.InspectModelFrameRotateRightButton:SetPoint('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', -6, 0)
		elseif RA.Classic then

		end
	else
		--! Edit ElvUI Skinned InspectFrame
		if RA.Retail then
			--* Retail
			--* Resize InspectFrame
			_G.InspectFrame:Size(450, 475)

			--* Move MainHandSlot
			_G.InspectMainHandSlot:SetPoint('BOTTOMLEFT', _G.InspectPaperDollItemsFrame, 'BOTTOMLEFT', 185, 14)

			--* Resize InspectModelFrame
			_G.InspectModelFrame:ClearAllPoints()
			_G.InspectModelFrame:SetPoint('TOPLEFT', _G.InspectHeadSlot, 0, 5)
			_G.InspectModelFrame:SetPoint('RIGHT', _G.InspectHandsSlot)
			_G.InspectModelFrame:SetPoint('BOTTOM', _G.InspectMainHandSlot)

			--* Hide Background Overlay & Backdrop
			_G.InspectModelFrame.BackgroundOverlay:Hide()
			_G.InspectModelFrame.BackgroundTopLeft:Hide()
			_G.InspectModelFrame.BackgroundTopRight:Hide()
			_G.InspectModelFrame.BackgroundBotLeft:Hide()
			_G.InspectModelFrame.BackgroundBotRight:Hide()
		elseif RA.Cata then
			--* Cata
			--* Resize InspectFrame
			_G.InspectFrame:Size(415, 538)

			--* Move Hands Slot
			_G.InspectHandsSlot:ClearAllPoints()
			_G.InspectHandsSlot:SetPoint('TOPLEFT', _G.InspectPaperDollItemsFrame, 'TOPLEFT', 336, -74)

			--* Resize InspectModelFrame
			_G.InspectModelFrame:ClearAllPoints()
			_G.InspectModelFrame:SetPoint('TOPLEFT', _G.InspectHeadSlot, 'TOPRIGHT', 0, 0)
			_G.InspectModelFrame:SetPoint('BOTTOMRIGHT', _G.InspectTrinket1Slot, 'BOTTOMLEFT', 0, -30)

			--* Attach MH to OH and center the 3 slots based off the oh
			_G.InspectSecondaryHandSlot:ClearAllPoints()
			_G.InspectSecondaryHandSlot:SetPoint('TOP', _G.InspectModelFrame, 'BOTTOM', 0, 22)
			_G.InspectMainHandSlot:ClearAllPoints()
			_G.InspectMainHandSlot:SetPoint('TOPRIGHT', _G.InspectSecondaryHandSlot, 'TOPLEFT', -5, 0)
		else
			--* Classic

		end
	end
	RA:CreateAvgItemLevel(_G.InspectFrame, 'inspect')
	_G.InspectFrame.RA_Hooked = true
end

function RA:InspectPaperDollFrame_SetLevel()
	--* Fires Each Inspect OnShow
	--! ElvUI Skin: Updates OnShow
	local isSkinned = ElvUI and (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.inspect)
	if isSkinned then
		if RA.Retail then
			--* Hide Backdrop from InspectModelFrame
			_G.InspectModelFrame.backdrop:Hide()
		elseif RA.Cata then
			--* Move Tab1 (others are attached)
			_G.InspectFrameTab1:ClearAllPoints();
			_G.InspectFrameTab1:SetPoint('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', 1, 78)

			--* Move Model Rotation Buttons
			_G.InspectModelFrameRotateLeftButton:ClearAllPoints()
			_G.InspectModelFrameRotateLeftButton:SetPoint('TOPLEFT', _G.InspectFramePortrait, 'TOPLEFT', 13, -15)
		end
	-- else
	-- 	if RA.Retail then
	-- 		_G.InspectFrame:SetHeight(PANEL_DEFAULT_HEIGHT + 25)
	-- 	end
	end
	if RA.Retail then
		_G.InspectFrame:SetHeight(PANEL_DEFAULT_HEIGHT + 35)
		_G.InspectFrame:SetWidth(PANEL_DEFAULT_WIDTH + 45)
	end

	--! _G.InspectFrameTitleText (Retail & Cata)
	--! _G.InspectNameFrame
	local db = RA.db.inspect

	if RA.Retail then
		_G.InspectFrameTitleText:ClearAllPoints()
		_G.InspectFrameTitleText:SetPoint('TOP', _G.InspectFrame, 'TOP', 0, -5 + db.nameText.yOffset)
		_G.InspectFrameTitleText:SetPoint('LEFT', _G.InspectFrame, 'LEFT', 60 + db.nameText.xOffset, 0)
		_G.InspectFrameTitleText:SetPoint('RIGHT', _G.InspectFrame, 'RIGHT', -60 + db.nameText.xOffset, 0)
	elseif RA.Cata then
		_G.InspectNameFrame:ClearAllPoints()
		_G.InspectNameFrame:SetPoint('TOP', _G.InspectPaperDollFrame, 'TOP', 0, -17 + db.nameText.yOffset)
		_G.InspectNameFrame:SetPoint('LEFT', _G.InspectPaperDollFrame, 'LEFT', 60 + db.nameText.xOffset, 0)
		_G.InspectNameFrame:SetPoint('RIGHT', _G.InspectPaperDollFrame, 'RIGHT', -60 + db.nameText.xOffset, 0)
		_G.InspectLevelText:ClearAllPoints()
		_G.InspectLevelText:SetPoint('TOP', _G.InspectNameText, 'BOTTOM', db.levelText.xOffset, db.levelText.yOffset)
	elseif RA.Classic then
		_G.InspectNameFrame:ClearAllPoints()
		_G.InspectNameFrame:SetPoint('CENTER', _G.InspectFrame, 'CENTER', 6 + db.nameText.xOffset, 232)
	end

	RA:UpdateAverageString(_G.InspectFrame, _G.InspectFrame.unit or 'target')
	RA:UpdateAvgItemLevel(_G.InspectFrame, _G.InspectFrame.unit or 'target')
end

function RA:InspectFrame_OnShow()
	local frame = _G.InspectFrame
	if not frame then return end

	local isSkinned = ElvUI and (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.inspect)

	-- _G.InspectFrame:SetHeight(PANEL_DEFAULT_HEIGHT + 35)
	-- _G.InspectFrame:SetWidth(PANEL_DEFAULT_WIDTH + 45)

	--* Edit Blizzard Skinned CharacterFrame or no ElvUI
	if RA.Retail and not isSkinned then
		_G.InspectModelFrameBorderLeft:Hide()
		_G.InspectModelFrameBorderBottomLeft:Hide()
		_G.InspectModelFrameBorderBottom:Hide()
		_G.InspectModelFrameBorderBottom2:Hide()
		_G.InspectModelFrameBorderBottomRight:Hide()
		_G.InspectModelFrameBorderRight:Hide()
		_G.InspectModelFrameBackgroundOverlay:Hide()


		_G.InspectModelFrameBackgroundBotLeft:Hide()
		_G.InspectModelFrameBackgroundBotRight:Hide()
		_G.InspectModelFrameBackgroundTopLeft:Hide()
		_G.InspectModelFrameBackgroundTopRight:Hide()
	end
end
