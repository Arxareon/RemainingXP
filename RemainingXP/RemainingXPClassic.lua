--Parameters
local maxLevel = 60 --TODO: Update when the level cap changes
local separator = ',' --Thousand separator character

--Colors
local b = "|cFF" .. "0F89FF" --blue
local p = "|cFF" .. "D41BCA" --purple
local fb = "|cFF" .. "75B3F0" -- faint blue
local fp = "|cFF" .. "D257CB" -- faint purple

--DB table & defaults
local dbPreset --account-wide
local dbDisplay --character-specific
local dbPresetDefault = {
	["point"] = "BOTTOM",
	["offsetX"] = 485,
	["offsetY"] = 42
}
local dbDisplayDefault = {
	["hidden"] = false,
	["toggle"] = false,
	["disabled"] = false
}
local startLocation = {
	["point"] = "BOTTOM",
	["offsetX"] = 27,
	["offsetY"] = 42
}

--Slash keywords and commands
local keyword = "/remxp"
local resetPosition = "reset"
local presetPosition = "preset"
local defaultPreset = "default"
local savePreset = "save"
local hideDisplay = "hide"
local showDisplay = "show"
local toggleMouseover = "toggle"

--Creating the frame & text
local remXP = CreateFrame("Frame", "RemainingXP", UIParent)
local text = remXP:CreateFontString("text", "HIGH")

--Registering events
remXP:RegisterEvent("ADDON_LOADED")
remXP:RegisterEvent("PLAYER_LOGIN")
remXP:RegisterEvent("PLAYER_XP_UPDATE")
remXP:RegisterEvent("PLAYER_LEVEL_UP")
remXP:SetScript("OnEvent", function(self, event, ...) --Event handler
	return self[event] and self[event](self, ...)
end)

--Display visibility utilities
local function FlipVisibility(visible)
	if visible then
		text:Hide()
	else
		text:Show()
	end
end

local function ToggleState(toggle)
	if toggle then
		return "ON"
	else
		return "OFF"
	end
	return ""
end

--Chat control utilities
local function PrintStatus()
	local status = p .. "Remaining XP"
	if UnitLevel("player") == maxLevel then
		status = status .. b .. " is disabled " .. fb .. "(you are level " .. maxLevel .. ")" .. b .. "."
	else
		if text:IsShown() then
			status = status .. b .. " is visible "
		else
			status = status .. b .. " is not visible "
		end
		status = status .. fb .. "(status: " .. b .. "hidden: " .. p .. ToggleState(dbDisplay["hidden"])
		status = status .. fb .. ", " .. b .. "mouseover only: " .. p .. ToggleState(dbDisplay["mouseover"]) .. fb .. ")" .. b .. "."
	end
	print(status);
end

local function PrintHelp()
	print(b .. "Thank you for using " .. p .. "Remaining XP" .. b .. "!")
	PrintStatus()
	print(fb .. "Type " .. fp .. keyword .. " help" .. fb .. " to see the full command list.")
	print(fb .. "Hold " .. fp .. "SHIFT" .. fb .. " to drag & drop the Remaining XP display anywhere you like.")
end

local function PrintCommands()
	print(p .. "Remaining XP" .. b ..  " chat command list:")
	print("    " .. fp .. keyword .. " " .. resetPosition .. fb .. " - set location to the bottom-center of the screen")
	print("    " .. fp .. keyword .. " " .. presetPosition .. fb .. " - set location to the specified preset location")
	print("    " .. fp .. keyword .. " " .. savePreset .. fb .. " - save the current location as the preset location")
	print("    " .. fp .. keyword .. " " .. defaultPreset .. fb .. " - set the preset location to the default location")
	print("    " .. fp .. keyword .. " " .. hideDisplay .. fb .. " - hide the XP value display (" .. b .. "hidden: " .. p.. ToggleState(dbDisplay["hidden"]) .. fb .. ")")
	print("    " .. fp .. keyword .. " " .. showDisplay .. fb .. " - show the XP value display (" .. b .. "visibility: " .. p.. ToggleState(text:IsShown()) .. fb .. ")")
	print("    " .. fp .. keyword .. " " .. toggleMouseover .. fb .. " - show the XP value only on mouseover (" .. p.. ToggleState(dbDisplay["mouseover"]) .. fb .. ")")
end

--Initialization
function remXP:ADDON_LOADED(addon)
	if addon == "RemainingXP" then
		remXP:UnregisterEvent("ADDON_LOADED")

		--Load the DBs
		local firstLoad = RemainingXPDB == nil or RemainingXPDBC == nil
		RemainingXPDB = RemainingXPDB or dbPresetDefault
		RemainingXPDBC = RemainingXPDBC or dbDisplayDefault
		dbPreset = RemainingXPDB
		dbDisplay = RemainingXPDBC

		--Set up the frame & text
		remXP:SetFrameStrata("HIGH")
		remXP:SetFrameLevel(0)
		remXP:SetSize(64, 10)
		if not remXP:IsUserPlaced() then
			remXP:ClearAllPoints()
			remXP:SetPoint(startLocation["point"], startLocation["offsetX"], startLocation["offsetY"])
			remXP:SetUserPlaced(true)
		end
		text:SetPoint("CENTER")
		text:SetFont("Fonts\\FRIZQT__.TTF", 10, "THINOUTLINE")
		text:SetTextColor(1,1,1,1)
		FlipVisibility(dbDisplay["hidden"] or dbDisplay["mouseover"] or dbDisplay["disabled"])

		--Load welcome message
		if firstLoad then
			PrintHelp()
		else
			PrintStatus()
		end
	end
end

--Recalculate the XP value and update the displayed text
local function UpdateXP()
	--Calculate
	local xp = UnitXPMax("player") - UnitXP("player")
	--Format
	local leftover
	while true do
		xp, leftover = string.gsub(xp, "^(-?%d+)(%d%d%d)", '%1' .. separator .. '%2')
		if (leftover == 0) then
			break
		end
	end
	--Display
	text:SetText(xp)
end

--Disable the frame and display if the player is max level
local function CheckMax(level)
	if level == maxLevel then
		text:Hide()
		remXP:Hide()
		dbDisplay["hidden"] = true
		dbDisplay["disabled"] = true
	else
		dbDisplay["disabled"] = false
	end
end

--Updating the remaining XP value
function remXP:PLAYER_LOGIN()
	UpdateXP()
	CheckMax(UnitLevel("player"))
end
function remXP:PLAYER_XP_UPDATE(unit)
	if unit == "player" then
		UpdateXP()
	end
end
function remXP:PLAYER_LEVEL_UP(newLevel)
	CheckMax(newLevel)
	if newLevel == maxLevel then
		print(p .. "Remaining XP" .. b .. " has now been disabled " .. fb .. "(you reached level " .. maxLevel .. ")" .. b .. ". Congrats!")
	end
end

--Making the frame moveable
remXP:SetMovable(true)
remXP:SetScript("OnMouseDown", function(self)
	if (IsShiftKeyDown() and not self.isMoving) then
		remXP:StartMoving()
		self.isMoving = true
	end
end)
remXP:SetScript("OnMouseUp", function(self)
	if (self.isMoving) then
		remXP:StopMovingOrSizing()
		self.isMoving = false
	end
end)

--Toggling view on mouseover
remXP:SetScript('OnEnter', function()
	if dbDisplay["mouseover"] then
		text:Show()
	end
end)
remXP:SetScript('OnLeave', function()
	if dbDisplay["mouseover"] then
		text:Hide()
	end
end)

--Set up slash commands
SLASH_REMXP1 = keyword
function SlashCmdList.REMXP(command)
	if command == "help" then
		PrintCommands()
	elseif command == resetPosition then
		remXP:ClearAllPoints()
		remXP:SetUserPlaced(false)
		remXP:SetPoint(startLocation["point"], startLocation["offsetX"], startLocation["offsetY"])
		remXP:SetUserPlaced(true)
		print(p .. "Remaining XP:" .. b .. " The location has been reset to the bottom-center.")
	elseif command == presetPosition then
		remXP:ClearAllPoints()
		remXP:SetUserPlaced(false)
		remXP:SetPoint(dbPreset["point"], dbPreset["offsetX"], dbPreset["offsetY"])
		remXP:SetUserPlaced(true)
		print(p .. "Remaining XP:" .. b .. " The location has been set to the preset location.")
	elseif command == savePreset then
		local x local y dbPreset["point"], x, y, dbPreset["offsetX"], dbPreset["offsetY"] = remXP:GetPoint()
		print(p .. "Remaining XP:" .. b .. " The current location was saved as the preset location.")
	elseif command == defaultPreset then
		dbPreset = dbPresetDefault
		print(p .. "Remaining XP:" .. b .. " The preset location has been reset to the default location.")
	elseif command == hideDisplay then
		dbDisplay["mouseover"] = false
		dbDisplay["hidden"] = true
		text:Hide()
		PrintStatus()
	elseif command == showDisplay then
		if not dbDisplay["disabled"] then
			dbDisplay["mouseover"] = false
			dbDisplay["hidden"] = false
			text:Show()
		end
		PrintStatus()
	elseif command == toggleMouseover then
		if not dbDisplay["disabled"] then
			dbDisplay["hidden"] = false
			dbDisplay["mouseover"] = not dbDisplay["mouseover"]
			FlipVisibility(dbDisplay["mouseover"])
		end
		PrintStatus()
	else
		PrintHelp()
	end
end