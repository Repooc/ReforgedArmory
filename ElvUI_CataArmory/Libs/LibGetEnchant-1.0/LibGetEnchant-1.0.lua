local MAJOR, MINOR = 'LibGetEnchant-1.0-ReforgedArmory', 5
assert(LibStub, MAJOR..' requires LibStub')
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

function lib.GetEnchant(enchantID)
	local enchant = tonumber(enchantID)
	if not lib.LibGetEnchantDB[enchant] then return end

	return lib.LibGetEnchantDB[enchant]
end
