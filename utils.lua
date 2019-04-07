local addonName, A = ...

-- GLOBALS: UIErrorsFrame, UIErrorsFrame_OnEvent

-- Messages to the user
function A.Warn(message)
	if not msg then return end
	local event = "UI_INFO_MESSAGE"
	UIErrorsFrame:TryDisplayMessage(messageType, message, r, g, b)
end -- function
function A.Error(message)
	if not msg then return end
	local event = "UI_ERROR_MESSAGE"
	UIErrorsFrame:TryDisplayMessage(messageType, message, r, g, b)
end -- function

-- Returns the item ID from its link
function A.link2ID(link)
	-- print(gsub(link, "\124", "\124\124"))
	return tonumber(select(3,string.find(link or "", "-*:(%d+)[:|].*")) or "")
end -- function

function A.IsPlayerTradeSkill()
	return not (C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillLinked())
end

function A.ReagentButtonInfo(reagentButton)
	local info = {}
	info.reagentButton = reagentButton

	-- Do not manage guild tradeskill
	if not A.IsPlayerTradeSkill() then return info end

	-- Index of the reagent in the recipe
	info.reagentIndex = reagentButton.reagentIndex

	-- Selected recipe
	info.selectedRecipeID = TradeSkillFrame.DetailsFrame.selectedRecipeID

	-- ID of the reagent we want to craft
	info.reagentItemLink = C_TradeSkillUI.GetRecipeReagentItemLink(
		info.selectedRecipeID,
		info.reagentIndex)
	info.reagentItemID = A.link2ID(info.reagentItemLink)

	-- Continue only if the reagent is known
	if not info.reagentItemID or not A.data[info.reagentItemID] then return info end
	info.recipeIDs = A.data[info.reagentItemID]

	-- Check if the item is made by only one recipe. If not, return
	if #(info.recipeIDs) > 1 then return info end
	info.recipeID = info.recipeIDs[1]
	info.recipeLink = C_TradeSkillUI.GetRecipeLink(info.recipeID)

	return info
end

function A.ReagentInfo(recipeID, reagentIndex)
	local info = {}
	info.recipeID = recipeID
	info.reagentIndex = reagentIndex

	info.reagentItemLink = C_TradeSkillUI.GetRecipeReagentItemLink(
		info.selectedRecipeID,
		info.reagentIndex)
	info.reagentItemID = A.link2ID(info.reagentItemLink)

	-- Continue only if the reagent is known
	if not info.reagentItemID or not A.data[info.reagentItemID] then return info end
	info.recipeIDs = A.data[info.reagentItemID]

	-- Check if the item is made by only one recipe. If not, return
	if #(info.recipeIDs) > 1 then return info end
	info.recipeID = info.recipeIDs[1]
	info.recipeLink = C_TradeSkillUI.GetRecipeLink(info.recipeID)

	return info
end
