local addonName, A = ...

A.data = A.CommonData

do
	-- lua functions
	local ipairs = ipairs
	local pairs = pairs
	local tinsert = tinsert
	local select = select

	-- Wow functions
	local GetNumTradeSkills = GetNumTradeSkills
	local GetTradeSkillInfo = GetTradeSkillInfo
	local GetTradeSkillNumReagents = GetTradeSkillNumReagents
	local GetTradeSkillItemLink = GetTradeSkillItemLink
	local GetTradeSkillRecipeLink = GetTradeSkillRecipeLink
	local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
	local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
	local GetTradeSkillNumMade = GetTradeSkillNumMade
	local GetSpellInfo = GetSpellInfo

	-- Wow objects
	local GetTradeSkillLine = GetTradeSkillLine

	-- the function who scans the tradeskill
	function A:ScanSimpleRecipes()
		-- Do not scan while we modify the tradeskill display
		if A.blockScan then return end

		-- Check if the tradeskill is loaded
		-- Has to have recipes and begin with a header
		local numRecipes  = GetNumTradeSkills()
		local firstRecipe = GetFirstTradeSkill()
		if numRecipes == 0 or not firstRecipe then return end

		-- Check if the pseudo tradeskills have to be added
		local tradeskillName = GetTradeSkillLine()
		if tradeskillName == GetSpellInfo(25229) then -- Jewelcrafting
			if not A.ProspectingDataLoaded then
				for itemID,data in pairs(A.ProspectingData) do
					A.data[itemID] = data
				end
				A.ProspectingDataLoaded = true
			end
		elseif tradeskillName == GetSpellInfo(45357) then -- Inscription
			if not A.MillingDataLoaded then
				for itemID,data in pairs(A.MillingData) do
					A.data[itemID] = data
				end
				A.MillingDataLoaded = true
			end
		end

		local _, lastHeader, craftedItem, skillName, skillType, serviceType
		local isScanCorrect = true
		for i = firstRecipe, numRecipes do
			-- skillName, skillType, numAvailable, isExpanded, serviceType, numSkillUps = GetTradeSkillInfo(index)
			-- serviceType is nil if the recipe creates an item
			skillName, skillType, _, _, serviceType = GetTradeSkillInfo(i)
			craftedItem = GetTradeSkillItemLink(i)

			if not skillType or not skillName then
				return
			elseif skillType == "header" or skillType == "subheader" then
				-- Save the name of the header
				lastHeader = skillName
			elseif craftedItem then
				-- recipe creates an item
				local isRecipeCorrect = true

				-- item ID
				local itemID = A.link2ID(craftedItem)
				if not itemID then isRecipeCorrect = false end

				local numReagents = GetTradeSkillNumReagents(i) or 0
				local reagentID, reagentCount, subReagentID, subReagentCount

				if numReagents == 1 then
					reagentID = A.link2ID(GetTradeSkillReagentItemLink(i, 1))
					_, _, reagentCount = GetTradeSkillReagentInfo(i, 1)

					if not reagentCount or not reagentID then isRecipeCorrect = false end
				else
					-- no reagentID (is already nil)
					-- contains data for the whole reagents
					reagentCount = {}
					for j = 1, numReagents do
						subReagentID = A.link2ID( GetTradeSkillReagentItemLink(i, j) )
						_, _, subReagentCount = GetTradeSkillReagentInfo(i, j)
						if not subReagentID or not subReagentCount then
							isRecipeCorrect = false
							break
						end
						tinsert(reagentCount, {subReagentID, subReagentCount})
					end
				end

				-- number of reagent created by the recipe
				local minMade, maxMade = GetTradeSkillNumMade(i)
				if not minMade or not maxMade then isRecipeCorrect = false end

				-- recipe link (for tooltips)
				local recipeLink = GetTradeSkillRecipeLink(i)
				if not recipeLink then isRecipeCorrect = false end

				if not isRecipeCorrect then
					isScanCorrect = false
				end
				-- error checking
				if isRecipeCorrect then
					-- remove unneeded minMade/maxMade
					if maxMade==minMade then
						maxMade = nil
						if minMade==1 then
							minMade = nil
						end -- if
					end -- if

					-- As we scan multiple times, check if this recipe is already stored
					local addSpell	= true
					if not A.data[itemID] then
						A.data[itemID] = {}
					else
						for _,v in ipairs(A.data[itemID]) do
							if v.spellLink==recipeLink then
								addSpell = nil
								break
							end -- if
						end -- for
					end -- if

					-- Cache the data
					if addSpell then
						local spell = {reagentID,reagentCount,minMade,maxMade}
							  spell.skillName = skillName
							  spell.tradeskillName = tradeskillName
							  spell.spellLink = recipeLink
							  spell.header = lastHeader
						tinsert(A.data[itemID],spell)
					end
				end -- if
			end
		end -- for
		-- the scanning is complete
		return isScanCorrect
	end -- function
end -- do
