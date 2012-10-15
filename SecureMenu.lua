local addonName, A = ...

-- Lua functions
local ipairs = ipairs
local type = type

-- Wow variables

-- Create the menu frame
local MenuFrame = CreateFrame("Frame","ReagentMaker_ExternalFrame",UIParent)
MenuFrame:Hide()
MenuFrame:SetSize(192,256)
--MenuFrame:SetFrameStrata("DIALOG")
MenuFrame:EnableMouse(true)
MenuFrame:SetPoint("CENTER")
MenuFrame:SetToplevel(true) -- raised if clicked
tinsert(UISpecialFrames,"ReagentMaker_ExternalFrame") -- make it closable with escape

-- Throttling is made in ReagentMaker.lua
MenuFrame:SetScript("OnEvent",function() MenuFrame:Hide() end)
MenuFrame:RegisterEvent("TRADE_SKILL_CLOSE")
MenuFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

MenuFrame:SetScript("OnEnter",function(self)
	if self.reagentLink then
		GameTooltip:SetOwner(self)
		GameTooltip:SetHyperlink(self.reagentLink)
		GameTooltip:Show()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT",10,0)
		if self.spellLink then
			A.tooltipRecipe:SetOwner(GameTooltip)
			A.tooltipRecipe:SetHyperlink(self.spellLink)
			A.tooltipRecipe:Show()
			A.tooltipRecipe:ClearAllPoints()
			A.tooltipRecipe:SetPoint("TOPRIGHT",GameTooltip,"BOTTOMRIGHT")
		end
	end
end)
MenuFrame:SetScript("OnLeave",function()
	GameTooltip:Hide()
	A.tooltipRecipe:Hide()
end)

-- Hide frame when selecting a recipe which doesn't need this reagent
hooksecurefunc("SelectTradeSkill",function()
	local selectedIndex = GetTradeSkillSelectionIndex()
	for reagentIndexInRecipe = 1,GetTradeSkillNumReagents(selectedIndex) do
		local reagentID = A.link2ID(GetTradeSkillReagentItemLink(selectedIndex, reagentIndexInRecipe))
		if reagentID == MenuFrame.itemID or (MenuFrame.superItemID and reagentID == MenuFrame.superItemID) then
			return
		end
	end
	MenuFrame:Hide()
end)
A.MenuFrame = MenuFrame

-- Background adaptable vertically
local bg_top = MenuFrame:CreateTexture(nil,"BACKGROUND",nil,0)
bg_top:SetTexture("Interface\\LootFrame\\UI-LootPanel")
bg_top:SetSize(192,80)
bg_top:SetPoint("TOP")
bg_top:SetTexCoord(0,192/256,0,80/256)
local bg_bot = MenuFrame:CreateTexture(nil,"BACKGROUND",nil,0)
bg_bot:SetTexture("Interface\\LootFrame\\UI-LootPanel")
bg_bot:SetSize(192,16)
bg_bot:SetPoint("BOTTOM")
bg_bot:SetTexCoord(0,192/256,240/256,1)
local bg_mid = MenuFrame:CreateTexture(nil,"BACKGROUND",nil,0)
bg_mid:SetTexture("Interface\\LootFrame\\UI-LootPanel")
bg_mid:SetWidth(192)
bg_mid:SetPoint("TOP",bg_top,"BOTTOM")
bg_mid:SetPoint("BOTTOM",bg_bot,"TOP")
bg_mid:SetTexCoord(0,192/256,80/256,240/256)

-- Bouton de fermeture
local CloseButton = CreateFrame("Button",nil,MenuFrame,"UIPanelCloseButton");
CloseButton:SetPoint("TOPRIGHT",0,-10)

-- Main icon
local itemIcon = MenuFrame:CreateTexture(nil,"BACKGROUND",nil,-1)
itemIcon:SetSize(64,64)
itemIcon:SetPoint("TOPLEFT",8,-4)

-- Title
local TitleText = MenuFrame:CreateFontString(nil,"ARTWORK","GameFontHighlight")
--TitleText:SetSize(92,14)
TitleText:SetSize(92,36)
TitleText:SetPoint("TOPRIGHT",CloseButton,"TOPLEFT",4,-8)
TitleText:SetWordWrap(true)
TitleText:SetNonSpaceWrap(false)
TitleText:SetJustifyV("TOP")


local MENU_ENTRY_HEIGHT = 41
local MENU_ENTRY_WIDTH = 147
local MENU_ENTRY_ICON_RATIO = 40/48

local numActiveEntries = 0
local menuEntries = {}

-- Button hovering
local function btnEntered(btn)
	if btn.numMakable and btn.numMakable>0 then
		btn.textureHighlight:Show()
	end

	GameTooltip:SetOwner(btn,"ANCHOR_LEFT")
	GameTooltip:SetHyperlink(btn.reagentLink)
	GameTooltip:Show()
	if btn.spellLink and btn.spellLink~=btn.reagentLink then
		A.tooltipRecipe:SetOwner(GameTooltip)
		A.tooltipRecipe:SetHyperlink(btn.spellLink)
		A.tooltipRecipe:Show()
		A.tooltipRecipe:ClearAllPoints()
		A.tooltipRecipe:SetPoint("TOPRIGHT",GameTooltip,"BOTTOMRIGHT")
	end
end
local function btnLeft(btn)
	btn.textureHighlight:Hide()
	GameTooltip:Hide()
	A.tooltipRecipe:Hide()
end
local function createMenuEntry()
	local btn = CreateFrame("Button", nil, MenuFrame, "SecureActionButtonTemplate")
	table.insert(menuEntries,btn)

	btn:Hide()
	btn:SetSize(MENU_ENTRY_WIDTH,MENU_ENTRY_HEIGHT)
	--btn:SetFrameStrata("DIALOG")

	-- Set its position
	if #menuEntries>1 then
		btn:SetPoint("TOP",menuEntries[#menuEntries-1],"BOTTOM",0,-2)
	else
		btn:SetPoint("TOPLEFT",MenuFrame,"TOPLEFT",24,-79)
	end

	local icon = btn:CreateTexture(nil,"BACKGROUND")
	icon:SetPoint("TOPLEFT")
	icon:SetSize(39,39)
	btn.icon = icon

	local itemNameBG = btn:CreateTexture(nil,"BACKGROUND")
	itemNameBG:SetTexture("Interface\\QuestFrame\\UI-QuestItemNameFrame")
	itemNameBG:SetSize(128,64)
	itemNameBG:SetPoint("LEFT",icon,"RIGHT",-10,0)

	local itemName = btn:CreateFontString(nil,"BACKGROUND","GameFontHighlight")
	itemName:SetSize(90,36)
	itemName:SetPoint("LEFT",itemNameBG,"LEFT",15,0)
	itemName:SetJustifyH("LEFT")
	itemName:SetWordWrap(true)
	itemName:SetNonSpaceWrap(false)
	btn.itemName = itemName

	local textureHighlight = btn:CreateTexture(nil,"BORDER")
	textureHighlight:Hide()
	textureHighlight:SetTexture("Interface\\BUTTONS\\CheckButtonHilight")
	--textureHighlight:SetTexture("Interface\\BUTTONS\\ButtonHilight-Square")
	textureHighlight:SetBlendMode("ADD")
	textureHighlight:SetAllPoints(icon)
	btn.textureHighlight = textureHighlight

	local countDetail = btn:CreateFontString(nil,"ARTWORK","NumberFontNormal")
	countDetail:SetPoint("BOTTOMRIGHT",icon,"BOTTOMRIGHT",-1,1)
	countDetail:SetJustifyH("RIGHT")
	countDetail:SetJustifyV("BOTTOM")
	btn.countDetail = countDetail

	local resultNumber = btn:CreateFontString(nil,"ARTWORK","NumberFontNormal")
	resultNumber:SetPoint("TOPLEFT",icon,"TOPLEFT",1,-3)
	resultNumber:SetJustifyH("LEFT")
	resultNumber:SetJustifyV("TOP")
	resultNumber:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	btn.resultNumber = resultNumber

	-- Used to choose the number of items to make
	btn.SplitStack = A.SplitStack

	btn:SetScript("OnEnter", btnEntered)
	btn:SetScript("OnLeave", btnLeft)

	return btn
end

local function WarnNotMakable(btn)
	if not btn.reagentID then
		A.Error(A.L["You do not have enough reagents to craft [%s]"]:format(TitleText:GetText()))
	else
		A.Error(A.L["You do not have enough [%s] to craft [%s]"]:format(btn.itemNameString,TitleText:GetText()))
	end
end

local function CraftFromExternal(btn)
	local chooseNumberToCraft = IsShiftKeyDown()

	A.CraftItemWithRecipe(	GetTradeSkillSelectionIndex(),
									btn.itemID,
									btn.reagent,
									MenuFrame.reagentIndexInRecipe,
									IsShiftKeyDown(),
									btn)
end

-- Update counts and button actions
function MenuFrame.updateCounts()
	local anyMakable
	for i=1,numActiveEntries do
		local btn = menuEntries[i]
		local itemCount = GetItemCount(btn.reagentID)

		local numMakable
		if btn.reagentID then
			numMakable = math.floor(itemCount/(btn.reagentsForOneRecipe or 1))
			btn.countDetail:SetText(itemCount.."/"..(btn.reagentsForOneRecipe or 1))
		else
			for _,reagent in pairs(btn.reagentsForOneRecipe) do
				itemCount = GetItemCount(reagent[1])
				if not itemCount then
					numMakable = 0
					break
				end
				if not numMakable then
					numMakable = math.floor(itemCount/reagent[2])
				else
					numMakable = math.min(numMakable,math.floor(itemCount/reagent[2]))
				end
				if numMakable==0 then break end
			end
			btn.countDetail:SetText(numMakable)
		end

		if numMakable>0 then
			-- Set action
			if type(btn.action)=="function" then
				btn:SetScript("PreClick",btn.action)
				btn:SetAttribute("type", nil)
				btn:SetAttribute("macrotext", nil)
			else --if type(action)=="string" then
				btn:SetScript("PreClick",nil)
				btn:SetAttribute("type", "macro")
				btn:SetAttribute("macrotext", btn.action:format(btn.itemNameString))
			end -- if

			anyMakable = true
			btn.countDetail:SetTextColor(1, 1, 1, 1)
			btn.icon:SetVertexColor(1,1,1);
			btn.itemName:SetTextColor(1,1,1,1)
		else
			-- Do not disable the button, to be able to show the tooltip
			-- Disable only the effects
			btn:SetScript("PreClick",WarnNotMakable)
			btn:SetAttribute("type", nil)
			btn:SetAttribute("macrotext", nil)

			btn.countDetail:SetTextColor(1, 0.1, 0.1, 1)
			btn.icon:SetVertexColor(0.5, 0.5, 0.5)
			btn.itemName:SetTextColor(1,1,1,0.5)
		end

		btn.numMakable = numMakable
	end

	local r,g,b = TitleText:GetTextColor()
	if anyMakable then
		itemIcon:SetVertexColor(1,1,1)
		TitleText:SetTextColor(r,g,b,1)
	else
		itemIcon:SetVertexColor(0.5, 0.5, 0.5)
		TitleText:SetTextColor(r,g,b,0.7)
	end
end

local function menuAddItem(action,itemID,reagent)
	local btn
	-- Create a button only if necessary
	if numActiveEntries >= #menuEntries then
		btn = createMenuEntry()
	else
		btn = menuEntries[numActiveEntries+1]
	end

	-- Set text and icon
	local name, link, texture, _
	if reagent[1] then
		name, link, _, _, _, _, _, _, _, texture = GetItemInfo(reagent[1])
		if not (name and link and texture) then
			-- Will be retried on next OnUpdate
			return
		end
	elseif reagent.spellLink then
		--name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = GetSpellInfo(id)
		name, _, texture = GetSpellInfo(A.link2ID(reagent.spellLink))
		if not (name and texture) then
			-- Will be retried on next OnUpdate
			return
		end
		link = reagent.spellLink
	end

	btn.itemName:SetText(name)
	btn.icon:SetTexture(texture)

	-- Set chance to have the item or the number of items created
	btn.resultNumber:Hide()
	if reagent[3] then
		if reagent[3]<1 then
			btn.resultNumber:SetText((reagent[3]*100).."%")
			btn.resultNumber:Show()
		elseif reagent[4] and reagent[3]~=reagent[4] then
			btn.resultNumber:SetText(math.min(reagent[3],reagent[4]).."-"..math.max(reagent[3],reagent[4]))
			btn.resultNumber:Show()
		elseif reagent[3]>1 then
			btn.resultNumber:SetText(reagent[3])
			btn.resultNumber:Show()
		end
	end

	-- Save params
	btn.itemID = itemID
	btn.reagent = reagent
	btn.reagentID = reagent[1]
	btn.reagentLink = link
	btn.reagentsForOneRecipe = reagent[2]
	btn.spellLink = reagent.spellLink
	btn.action = action
	btn.itemNameString = name

	btn:Show()

	-- Increase the entry number
	numActiveEntries = numActiveEntries + 1

	-- Everything went well
	return true
end -- function

-- Function used on OnUpdate tu update the frame if there were errors the previous time
local function reopen()
	-- Release OnUpdate frame (could conflict with BAG_UPDATE)
	MenuFrame:SetScript("OnUpdate",nil)

	-- reopen
	A.externalCraftWindow(MenuFrame.itemID,MenuFrame.reagentIndexInRecipe,MenuFrame.superItemID)
end

-- Fill the window and open it
function A.externalCraftWindow(itemID,reagentIndexInRecipe,superItemID)
	-- Do not open during combat
	if InCombatLockdown() then
		A.Error(SPELL_FAILED_AFFECTING_COMBAT)
		return
	end

	-- Save the tradeskill
	A.currentTradeSkill = GetTradeSkillLine()

	-- Close the previous menu
	MenuFrame:Hide()
	for i=1,numActiveEntries do
		menuEntries[i]:Hide()
	end
	numActiveEntries = 0

	-- Fill the info of the reagent to make
	local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID)
	SetPortraitToTexture(itemIcon, texture)
	TitleText:SetText(name)
	local color = ITEM_QUALITY_COLORS[quality]
	TitleText:SetTextColor(color.r, color.g, color.b)

	-- Save vars to show the tooltip later
	MenuFrame.reagentLink = link
	MenuFrame.spellLink = A.isRecipeUnique(A.data[itemID]) and A.data[itemID][1].spellLink
	MenuFrame.itemID = itemID
	MenuFrame.reagentIndexInRecipe = reagentIndexInRecipe
	MenuFrame.superItemID = superItemID -- optional, will be nil if not set

	-- Loop over the available recipes
	local noSkipped = true -- check if we have to reload the external frame to get all the data
	local existsValidEntries -- check if the menu contains at least one item (cross-tradeskill problem)
	for _,reagent in ipairs(A.data[itemID]) do
		if reagent.macro then
			-- Special spell
			existsValidEntries = true
			noSkipped = menuAddItem(reagent.macro,itemID,reagent) and noSkipped
		else
			-- Standard tradeskill spell
			if not reagent.tradeskillName or reagent.tradeskillName == A.currentTradeSkill then
				existsValidEntries = true
				noSkipped = menuAddItem(CraftFromExternal,itemID,reagent) and noSkipped
			end
		end -- if
	end -- for

	-- do not show an empty menu
	if not existsValidEntries then
		return false
	end

	MenuFrame:SetHeight(89 + numActiveEntries*(MENU_ENTRY_HEIGHT+2))

	MenuFrame:ClearAllPoints()
	MenuFrame:SetPoint("TOPLEFT",TradeSkillFrame,"TOPRIGHT",-2,14)

	-- Update counts and set actions
	MenuFrame.updateCounts()

	MenuFrame:Show()

	if not noSkipped then
		MenuFrame:SetScript("OnUpdate",reopen)
	end
end
