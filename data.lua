local addonName, A = ...

A.data = A.CommonData


function A:ScanCurrentTradeskill()
	if not A.IsPlayerTradeSkill() then return end

	for _, recipeID in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
		if recipeInfo.learned then
			recipeItemLink = C_TradeSkillUI.GetRecipeItemLink(recipeInfo.recipeID)
			recipeItemID = A.link2ID(recipeItemLink)

			addSpell = true
			if not A.data[recipeItemID] then
				A.data[recipeItemID] = {}
			else
				-- Check that the spell is not already in the base
				for _, otherRecipeID in ipairs(A.data[recipeItemID]) do
					if otherRecipeID.recipeID == recipeInfo.recipeID then
						addSpell = false
						break
					end -- if
				end -- for
			end -- if

			-- Keep the data
			if addSpell then
				tinsert(A.data[recipeItemID], {recipeID=recipeInfo.recipeID})
			end -- if
		end
	end
end
