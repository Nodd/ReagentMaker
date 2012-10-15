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
local GetTradeSkillLine = GetTradeSkillLine
local IsTradeSkillGuild = IsTradeSkillGuild
local IsTradeSkillLinked = IsTradeSkillLinked
local GetTradeSkillSelectionIndex = GetTradeSkillSelectionIndex
local GetTradeSkillNumReagents = GetTradeSkillNumReagents
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink

-- constant vars
local GameTooltip = GameTooltip

---------------------------------------------------
-- Manage events and throttling
---------------------------------------------------
A.EventsFrame = CreateFrame("Frame")

local SCAN_DELAY = 0.2
local t_throttle = SCAN_DELAY
local function throttleScan(self, t_elapsed)
	t_throttle = t_throttle - t_elapsed
	if t_throttle<0 then
		self:SetScript("OnUpdate", nil)

		-- Close the external window if the tradeskill changed
		if A.currentTradeSkill ~= GetTradeSkillLine() then
			A.MenuFrame:Hide()
		end
		if IsTradeSkillGuild() or IsTradeSkillLinked() then
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
A.EventsFrame:SetScript("OnEvent", function(self, event)
	if event == "TRADE_SKILL_UPDATE" then
		t_throttle = SCAN_DELAY
		self:SetScript("OnUpdate", throttleScan)
		A.ManageCampFireBtn()

	elseif event == "PLAYER_REGEN_DISABLED" then
		A.HideCampFireBtn()

	elseif event == "PLAYER_REGEN_ENABLED" then
		A.ManageCampFireBtn()

	elseif event == "TRADE_SKILL_SHOW" then
		A:Initialize()
		A.EventsFrame:UnregisterEvent("TRADE_SKILL_SHOW")
	end -- if
end) -- function

A.EventsFrame:RegisterEvent("TRADE_SKILL_SHOW")
A.EventsFrame:RegisterEvent("TRADE_SKILL_UPDATE")


---------------------------------------------------
-- Initialize
---------------------------------------------------
function A:Initialize()

	-- Register clics on reagent's buttons
	for i=1,7 do
		local btn = _G["TradeSkillReagent"..i]
		btn:HookScript("OnDoubleClick", A.ProcessReagent)
		btn:HookScript("OnEnter", A.btnEntered)
		btn:HookScript("OnLeave", A.btnLeft)
		btn.SplitStack = A.SplitStack

		local textureHighlight = btn:CreateTexture()
		textureHighlight:Hide()
		textureHighlight:SetTexture("Interface\\BUTTONS\\CheckButtonHilight")
		--textureHighlight:SetTexture("Interface\\BUTTONS\\ButtonHilight-Square")
		textureHighlight:SetBlendMode("ADD")
		textureHighlight:SetAllPoints("TradeSkillReagent"..i.."IconTexture")
		btn.textureHighlight = textureHighlight

		local label = btn:CreateFontString(nil,"ARTWORK","GameFontHighlight")
		label:SetSize(100,20)
		label:SetPoint("TOPLEFT",btn,"TOPLEFT",4,-4)
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		btn.label = label
	end -- for

	-- Secondary Tooltip
	A.tooltipRecipe = CreateFrame("GameTooltip", "ReagentMaker_tooltipRecipe",UIParent, "GameTooltipTemplate")
	A.tooltipRecipe:SetFrameStrata("TOOLTIP")
	A.tooltipRecipe:Hide()

	-- Used for the campfire button only
	A.EventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	A.EventsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	-- Button for enchanting directy on a scroll
	A.LoadEnchantOnScroll()
end -- function

---------------------------------------------------
-- Dynamic display
---------------------------------------------------
-- Button hovering (entered)
function A.btnEntered(btn)
	-- Do not manage guild tradeskill
	if IsTradeSkillGuild() or IsTradeSkillLinked() then return end

	-- Index of the reagent in the recipe, taken from the button name
	local reagentIndexInRecipe = A.buttonNumber(btn)

	-- ID of the reagent we want to craft
	local reagentLink = GetTradeSkillReagentItemLink(GetTradeSkillSelectionIndex(), reagentIndexInRecipe)
	local reagentID = A.link2ID(reagentLink)

	-- Continue only if the reagent is known
	if not reagentID or not A.data[reagentID] then return end

	btn.textureHighlight:Show()

	-- Check if the item is made by only one recipe. If not, return
	if not A.isRecipeUnique(A.data[reagentID]) then return end

	-- Tooltips
	local link = A.data[reagentID][1].spellLink
	if link then
		A.tooltipRecipe:SetOwner(btn)
		A.tooltipRecipe:SetHyperlink(link)
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

-- Show counts on buttons
local CountThrottleFrame = CreateFrame("Frame")
local COUNT_DELAY = 0.1
local t_throttleCount = SCAN_DELAY
function UpdateCounts(recipeIndex)
	-- Needs an argument
	if not recipeIndex then return end

	-- Do not manage guild tradeskill
	if IsTradeSkillGuild() or IsTradeSkillLinked() then
		for reagentIndexInRecipe = 1,GetTradeSkillNumReagents(recipeIndex) do
			-- If the normal tradeskill hasn't been opened yet, the field 'label' doesn't exists yet
			local label = _G["TradeSkillReagent"..reagentIndexInRecipe].label
			if label then
				label:Hide()
			end
		end
		return
	end

	-- Count makable items and show it
	for reagentIndexInRecipe = 1,GetTradeSkillNumReagents(recipeIndex) do
		-- ID of the reagent we want to craft
		local reagentID = A.link2ID(GetTradeSkillReagentItemLink(recipeIndex, reagentIndexInRecipe))

		local label = _G["TradeSkillReagent"..reagentIndexInRecipe].label
		if label then
			-- Continue only if the reagent is known
			if not reagentID or not A.data[reagentID] then
				label:Hide()
			else
				-- Count and show
				local numMakableMin, numMakableMax, numMakableIsApprox = A.numMakable(reagentID)
				if not numMakableMin then
					label:SetText("?")
					label:SetTextColor(0, 0.5, 1, 1) -- blue
				else
					local txt = numMakableIsApprox and "~" or ""
					if numMakableMin == numMakableMax then
						label:SetFormattedText("%s%.2g",txt,numMakableMin)
					else
						label:SetFormattedText("%s%.2g-%.2g",txt,numMakableMin,numMakableMax)
					end
					if numMakableMax==0 then
						label:SetTextColor(1, 0, 0, 1) -- red
					else
						label:SetTextColor(0, 1, 0, 1) -- green
					end
				end -- if
				label:Show()
			end -- if
		end -- if
	end -- for
end -- function
local function throttleCount(self, t_elapsed)
	t_throttle = t_throttle - t_elapsed
	if t_throttle<0 then
		self:SetScript("OnUpdate", nil)

		-- Show makables reagents
		UpdateCounts(GetTradeSkillSelectionIndex())
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
CountThrottleFrame:RegisterEvent("TRADE_SKILL_UPDATE")
CountThrottleFrame:RegisterEvent("TRADE_SKILL_CLOSE")
hooksecurefunc("SelectTradeSkill",A.updateCount_throttle)
