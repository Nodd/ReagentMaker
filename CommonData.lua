local addonName, A = ...

A.CommonData = {
	[10939] = {{10938, 3, 1,spellID=13361}}, -- Lesser to Greater Magic Essence
	[11082] = {{10998, 3, 1,spellID=13497}}, -- Lesser to Greater Astral Essence
	[11135] = {{11134, 3, 1,spellID=13632}}, -- Lesser to Greater Mystic Essence
	[11175] = {{11174, 3, 1,spellID=13739}}, -- Lesser to Greater Nether Essence
	[16203] = {{16202, 3, 1,spellID=20039}}, -- Lesser to Greater Eternal Essence
	[22446] = {{22447, 3, 1,spellID=32977}}, -- Lesser to Greater Planar Essence
	[34055] = {{34056, 3, 1,spellID=44123}}, -- Lesser to Greater Cosmic Essence
	[52719] = {{52718, 3, 1,spellID=74186}}, -- Lesser to Greater Celestial Essence

	[10938] = {{10939, 1, 3,spellID=13362}}, -- Greater to Lesser Magic Essence
	[10998] = {{11082, 1, 3,spellID=13498}}, -- Greater to Lesser Astral Essence
	[11134] = {{11135, 1, 3,spellID=13633}}, -- Greater to Lesser Mystic Essence
	[11174] = {{11175, 1, 3,spellID=13740}}, -- Greater to Lesser Nether Essence
	[16202] = {{16203, 1, 3,spellID=20040}}, -- Greater to Lesser Eternal Essence
	[22447] = {{22446, 1, 3,spellID=32978}}, -- Greater to Lesser Planar Essence
	[34056] = {{34055, 1, 3,spellID=44122}}, -- Greater to Lesser Cosmic Essence
	[52718] = {{52719, 1, 3,spellID=74187}}, -- Greater to Lesser Celestial Essence

	[52721] = {{52720, 3, 1,spellID=74188}}, -- Small Heavenly Shard to Heavenly Shard
	[34052] = {{34053, 3, 1,spellID=61755}}, -- Small Dream Shard to Dream Shard

	[33568] = {{33567, 5, 1,spellID=59926}}, -- Borean Leather Scraps to Borean Leather
	[52976] = {{52977, 5, 1,spellID=74493}}, -- Savage Leather Scraps to Savage Leather

	[22451] = {{22572,10, 1,spellID=28100}}, -- Mote of Air to Primal Air
	[22452] = {{22573,10, 1,spellID=28101}}, -- Mote of Earth to Primal Earth
	[21884] = {{22574,10, 1,spellID=28102}}, -- Mote of Fire to Primal Fire
	[21886] = {{22575,10, 1,spellID=28106}}, -- Mote of Life to Primal Life
	[22457] = {{22576,10, 1,spellID=28105}}, -- Mote of Mana to Primal Mana
	[22456] = {{22577,10, 1,spellID=28104}}, -- Mote of Shadow to Primal Shadow
	[21885] = {{22578,10, 1,spellID=28103}}, -- Mote of Water to Primal Water

	[35623] = {{37700,10, 1,spellID=49234}}, -- Crystallized to Eternal Air
	[35624] = {{37701,10, 1,spellID=49248}}, -- Crystallized to Eternal Earth
	[36860] = {{37702,10, 1,spellID=49244}}, -- Crystallized to Eternal Fire
	[35625] = {{37704,10, 1,spellID=49247}}, -- Crystallized to Eternal Life
	[35627] = {{37703,10, 1,spellID=49246}}, -- Crystallized to Eternal Shadow
	[35622] = {{37705,10, 1,spellID=49245}}, -- Crystallized to Eternal Water

	[37700] = {{35623, 1,10,spellID=56045}}, -- Eternal to Crystallized Air
	[37701] = {{35624, 1,10,spellID=56041}}, -- Eternal to Crystallized Earth
	[37702] = {{36860, 1,10,spellID=56042}}, -- Eternal to Crystallized Fire
	[37704] = {{35625, 1,10,spellID=56043}}, -- Eternal to Crystallized Life
	[37703] = {{35627, 1,10,spellID=56044}}, -- Eternal to Crystallized Shadow
	[37705] = {{35622, 1,10,spellID=56040}}, -- Eternal to Crystallized Water

	[76061] = {{89112,10,1,spellID=129352}}, -- Motes of Harmony to Spirit of Harmony
}

-- Add "Tradeskill" data to each "recipe"
for itemID,t in pairs(A.CommonData) do
	t[1].macro = "/use %s"
	--t[1].spellName = GetSpellInfo(t[1].spellID)
	t[1].spellLink = GetSpellLink(t[1].spellID)
end
