local addonName, A = ...

-- GLOBALS: SPELL_FAILED_ERROR, OpenStackSplitFrame, StackSplitFrame_OnChar, StackSplitFrame

-- Lua functions
local tostring = tostring
local min = math.min
local max = math.max
local floor = math.floor

-- Wow functions
local IsTradeSkillGuild = IsTradeSkillGuild
local IsTradeSkillLinked = IsTradeSkillLinked
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local GetTradeSkillSelectionIndex = GetTradeSkillSelectionIndex
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillLine = GetTradeSkillLine
local GetItemInfo = GetItemInfo
local DoTradeSkill = DoTradeSkill

--SPELL_FAILED_REAGENTS = "Missing reagent: %s";
--ERR_SPELL_FAILED_REAGENTS_GENERIC = "Missing reagent";
--ERR_INTERNAL_BAG_ERROR = "Internal Bag Error";
--SPELL_FAILED_ERROR = "Internal error";

---------------------------------------------------
-- Craft items
---------------------------------------------------
-- Function run after selecting a item in the tradeskill window
-- It only "prefilters" the possibilities
function A.ProcessReagent(reagentButton)
	print("craft")
	info = A.ReagentButtonInfo(reagentButton)

	-- Do not manage guild or linked tradeskill
	if not info.recipeIDs then return end

	-- We want no modifiers, or shift to choose the number of reagent to craft
	if IsModifierKeyDown() and not IsShiftKeyDown() then return end
	local chooseNumberToCraft = IsShiftKeyDown()

	-- If only one recipe is known for the reagent and it is an actual recipe, use it
	if info.recipeID then -- and not recipeIDs[1].macro then
		amount = 1
		C_TradeSkillUI.CraftRecipe(info.recipeID, amount)
		--A.CraftItemWithRecipe(recipeIndex,reagentID,recipeIDs[1],reagentIndexInRecipe,chooseNumberToCraft,btn)

	else -- Many recipes are known for this item, or it is not a standard tradeskill display them all
		A.externalCraftWindow(reagentID,reagentIndexInRecipe)
	end -- if
end -- function

-- Launch the procedure for a standard recipe
-- Can be called from the external window
function A.CraftItemWithRecipe(recipeID,reagentID,recipeData,reagentIndexInRecipe,chooseNumberToCraft,btn)
	-- Check that it's the same tradeskill
	--if recipeData.tradeskillName ~= GetTradeSkillLine() then
	--	A.Error(A.L["The recipe to make this reagent is in another tradeskill. Currently ReagentMaker can not manage such a case, sorry."])
	--	return
	--end

	-- Check how many times the recipe is makable
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
	local numMakable = recipeInfo.numAvailable
	if not numMakable then
		A.Error(SPELL_FAILED_ERROR)
		return
	end

	if numMakable<=0 then
		-- If not makable, try a one-step recursion
		-- enables e.g. to mill to create an ink
		-- need a unique reagent
		if recipeData[1] and A.data[recipeData[1]] then
			if A.externalCraftWindow(recipeData[1],reagentIndexInRecipe,reagentID) ~= false then
				-- there was no problem opening the external window
				return
			end
		end

		-- There isn't enough reagents
		--@todo include name of reagent if unique
		A.Error(A.L["You do not have enough reagents to craft [%s]"]:format(GetItemInfo(reagentID) or "item #"..reagentID))
		return
	end

	-- Optimal number of items to craft
	local numToMake = A.numToMake(recipeIndex, reagentIndexInRecipe,numMakable, recipeData[3], recipeData[4])

	-- Choose number or craft directly
	if chooseNumberToCraft then
		-- Store info to be able to run the function later
		btn.ReagentMaker_reagentID = reagentID
		btn.ReagentMaker_recipeData = recipeData

		-- Open dialog
		OpenStackSplitFrame(numMakable, btn, "TOP", "BOTTOM")

		-- Fill in the number to make
		numToMake = tostring(numToMake)
		for i = 1,numToMake:len() do
			StackSplitFrame_OnChar(StackSplitFrame,numToMake:gsub(i,i))
		end
		StackSplitFrame.typing = 0 -- reinit the frame so that the entered value will be erased on text entry
	else
		A.DoCraft(reagentID,recipeData,numToMake)
	end -- if
end

-- Gives the total number of craftable items
function A.numMakable(reagentItemID)
	local recipeIDs = A.data[reagentItemID]

	-- No recipe
	if not recipeIDs then return nil, nil, nil end

	-- Many recipes
	local craftableMin = 0
	local craftableMax = 0
	local isApprox = false
	local recipeInfo = {}
	for _, recipeID in ipairs(recipeIDs) do
		-- number of times the recipe is makable
		C_TradeSkillUI.GetRecipeInfo(recipeID, recipeInfo)
		local numAvailable = recipeInfo.numAvailable
		local minMade, maxMade = C_TradeSkillUI.GetRecipeNumItemsProduced(recipeID)
		craftableMin = craftableMin + minMade * numAvailable
		craftableMax = craftableMax + minMade * numAvailable
	end -- for
	return craftableMin, craftableMax, isApprox
end -- function

-- Compute optimal number of items to craft
function A.numToMake(recipeIndex, reagentIndexInRecipe,numReagentMakable,minMade,maxMade)
	-- Look at how many we need to make one item for the selected recipe
	local numToMake = 1
	local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(recipeIndex, reagentIndexInRecipe)
	-- make enough reagents to craft one more item
	numToMake = min(floor(playerReagentCount/reagentCount+1)*reagentCount-playerReagentCount,numReagentMakable)

	-- take into account that some recipe craft more than one item
	-- use the mean between min and max, but make at least one...
	if not minMade then
		minMade = 1
	elseif minMade<1 then
		-- from the percentage, compute the mean number of crafts to make
		minMade = 1/minMade
	end
	if not maxMade then
		maxMade = minMade
	end
	numToMake = max(floor(2*numToMake/(maxMade+minMade)),1)
	return numToMake
end

-- function used after choosing the number of reagent to craft
function A.SplitStack(owner,split)
	A.DoCraft(owner.ReagentMaker_reagentID,owner.ReagentMaker_recipeData,split)
	owner.ReagentMaker_reagentID = nil
	owner.ReagentMaker_recipeData = nil
end

-- Find the recipe and do the crafting
function A.DoCraft(reagentID,recipeData,numToMake)
	-- Remove filters
	A.SaveActiveFilters(recipeData.header)

	-- Find recipe index
	local reagentIndex = A.findExactSkillIndex(reagentID,recipeData.spellLink)

	-- Error if not found
	if not reagentIndex then
		A.Error(A.L["The recipe to make the reagent seems to be hidden, it is not makable. Try to remove the filters on the recipes."])
		A.RestoreActiveFilters()
		return
	end

	-- Craft the item, finally !
	DoTradeSkill(reagentIndex,numToMake)

	-- Restore Filters
	A.RestoreActiveFilters()
end
