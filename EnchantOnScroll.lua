local addonName, A = ...

local SCROLL_ID = 38682
local ENCHANTING_ID = 7411
local btn

local EventsFrame = CreateFrame("Frame",nil,TradeSkillFrame) -- It will be hidden with the TradeSkillFrame

local function CheckButtonAvailable(arg1)
	if not btn then return end

	-- Do not manage guild tradeskill
	-- Check that we're still with the enchanting tradeskill
	if IsTradeSkillGuild() or IsTradeSkillLinked() or GetTradeSkillLine() ~= GetSpellInfo(ENCHANTING_ID) then
		btn:Hide()
		return
	end

	-- Check that the selected recipe can be crafted, and the crafted thing is an enchant
	local index = GetTradeSkillSelectionIndex()
	if not index then
		btn:Hide()
		return
	end
	local _, _, numAvailable, _, serviceType = GetTradeSkillInfo(index)

	-- serviceType is localised, but nil if an item is created
	if not serviceType then
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

	if numAvailable==0 then
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
hooksecurefunc("SelectTradeSkill",CheckButtonAvailable)

function A.LoadEnchantOnScroll()
	btn = CreateFrame("Button", nil, TradeSkillFrame, "UIPanelButtonTemplate")
	btn:SetSize(168,22)
	btn:SetPoint("TOPRIGHT",TradeSkillCreateButton,"TOPLEFT",0,0)
	btn:SetText(A.L["Enchant on a scroll"])
	btn:Show()

	local currentTradeSkill = GetTradeSkillLine()
	local enchanting = GetSpellInfo(ENCHANTING_ID)
	if currentTradeSkill ~= enchanting then
		btn:Hide()
	end

	btn:SetScript("OnClick",function()
		-- from http://wowprogramming.com/utils/xmlbrowser/live/AddOns/Blizzard_TradeSkillUI/Blizzard_TradeSkillUI.xml
		DoTradeSkill(TradeSkillFrame.selectedSkill,1)

		-- From GnomeWorks/ScrollMaking.lua
		UseItemByName(SCROLL_ID)
	end)
end
