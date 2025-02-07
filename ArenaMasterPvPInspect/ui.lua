-----------REGION DROPDOWN + CPYPROFILE START-----------
local regionsTable = {
	[1] = "us",
	[2] = "kr",
	[3] = "eu",
	[4] = "tw",
	[5] = "ch"
}



local dropdownTableLFGData = {}
local dropdownData = {}

local dropdownTableBNetData = {}
local friendsTooltipShown = false
local ampvpFriendsTooltipShown = false
local rioEnabledData = {}

local function AMPVPGetProfileLinkFunc(self, ...)

	if self.value == "AMPVPLinkGet" then

		local drop = _G["UIDROPDOWNMENU_INIT_MENU"]
		local currRegion = GetCurrentRegion()
		local unitName = drop.name
		local unitServer = drop.server

		local name2, realm

		if (unitName == nil and dropdownData.tempNameHooked ~= nil) or (unitName ~= nil and dropdownData.tempNameHooked ~= nil and unitServer == nil) then

			name2, realm = string.split("-", dropdownData.tempNameHooked)
			unitName = name2
			unitServer = realm

		end

		if unitServer == nil and drop.server ~= nil then
			unitServer = drop.server
		end

		if unitServer == nil or unitServer == "" then
			unitServer = GetRealmName();
		end

		unitServer = AMPVP_FixSlangRealms(unitServer)

		AMPVP_CopyCharNameFrame2InputFrameTitleText:SetText("https://arenamaster.io/"..regionsTable[currRegion].."/"..string.lower(unitServer).."/"..string.lower(unitName).."?ref=addon")
		AMPVP_CopyCharNameFrame2InputFrameTitleText:HighlightText()
		AMPVP_CopyCharNameFrame2:Show()
		AMPVP_CopyCharNameFrame2InputFrameTitleText:SetFocus()

		dropdownTableLFGData = {}
		dropdownData.tempNameHooked = nil

	end
end


hooksecurefunc("LFGListUtil_GetApplicantMemberMenu", function(applicantID, memberIdx)

	dropdownTableLFGData = {}
	dropdownTableBNetData = {}
	dropdownData.tempNameHooked = nil

    local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
    local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID);
	local namePH, realm = string.split("-", name)

	if realm == nil then
		realm = GetRealmName()
	end

	if namePH ~= nil and realm ~= nil then
		dropdownTableLFGData["name"] = namePH
		dropdownTableLFGData["realm"] = realm
	end

end)

hooksecurefunc("LFGListUtil_GetSearchEntryMenu", function(resultID)

	dropdownTableLFGData = {}
	dropdownTableBNetData = {}
	dropdownData.tempNameHooked = nil

    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local name = searchResultInfo.leaderName
	local namePH, realm = string.split("-", name)

	if realm == nil then
		realm = GetRealmName()
	end

	if namePH ~= nil and realm ~= nil then
		dropdownTableLFGData["name"] = namePH
		dropdownTableLFGData["realm"] = realm
	end

end)


hooksecurefunc("UIDropDownMenu_OnHide", function(self)

	dropdownTableBNetData = {}
	dropdownTableLFGData = {}

end)

DropDownList1:HookScript("OnShow", function(self, ...)

	dropdownTableBNetData = {}

	local dropMenu = self.dropdown
	local realm = nil
	local checkAccInfo = false
	local characterName = nil
	if dropMenu.accountInfo ~= nil then
		if dropMenu.accountInfo.gameAccountInfo ~= nil then
			checkAccInfo = true
		end
	end

	if checkAccInfo then
		for k, v in pairs(dropMenu.accountInfo.gameAccountInfo) do

			if k == "realmName" then
				realm = v
			end

			if k == "characterName" then
				characterName = v
			end

		end
	end


	if characterName ~= "" and realm ~= nil then
		dropdownTableBNetData["name"] = characterName.."-"..realm
	end

	if dropdownTableLFGData["name"] == nil and dropdownTableBNetData["name"] == nil then
		return
	end

	if (UIDROPDOWNMENU_MENU_LEVEL > 1) then
		return
	end

	local namePH = dropdownTableLFGData["name"]
	local realm = dropdownTableLFGData["realm"]

	if namePH == nil and realm == nil then
		namePH, realm = string.split("-", dropdownTableBNetData["name"])
	end

	if dropdownData.tempNameHooked == nil then

		UIDropDownMenu_AddSeparator()
		local info = UIDropDownMenu_CreateInfo()
		info.text = "ArenaMaster Profile"
		info.notCheckable = 1
		info.func = AMPVPGetProfileLinkFunc
		info.colorCode = "|cffc72429"
		info.value = "AMPVPLinkGet"
		dropdownData.tempNameHooked = namePH.."-"..realm
		UIDropDownMenu_AddButton(info)
		dropdownTableBNetData = {}
		dropdownTableLFGData = {}

	end
end)


hooksecurefunc("UnitPopup_ShowMenu", function(self, ...)
	if (UIDROPDOWNMENU_MENU_LEVEL > 1) then
		return
	end

	dropdownTableLFGData = {}

	dropdownData.tempNameHooked = nil

	local unit = self.unit
	local ctype, _, uName = ...

	if unit == nil then

		if ctype == "COMMUNITIES_GUILD_MEMBER" or ctype == "COMMUNITIES_WOW_MEMBER" or ctype == "FRIEND" or (ctype:find("FRIEND") and not ctype:find("BN")) then

			UIDropDownMenu_AddSeparator()

			local info = UIDropDownMenu_CreateInfo()

			info.text = "ArenaMaster Profile"
			info.owner = self.which
			info.notCheckable = 1
			info.func = AMPVPGetProfileLinkFunc
			info.colorCode = "|cffc72429"
			info.value = "AMPVPLinkGet"
			dropdownData.tempNameHooked = uName

			UIDropDownMenu_AddButton(info)

		end


	end

	if UnitIsPlayer(unit) and not self.accountInfo then

		UIDropDownMenu_AddSeparator()

		local info = UIDropDownMenu_CreateInfo()

		info.text = "ArenaMaster Profile"
		info.owner = self.which
		info.notCheckable = 1
		info.func = AMPVPGetProfileLinkFunc
		info.colorCode = "|cffc72429"
		info.value = "AMPVPLinkGet"

		dropdownData.tempNameHooked = uName

		UIDropDownMenu_AddButton(info)

	end
end)

AMPVP_CreateFrame("AMPVP_CopyCharNameFrame2", UIParent, "CENTER", 0, 0, 450, 100, 0.5, true)
tinsert(UISpecialFrames, AMPVP_CopyCharNameFrame2:GetName())
AMPVP_CreateFrame2("AMPVP_FriendsListTooltip", FriendsFrame, "BOTTOM", 0, -100, 250, 200, 0.7, false)
----------------Logo frame Start------------------
AMPVP_CreateFrame("AMPVP_LogoFrame", AMPVP_CopyCharNameFrame2, "TOP", 0, 61, 60, 60, 0, false)
AMPVP_LogoFrame:SetFrameStrata("BACKGROUND")
AMPVP_LogoFrame.t:SetTexture("Interface\\AddOns\\ArenaMasterPVPInspect\\textures\\arenamaster-logo")
AMPVP_LogoFrame.t:SetPoint("CENTER", AMPVP_LogoFrame, 1, 0)

----------------Logo frame End--------------------
AMPVP_CopyCharNameFrame2:Hide()
AMPVP_CreateCloseButton(AMPVP_CopyCharNameFrame2)
AMPVP_CreateText("TextTitle", AMPVP_CopyCharNameFrame2, "CENTER", -0, 15, "Copy and paste on the website")
AMPVP_CreateEditBox("cpyName", AMPVP_CopyCharNameFrame2, "LEFT", -20, -15, 400, 20, "")
AMPVP_CopyCharNameFrame2InputFrameTitleText:SetText("")
AMPVP_CopyCharNameFrame2InputFrameTitleText:HighlightText()
AMPVP_CopyCharNameFrame2InputFrameTitleText:SetFocus()

AMPVP_CopyCharNameFrame2.titleTexture = AMPVP_CopyCharNameFrame2:CreateTexture(nil, "ARTWORK")
AMPVP_CopyCharNameFrame2.titleTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
AMPVP_CopyCharNameFrame2.titleTexture:SetWidth(460)
AMPVP_CopyCharNameFrame2.titleTexture:SetHeight(64)
AMPVP_CopyCharNameFrame2.titleTexture:SetPoint("TOP", 0, 12)
AMPVP_CopyCharNameFrame2.title = AMPVP_CopyCharNameFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormal")
AMPVP_CopyCharNameFrame2.title:SetPoint("TOP", 0, -3)
AMPVP_CopyCharNameFrame2.title:SetText("ArenaMaster.IO - PVP Inspect")

-----------REGION DROPDOWN + CPYPROFILE END-----------


-----------REGION TOOLTIPSDATA START-----------
hooksecurefunc("LFGListSearchEntry_OnEnter", function(entry)

	GameTooltip.ampvpLastID = nil
	if entry.resultID ~= nil then

		if GameTooltip.ampvpLastID ~= entry.resultID then

			local searchResultData = C_LFGList.GetSearchResultInfo(entry.resultID)

			local lName = searchResultData.leaderName

			if lName == nil then return end

			local aname, realm = string.split("-", lName)

			if realm == nil or realm == "" then
				realm = GetRealmName()
			end

			local name = aname.."-"..realm

			if name ~= nil then

				GameTooltip.ampvpHooked = nil
				AMPVP_AddTooltipDetails(name, true)
				GameTooltip.ampvpLastID = entry.resultID

			end

		end

	end

end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self, ...)

	GameTooltip.ampvpHooked = nil
	local unitIncompleteName, unit = self:GetUnit()

	if unit == nil then return end

	local name, realm = UnitName(unit), select(2,UnitName(unit))
	local compName = nil

	if name == nil then return end

	if realm == nil then
		realm = GetRealmName()
		compName = name.."-"..realm
	else
		compName = name.."-"..realm
	end

	if UnitIsPlayer(unit) then
		if compName ~= nil then
			AMPVP_AddTooltipDetails(compName)
		end
	end

end)

hooksecurefunc(GameTooltip, "Hide", function(self)

	if GameTooltip.ampvpHooked then
		GameTooltip.ampvpHooked = nil
	end

	if GameTooltip.ampvpHooked2 then
		GameTooltip.ampvpHooked2 = nil
	end

	if friendsTooltipShown then
		friendsTooltipShown = false
	end

end)


GameTooltip:HookScript("OnUpdate", function(self)

	local entry = GetMouseFocus()

	if entry == nil then
		return
	end

	if entry.resultID ~= nil then

		if GameTooltip.ampvpLastID ~= entry.resultID then

			local searchResultData = C_LFGList.GetSearchResultInfo(entry.resultID)

			local lName = searchResultData.leaderName

			if lName == nil then return end

			local aname, realm = string.split("-", lName)

			if realm == nil or realm == "" then
				realm = GetRealmName()
			end

			local name = aname.."-"..realm

			if name ~= nil then
				GameTooltip.ampvpHooked = nil
				AMPVP_AddTooltipDetails(name, true)
				GameTooltip.ampvpLastID = entry.resultID
			end

		end

	end


end)

GameTooltip:HookScript("OnShow", function(self, ...)

	local entry = GetMouseFocus()

	local isBnetEntry = false

	if entry == nil then return end

	if entry.memberIdx ~= nil then

		local sname, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(entry:GetParent().applicantID, entry.memberIdx)

		local aname, realm = string.split("-", sname)

		if realm == nil or realm == "" then
			realm = GetRealmName()
		end

		local name = aname.."-"..realm

		if name ~= nil then

			if IsAddOnLoaded("RaiderIO") then
				C_Timer.NewTicker(0.001, function()
					AMPVP_AddTooltipDetails(name, true)
				end, 1)
			else
				AMPVP_AddTooltipDetails(name, true)
			end

		end
	end

end)



local function friedsListFunc2(self)

	local bnetIndex = nil

	friendsTooltipShown = false

	for k, v in pairs(self.button) do
		if k == "id" then
			bnetIndex = v
		end
	end

	local accData = C_BattleNet.GetFriendGameAccountInfo(bnetIndex, 1)

	if accData == nil then return end

	local realm, name = accData.realmName, accData.characterName

	if name == "" and realm == "" or name == nil or realm == nil then
		return
	end

	local compName = name.."-"..realm

	rioEnabledData["name"] = compName

	local dbg = "BNET Name:" .. compName .. " " .. name .. " " .. realm .. " " .. bnetIndex

	AMPVP_PrintDebug(dbg)

	AMPVP_AddTooltipFrameText(compName)
	AMPVP_PrintDebug("Spawning own anchor")
	AMPVP_FriendsListTooltip.isAmPVPFromBnet = true

end

hooksecurefunc(FriendsTooltip, "Show", friedsListFunc2)

FriendsTooltip:HookScript("OnHide", function(self, ...)

	GameTooltip:Hide()
	rioEnabledData = {}
	AMPVP_FriendsListTooltip.isAmPVPFromBnet = nil
	AMPVP_FriendsListTooltip:Hide()
end)

SLASH_AMPVP1 = "/ampvp"
SlashCmdList["AMPVP"] = function(msg)

	local cmp = string.lower(msg)

	if cmp == "debug" or cmp == "dbg" then
		if AMPVP_DebugMode then
			AMPVP_DebugMode = false
			AMPVP_Print("Debug mode: Disabled")
		else
			AMPVP_DebugMode = true
			AMPVP_Print("Debug mode: Enabled")
		end
	end

end

function AMPVP_PrintDebug(msg)

	if AMPVP_DebugMode then
		print("|cffc72429AMPVPDEBUG:|r "..tostring(msg))
	end

end
-----------FriendsTooltip Frame Start--------
local function maintainTooltipFrame()
	for i=1, 20 do
		local line = _G["AMPVP_FriendsListTooltipLine"..i]
		local lineRight = _G["AMPVP_FriendsListTooltipLine"..i.."Right"]

		if lineRight ~= nil and line ~= nil then
			line:SetText("")
			lineRight:SetText("")
		end
	end
end

AMPVP_friendsTTlines = {
	["nrLines"] = 0,
}

AMPVP_FriendsListTooltip:SetScript("OnUpdate", function(self)

	if FriendsTooltip:IsVisible() then

		maintainTooltipFrame()
		
		local a, b, c, x, y = FriendsTooltip:GetPoint()
		AMPVP_FriendsListTooltip:ClearAllPoints()
		AMPVP_FriendsListTooltip:SetPoint("BOTTOMLEFT", FriendsTooltip ,"TOPLEFT", x - 35, y + 10)

		if AMPVP_friendsTTlines["nrLines"] > 2 then
			-- here the first parameter (270) is the width of the frame, in case you wish to enlarge it a bit.
			AMPVP_FriendsListTooltip:SetSize(270, (AMPVP_friendsTTlines["nrLines"] * 23))
		else
			AMPVP_FriendsListTooltip:SetSize(270, 35)
		end
		--print(point, x, y)
		local ySpacer = 20
		for i=1, AMPVP_friendsTTlines["nrLines"] do

			local textLeft, textRight

			if AMPVP_friendsTTlines[i] ~= nil then
				textLeft, textRight = string.split("-", AMPVP_friendsTTlines[i])
			end

			local line = _G["AMPVP_FriendsListTooltipLine"..i]
			local lineRight = _G["AMPVP_FriendsListTooltipLine"..i.."Right"]

			if line == nil and lineRight == nil then

				local prevLineY = _G["AMPVP_FriendsListTooltipLine"..i-1]
				local prevLineRightY = _G["AMPVP_FriendsListTooltipLine".. i-1 .."Right"]

				if prevLineY == nil then
					-- here you can set the padding and such: it goes like: frameName, frameParent, lrOffset, xOffset, yOffset, text, fontName
					AMPVP_CreateText("AMPVP_FriendsListTooltipLine"..i, AMPVP_FriendsListTooltip, "TOPLEFT", 12, -9, "nimic yet")
				else
					AMPVP_CreateText("AMPVP_FriendsListTooltipLine"..i, AMPVP_FriendsListTooltip, "TOPLEFT", 12, select(5, prevLineY:GetPoint(1)) - ySpacer, "nimic yet")
				end

				if prevLineRightY == nil then
					AMPVP_CreateText("AMPVP_FriendsListTooltipLine"..i.."Right", AMPVP_FriendsListTooltip, "TOPRIGHT", -12, -9, "nimic yet")
				else
					AMPVP_CreateText("AMPVP_FriendsListTooltipLine"..i.."Right", AMPVP_FriendsListTooltip, "TOPRIGHT", -12, select(5, prevLineRightY:GetPoint(1)) - ySpacer, "nimic yet")
				end

				AMPVP_AddDoubleLine(line, lineRight, "", "")
			else
				AMPVP_AddDoubleLine(line, lineRight, textLeft, textRight)
			end

		end

	end

end)


local updateVisualTT = CreateFrame("frame")
updateVisualTT:SetScript("OnUpdate", function()
	if AMPVP_FriendsListTooltip.isAmPVPFromBnet then
		AMPVP_FriendsListTooltip:Show()
	else
		AMPVP_FriendsListTooltip:Hide()
	end
end)
-----------FriendsTooltip Frame End--------
