local maxLevel = 120 --TODO: Update when thhe level cap changes
local separator = ',' --Thousand separator character
--Preset location offset (compared to the bottom-center of the screen)
local offsetX = 380
local offsetY = 2
--Shash keyrods and commands
local slashKeyword = "/remxp"
local resetPosition = "reset"
local presetPosition = "preset"

--Setting up the frame
local remainingXP = CreateFrame("Frame", "RemainingXP", UIParent)
local displayText = remainingXP:CreateFontString("DisplayText", "HIGH")

remainingXP:SetFrameStrata("HIGH")
remainingXP:SetSize(64, 8)
remainingXP:SetPoint("BOTTOM", 0, 2)
displayText:SetPoint("CENTER")
displayText:SetFont("Fonts\\ARIALN.TTF", 12, "THINOUTLINE")
displayText:SetTextColor(1,1,1,1)
remainingXP:Show()

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

--Registering events
onLoad = remainingXP:RegisterEvent("PLAYER_ENTERING_WORLD")
onUpdate = remainingXP:RegisterEvent("PLAYER_XP_UPDATE")
onLevelUp = remainingXP:RegisterEvent("PLAYER_LEVEL_UP")

if not (onLoad and onUpdate and onLevelUp) then
	print("RemainingXP failed to load. Sorry. :(")
end

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

--Set up slash commands
SLASH_REMXP1 = slashKeyword
function SlashCmdList.REMXP(command)
	if command == "" or command == "help" then
		print("Thank you for using Remaining XP!")
		print("You can click & drag to resposition the text while holding the SHIFT key.")
		print("Chat command list:")
		print("    " .. slashKeyword .. " " .. resetPosition .. " - set location to the bottom-center of the screen")
		print("    " .. slashKeyword .. " " .. presetPosition .. " - set location to the specified preset location")
	elseif command == resetPosition then
		remainingXP:SetPoint("BOTTOM", 0, 2)
	elseif command == presetPosition then
		remainingXP:SetPoint("BOTTOM", offsetX, offsetY)
	end
end

--Toggling view on mousover
--[[ remainingXP:EnableMouse()
remainingXP:SetScript('OnEnter', function()
	displayText:Show()
end)
remainingXP:SetScript('OnLeave', function()
	displayText:Hide()
end) ]]