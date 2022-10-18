local MAJOR, MINOR = "LibGetEnchant-1.0-WrathArmory", 3
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

function lib.GetEnchant(enchantID)
	local enchant = tonumber(enchantID)
	if lib.LibGetEnchantDB[enchant] then
		return lib.LibGetEnchantDB[enchant]
	end
end
