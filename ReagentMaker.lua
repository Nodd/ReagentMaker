local addonName, A = ...

-- @todo add support for cross tradeskill, like mining + forge/ingé
-- @todo add support for dez ?
-- @todo scroll to the selected recipe on opening ?
-- @todo add a button to clear search ?

-- @bug Enter when choosing number of crafts

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
A.EventsFrame = CreateFrame("Frame")
A.EventsFrame:SetScript("OnEvent", function(self, event)
	--print(event)
	if event == "PLAYER_REGEN_DISABLED" then
		A.HideCampFireBtn()

	elseif event == "PLAYER_REGEN_ENABLED" then
		A.ManageCampFireBtn()

	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		A:ScanCurrentTradeskill()

	elseif event == "UPDATE_TRADESKILL_RECAST" then
		A:UpdateCounts()

	elseif event == "TRADE_SKILL_SHOW" then
		A:Initialize()
		A.EventsFrame:UnregisterEvent("TRADE_SKILL_SHOW")
	end -- if
end) -- function
A.EventsFrame:RegisterEvent("TRADE_SKILL_SHOW")
A.EventsFrame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
A.EventsFrame:RegisterEvent("UPDATE_TRADESKILL_RECAST")
--A.EventsFrame:RegisterAllEvents()


---------------------------------------------------
-- Initialize
---------------------------------------------------
function A:Initialize()

	-- Register clics on reagent's buttons
	for i=1,7 do
		local reagentButton = TradeSkillFrame.DetailsFrame.Contents.Reagents[i]
		reagentButton:HookScript("OnDoubleClick", A.ProcessReagent)
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
		label:SetPoint("TOPLEFT",reagentButton,"TOPLEFT",4,-4)
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		reagentButton.label = label
	end -- for

	-- Secondary Tooltip
	A.tooltipRecipe = CreateFrame("GameTooltip", "ReagentMaker_tooltipRecipe", UIParent, "GameTooltipTemplate")
	A.tooltipRecipe:SetFrameStrata("TOOLTIP")
	A.tooltipRecipe:Hide()

	-- Used for the campfire button only
	--A.EventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	--A.EventsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

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
	info = A.ReagentButtonInfo(reagentButton)

	-- Highlight the icon
	if info.recipeIDs then
		reagentButton.textureHighlight:Show()
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

-- Button hovering (left)
function A.btnLeft(btn)
	btn.textureHighlight:Hide()
	A.tooltipRecipe:Hide()
end -- function


function A:UpdateCounts()
	-- Needs an argument
	local recipeID = TradeSkillFrame.DetailsFrame.selectedRecipeID

	-- Count makable items and show it
	for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
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
						countLabel:SetFormattedText("%s%.2g",txt,numMakableMin)
					else
						countLabel:SetFormattedText("%s%.2g-%.2g",txt,numMakableMin,numMakableMax)
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



return;



--[[



local SCAN_DELAY = 0.2
local t_throttle = SCAN_DELAY
local function throttleScan(self, t_elapsed)
	t_throttle = t_throttle - t_elapsed
	if t_throttle<0 then
		self:SetScript("OnUpdate", nil)

		-- Close the external window if the tradeskill changed
		if A.currentTradeSkill ~= C_TradeSkillUI.GetTradeSkillLine() then
			A.MenuFrame:Hide()
		end
		if C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillLinked() then
			A.MenuFrame:Hide()
			return
		end

		-- Scan availabe recipes
		-- Rescan in case of problem
		if not A:ScanSimpleRecipes() then
			t_throttle = SCAN_DELAY
			self:SetScript("OnUpdate", throttleScan)
		end

		-- Show makables reagents
		A.updateCount_throttle()
	end
end

-- Show counts on buttons
local CountThrottleFrame = CreateFrame("Frame")
local COUNT_DELAY = 0.1
local t_throttleCount = SCAN_DELAY

local function throttleCount(self, t_elapsed)
	t_throttle = t_throttle - t_elapsed
	if t_throttle < 0 then
		self:SetScript("OnUpdate", nil)

		-- Show makables reagents
		UpdateCounts(C_TradeSkillUI.GetTradeSkillLine())
	end
end
function A.updateCount_throttle(self,event)
	if not TradeSkillFrame or not TradeSkillFrame:IsVisible() or event=="TRADE_SKILL_CLOSE" then
		CountThrottleFrame:UnregisterEvent("BAG_UPDATE")
		t_throttleCount = 0
		CountThrottleFrame:SetScript("OnUpdate", nil)
		return
	else
		CountThrottleFrame:RegisterEvent("BAG_UPDATE")
	end
	t_throttleCount = SCAN_DELAY
	CountThrottleFrame:SetScript("OnUpdate", throttleCount)

	A.MenuFrame.updateCounts()
end
CountThrottleFrame:SetScript("OnEvent", A.updateCount_throttle)
CountThrottleFrame:RegisterEvent("TRADE_SKILL_SHOW")
--CountThrottleFrame:RegisterEvent("TRADE_SKILL_UPDATE")
CountThrottleFrame:RegisterEvent("TRADE_SKILL_CLOSE")
--hooksecurefunc("SelectTradeSkill",A.updateCount_throttle)
--]]