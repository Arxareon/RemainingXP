--Parameters
local maxLevel = 50 --TODO: Update when thhe level cap changes
local separator = ',' --Thousand separator character

--Colors
local b = "|cFF" .. "0F89FF" --blue
local p = "|cFF" .. "D41BCA" --purple
local fb = "|cFF" .. "75B3F0" -- faint blue
local fp = "|cFF" .. "D257CB" -- faint purple

--Shash keywords and commands
local keyword = "/remxp"
local resetPosition = "reset"
local presetPosition = "preset"
local defaultPreset = "default"
local savePreset = "save"
local hideDisplay = "hide"
local showDisplay = "show"
local toggleMouseover = "toggle"

--Creating the frame & text
local remXP = CreateFrame("Frame", "remXP", UIParent)
local text = remXP:CreateFontString("text", "HIGH")

--Registering events
remXP:RegisterEvent("ADDON_LOADED")
remXP:RegisterEvent("PLAYER_LOGIN")
remXP:RegisterEvent("PLAYER_XP_UPDATE")
remXP:RegisterEvent("PLAYER_LEVEL_UP")
remXP:SetScript("OnEvent", function(self, event, ...) --Event handler
	return self[event] and self[event](self, ...)
end)

--DB table & defaults
local db
local defaultDB = {
	["preset"] = {
		["point"] = "BOTTOM",
		["offsetX"] = 380,
		["offsetY"] = 2
	},
	["hidden"] = true,
	["toggle"] = false,
	["disabled"] = false
}
local startLocation = {
	["point"] = "BOTTOM",
	["offsetX"] = 0,
	["offsetY"] = 2
}

--Initialization
function remXP:ADDON_LOADED(addon)
	if addon == "RemainingXP" then
		remXP:UnregisterEvent("ADDON_LOADED")
		--First load
		if RemainingXPDB == nil then
			RemainingXPDB = defaultDB
			PrintHelp()
		end
		--Load the db
		db = RemainingXPDB
		--Set up the UI
		UpdateDisplay()
	end
end

--Updating the remaining XP value
function remXP:PLAYER_LOGIN()
	UpdateXP()
	CheckMax()
end
function remXP:PLAYER_XP_UPDATE(unit)
	if unit == "player" then
		UpdateXP()
	end
end
function remXP:PLAYER_LEVEL_UP()
	CheckMax()
end

--Disable the frame and display if the player is max level
function CheckMax()
	if UnitLevel("player") == maxLevel then
		text:Hide()
		remXP:Hide()
		db["hidden"] = true
		db["disabled"] = true
		print(p .. "Remaining XP" .. b .. " is disabled " .. fb .. "(you are level " .. maxLevel .. ")" .. b .. ".")
	else
		db["disabled"] = false
	end
end

--Setting up the frame & text
function UpdateDisplay()
	remXP:SetFrameStrata("HIGH")
	remXP:SetFrameLevel(0)
	remXP:SetSize(64, 10)
	if not remXP:IsUserPlaced() then
		remXP:ClearAllPoints()
		remXP:SetPoint(startLocation["point"], startLocation["offsetX"], startLocation["offsetY"])
		remXP:SetUserPlaced(true)
	end
	text:SetPoint("CENTER")
	text:SetFont("Fonts\\ARIALN.TTF", 12, "THINOUTLINE")
	text:SetTextColor(1,1,1,1)
	FlipVisibility(db["hidden"] or db["toggle"] or db["disabled"])
end

--Recalculate the XP value and update the diplayed text
function UpdateXP()
	local xp = UnitXPMax("player") - UnitXP("player")
	while true do
		xp, leftover = string.gsub(xp, "^(-?%d+)(%d%d%d)", '%1' .. separator .. '%2')
		if (leftover == 0) then
			break
		end
	end
	text:SetText(xp)
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

--Toggling view on mousover
remXP:SetScript('OnEnter', function()
	if db["toggle"] then
		text:Show()
	end
end)
remXP:SetScript('OnLeave', function()
	if db["toggle"] then
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
		remXP:SetPoint(db["preset"]["point"], db["preset"]["offsetX"], db["preset"]["offsetY"])
		remXP:SetUserPlaced(true)
		print(p .. "Remaining XP:" .. b .. " The location has been set to the preset location.")
	elseif command == savePreset then
		db["preset"]["point"], x, y, db["preset"]["offsetX"], db["preset"]["offsetY"] = remXP:GetPoint()
		print(p .. "Remaining XP:" .. b .. " The current location was saved as the preset location.")
	elseif command == defaultPreset then
		db["preset"] = defaultDB["preset"]
		print(p .. "Remaining XP:" .. b .. " The preset location has been reset to the default location.")
	elseif command == hideDisplay then
		db["toggle"] = false
		db["hidden"] = true
		text:Hide()
		print(p .. "Remaining XP: " .. GetStatus())
	elseif command == showDisplay then
		if not db["disabled"] then
			db["toggle"] = false
			db["hidden"] = false
			text:Show()
		end
		print(p .. "Remaining XP: " .. GetStatus())
	elseif command == toggleMouseover then
		if not db["disabled"] then
			db["hidden"] = false
			db["toggle"] = not db["toggle"]
			FlipVisibility(db["toggle"])
		end
		print(p .. "Remaining XP: " .. GetStatus())
	else
		PrintHelp()
	end
end

function PrintHelp()
	print(b .. "Thank you for using " .. p .. "Remaining XP" .. b .. "!")
	print(fb .. "Display status: " .. GetStatus())
	print(fb .. "Type " .. fp .. keyword .. " help" .. fb .. " to see the full command list.")
	print(fb .. "Hold SHIFT to drag the Remaining XP display to anywhere you like.")
end

function PrintCommands()
	print(p .. "Remaining XP" .. b ..  " chat command list:")
	print("    " .. fp .. keyword .. " " .. resetPosition .. fb .. " - set location to the bottom-center of the screen")
	print("    " .. fp .. keyword .. " " .. presetPosition .. fb .. " - set location to the specified preset location")
	print("    " .. fp .. keyword .. " " .. savePreset .. fb .. " - save the current location as the preset location")
	print("    " .. fp .. keyword .. " " .. defaultPreset .. fb .. " - set the preset location to the default location")
	print("    " .. fp .. keyword .. " " .. hideDisplay .. fb .. " - hide the XP value display (" .. b .. "hidden: " .. p.. ToggleState(db["hidden"]) .. fb .. ")")
	print("    " .. fp .. keyword .. " " .. showDisplay .. fb .. " - show the XP value display (" .. b .. "visibility: " .. p.. ToggleState(text:IsShown()) .. fb .. ")")
	print("    " .. fp .. keyword .. " " .. toggleMouseover .. fb .. " - show the XP value only on mouseover (" .. p.. ToggleState(db["toggle"]) .. fb .. ")")
end

function GetStatus()
	local status = ""
	status = status .. b .. "visible: " .. p .. ToggleState(text:IsShown())
	status = status .. b .. ", hidden: " .. p .. ToggleState(db["hidden"])
	status = status .. b .. ", mouseover only: " .. p .. ToggleState(db["toggle"])
	return status
end

--Set the display visibility (flipped)
function FlipVisibility(visible)
	if visible then
		text:Hide()
	else
		text:Show()
	end
end

--Get display toggle state
function ToggleState(toggle)
	if toggle then
		return "ON"
	else
		return "OFF"
	end
	return ""
end