local addonName, A = ...

-- GLOBALS: SPELL_FAILED_ERROR, OpenStackSplitFrame, StackSplitFrame_OnChar, StackSplitFrame

-- Lua functions
local tostring = tostring
local min = math.min
local max = math.max
local floor = math.floor

-- Wow functions
local C_TradeSkillUI = C_TradeSkillUI
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local GetItemInfo = GetItemInfo

--SPELL_FAILED_REAGENTS = "Missing reagent: %s";
--ERR_SPELL_FAILED_REAGENTS_GENERIC = "Missing reagent";
--ERR_INTERNAL_BAG_ERROR = "Internal Bag Error";
--SPELL_FAILED_ERROR = "Internal error";

---------------------------------------------------
-- Craft items
---------------------------------------------------
-- Function run after selecting a item in the tradeskill window
function A.ProcessReagent(reagentButton)
	local reagentInfo = A.ReagentButtonInfo(reagentButton)

	-- Abort if this reagant is not managed
	if not reagentInfo.recipes then return end

	-- We want either no modifiers, or shift to choose the number of reagent to
	-- craft
	if IsModifierKeyDown() and not IsShiftKeyDown() then return end
	local chooseNumberToCraft = IsShiftKeyDown()

	-- If only one recipe is known for the reagent and it is an actual recipe, use it
	if reagentInfo.recipeID then
		A.CraftItemWithRecipe(reagentInfo, chooseNumberToCraft, reagentButton)

	else -- Many recipes are known for this item, or it is not a standard tradeskill display them all
		A.externalCraftWindow(reagentID, reagentIndex)
	end -- if
end -- function

-- Launch the procedure for a standard recipe
-- Can be called from the external window
function A.CraftItemWithRecipe(reagentInfo, chooseNumberToCraft, reagentButton)
	-- Check that it's the same tradeskill
	--if recipeData.tradeskillName ~= GetTradeSkillLine() then
	--	A.Error(A.L["The recipe to make this reagent is in another tradeskill. Currently ReagentMaker can not manage such a case, sorry."])
	--	return
	--end

	-- Check how many times the recipe is makable
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(reagentInfo.recipeID)
	local numReagentRecipeMakable = recipeInfo.numAvailable

	--[[
	if numReagentRecipeMakable<=0 then
		-- If not makable, try a one-step recursion
		-- enables e.g. to mill to create an ink
		-- need a unique reagent
		if A.data[reagentItemID] then
			if A.externalCraftWindow(recipeData[1],reagentIndex,reagentID) ~= false then
				-- there was no problem opening the external window
				return
			end
		end

		-- There isn't enough reagents
		--@todo include name of reagent if unique
		A.Error(A.L["You do not have enough reagents to craft [%s]"]:format(GetItemInfo(reagentID) or "item #"..reagentID))
		return
	end
	--]]

	-- Optimal number of items to craft
	local numToMake = A.numToMake(reagentInfo, numReagentRecipeMakable)
	if not numToMake then return end

	-- Choose number or craft directly
	if chooseNumberToCraft then
		-- Store info to be able to run the function later
		reagentButton.ReagentMaker_reagentID = reagentID
		reagentButton.ReagentMaker_recipeData = recipeData

		-- Open dialog
		OpenStackSplitFrame(numMakable, reagentButton, "TOP", "BOTTOM")

		-- Fill in the number to make
		numToMake = tostring(numToMake)
		for i = 1,numToMake:len() do
			StackSplitFrame_OnChar(StackSplitFrame,numToMake:gsub(i,i))
		end
		StackSplitFrame.typing = 0 -- reinit the frame so that the entered value will be erased on text entry
	else
		-- Craft the item, finally !
		C_TradeSkillUI.CraftRecipe(recipeInfo.recipeID, numToMake)
	end -- if
end

-- Gives the total number of craftable items
function A.numMakable(reagentItemID)
	local recipes = A.data[reagentItemID]

	-- No recipe
	if not recipes then return nil, nil, nil end

	-- Many recipes
	local craftableMin = 0
	local craftableMax = 0
	local isApprox = false
	local recipeInfo = {}
	for _, recipe in ipairs(recipes) do
		-- number of times the recipe is makable
		local numAvailable, minMade, maxMade
		if recipe.recipeID then
			C_TradeSkillUI.GetRecipeInfo(recipe.recipeID, recipeInfo)
			numAvailable = recipeInfo.numAvailable
			minMade, maxMade = C_TradeSkillUI.GetRecipeNumItemsProduced(recipe.recipeID)
			-- Hack for recipes from another tradeskill
			if not minMade then minMade = 0 end
			if not maxMade then maxMade = 0 end
			if not numAvailable then numAvailable = 0 end
		elseif recipe.spellID then
			minMade = recipe.numOut
			maxMade = recipe.numOut
			local count = GetItemCount(recipe.reagentID, true) -- includeBank
			numAvailable = floor(count / recipe.numIn)
		end
		craftableMin = craftableMin + minMade * numAvailable
		craftableMax = craftableMax + maxMade * numAvailable
	end -- for
	return craftableMin, craftableMax, isApprox
end -- function

-- Compute optimal number of reagents to craft
function A.numToMake(reagentInfo, numReagentRecipeMakable)
	-- Look at how many reagent we need to make one item of the selected recipe
	local _, _, reagentCount, playerReagentCount = C_TradeSkillUI.GetRecipeReagentInfo(
		reagentInfo.selectedRecipeID,
		reagentInfo.reagentIndex)

	-- Enough reagents to craft one more item
	local numReagentToMake = reagentCount - (playerReagentCount % reagentCount)

	-- take into account that some recipe craft more than one item
	-- use the mean between min and max, but make at least one...
	local minMade, maxMade = C_TradeSkillUI.GetRecipeNumItemsProduced(reagentInfo.recipeID)
	local meanMade = (minMade + maxMade) / 2
	numRecipeToMake = floor(numReagentToMake / meanMade) -- floor() to not waste reagents
	numRecipeToMake = max(numRecipeToMake, 1) -- Make at least one
	if numRecipeToMake > numReagentRecipeMakable then
		UIErrorsFrame:TryDisplayMessage(
			LE_GAME_ERR_SPELL_FAILED_REAGENTS,
			A.L["Unable to make enough reagent for one more recipe."],
			1, 0, 0)
		numRecipeToMake = nil
	end
	return numRecipeToMake
end

-- function used after choosing the number of reagent to craft
function A.SplitStack(owner,split)
	A.DoCraft(owner.ReagentMaker_reagentID,owner.ReagentMaker_recipeData,split)
	owner.ReagentMaker_reagentID = nil
	owner.ReagentMaker_recipeData = nil
end
