local ReforgedArmory = select(2, ...)
ReforgedArmory[2] = ReforgedArmory[1].Libs.ACL:GetLocale('ReforgedArmory', ReforgedArmory[1]:GetLocale()) -- Locale doesn't exist yet, make it exist.
local RA, L, P, G = unpack(ReforgedArmory)

RA.myName = UnitName('player')
RA.myRealm = GetRealmName()
RA.myNameRealm = format('%s - %s', RA.myName, RA.myRealm)

RA.AttachToObjects = {}
RA.AttachToObjects['character'] = {
	PaperDollFrame = 'PaperDollFrame',
	CharacterLevelText = 'CharacterLevelText',
}
if RA.Cata then
	RA.AttachToObjects.character['CharacterFrameInsetRight'] = 'CharacterFrameInsetRight'
end
if not RA.Classic then
	RA.AttachToObjects.character['CharacterFrameInset'] = 'CharacterFrameInset'
end

RA.AttachToObjects['inspect'] = {
	InspectPaperDollFrame = 'InspectPaperDollFrame',
	InspectLevelText = 'InspectLevelText',
}

function RA:DBConvert()
	if RA.db.character.avgItemLevel.frame.attachTo == 'CharacterStatsPane' then
		RA.db.character.avgItemLevel.frame.attachTo = 'CharacterLevelText'
	end
end

function RA:SetupProfile()
	RA.global = RA.data.global
	RA.db = RA.data.profile
end

function RA:Initialize()
	wipe(RA.db)
	wipe(RA.global)

	RA.isTimeRunning = PlayerGetTimerunningSeasonID and PlayerGetTimerunningSeasonID()

	RA.data = RA.Libs.AceDB:New('RADB', RA.Defaults, true)
	RA.data.RegisterCallback(RA, 'OnProfileChanged', 'SetupProfile')
	RA.data.RegisterCallback(RA, 'OnProfileCopied', 'SetupProfile')
	RA.data.RegisterCallback(RA, 'OnProfileReset', 'SetupProfile')

	RA.global = RA.data.global
	RA.db = RA.data.profile
	RA.initialized = true

	--* Furture DB Conversion Function
	RA:DBConvert()
	RA:BuildOptions()

	if RA.db.general.showLoginMsg then
		RA:Print('|cff16c3f2Successfully loaded.|r')
	end

	--* InspectFrame Hooks if loaded, otherwise register event
	RA:ADDON_LOADED('FAKE_LOGIN_EVENT')

	--* CharacterFrame Hooks
	RA:SecureHookScript(_G.CharacterFrame, 'OnShow', 'CharacterFrame_OnShow')
	if RA.Cata then
		RA:SecureHook(_G.CharacterFrame, 'ShowSubFrame', RA.HandleCharacterFrameExpand)
		local isSkinned = ElvUI and (ElvUI[1].private.skins.blizzard.enable and ElvUI[1].private.skins.blizzard.inspect)
		RA:SecureHook(_G.CharacterFrame, 'UpdateSize', function()
			if isSkinned then
				if _G.CharacterFrame.Expanded then
					_G.CharacterFrame:SetWidth(572)
					_G.CharacterFrame.InsetRight:ClearAllPoints()
					_G.CharacterFrame.InsetRight:Point('TOPLEFT', _G.CharacterFrameInset, 'TOPRIGHT', 33, 0)
					_G.CharacterFrame.InsetRight:Point('BOTTOMRIGHT', _G.CharacterFrame, 'BOTTOMRIGHT', -4, 4)
				end
			end
		end)
	end

	if RA.Retail or RA.Cata then
		RA:SecureHook('EquipmentFlyout_UpdateItems', RA.EquipmentFlyout_UpdateItems)
	end

	RA:SecureHook('PaperDollItemSlotButton_Update', function(button)
		if button.GetName and string.match(button:GetName(), 'Bag') then return end
		RA:UpdateItemSlot(button, 'player')
	end)

	--* Sets Name & Level Text
	RA:SecureHook('PaperDollFrame_SetLevel', RA.PaperDollFrame_SetLevel)
end
