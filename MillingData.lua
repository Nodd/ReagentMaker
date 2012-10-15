local addonName, A = ...

-- "Recipe" data
-- [itemID] = {
--     {reagentID, numberNeeded}
--     {reagentID, numberNeeded, minProduced, maxProduced}
--     {reagentID, numberNeeded, chanceToHaveOne}}
A.MillingData = {
	-- Normal pigments
	[39151] = { -- Alabaster Pigment
		{2447,5,2,3}, -- Peacebloom
		{ 765,5,2,3},  -- Silverleaf
		{2449,5,2,4}}, -- Earthroot
	[39334] = { -- Dusky Pigment
		{ 785,5,2,3}, -- Mageroyal
		{2450,5,2,3}, -- Briarthorn
		{2452,5,2,3}, -- Swiftthistle
		{2453,5,2,4}, -- Bruiseweed
		{3820,5,2,4}}, -- Stranglekelp
	[39338] = { -- Golden Pigment
		{3369,5,2,3}, -- Grave Moss
		{3355,5,2,3}, -- Wild Steelbloom
		{3356,5,2,4}, -- Kingsblood
		{3357,5,2,4}}, -- Liferoot
	[39339] = { -- Emerald Pigment
		{3818,5,2,3}, -- Fadeleaf
		{3821,5,2,3}, -- Goldthorn
		{3358,5,3,4}, -- Khadgar's Whisker
		{3819,5,3,4}}, -- Dragon's Teeth
	[39340] = { -- Violet Pigment
		{4625,5,2,3}, -- Firebloom
		{8831,5,2,3}, -- Purple Lotus
		{8836,5,2,3}, -- Arthas' Tears
		{8838,5,2,3}, -- Sungrass
		{8839,5,2,4}, -- Blindweed
		{8845,5,2,4}, -- Ghost Mushroom
		{8846,5,2,4}}, -- Gromsblood
	[39341] = { -- Silvery Pigment
		{13464,5,2,3}, -- Golden Sansam
		{13463,5,2,3}, -- Dreamfoil
		{13465,5,2,4}, -- Mountain Silversage
		{13466,5,2,4}, -- Sorrowmoss
		{13467,5,2,4}}, -- Icecap
	[39342] = { -- Nether Pigment
		{22786,5,2,3}, -- Dreaming Glory
		{22785,5,2,3}, -- Felweed
		{22789,5,2,3}, -- Terocone
		{22787,5,2,3}, -- Ragveil
		{22790,5,2,4}, -- Ancient Lichen
		{22793,5,2,4}, -- Mana Thistle
		{22791,5,2,4}, -- Netherbloom
		{22792,5,2,4}}, -- Nightmare Vine
	[39343] = { -- Azure Pigment
		{37921,5,2,3}, -- Deadnettle
		{36901,5,2,3}, -- Goldclover
		{36907,5,2,3}, -- Talandra's Rose
		{36904,5,2,3}, -- Tiger Lily
		{39970,5,2,3}, -- Fire Leaf
		{39969,5,2.3,3}, -- Fire Seed (2:33%/3:67%)
		{36903,5,2,4}, -- Adder's Tongue
		{36906,5,2,4}, -- Icethorn
		{36905,5,2,4}}, -- Lichbloom
	[61979] = { -- Ashen Pigment
		{52983,5,2,3}, -- Cinderbloom
		{52985,5,2,3}, -- Azshara's Veil
		{52984,5,2,3}, -- Stormvine
		{52986,5,2,3}, -- Heartblossom
		{52988,5,2,4}, -- Whiptail
		{52987,5,2,4}}, -- Twilight Jasmine
	[79251] = { -- Shadow Pigment
		{79011,5,2,4}, -- Fool's Cap
		{72234,5,2,3}, -- Green Tea Leaf
		{72237,5,2,3}, -- Rain Poppy
		{72235,5,2,3}, -- Silkweed
		{79010,5,2,3}, -- Snow Lily
		{89639,5,2,3}, -- Desecrated Herb
		{72238,5,2,4}}, -- Golden Lotus

	-- Rare pigments
	[43103] = { -- Verdant Pigment
		{785,5,0.25},  -- Mageroyal
		{2450,5,0.25}, -- Briarthorn
		{2452,5,0.25}, -- Swiftthistle
		{2453,5,0.5}, -- Bruiseweed
		{3820,5,0.5}}, -- Stranglekelp
	[43104] = { -- Burnt Pigment
		{3369,5,0.25}, -- Grave Moss
		{3355,5,0.25}, -- Wild Steelbloom
		{3356,5,0.5}, -- Kingsblood
		{3357,5,0.5}}, -- Liferoot
	[43105] = { -- Indigo Pigment
		{3818,5,0.25}, -- Fadeleaf
		{3821,5,0.25}, -- Goldthorn
		{3358,5,0.5}, -- Khadgar's Whisker
		{3819,5,0.5}}, -- Dragon's Teeth
	[43106] = { -- Ruby Pigment
		{4625,5,0.25}, -- Firebloom
		{8831,5,0.25}, -- Purple Lotus
		{8836,5,0.25}, -- Arthas' Tears
		{8838,5,0.25}, -- Sungrass
		{8839,5,0.5}, -- Blindweed
		{8845,5,0.5}, -- Ghost Mushroom
		{8846,5,0.5}}, -- Gromsblood
	[43107] = { -- Sapphire Pigment
		{13464,5,0.25}, -- Golden Sansam
		{13463,5,0.25}, -- Dreamfoil
		{13465,5,0.5}, -- Mountain Silversage
		{13466,5,0.5}, -- Sorrowmoss
		{13467,5,0.5}}, -- Icecap
	[43108] = { -- Ebon Pigment
		{22786,5,0.25}, -- Dreaming Glory
		{22785,5,0.25}, -- Felweed
		{22789,5,0.25}, -- Terocone
		{22787,5,0.25}, -- Ragveil
		{22790,5,0.5}, -- Ancient Lichen
		{22793,5,0.5}, -- Mana Thistle
		{22791,5,0.5}, -- Netherbloom
		{22792,5,0.5}}, -- Nightmare Vine
	[43109] = { -- Icy Pigment
		{37921,5,0.25}, -- Deadnettle
		{36901,5,0.25}, -- Goldclover
		{36907,5,0.25}, -- Talandra's Rose
		{36904,5,0.25}, -- Tiger Lily
		{39970,5,0.25}, -- Fire Leaf
		{39969,5,0.25}, -- Fire Seed
		{36903,5,0.5}, -- Adder's Tongue
		{36906,5,0.5}, -- Icethorn
		{36905,5,0.5}}, -- Lichbloom
	[61980] = { -- Burning Embers
		{52983,5,0.25}, -- Cinderbloom
		{52985,5,0.25}, -- Azshara's Veil
		{52984,5,0.25}, -- Stormvine
		{52986,5,0.25}, -- Heartblossom
		{52988,5,0.5}, -- Whiptail
		{52987,5,0.5}}, -- Twilight Jasmine
	[79253] = { -- Misty Pigment
		{72234,5,0.25}, -- Green Tea Leaf
		{72237,5,0.25}, -- Rain Poppy
		{72235,5,0.25}, -- Silkweed
		{79010,5,0.25}, -- Snow Lily
		{89639,5,0.25}, -- Desecrated Herb
		{79011,5,0.5}, -- Fool's Cap
		{72238,5,0.5}}, -- Golden Lotus
}

-- "Tradeskill" data
local MillID = 51005
local MillName = GetSpellInfo(MillID)
local macroMill = "/cast "..MillName.."\n/use %s"
local MillLink = GetSpellLink(MillID)

-- Add "Tradeskill" data to each "recipe"
for itemID,t in pairs(A.MillingData) do
	for i,v in ipairs(t) do
		v.macro = macroMill
		v.spellID = MillID
		v.spellLink = MillLink
	end
end
