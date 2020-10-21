local maxLevel = 50 --TODO: Update when thhe level cap changes
local separator = ',' --Thousand separator character

--Shash keywords and commands
local slashKeyword = "/remxp"
local resetPosition = "reset"
local presetPosition = "preset"
local defaultPreset = "default"
local savePreset = "save"
local toggleVisibility = "toggle"
local toggleMouseover = "hover"

--Creating the frame & text
local remainingXP = CreateFrame("Frame", "RemainingXP", UIParent)
local displayText = remainingXP:CreateFontString("DisplayText", "HIGH")

--Registering events
remainingXP:RegisterEvent("ADDON_LOADED");
remainingXP:RegisterEvent("PLAYER_XP_UPDATE")
remainingXP:RegisterEvent("PLAYER_LEVEL_UP")

--DB table & defaults
local db
local defaultDB = {
	["preset"] = {
		["point"] = "BOTTOM",
		["offsetX"] = 380,
		["offsetY"] = 2
	},
	["toggle"] = false
}

--Loading the db
db = defaultDB --[PH!!!] TODO: Implement DB variable saving
--[[ remainingXP:SetScript("OnEvent", function(self, event, addon, variable)
	if event == "ADDON_LOADED" and addon == "Remaining XP" and variable == "RemainingXPDB" then
		if RemainingXPDB == nil then
			RemainingXPDB = dbDefaults
			PrintHelp()
		end
		
			db = dbDefaults
		db = RemainingXPDB
		print(db["preset"]["point"])
	end
end) ]]

--Setting up the frame & text
remainingXP:SetFrameStrata("MEDIUM")
remainingXP:SetSize(64, 8)
remainingXP:SetPoint(db["preset"]["point"], db["preset"]["offsetX"], db["preset"]["offsetY"])
displayText:SetPoint("CENTER")
displayText:SetFont("Fonts\\ARIALN.TTF", 12, "THINOUTLINE")
displayText:SetTextColor(1,1,1,1)
remainingXP:Show()

--Updating the remaining XP value
remainingXP:SetScript("OnEvent", function(self, event, ...)
	if UnitLevel("player") < maxLevel then
		local xp = UnitXPMax("player") - UnitXP("player")
		while true do
			xp, leftover = string.gsub(xp, "^(-?%d+)(%d%d%d)", '%1' .. separator .. '%2')
			if (leftover == 0) then
				break
			end
		end
		displayText:SetText(xp)
	else
		remainingXP:Hide()
	end
end)

--Making the frame moveable
remainingXP:SetMovable(true)
remainingXP:SetUserPlaced(true)
remainingXP:SetScript("OnMouseDown", function(self)
	if (IsShiftKeyDown() and not self.isMoving) then
		remainingXP:StartMoving()
		self.isMoving = true
	end
end)
remainingXP:SetScript("OnMouseUp", function(self)
	if (self.isMoving) then
		remainingXP:StopMovingOrSizing()
		self.isMoving = false
	end
end)

--Toggling view on mousover
remainingXP:SetScript('OnEnter', function()
	if db["toggle"] then
		displayText:Show()
	end
end)
remainingXP:SetScript('OnLeave', function()
	if db["toggle"] then
		displayText:Hide()
	end
end)

--Set up slash commands
SLASH_REMXP1 = slashKeyword
function SlashCmdList.REMXP(command)
	if command == "" or command == "help" then
		PrintHelp()
	elseif command == resetPosition then
		remainingXP:SetPoint("BOTTOM", 0, 2)
		print("Remaining XP: The location has been set to the bottom-center of the screen.")
	elseif command == presetPosition then
		remainingXP:SetPoint(db["preset"]["point"], db["preset"]["offsetX"], db["preset"]["offsetY"])
		print("Remaining XP: The location has been set to the preset location.")
	elseif command == savePreset then
		db["preset"]["point"], x, y, db["preset"]["offsetX"], db["preset"]["offsetY"] = RemainingXP:GetPoint() --relativeTo, relativePoint aren't needed
		--Save DB
		print("Remaining XP: The current location was saved as the preset location.")
	elseif command == defaultPreset then
		db["preset"] = defaultDB["preset"]
		--Save DB
		print("Remaining XP: The preset location has been reset to the default location.")
	elseif command == toggleVisibility then
		SetToggle(false)
		FlipVisibility(displayText:IsShown())
		print("Remaining XP visibility is now " .. ToggleState(displayText:IsShown()) .. ". Toggle on mouseover is disabled.")
	elseif command == toggleMouseover then
		SetToggle()
		FlipVisibility(db["toggle"])
		print("Remaining XP: Toggle on mouseover has been " .. ToggleState(db["toggle"]) .. ".")
	end
end

function PrintHelp()
	print("Thank you for using Remaining XP!")
	print("Chat command list:")
	print("    " .. slashKeyword .. " " .. resetPosition .. " - set location to the bottom-center of the screen")
	print("    " .. slashKeyword .. " " .. presetPosition .. " - set location to the specified preset location")
	print("    " .. slashKeyword .. " " .. savePreset .. " - save the current location as the preset location")
	print("    " .. slashKeyword .. " " .. defaultPreset .. " - set the preset location to the default location")
	print("    " .. slashKeyword .. " " .. toggleVisibility .. " - hide/show the XP value display (" .. ToggleState(displayText:IsShown()) .. ")")
	print("    " .. slashKeyword .. " " .. toggleMouseover .. " - show the XP value only on mouseover (" .. ToggleState(db["toggle"]) ..")")
	print("Tip: Hold SHIFT and drag the Remaining XP display to a different place.")
end

function FlipVisibility(toggle)
	if toggle then
		displayText:Hide()
	else
		displayText:Show()
	end
end

--Flip the display toggle
function SetToggle(toggle)
	if toggle == nil then
		db["toggle"] = not db["toggle"] --Flip toggle
	else
		db["toggle"] = toggle --Set toggle
	end
	--Save DB
end

--Get display toggle state
function ToggleState(toggle)
	if toggle then
		return "enabled"
	else
		return "disabled"
	end
	return ""
end