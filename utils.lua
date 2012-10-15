local addonName, A = ...

-- GLOBALS: UIErrorsFrame, UIErrorsFrame_OnEvent

-- Lua functions
local tonumber = tonumber
local select = select
local sfind = string.find
local min = math.min
local floor = math.floor
local pairs = pairs
local ipairs = ipairs
local wipe = wipe
local tinsert = tinsert
local tremove = tremove

-- Wow functions
local GetItemCount = GetItemCount

-- Messages to the user
function A.Warn(msg)
	if not msg then return end
	local event = "UI_INFO_MESSAGE"
	UIErrorsFrame_OnEvent(UIErrorsFrame, event, msg)
end -- function
function A.Error(msg)
	if not msg then return end
	local event = "UI_ERROR_MESSAGE"
	UIErrorsFrame_OnEvent(UIErrorsFrame, event, msg)
end -- function

-- Returns the item ID from its link
function A.link2ID(link)
	return tonumber(select(3,sfind(link or "", "-*:(%d+)[:|].*")) or "")
end -- function

-- Returns the button number for the reagents buttons
function A.buttonNumber(btn)
	-- "TradeSkillReagentN"
	return tonumber(btn:GetName():sub(-1))
end

do
	-- Wow functions
	local GetTradeSkillInfo = GetTradeSkillInfo
	local GetNumTradeSkills = GetNumTradeSkills
	local GetTradeSkillItemLink = GetTradeSkillItemLink
	local GetTradeSkillRecipeLink = GetTradeSkillRecipeLink

	function A.numRecipeMakable(reagentIDIfUnique,reagents)
		local itemCount
		if reagentIDIfUnique then -- only one reagent
			itemCount = GetItemCount(reagentIDIfUnique)
			if not itemCount then return end
			return floor(itemCount/reagents)
		else -- many reagents
			local m
			for _,reagent in pairs(reagents) do
				itemCount = GetItemCount(reagent[1])
				if not itemCount then return end
				if not m then
					m = floor(itemCount/reagent[2])
				else
					m = min(m,floor(itemCount/reagent[2]))
				end
				if m==0 then break end
			end
			return m
		end -- if
	end

	-- Gives the total number of craftable items
	function A.numMakable(reagentID)
		-- No recipe
		if not A.data[reagentID] then return 0 end

		-- Many recipes
		local n1 = 0
		local n2 = 0
		local m
		local approx = nil
		for _,recipe in pairs(A.data[reagentID]) do
			-- number of times the recipe is makable
			m = A.numRecipeMakable(recipe[1],recipe[2])
			if not m then return end

			-- number of items it gives
			if not recipe[3] or recipe[3]==1 then
				n1 = n1 + m
				n2 = n2 + m
			elseif recipe[3]<1 then
				approx = approx or m>0 -- 0 is not approx
				n1 = n1 + m*recipe[3]
				n2 = n2 + m*recipe[3]
			elseif recipe[4] then
				n1 = n1 + m*recipe[3]
				n2 = n2 + m*recipe[4]
			else
				n1 = n1 + m*recipe[3]
				n2 = n2 + m*recipe[3]
			end
		end -- for
		return n1,n2,approx
	end -- function

	-- Find the first tradeskill index of the recipe to make an item
	function A.findSkillIndex(itemID)
		if not itemID then return end
		for i = 1,GetNumTradeSkills() do
			if select(2,GetTradeSkillInfo(i)) ~= "header" and A.link2ID(GetTradeSkillItemLink(i)) == itemID then
				return i
			end -- if
		end -- for
	end -- function

	-- Find the exact tradeskill index of the recipe to make an item
	function A.findExactSkillIndex(itemID,recipeLink)
		if not itemID or not recipeLink then return end
		for i = 1,GetNumTradeSkills() do
			if select(2,GetTradeSkillInfo(i)) ~= "header" and GetTradeSkillRecipeLink(i)==recipeLink and A.link2ID(GetTradeSkillItemLink(i)) == itemID then
				return i
			end -- if
		end -- for
	end -- function
end -- do


-- Bypass filters and collpsed headers
do
	local selectedTradeSkillIndex
	local stateSaved
	local filtersState = {}
	local headersState = {}

	local function ApplyFilters()
		TradeSkillOnlyShowSkillUps(TradeSkillFrame.filterTbl.hasSkillUp);
		TradeSkillOnlyShowMakeable(TradeSkillFrame.filterTbl.hasMaterials);
		SetTradeSkillCategoryFilter(TradeSkillFrame.filterTbl.subClassValue, 0)
		SetTradeSkillInvSlotFilter(TradeSkillFrame.filterTbl.slotValue, 1, 1);
		TradeSkillUpdateFilterBar();
		CloseDropDownMenus();
	end

	function A.SaveActiveFilters(headerName)
		A.blockScan = true

		-- Save position
		filtersState.positionOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
		filtersState.positionValue = TradeSkillListScrollFrameScrollBar:GetValue()

		-- Save filters
		filtersState.text = GetTradeSkillItemNameFilter()
		filtersState.minLevel, filtersState.maxLevel = GetTradeSkillItemLevelFilter()
		filtersState.hasMaterials = TradeSkillFrame.filterTbl.hasMaterials
		filtersState.hasSkillUp = TradeSkillFrame.filterTbl.hasSkillUp
		filtersState.subClassValue = TradeSkillFrame.filterTbl.subClassValue
		filtersState.slotValue = TradeSkillFrame.filterTbl.slotValue

		-- Remove all filters
		SetTradeSkillItemNameFilter(nil)
		SetTradeSkillItemLevelFilter(0, 0)
		TradeSkillFrame.filterTbl.hasMaterials = false
		TradeSkillFrame.filterTbl.hasSkillUp = false
		TradeSkillFrame.filterTbl.subClassValue = -1
		TradeSkillFrame.filterTbl.slotValue = -1
		ApplyFilters()

		-- Headers
		headersState.headerName = headerName
		for i = GetNumTradeSkills(), 1, -1 do		-- 1st pass, expand all categories
			local skillName, skillType, _, isExpanded  = GetTradeSkillInfo(i)
			if (skillType == "header") and skillName==headerName then
				if not isExpanded then
					ExpandTradeSkillSubClass(i)
					tinsert(headersState,true)
				else
					tinsert(headersState,false)
				end
			end
		end

		stateSaved = true
		A.blockScan = nil
	end

	function A.RestoreActiveFilters()
		if not stateSaved then return end
		A.blockScan = true

		-- restore headers
		for i = GetNumTradeSkills(), 1, -1 do
			local skillName, skillType  = GetTradeSkillInfo(i)
			if (skillType == "header") and skillName==headersState.headerName and tremove(headersState,1) then
					CollapseTradeSkillSubClass(i)
			end
		end
		wipe(headersState)

		-- restore filters
		SetTradeSkillItemNameFilter(filtersState.text)
		SetTradeSkillItemLevelFilter(filtersState.minLevel, filtersState.maxLevel)
		TradeSkillFrame.filterTbl.hasMaterials = filtersState.hasMaterials
		TradeSkillFrame.filterTbl.hasSkillUp = filtersState.hasSkillUp
		TradeSkillFrame.filterTbl.subClassValue = filtersState.subClassValue
		TradeSkillFrame.filterTbl.slotValue = filtersState.slotValue
		ApplyFilters()

		-- Re set position
		FauxScrollFrame_SetOffset(TradeSkillListScrollFrame,filtersState.positionOffset)
		TradeSkillListScrollFrameScrollBar:SetValue(filtersState.positionValue)

		stateSaved = nil
		A.blockScan = nil
	end
end

function A.isRecipeUnique(itemData)
	local unique = true

	-- Check if the item is made by only one recipe. If not, return
	if #itemData>1 then
		local spellLink
		for _,v in ipairs(itemData) do
			if not spellLink then
				spellLink = v.spellLink
			else
				if v.spellLink ~= spellLink then
					unique = nil
					break
				end
			end
		end
	end

	return unique
end

--[[
function A.isTradeskillUnique(itemData)
	local tradeskillName = itemData[1].tradeskillName

	-- Check if the item is made by only one recipe. If not, return
	if #itemData>1 then
		for _,v in ipairs(itemData) do
			if v.tradeskillName ~= tradeskillName then
				tradeskillName = nil
				break
			end
		end
	end

	return tradeskillName
end
--]]
