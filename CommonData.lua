local addonName, A = ...

A.CommonData = {
	[10939] = {{reagentID=10938, numIn=3, numOut=1, spellID=13361}}, -- Lesser to Greater Magic Essence
	[11082] = {{reagentID=10998, numIn=3, numOut=1, spellID=13497}}, -- Lesser to Greater Astral Essence
	[11135] = {{reagentID=11134, numIn=3, numOut=1, spellID=13632}}, -- Lesser to Greater Mystic Essence
	[11175] = {{reagentID=11174, numIn=3, numOut=1, spellID=13739}}, -- Lesser to Greater Nether Essence
	[16203] = {{reagentID=16202, numIn=3, numOut=1, spellID=20039}}, -- Lesser to Greater Eternal Essence
	[22446] = {{reagentID=22447, numIn=3, numOut=1, spellID=32977}}, -- Lesser to Greater Planar Essence
	[34055] = {{reagentID=34056, numIn=3, numOut=1, spellID=44123}}, -- Lesser to Greater Cosmic Essence
	[52719] = {{reagentID=52718, numIn=3, numOut=1, spellID=74186}}, -- Lesser to Greater Celestial Essence

	[10938] = {{reagentID=10939, numIn=1, numOut=3, spellID=13362}}, -- Greater to Lesser Magic Essence
	[10998] = {{reagentID=11082, numIn=1, numOut=3, spellID=13498}}, -- Greater to Lesser Astral Essence
	[11134] = {{reagentID=11135, numIn=1, numOut=3, spellID=13633}}, -- Greater to Lesser Mystic Essence
	[11174] = {{reagentID=11175, numIn=1, numOut=3, spellID=13740}}, -- Greater to Lesser Nether Essence
	[16202] = {{reagentID=16203, numIn=1, numOut=3, spellID=20040}}, -- Greater to Lesser Eternal Essence
	[22447] = {{reagentID=22446, numIn=1, numOut=3, spellID=32978}}, -- Greater to Lesser Planar Essence
	[34056] = {{reagentID=34055, numIn=1, numOut=3, spellID=44122}}, -- Greater to Lesser Cosmic Essence
	[52718] = {{reagentID=52719, numIn=1, numOut=3, spellID=74187}}, -- Greater to Lesser Celestial Essence

	[52721] = {{reagentID=52720, numIn=3, numOut=1, spellID=74188}}, -- Small Heavenly Shard to Heavenly Shard
	[34052] = {{reagentID=34053, numIn=3, numOut=1, spellID=61755}}, -- Small Dream Shard to Dream Shard

	[33568] = {{reagentID=33567, numIn=5, numOut=1, spellID=59926}}, -- Borean Leather Scraps to Borean Leather
	[52976] = {{reagentID=52977, numIn=5, numOut=1, spellID=74493}}, -- Savage Leather Scraps to Savage Leather

	[22451] = {{reagentID=22572, numIn=10, numOut=1, spellID=28100}}, -- Mote of Air to Primal Air
	[22452] = {{reagentID=22573, numIn=10, numOut=1, spellID=28101}}, -- Mote of Earth to Primal Earth
	[21884] = {{reagentID=22574, numIn=10, numOut=1, spellID=28102}}, -- Mote of Fire to Primal Fire
	[21886] = {{reagentID=22575, numIn=10, numOut=1, spellID=28106}}, -- Mote of Life to Primal Life
	[22457] = {{reagentID=22576, numIn=10, numOut=1, spellID=28105}}, -- Mote of Mana to Primal Mana
	[22456] = {{reagentID=22577, numIn=10, numOut=1, spellID=28104}}, -- Mote of Shadow to Primal Shadow
	[21885] = {{reagentID=22578, numIn=10, numOut=1, spellID=28103}}, -- Mote of Water to Primal Water

	[35623] = {{reagentID=37700, numIn=10, numOut=1, spellID=49234}}, -- Crystallized to Eternal Air
	[35624] = {{reagentID=37701, numIn=10, numOut=1, spellID=49248}}, -- Crystallized to Eternal Earth
	[36860] = {{reagentID=37702, numIn=10, numOut=1, spellID=49244}}, -- Crystallized to Eternal Fire
	[35625] = {{reagentID=37704, numIn=10, numOut=1, spellID=49247}}, -- Crystallized to Eternal Life
	[35627] = {{reagentID=37703, numIn=10, numOut=1, spellID=49246}}, -- Crystallized to Eternal Shadow
	[35622] = {{reagentID=37705, numIn=10, numOut=1, spellID=49245}}, -- Crystallized to Eternal Water

	[37700] = {{reagentID=35623, numIn=1, numOut=10, spellID=56045}}, -- Eternal to Crystallized Air
	[37701] = {{reagentID=35624, numIn=1, numOut=10, spellID=56041}}, -- Eternal to Crystallized Earth
	[37702] = {{reagentID=36860, numIn=1, numOut=10, spellID=56042}}, -- Eternal to Crystallized Fire
	[37704] = {{reagentID=35625, numIn=1, numOut=10, spellID=56043}}, -- Eternal to Crystallized Life
	[37703] = {{reagentID=35627, numIn=1, numOut=10, spellID=56044}}, -- Eternal to Crystallized Shadow
	[37705] = {{reagentID=35622, numIn=1, numOut=10, spellID=56040}}, -- Eternal to Crystallized Water

	[76061] = {{reagentID=89112, numIn=10, numOut=1, spellID=129352}}, -- Motes of Harmony to Spirit of Harmony
}

-- Add "Tradeskill" data to each "recipe"
for itemID, t in pairs(A.CommonData) do
	t[1].macro = "/use %s"
	--t[1].spellName = GetSpellInfo(t[1].spellID)
	t[1].spellLink = GetSpellLink(t[1].spellID)
end
