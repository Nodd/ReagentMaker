local addonName, A = ...

LibStub("AceAddon-3.0"):NewAddon(A, addonName, "AceConsole-3.0", "AceEvent-3.0")

A.debug = false
function A:DBG(...)
	if A.debug then
		A:Print(...)
	end
end

-- @todo add support for cross tradeskill, like mining + forge/ingé
-- @todo add support for dez ?

---------------------------------------------------
-- Variables
---------------------------------------------------
-- Used by findglobals
-- GLOBALS: _G, CreateFrame, DEFAULT_CHAT_FRAME, UIParent

-- Lua functions

-- Wow functions

-- constant vars
local GameTooltip = GameTooltip


---------------------------------------------------
-- Manage events and throttling
---------------------------------------------------
A:RegisterEvent("PLAYER_REGEN_DISABLED", A.HideCampFireBtn)
A:RegisterEvent("PLAYER_REGEN_ENABLED", A.ManageCampFireBtn)
A:RegisterEvent("TRADE_SKILL_LIST_UPDATE", A.ScanCurrentTradeskill)
A:RegisterEvent("UPDATE_TRADESKILL_RECAST", function()
	A:UpdateCounts()
	A.ManageCampFireBtn()
end)
A:RegisterEvent("TRADE_SKILL_SHOW", function()
	A:Initialize()
	A:UnregisterEvent("TRADE_SKILL_SHOW")
end)

---------------------------------------------------
-- Initialize
---------------------------------------------------
function A:Initialize()

	-- Register clics on reagent's buttons
	for i=1,7 do
		local reagentButton = TradeSkillFrame.DetailsFrame.Contents.Reagents[i]
		reagentButton:HookScript("OnMouseDown",
			function(reagentButton, mouseButton)
				if (mouseButton == "MiddleButton") then
					A.ProcessReagent(reagentButton)
				end
			end)
		reagentButton:HookScript("OnMouseWheel", A.btnWheel)
		reagentButton:HookScript("OnEnter", A.btnEntered)
		reagentButton:HookScript("OnLeave", A.btnLeft)
		--reagentButton.SplitStack = A.SplitStack

		local textureHighlight = reagentButton:CreateTexture()
		textureHighlight:Hide()
		textureHighlight:SetTexture("Interface\\BUTTONS\\CheckButtonHilight")
		--textureHighlight:SetTexture("Interface\\BUTTONS\\ButtonHilight-Square")
		textureHighlight:SetBlendMode("ADD")
		textureHighlight:SetAllPoints(reagentButton.Icon)
		reagentButton.textureHighlight = textureHighlight

		local label = reagentButton:CreateFontString(nil,"ARTWORK","GameFontHighlight")
		label:SetSize(100,20)
		label:SetPoint("TOPLEFT",reagentButton,"TOPLEFT",2,-3)
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		label:Hide()
		reagentButton.label = label

		local label2 = reagentButton:CreateFontString(nil,"ARTWORK","GameFontHighlight")
		label2:SetSize(100,20)
		label2:SetPoint("BOTTOMRIGHT",reagentButton,"BOTTOMRIGHT",-2,3)
		label2:SetJustifyH("RIGHT")
		label2:SetJustifyV("BOTTOM")
		label2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		label2:Hide()
		reagentButton.makeLabel = label2
	end -- for

	-- Secondary Tooltip
	A.tooltipRecipe = CreateFrame("GameTooltip", "ReagentMaker_tooltipRecipe", UIParent, "GameTooltipTemplate")
	A.tooltipRecipe:SetFrameStrata("TOOLTIP")
	A.tooltipRecipe:Hide()

	-- Button for enchanting directy on a scroll
	A.LoadEnchantOnScroll()

	hooksecurefunc(
		TradeSkillFrame.RecipeList,
		"OnRecipeButtonClicked",
		function(self, info, button) A:UpdateCounts() end
	)
end -- function


---------------------------------------------------
-- Dynamic display
---------------------------------------------------
-- Button hovering (entered)
function A.btnEntered(reagentButton)
	A.makeCount = 1
	info = A.ReagentButtonInfo(reagentButton)

	-- Highlight the icon
	if info.recipes then
		reagentButton.textureHighlight:Show()
		reagentButton.makeLabel:SetText(A.makeCount)
		reagentButton.makeLabel:Show()
	end

	-- Tooltips
	if info.link then
		A.tooltipRecipe:SetOwner(reagentButton)
		A.tooltipRecipe:SetHyperlink(info.link)
		A.tooltipRecipe:Show()
		A.tooltipRecipe:ClearAllPoints()
		A.tooltipRecipe:SetPoint("BOTTOMLEFT",GameTooltip,"BOTTOMRIGHT")
	end
end

function A.btnWheel(reagentButton, direction)
	A.makeCount = A.makeCount + direction
	if A.makeCount < 1 then A.makeCount = 1 end
	reagentButton.makeLabel:SetText(A.makeCount)
end

-- Button hovering (left)
function A.btnLeft(reagentButton)
	A.makeCount = 1
	reagentButton.textureHighlight:Hide()
	reagentButton.makeLabel:Hide()
	A.tooltipRecipe:Hide()
end -- function

local function simpleFloat(number)
	str = ("%.2f"):format(number)
	if str:sub(-3,-1) == ".00" then
		str = str:sub(0, -4)
	elseif str:sub(-1) == "0" then
		str = str:sub(0, -2)
	end
    return str
end

function A:UpdateCounts()
	-- Needs an argument
	local recipeID = TradeSkillFrame.DetailsFrame.selectedRecipeID
	if not recipeID then
		-- May happend while switching tradeskills
		return
	end
	numReagents = C_TradeSkillUI.GetRecipeNumReagents(recipeID)
	if not numReagents then
		-- May happend while switching tradeskills
		return
	end

	-- Count makable items and show it
	for reagentIndex = 1, numReagents do
		local reagentButton = TradeSkillFrame.DetailsFrame.Contents.Reagents[reagentIndex]
		local countLabel = reagentButton.label
		if not A.IsPlayerTradeSkill() then
			countLabel:Hide()
		else
			info = A.ReagentButtonInfo(reagentButton)

			if not info.recipes then
				countLabel:Hide()
			else
				-- Count and show
				local numMakableMin, numMakableMax, numMakableIsApprox = A.numMakable(info.reagentItemID)
				if not numMakableMin then
					countLabel:SetText("?")
					countLabel:SetTextColor(0, 0.5, 1, 1) -- blue
				else
					local txt = numMakableIsApprox and "~" or ""
					if numMakableMin == numMakableMax then
						countLabel:SetFormattedText("%s%s",txt,simpleFloat(numMakableMin))
					else
						countLabel:SetFormattedText("%s%s-%s",txt,simpleFloat(numMakableMin),simpleFloat(numMakableMax))
					end
					if numMakableMax==0 then
						countLabel:SetTextColor(1, 0, 0, 1) -- red
					else
						countLabel:SetTextColor(0, 1, 0, 1) -- green
					end
				end -- if
				countLabel:Show()
			end -- if
		end -- if
	end -- for
end -- function
