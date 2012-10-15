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
		local NRecipes = GetNumTradeSkills()
		if NRecipes==0 or select(2,GetTradeSkillInfo(1))~="header" then
			return
		end

		local tradeskillName = GetTradeSkillLine()

		-- Check if the pseudo tradeskills have to be added
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

		local lastHeader
		local isScanCorrect = true
		for i = 1,NRecipes do
			-- skillName, skillType, numAvailable, isExpanded, serviceType, numSkillUps = GetTradeSkillInfo(index)
			-- serviceType is nil if the recipe creates an item
			local skillName, skillType, _, _, serviceType = GetTradeSkillInfo(i)
			if not skillName then return end

			-- Save the name of the header
			if skillType and skillType == "header" then
				lastHeader = skillName

			-- Analyse recipe
			elseif skillType and skillType ~= "header" and serviceType==nil then
				local isRecipeCorrect = true

				-- item ID
				local itemID = A.link2ID(GetTradeSkillItemLink(i))
				if not itemID then isRecipeCorrect = false; end

				local numReagents = GetTradeSkillNumReagents(i)
				if not numReagents then isRecipeCorrect = false; end

				local reagentID, reagentCount
				if numReagents==1 then
					-- reagent ID
					reagentID = A.link2ID(GetTradeSkillReagentItemLink(i, 1))
					if not reagentID then isRecipeCorrect = false; end

					-- reagent number needed
					reagentCount = select(3,GetTradeSkillReagentInfo(i, 1))
					if not reagentCount then isRecipeCorrect = false; end
				else
					-- no reagentID (is already nil)
					--reagentID = nil

					-- contains data for the whole reagents
					reagentCount = {}
					for j = 1,numReagents do
						local id = A.link2ID(GetTradeSkillReagentItemLink(i, j))
						local num = select(3,GetTradeSkillReagentInfo(i, j))
						if not id or not num then isRecipeCorrect = false; break; end
						tinsert(reagentCount,{id, num})
					end
				end

				-- number of reagent created by the recipe
				local minMade, maxMade = GetTradeSkillNumMade(i)
				if not minMade or not maxMade then isRecipeCorrect = false; end

				-- recipe link (for tooltips)
				local recipeLink = GetTradeSkillRecipeLink(i)
				if not recipeLink then isRecipeCorrect = false; end

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
			end -- if
		end -- for
		-- the scanning is complete
		return isScanCorrect
	end -- function
end -- do
