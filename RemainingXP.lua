--Parameters
local maxLevel = 60 --TODO: Update when the level cap changes
local separator = ',' --Thousand separator character

--Colors
local colors = {
	["b"] = "|cFF" .. "0F89FF", --blue
	["p"] = "|cFF" .. "D41BCA", --purple
	["fb"] = "|cFF" .. "75B3F0", -- faint blue
	["fp"]= "|cFF" .. "D257CB", -- faint purple
}

--DB table & defaults
local dbPreset --account-wide
local dbDisplay --character-specific
local dbPresetDefault = {
	["position"] = {
		["point"] = "BOTTOM",
		["offset"] = {
			["x"] = 380,
			["y"] = 2,
		},
	},
	["font"] = {
		["family"] = "Fonts\\FRIZQT__.TTF",
		["size"] = 11,
	},
}
local dbDisplayDefault = {
	["hidden"] = false,
	["toggle"] = false,
	["disabled"] = false,
}
local startLocation = {
	["point"] = "BOTTOM",
	["offset"] = {
		["x"] = 0,
		["y"] = 2,
	},
}

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

--Slash keywords and commands
local keyword = "/remxp"
local helpCommand = {
	["name"] = "help",
	["description"] = "see the full command list",
}
local commands = {
	["1resetPosition"] = {
		["name"] = "reset",
		["description"] = "set location to the bottom-center of the screen",
	},
	["2presetPosition"] = {
		["name"] = "preset",
		["description"] = "set location to the specified preset location",
	},
	["3savePreset"] = {
		["name"] = "save",
		["description"] = "save the current location as the preset location",
	},
	["4defaultPreset"] = {
		["name"] = "default",
		["description"] = "set the preset location to the default location",
	},
	["5hideDisplay"] = {
		["name"] = "hide",
		["description"] = "hide the XP value display (" .. colors["b"] .. "hidden: " .. colors["p"] .. ToggleState(dbDisplay["hidden"]) .. colors["fb"] .. ")",
	},
	["6showDisplay"] = {
		["name"] = "show",
		["description"] = "show the XP value display (" .. colors["b"] .. "visibility: " .. colors["p"] .. ToggleState(text:IsShown()) .. colors["fb"] .. ")",
	},
	["7toggleMouseover"] = {
		["name"] = "toggle",
		["description"] = "show the XP value only on mouseover (" .. colors["p"] .. ToggleState(dbDisplay["toggle"]) .. colors["fb"] .. ")",
	},
	["8fontSize"] = {
		["name"] = "size",
		["description"] = "change the font size (e.g. " .. colors["fp"] .. "size " .. dbPresetDefault["font"]["size"] .. colors["fb"] .. ")",
	},
}

--Chat control utilities
local function PrintStatus()
	local status = colors["p"] .. "Remaining XP"
	if UnitLevel("player") == maxLevel then
		status = status .. colors["b"] .. " is disabled " .. colors["fb"] .. "(you are level " .. maxLevel .. ")" .. colors["b"] .. "."
	else
		if text:IsShown() then
			status = status .. colors["b"] .. " is visible "
		else
			status = status .. colors["b"] .. " is not visible "
		end
		status = status .. colors["fb"] .. "(status: " .. colors["b"] .. "hidden: " .. colors["p"] .. ToggleState(dbDisplay["hidden"])
		status = status .. colors["fb"] .. ", " .. colors["b"] .. "mouseover only: " .. colors["p"] .. ToggleState(dbDisplay["toggle"]) .. colors["fb"] .. ")" .. colors["b"] .. "."
	end
	print(status);
end
local function PrintHelp()
	print(colors["b"] .. "Thank you for using " .. colors["p"] .. "Remaining XP" .. colors["b"] .. "!")
	PrintStatus()
	print(colors["fb"] .. "Type " .. colors["fp"] .. keyword .. " " .. helpCommand["name"] .. colors["fb"] .. " to " .. helpCommand["description"])
	print(colors["fb"] .. "Hold " .. colors["fp"] .. "SHIFT" .. colors["fb"] .. " to drag the Remaining XP display anywhere you like.")
end
local function PrintCommands()
	print(colors["p"] .. "Remaining XP" .. colors["b"] ..  " chat command list:")
	local temp = {}
	for n in pairs(commands) do table.insert(temp, n) end
    table.sort(temp)
    for i,n in ipairs(temp) do 
		print("    " .. colors["fp"] .. keyword .. " " .. commands[n]["name"] .. colors["fb"] .. " - " .. commands[n]["description"])
	end
end

--Check and fix the DB
local oldData = {};
local function AddItems(dbToCheck, dbToSample) --Check for and fill in missing data
	if type(dbToCheck) ~= "table"  and type(dbToSample) ~= "table" then return end
	for k,v in pairs(dbToSample) do
		if dbToCheck[k] == nil then
			dbToCheck[k] = v;
		else
			AddItems(dbToCheck[k], dbToSample[k])
		end
	end
end
local function RemoveItems(dbToCheck, dbToSample) --Remove unused or outdated data while trying to keep any old data
	if type(dbToCheck) ~= "table"  and type(dbToSample) ~= "table" then return end
	for k,v in pairs(dbToCheck) do
		if dbToSample[k] == nil then
			oldData[k] = v;
			dbToCheck[k] = nil;
		else
			RemoveItems(dbToCheck[k], dbToSample[k])
		end
	end
end
local function RestoreOldData() --Restore old data to the DB
	for k,v in pairs(oldData) do
		if k == "offsetX" then
			dbPreset["position"]["offset"]["x"] = v
		elseif k == "offsetY" then
			dbPreset["position"]["offset"]["y"] = v
		end
	end
end

--Initialization
local function LoadDBs()
	--First load
	local firstLoad = RemainingXPDBPreset == nil or RemainingXPDBDisplay == nil
	RemainingXPDBPreset = RemainingXPDBPreset or dbPresetDefault
	RemainingXPDBDisplay = RemainingXPDBDisplay or dbDisplayDefault
	--Load the DBs
	dbPreset = RemainingXPDBPreset
	dbDisplay = RemainingXPDBDisplay
	--Check for missing data
	AddItems(dbPreset, dbPresetDefault)
	AddItems(dbDisplay, dbDisplayDefault)
	--Remove unneeded data
	RemoveItems(dbPreset, dbPresetDefault)
	RemoveItems(dbDisplay, dbDisplayDefault)
	--Save old data
	RestoreOldData()
	--Signal first load
	return firstLoad
end
local function SetFrameParameters()
	remXP:SetFrameStrata("HIGH")
	remXP:SetFrameLevel(0)
	remXP:SetSize(64, 10)
	if not remXP:IsUserPlaced() then
		remXP:ClearAllPoints()
		remXP:SetPoint(startLocation["point"], startLocation["offset"]["x"], startLocation["offset"]["y"])
		remXP:SetUserPlaced(true)
	end
	text:SetPoint("CENTER")
	text:SetFont(dbPreset["font"]["family"], dbPreset["font"]["size"], "THINOUTLINE")
	text:SetTextColor(1,1,1,1)
	FlipVisibility(dbDisplay["hidden"] or dbDisplay["toggle"] or dbDisplay["disabled"])
end
function remXP:ADDON_LOADED(addon)
	if addon == "RemainingXP" then
		remXP:UnregisterEvent("ADDON_LOADED")
		--Load and check the DBs
		local firstLoad = LoadDBs()
		--Set up the UI frame & text
		SetFrameParameters()
		--Load welcome message
		if firstLoad then PrintHelp() else PrintStatus() end
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
		print(colors["p"] .. "Remaining XP" .. colors["b"] .. " has now been disabled " .. colors["fb"] .. "(you reached level " .. maxLevel .. ")" .. colors["b"] .. ". Congrats!")
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
	if dbDisplay["toggle"] then
		text:Show()
	end
end)
remXP:SetScript('OnLeave', function()
	if dbDisplay["toggle"] then
		text:Hide()
	end
end)

--Set up slash commands
SLASH_REMXP1 = keyword
function SlashCmdList.REMXP(command)
	local name, value = strsplit(" ", command)
	if name == helpCommand["name"] then
		PrintCommands()
	elseif name == commands["1resetPosition"]["name"] then
		remXP:ClearAllPoints()
		remXP:SetUserPlaced(false)
		remXP:SetPoint(startLocation["point"], startLocation["offset"]["x"], startLocation["offset"]["y"])
		remXP:SetUserPlaced(true)
		print(colors["p"] .. "Remaining XP:" .. colors["b"] .. " The location has been reset to the bottom-center.")
	elseif name == commands["2presetPosition"]["name"] then
		remXP:ClearAllPoints()
		remXP:SetUserPlaced(false)
		remXP:SetPoint(dbPreset["position"]["point"], dbPreset["position"]["offset"]["x"], dbPreset["position"]["offset"]["y"])
		remXP:SetUserPlaced(true)
		print(colors["p"] .. "Remaining XP:" .. colors["b"] .. " The location has been set to the preset location.")
	elseif name == commands["3savePreset"]["name"] then
		local x local y dbPreset["position"]["point"], x, y, dbPreset["position"]["offset"]["x"], dbPreset["position"]["offset"]["y"] = remXP:GetPoint()
		print(colors["p"] .. "Remaining XP:" .. colors["b"] .. " The current location was saved as the preset location.")
	elseif name == commands["4defaultPreset"]["name"] then
		dbPreset["position"] = dbPresetDefault["position"]
		print(colors["p"] .. "Remaining XP:" .. colors["b"] .. " The preset location has been reset to the default location.")
	elseif name == commands["5hideDisplay"]["name"] then
		dbDisplay["toggle"] = false
		dbDisplay["hidden"] = true
		text:Hide()
		PrintStatus()
	elseif name == commands["6showDisplay"]["name"] then
		if not dbDisplay["disabled"] then
			dbDisplay["toggle"] = false
			dbDisplay["hidden"] = false
			text:Show()
		end
		PrintStatus()
	elseif name == commands["7toggleMouseover"]["name"] then
		if not dbDisplay["disabled"] then
			dbDisplay["hidden"] = false
			dbDisplay["toggle"] = not dbDisplay["toggle"]
			FlipVisibility(dbDisplay["toggle"])
		end
		PrintStatus()
	elseif command == commands["8fontSize"]["name"] then
		local size = tonumber(value)
		if size ~= nil then
			dbPreset["font"]["size"] = size
			text:SetFont(dbPreset["font"]["family"], dbPreset["font"]["size"], "THINOUTLINE")
			print(colors["p"] .. "Remaining XP:" .. colors["b"] .. "The font size has been set to " .. size .. ".")
		else
			print(colors["p"] .. "Remaining XP:" .. colors["b"] .. "The font size was not changed.")
			print(colors["fb"] .. "Please enter a valid number value (e.g. " .. colors["fp"] .. "/movespeed size 11" ..  colors["fb"] .. ").")
		end
		PrintStatus()
	else
		PrintHelp()
	end
end