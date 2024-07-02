local RA = unpack(ReforgedArmory)

function RA:CharacterFrame_OnShow()
	local frame = _G.CharacterFrame
	local isSkinned = ElvUI and (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.character)

	if not frame.RA_Hooked then
		RA:CreateAvgItemLevel(frame, 'character')
		if not ElvUI or not (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.character) then
			--* Edit Blizzard Skinned CharacterFrame or no ElvUI
			if RA.Retail or RA.Cata then
				--* Both Retail and Cata
				_G.CharacterFrame:SetHeight(PANEL_DEFAULT_HEIGHT + 35)
				_G.PaperDollInnerBorderBottom:Hide()
				_G.PaperDollInnerBorderBottom2:Hide()
				_G.PaperDollInnerBorderBottomLeft:Hide()
				_G.PaperDollInnerBorderBottomRight:Hide()
				_G.PaperDollInnerBorderLeft:Hide()
				_G.PaperDollInnerBorderRight:Hide()
				_G.PaperDollInnerBorderTop:Hide()
				_G.PaperDollInnerBorderTopLeft:Hide()
				_G.PaperDollInnerBorderTopRight:Hide()
			end
			-- _G.CharacterFrame:SetWidth(_G.CharacterFrame.Expanded and 650 or 444)

			if RA.Cata then
				--* Move StatsFrame ScrollBox Down
				_G.CharacterStatsPane.ScrollBox:ClearAllPoints()
				_G.CharacterStatsPane.ScrollBox:SetPoint('TOPLEFT', _G.CharacterStatsPane, 'TOPLEFT', 4, -30)

				--* Move ScrollBar from StatsFrame to the left a little
				_G.CharacterStatsPane.ScrollBar:ClearAllPoints()
				_G.CharacterStatsPane.ScrollBar:SetPoint('TOPLEFT', _G.CharacterStatsPane.ScrollBox, 'TOPRIGHT', 5, -5)
				_G.CharacterStatsPane.ScrollBar:SetPoint('BOTTOMLEFT', _G.CharacterStatsPane.ScrollBox, 'BOTTOMRIGHT', 5, 4)

				--* Change Anchor for Both Main and Secondary Hand Slots to center
				_G.CharacterSecondaryHandSlot:ClearAllPoints()
				_G.CharacterSecondaryHandSlot:SetPoint('BOTTOM', _G.CharacterFrameInset, 'BOTTOM', 0, 14)
				_G.CharacterMainHandSlot:ClearAllPoints()
				_G.CharacterMainHandSlot:SetPoint('TOPRIGHT', _G.CharacterSecondaryHandSlot, 'TOPLEFT', -5, 0)
			end
		else
			--* Edit ElvUI Skinned CharacterFrame
			if RA.Retail then
				--* Retail
				_G.CharacterMainHandSlot:ClearAllPoints()
				_G.CharacterMainHandSlot:SetPoint('BOTTOMLEFT', _G.PaperDollItemsFrame, 'BOTTOMLEFT', 130, -12)

				_G.CharacterFrameTab1:ClearAllPoints()
				_G.CharacterFrameTab1:SetPoint('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -3, -24)
			elseif RA.Cata then
				--* Cata
				_G.CharacterHandsSlot:ClearAllPoints()
				_G.CharacterHandsSlot:SetPoint('TOPRIGHT', _G.CharacterFrameInset, 'TOPRIGHT', 28, -2)

				_G.CharacterMainHandSlot:ClearAllPoints()
				_G.CharacterMainHandSlot:SetPoint('BOTTOMLEFT', _G.PaperDollItemsFrame, 'BOTTOMLEFT', 106, -7)

				_G.CharacterFrameTab1:ClearAllPoints()
				_G.CharacterFrameTab1:SetPoint('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -10, -24)


				_G.CharacterStatsPane.ScrollBox:ClearAllPoints()
				_G.CharacterStatsPane.ScrollBox:SetPoint('TOPLEFT', _G.CharacterStatsPane, 'TOPLEFT', 4, -30)
				-- _G.CharacterStatsPane.ScrollBox:SetHeight(370)

				_G.CharacterStatsPane.ScrollBar:ClearAllPoints()
				_G.CharacterStatsPane.ScrollBar:SetPoint('TOPLEFT', _G.CharacterStatsPane.ScrollBox, 'TOPRIGHT', 8, 0)
				_G.CharacterStatsPane.ScrollBar:SetPoint('BOTTOMLEFT', _G.CharacterStatsPane.ScrollBox, 'BOTTOMRIGHT', 8, 0)

			end

			if RA.Retail or RA.Cata then
				if _G.CharacterFrame.BottomRightCorner then
					_G.CharacterFrame.BottomRightCorner:ClearAllPoints()
					_G.CharacterFrame.BottomRightCorner:SetPoint('BOTTOMRIGHT', _G.CharacterFrame, 'BOTTOMRIGHT', 0, -26)
				end

				if _G.CharacterFrame.BottomLeftCorner then
					_G.CharacterFrame.BottomLeftCorner:ClearAllPoints()
					_G.CharacterFrame.BottomLeftCorner:SetPoint('BOTTOMLEFT', _G.CharacterFrame, 'BOTTOMLEFT', 0, -26)
				end

				--* Checked, not in classic, no error in cata
				_G.CharacterModelScene.backdrop:Hide()
			end
		end

		--* Do this regardless if ElvUI Skin or not
		if RA.Retail or RA.Cata then
			_G.CharacterModelScene.BackgroundTopLeft:Hide()
			_G.CharacterModelScene.BackgroundTopRight:Hide()
			_G.CharacterModelScene.BackgroundBotLeft:Hide()
			_G.CharacterModelScene.BackgroundBotRight:Hide()
			_G.CharacterModelScene.BackgroundOverlay:Hide() --! Maybe use this over background images?
		end

		frame.RA_Hooked = true
	end


	-- RA:UpdateAverageString(frame, 'player')
	RA:UpdateAverageString(_G.CharacterFrame, 'player')
	RA:UpdateAvgItemLevel(_G.CharacterFrame, 'player')

	RA:HandleCharacterFrameExpand()
end

function RA:PaperDollFrame_SetLevel()
	local db = RA.db.character

	if RA.Retail or RA.Cata then
		--! _G.CharacterFrameTitleText (Retail & Cata)
		_G.CharacterFrameTitleText:ClearAllPoints()
		_G.CharacterFrameTitleText:SetPoint('TOP', _G.CharacterFrame, 'TOP', 0, -5 + db.nameText.yOffset)
		_G.CharacterFrameTitleText:SetPoint('LEFT', _G.CharacterFrame, 'LEFT', 60 + db.nameText.xOffset, 0)
		_G.CharacterFrameTitleText:SetPoint('RIGHT', _G.CharacterFrame, 'RIGHT', -60 + db.nameText.xOffset, 0)
	elseif RA.Classic then
		--! _G.CharacterNameFrame (Classic)
		_G.CharacterNameFrame:ClearAllPoints()
		_G.CharacterNameFrame:SetPoint('CENTER', _G.CharacterFrame, 'CENTER', 6 + db.nameText.xOffset, 232)
	end


	-- No ElvUI Skin Use This as Default Anchor Option | CharacterModelFrame, CharacterFrame as the 2 anchor point options
	--* Current Defaults for Name/Title Text for both elvui skins or not (in cata)
	-- _G.CharacterFrameTitleText:ClearAllPoints()
	-- _G.CharacterFrameTitleText:SetPoint('TOP', _G.CharacterFrame, 'TOP', 0, -5)
	-- _G.CharacterFrameTitleText:SetPoint('LEFT', _G.CharacterFrame, 'LEFT', 60, 0)
	-- _G.CharacterFrameTitleText:SetPoint('RIGHT', _G.CharacterFrame, 'RIGHT', -60, 0)


	--! _G.CharacterLevelText (Cata, Retail)
	_G.CharacterLevelText:ClearAllPoints()
	_G.CharacterLevelText:SetPoint('TOP', _G.CharacterFrameTitleText, 'BOTTOM', db.levelText.xOffset, db.levelText.yOffset)
end

function RA:HandleCharacterFrameExpand()
	if not RA.Cata then return end
	local frame = _G.CharacterFrame
	local showStatus = RA.db.character.expandButton.autoExpand
	if _G.PaperDollFrame:IsVisible() or _G.PetPaperDollFrame:IsVisible() then
		if _G.CharacterStatsPane:IsShown() ~= showStatus then
			_G.CharacterFrameExpandButton:Click()
		end
	end
	_G.CharacterFrameExpandButton:SetShown(not RA.db.character.expandButton.hide)
end
