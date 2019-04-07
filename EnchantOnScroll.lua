local addonName, A = ...

local SCROLL_ID = 38682
local ENCHANTING_SKILL_ID = 2494
local btn

local EventsFrame = CreateFrame("Frame",nil,TradeSkillFrame) -- It will be hidden with the TradeSkillFrame

local function CheckButtonAvailable(arg1)
	if not btn then return end

	-- Do not manage guild tradeskill
	if not A.IsPlayerTradeSkill() then
		btn:Hide()
		return
	end
	-- Check that we're still with the enchanting tradeskill
	if C_TradeSkillUI.GetTradeSkillLine() ~= ENCHANTING_SKILL_ID then
		btn:Hide()
		return
	end

	-- Check that the selected recipe can be crafted, and the crafted thing is an enchant
	local selectedRecipeID = TradeSkillFrame.DetailsFrame.selectedRecipeID
	if not selectedRecipeID then
		btn:Hide()
		return
	end

	-- Check that it's an enchant
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(selectedRecipeID)
	if recipeInfo.alternateVerb ~= "Enchanter" then
		btn:Hide()
		return
	end

	-- Check that there's scrolls in the bags
	local itemCount = GetItemCount(SCROLL_ID)
	if not itemCount or itemCount==0 then
		btn:Disable()
		btn:Show()
		btn:SetText(A.L["Enchant a scroll (0)"])
		return
	end
	btn:SetText(A.L["Enchant a scroll (%d)"]:format(itemCount))

	if not recipeInfo.craftable or recipeInfo.disabled or recipeInfo.numAvailable==0 then
		btn:Disable()
		btn:Show()
		return
	end

	-- It passed the tests
	btn:Enable()
	btn:Show()
end
EventsFrame:SetScript("OnEvent",CheckButtonAvailable)
EventsFrame:RegisterEvent("BAG_UPDATE")
EventsFrame:RegisterEvent("UPDATE_TRADESKILL_RECAST")
--hooksecurefunc("SelectTradeSkill",CheckButtonAvailable)

function A.LoadEnchantOnScroll()
	btn = CreateFrame("Button", nil, TradeSkillFrame, "UIPanelButtonTemplate")
	btn:SetSize(168,22)
	btn:SetPoint("TOPRIGHT",TradeSkillFrame.DetailsFrame.CreateButton,"TOPLEFT",0,0)
	btn:SetText(A.L["Enchant on a scroll"])
	btn:Show()

	if C_TradeSkillUI.GetTradeSkillLine() ~= ENCHANTING_SKILL_ID then
		btn:Hide()
	end

	btn:SetScript("OnClick",function()
		C_TradeSkillUI.CraftRecipe(TradeSkillFrame.DetailsFrame.selectedRecipeID)
		UseItemByName(SCROLL_ID)
	end)
end
