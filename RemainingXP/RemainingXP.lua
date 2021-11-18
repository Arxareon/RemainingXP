--Addon name, namespace
local addonNameSpace, ns = ...
local _, addon = GetAddOnInfo(addonNameSpace)

--WidgetTools reference
local wt = WidgetToolsTable

--Parameters
local maxLevel = 60 --TODO: Update when the level cap changes


--[[ ASSETS & RESOURCES ]]

--Strings & Localization
local strings = ns.LoadLocale()
strings.chat.keyword = "/remxp"

--Colors
local colors = {
	b = "|cFF" .. "0F89FF", --blue
	p = "|cFF" .. "D41BCA", --purple
	fb = "|cFF" .. "75B3F0", -- faint blue
	fp = "|cFF" .. "D257CB", -- faint purple
}

--Fonts
local fonts = {
	[0] = { text = strings.misc.default, path = strings.options.font.family.default },
	[1] = { text = "Arbutus Slab", path = "Interface/AddOns/RemainingXP/Fonts/ArbutusSlab.ttf" },
	[2] = { text = "Caesar Dressing", path = "Interface/AddOns/RemainingXP/Fonts/CaesarDressing.ttf" },
	[3] = { text = "Germania One", path = "Interface/AddOns/RemainingXP/Fonts/GermaniaOne.ttf" },
	[4] = { text = "Mitr", path = "Interface/AddOns/RemainingXP/Fonts/Mitr.ttf" },
	[5] = { text = "Oxanium", path = "Interface/AddOns/RemainingXP/Fonts/Oxanium.ttf" },
	[6] = { text = "Pattaya", path = "Interface/AddOns/RemainingXP/Fonts/Pattaya.ttf" },
	[7] = { text = "Reem Kufi", path = "Interface/AddOns/RemainingXP/Fonts/ReemKufi.ttf" },
	[8] = { text = "Source Code Pro", path = "Interface/AddOns/RemainingXP/Fonts/SourceCodePro.ttf" },
	[9] = { text = strings.misc.custom, path = "Interface/AddOns/RemainingXP/Fonts/CUSTOM.ttf" },
}

--Textures
local textures = {
	logo = "Interface/AddOns/RemainingXP/Textures/Logo.tga"
}


--[[ DB TABLES ]]

local db --account-wide
local dbDefault = {
	position = {
		point = "BOTTOM",
		offset = { x = 380, y = 2, },
	},
	appearance = {
		frameStrata = "HIGH",
		backdrop = {
			visible = false,
			color = { r = 0, g = 0, b = 0, a = 0.5 },
		},
	},
	font = {
		family = fonts[0].path,
		size = 11,
		color = { r = 1, g = 1, b = 1, a = 1 },
	},
}
local startPosition = {
	point = "BOTTOM",
	offset = { x = 0, y = 2, },
}
local dbc --character-specific
local dbcDefault = {
	hidden = false,
	mouseover = false,
	disabled = false,
}


--[[ FRAMES & EVENTS ]]

--Create the main frame & text display
local remXP = CreateFrame("Frame", addon:gsub("%s+", ""), UIParent)
local mainDisplay = CreateFrame("Frame", remXP:GetName() .. "MainDisplay", remXP, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayText = mainDisplay:CreateFontString(mainDisplay:GetName() .. "Text", "OVERLAY")

--Registering events
remXP:RegisterEvent("ADDON_LOADED")
remXP:RegisterEvent("PLAYER_LOGIN")
remXP:RegisterEvent("PLAYER_XP_UPDATE")
remXP:RegisterEvent("PLAYER_LEVEL_UP")
remXP:RegisterEvent("PET_BATTLE_OPENING_START")
remXP:RegisterEvent("PET_BATTLE_CLOSE")

--Event handler
remXP:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)


--[[ UTILITIES ]]

local function Dump(object)
	if type(object) ~= "table" then
		print(object)
		return
	end
	for _, v in pairs(object) do
		Dump(v)
	end
end

--Make a new deep copy (not reference) of a table
local function Clone(object)
	if type(object) ~= "table" then
		return object
	end
	local copy = {}
	for k, v in pairs(object) do
		copy[k] = Clone(v)
	end
	return copy
end

---Convert table to string chunk
--- - Note: append "return " to the start when loading via [load()](https://www.lua.org/manual/5.2/manual.html#lua_load).
---@param table table
---@param compact boolean
---@return string
local function TableToString(table, compact)
	local s = ((compact ~= true) and " " or "")
	local chunk = "{" .. s
	for k, v in pairs(table) do
		--Key
		chunk = chunk .. "[" .. (type(k) == "string" and "\"" or "") .. k .. (type(k) == "string" and "\"" or "") .. "]"
		--Add =
		chunk = chunk .. s .. "=" .. s
		--Value
		if type(v) == "table" then
			chunk = chunk .. TableToString(v, compact)
		elseif type(v) == "string" then
			chunk = chunk .. "\"" .. v .. "\""
		else
			chunk = chunk .. tostring(v)
		end
		--Add separator
		chunk = chunk .. "," .. s
	end
	return ((chunk .. "}"):gsub("," .. s .. "}",  s .. "}"))
end

--DB checkup and fix
local oldData = {}
local function CheckValidity(k, v) --Check the validity of the provided key value pair
	if k == "size" and v <= 0 then return true
	elseif (k == "r" or k == "g" or k == "b" or k == "a") and (v < 0 or v > 1) then return true
	else return false end
end
local function RemoveEmpty(dbToCheck) --Remove all nil and empty items from the table
	if type(dbToCheck) ~= "table" then return end
	for k, v in pairs(dbToCheck) do
		if type(v) == "table" then
			if next(v) == nil then --The subtable is empty
				dbToCheck[k] = nil --Remove the empty subtable
			else
				RemoveEmpty(v)
			end
		elseif v == nil or v == "" or CheckValidity(k, v) then --The value is invalid, empty or doesn't exist
			dbToCheck[k] = nil --Remove the key value pair
		end
	end
end
local function AddMissing(dbToCheck, dbToSample) --Check for and fill in missing data
	if type(dbToCheck) ~= "table" and type(dbToSample) ~= "table" then return end
	if next(dbToSample) == nil then return end --The sample table is empty
	for k, v in pairs(dbToSample) do
		if dbToCheck[k] == nil then --The sample key doesn't exist in the table to check
			if v ~= nil and v ~= "" then
				dbToCheck[k] = v --Add the item if the value is not empty or nil
			end
		else
			AddMissing(dbToCheck[k], dbToSample[k])
		end
	end
end
local function RemoveMismatch(dbToCheck, dbToSample) --Remove unused or outdated data while trying to keep any old data
	if type(dbToCheck) ~= "table" and type(dbToSample) ~= "table" then return end
	if next(dbToCheck) == nil then return end --The table to check is empty
	for k, v in pairs(dbToCheck) do
		if dbToSample[k] == nil then --The checked key doesn't exist in the sample table
			oldData[k] = v --Add the item to the old data to be restored
			dbToCheck[k] = nil --Remove the unneeded item
		else
			RemoveMismatch(dbToCheck[k], dbToSample[k])
		end
	end
end
local function RestoreOldData(dbToSaveTo, dbcToSaveTo) --Restore old data to an account-wide and character-specific DB by matching removed items to known old keys
	-- for k, v in pairs(oldData) do
	-- 	if k == "" then
	-- 		dbToSaveTo. = v
	-- 		oldData.k = nil
	-- 	elseif k == "offsetX" then
	-- 		dbcToSaveTo. = v
	-- 		oldData.k = nil
	-- 	end
	-- end
end

--Find the ID of the font provided
local function GetFontID(fontPath)
	local selectedFont = 0
	for i = 0, #fonts do
		if fonts[i].path == fontPath then
			selectedFont = i
			break
		end
	end
	return selectedFont
end


--[[ OPTIONS SETTERS ]]

--Main frame positioning
local function SavePreset()
	db.position.point, _, _, db.position.offset.x, db.position.offset.y = remXP:GetPoint()
	print(colors.sg .. addon .. ":" .. colors.ly .. " " .. strings.chat.save.response)
end
local function MoveToPreset()
	remXP:ClearAllPoints()
	remXP:SetUserPlaced(false)
	remXP:SetPoint(db.position.point, db.position.offset.x, db.position.offset.y)
	remXP:SetUserPlaced(true)
	print(colors.sg .. addon .. ":" .. colors.ly .. " " .. strings.chat.preset.response)
end
local function DefaultPreset()
	db.position = Clone(dbDefault.position)
	print(colors.sg .. addon .. ":" .. colors.ly .. " " .. strings.chat.reset.response)
	MoveToPreset()
end

---Set the visibility of the main display frame based on the flipped value of the input parameter
---@param visible boolean
local function FlipVisibility(visible)
	if visible then
		remXP:Hide()
	else
		remXP:Show()
	end
end

---Set the size of the main display
---@param height number
local function SetDisplaySize(height)
	--Set dimensions
	height = math.ceil(height) + 2
	local width = height * 3 - 4
	mainDisplay:SetSize(width, height)
end

---Set the backdrop of the main display
---@param enabled boolean Set or remove backdrop
---@param r? number Red (Range: 0 - 1, Default: db.appearance.backdrop.color.r)
---@param g? number Green (Range: 0 - 1, Default: db.appearance.backdrop.color.g)
---@param b? number Blue (Range: 0 - 1, Default: db.appearance.backdrop.color.b)
---@param a? number Opacity (Range: 0 - 1, Default: db.appearance.backdrop.color.a or 1)
local function SetDisplayBackdrop(enabled, r, g, b, a)
	if enabled then
		mainDisplay:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			edgeFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5, edgeSize = 1,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		mainDisplay:SetBackdropColor(
			r or db.appearance.backdrop.color.r,
			g or db.appearance.backdrop.color.g,
			b or db.appearance.backdrop.color.b,
			a or db.appearance.backdrop.color.a or 1
		)
		mainDisplay:SetBackdropBorderColor(1, 1, 1, 0.4)
	else
		mainDisplay:SetBackdrop(nil)
	end
end

---Set the visibility, backdrop, font family, size and color of the main display to the currently saved values
---@param data table DB table to set the main display values from
local function SetDisplayValues(data, characterData)
	--Visibility
	remXP:SetFrameStrata(db.appearance.frameStrata)
	FlipVisibility(characterData.hidden or characterData.mouseover or characterData.disabled)
	--Display
	SetDisplaySize(data.font.size)
	SetDisplayBackdrop(
		data.appearance.backdrop.visible,
		data.appearance.backdrop.color.r,
		data.appearance.backdrop.color.g,
		data.appearance.backdrop.color.b,
		data.appearance.backdrop.color.a
	)
	--Font
	mainDisplayText:SetFont(data.font.family, data.font.size, "THINOUTLINE")
	mainDisplayText:SetTextColor(data.font.color.r, data.font.color.g, data.font.color.b, data.font.color.a)
end


--[[ CHAT CONTROL ]]

--Chat control utilities
local function ToggleState(enabled)
	if enabled then
		return "ON"
	else
		return "OFF"
	end
	return ""
end
local function PrintStatus()
	if UnitLevel("player") == maxLevel then
		print(strings.chat.status.disabled:gsub("#ADDON", colors.p .. addon .. colors.b) .. colors.fb .. " " .. strings.chat.status.max:gsub("#MAX", maxLevel) .. colors.b .. ".")
	else
		local status = ""
		if mainDisplayText:IsShown() then
			status = status .. strings.chat.status.visible:gsub("#ADDON", colors.p .. addon .. colors.b)
		else
			status = status .. strings.chat.status.hidden:gsub("#ADDON", colors.p .. addon .. colors.b)
		end
		-- status = status .. colors.fb .. " (" .. strings.chat.status.toggle:gsub("#STATE", colors.fp .. ToggleState(dbc.hidden))
		-- status = status .. colors.fb .. ", " .. strings.chat.status.mouseover:gsub("#STATE", colors.fp .. ToggleState(dbc.mouseover)) .. colors.fb .. ")" .. colors.b .. "."
	end
end
local function PrintInfo()
	print(colors.b .. strings.chat.help.thanks:gsub("#ADDON", colors.p .. addon .. colors.b))
	PrintStatus()
	print(colors.fb .. strings.chat.help.hint:gsub("#HELP_COMMAND", colors.fp .. strings.chat.keyword .. " " .. strings.chat.help.command .. colors.fb))
	print(colors.fb .. strings.chat.help.move:gsub("#SHIFT", colors.fp .. strings.keys.shift .. colors.fb):gsub("#ADDON", addon))
end
local function PrintCommands()
	print(colors.p .. addon .. colors.b .. " ".. strings.chat.help.list .. ":")
	--Index the commands (skipping the help command) and put replacement code segments in place
	local commands = {
		[0] = {
			command = strings.chat.options.command,
			description = strings.chat.options.description:gsub("#ADDON", addon)
		},
		[1] = {
			command = strings.chat.save.command,
			description = strings.chat.save.description
		},
		[2] = {
			command = strings.chat.preset.command,
			description = strings.chat.preset.description
		},
		[3] = {
			command = strings.chat.reset.command,
			description = strings.chat.reset.description
		},
		[4] = {
			command = strings.chat.toggle.command,
			description = strings.chat.toggle.description:gsub("#HIDDEN", colors.fp .. (dbc.hidden and strings.chat.toggle.hidden or strings.chat.toggle.shown) .. colors.fb)
		},
		[5] = {
			command = strings.chat.mouseover.command,
			description = strings.chat.mouseover.description:gsub("#STATE", colors.fp .. (dbc.mouseover and strings.chat.mouseover.enabled or strings.chat.mouseover.disabled) .. colors.fb)
		},
		[6] = {
			command = strings.chat.size.command,
			description =  strings.chat.size.description:gsub("#SIZE_DEFAULT", colors.fp .. strings.chat.size.command .. " " .. dbDefault.font.size .. colors.fb)
		},
	}
	--Print the list
	for i = 0, #commands do
		print("    " .. colors.fp .. strings.chat.keyword .. " " .. commands[i].command .. colors.fb .. " - " .. commands[i].description)
	end
end

--Slash command handler
SLASH_REMXP1 = strings.chat.keyword
function SlashCmdList.REMXP(line)
	local command, parameter = strsplit(" ", line)
	if command == strings.chat.help.command then
		PrintCommands()
	elseif command == strings.chat.options.command then
		InterfaceOptionsFrame_OpenToCategory(addon)
		InterfaceOptionsFrame_OpenToCategory(addon) --Load twice to make sure the proper page and category is loaded
	elseif command == strings.chat.save.command then
		SavePreset()
	elseif command == strings.chat.preset.command then
		MoveToPreset()
	elseif command == strings.chat.reset.command then
		DefaultPreset()
	elseif command == strings.chat.toggle.command then
		FlipVisibility(not dbc.hidden or dbc.disabled)
		dbc.hidden = not dbc.hidden
		dbc.mouseover = false
		--Update the GUI option in case it was open
		-- options.appearance.hidden:SetChecked(db.appearance.hidden)
		--Response
		print(colors.sg .. addon .. ": " .. colors.ly .. strings.chat.toggle.response:gsub("#HIDDEN", dbc.hidden and strings.chat.toggle.shown or strings.chat.toggle.hidden))
		PrintStatus()
	elseif command == strings.chat.mouseover.command then
		FlipVisibility(not dbc.mouseover or dbc.disabled)
		dbc.mouseover = not dbc.mouseover
		dbc.hidden = false
		--Update the GUI option in case it was open
		-- options.appearance.hidden:SetChecked(db.appearance.hidden)
		--Response
		print(colors.sg .. addon .. ": " .. colors.ly .. strings.chat.mouseover.response:gsub("#STATE", dbc.hidden and strings.chat.mouseover.shown or strings.chat.mouseover.hidden))
		PrintStatus()
	elseif command == strings.chat.size.command then
		local size = tonumber(parameter)
		if size ~= nil then
			db.font.size = size
			mainDisplayText:SetFont(db.font.family, db.font.size, "THINOUTLINE")
			SetDisplaySize(size)
			--Update the GUI option in case it was open
			-- options.font.size:SetValue(size)
			--Response
			print(colors.p .. addon .. ": " .. colors.b .. strings.chat.size.response:gsub("#VALUE", size))
		else
			--Error
			print(colors.p .. addon .. ": " .. colors.b .. strings.chat.size.unchanged)
			print(colors.fb .. strings.chat.size.error:gsub("#SIZE_DEFAULT", colors.fp .. strings.chat.size.command .. " " .. dbDefault.font.size .. colors.fb))
		end
		PrintStatus()
	else
		PrintInfo()
	end
end


--[[ DISPLAY FRAME SETUP ]]

--Set frame parameters
local function SetUpMainDisplayFrame()
	--Main frame
	remXP:SetToplevel(true)
	remXP:SetSize(64, 10)
	if not remXP:IsUserPlaced() then
		remXP:ClearAllPoints()
		remXP:SetPoint(startPosition.point, startPosition.offset.x, startPosition.offset.y)
		remXP:SetUserPlaced(true)
	end
	--Display
	SetDisplaySize(db.font.size)
	mainDisplay:SetPoint("CENTER")
	--Text
	mainDisplayText:SetPoint("CENTER") --TODO: Add font offset option to fine-tune the position (AND/OR, ad pre-tested offsets to keep each font in the center)
	--Visual elements
	SetDisplayValues(db, dbc)
end

--Making the frame moveable
remXP:SetMovable(true)
mainDisplay:SetScript("OnMouseDown", function()
	if (IsShiftKeyDown() and not remXP.isMoving) then
		remXP:StartMoving()
		remXP.isMoving = true
	end
end)
mainDisplay:SetScript("OnMouseUp", function()
	if (remXP.isMoving) then
		remXP:StopMovingOrSizing()
		remXP.isMoving = false
	end
end)

--Toggling view on mouseover
remXP:SetScript('OnEnter', function()
	if dbc.mouseover then
		mainDisplayText:Show()
	end
end)
remXP:SetScript('OnLeave', function()
	if dbc.mouseover then
		mainDisplayText:Hide()
	end
end)

--Hide during Pet Battle
function remXP:PET_BATTLE_OPENING_START() mainDisplay:Hide() end
function remXP:PET_BATTLE_CLOSE() mainDisplay:Show() end


--[[ INITIALIZATION ]]

local function LoadDBs()
	--First load
	if RemainingXPDB == nil or RemainingXPDBC == nil then
		RemainingXPDB = dbDefault
		RemainingXPDBC = dbcDefault
		PrintInfo()
	end
	--Load the DBs
	db = RemainingXPDB --account-wide
	dbc = RemainingXPDBC --character-specific
	--DB checkup & fix
	RemoveEmpty(db)
	RemoveEmpty(dbc)
	AddMissing(db, dbDefault)
	AddMissing(dbc, dbcDefault)
	RemoveMismatch(db, dbDefault)
	RemoveMismatch(dbc, dbcDefault)
	RestoreOldData(db, dbc)
end
function remXP:ADDON_LOADED(name)
	if name ~= addonNameSpace then return end
	remXP:UnregisterEvent("ADDON_LOADED")
	--Load & check the DBs
	LoadDBs()
	--Set up the main frame & text
	SetUpMainDisplayFrame()
	--Set up the interface options
	-- LoadInterfaceOptions()
	--Visibility notice
	if not remXP:IsShown() then PrintStatus() end
end


--[[ DISPLAY UPDATE ]]

--Recalculate the XP value and update the displayed text
local function UpdateXP()
	--Calculate
	local xp = UnitXPMax("player") - UnitXP("player")
	--Format
	local leftover
	while true do
		xp, leftover = string.gsub(xp, "^(-?%d+)(%d%d%d)", '%1' .. strings.decimal .. '%2')
		if (leftover == 0) then
			break
		end
	end
	--Display
	mainDisplayText:SetText(xp)
end

--Disable the frame and display if the player is max level
local function CheckMax(level)
	if level == maxLevel then
		remXP:Hide()
		dbc.disabled = true
	else
		dbc.disabled = false
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
		print(strings.chat.notify.disabled:gsub("#ADDON", colors.p .. addon .. colors.b):gsub(
			"#REASON", colors.fb .. strings.chat.notify.max:gsub("#MAX", maxLevel) .. colors.b
		) .. " " .. strings.chat.notify.congrats)
	end
end