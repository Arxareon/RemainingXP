--[[ ADDON INFO ]]

--Addon namespace string & table
local addonNameSpace, ns = ...

--Addon display name
local _, addonTitle = GetAddOnInfo(addonNameSpace)


--[[ RESOURCES ]]

---@class WidgetToolbox
local wt = ns.WidgetToolbox

--Clean up the addon title
addonTitle = wt.Clear(addonTitle):gsub("^%s*(.-)%s*$", "%1")


--[[ DATA TABLES ]]

--[ Addon DBs ]

--References
local db --Account-wide options
local dbc --Character-specific options
local cs --Cross-session account-wide data
local csc --Cross-session character-specific data

--Default values
local dbDefault = {
	display = {
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -120, },
		},
		visibility = {
			frameStrata = "HIGH",
			fade = {
				enabled = false,
				text = 1,
				background = 0.6,
			},
		},
		text = {
			visible = true,
			details = false,
			font = {
				family = ns.fonts[0].path,
				size = 11,
				color = { r = 1, g = 1, b = 1, a = 1 },
			},
		},
		background = {
			visible = true,
			size = { width = 116, height = 16, },
			colors = {
				bg = { r = 0, g = 0, b = 0, a = 0.8 },
				xp = { r = 0.8, g = 0.1, b = 0.8, a = 0.8 },
				rested = { r = 0.1, g = 0.5, b = 1, a = 0.8 },
				border = { r = 1, g = 1, b = 1, a = 0.4 },
			},
		},
	},
	enhancement = {
		enabled = true,
		keep = false,
		remaining = false,
	},
	removals = {
		statusBars = false,
	},
	notifications = {
		xpGained = true,
		restedXP = {
			gained = true,
			significantOnly = true,
			accumulated = true,
		},
		lvlUp = {
			congrats = true,
			timePlayed = false,
		},
		statusNotice = {
			enabled = true,
			maxReminder = true,
		},
	},
}
local dbcDefault = {
	hidden = false,
	disabled = false,
}

--[ Preset Data ]

local presets = {
	[0] = {
		name = ns.strings.misc.custom, --Custom
		data = {
			position = dbDefault.display.position,
			visibility = {
				frameStrata = dbDefault.display.visibility.frameStrata,
			},
			background = {
				visible = dbDefault.display.background.visible,
				size = dbDefault.display.background.size,
			},
		},
	},
	[1] = {
		name = ns.strings.options.display.quick.presets.list[0], --XP Bar Replacement
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = 0, y = 40.25, },
			},
			visibility = {
				frameStrata = "HIGH"
			},
			background = {
				visible = true,
				size = { width = 1014, height = 10, },
			},
		},
	},
	[2] = {
		name = ns.strings.options.display.quick.presets.list[1], --XP Bar Left Text
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = -485, y = 40.25, },
			},
			visibility = {
				frameStrata = "HIGH"
			},
			background = {
				visible = false,
				size = { width = 64, height = 10, },
			},
		},
	},
	[3] = {
		name = ns.strings.options.display.quick.presets.list[2], --XP Bar Right Text
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = 485, y = 40.25, },
			},
			visibility = {
				frameStrata = "HIGH"
			},
			background = {
				visible = false,
				size = { width = 64, height = 10, },
			},
		},
	},
	[4] = {
		name = ns.strings.options.display.quick.presets.list[3], --Player Frame Bar Above
		data = {
			position = {
				anchor = "TOPLEFT",
				offset = { x = 92, y = -10, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 122, height = 16, },
			},
		},
	},
	[5] = {
		name = ns.strings.options.display.quick.presets.list[4], --Player Frame Text Under
		data = {
			position = {
				anchor = "TOPLEFT",
				offset = { x = 0, y = -85, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = false,
				size = { width = 104, height = 16, },
			},
		},
	},
	[6] = {
		name = ns.strings.options.display.quick.presets.list[7], --Bottom-Left Chunky Bar
		data = {
			position = {
				anchor = "BOTTOMLEFT",
				offset = { x = 63, y = 10, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 240, height = 34, },
			},
		},
	},
	[7] = {
		name = ns.strings.options.display.quick.presets.list[9], --Bottom-Right Chunky Bar
		data = {
			position = {
				anchor = "BOTTOMRIGHT",
				offset = { x = -63, y = 10, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 240, height = 34, },
			},
		},
	},
	[8] = {
		name = ns.strings.options.display.quick.presets.list[8], --Top-Center Long Bar
		data = {
			position = {
				anchor = "TOP",
				offset = { x = 0, y = 3, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 980, height = 8, },
			},
		},
	},
}

--Add custom preset to DB
dbDefault.customPreset = wt.Clone(presets[0].data)


--[[ FRAMES & EVENTS ]]

--[ Main XP Display ]

--Creating frames
local remXP = CreateFrame("Frame", addonNameSpace, UIParent) --Main addon frame
local mainDisplay = CreateFrame("Frame", remXP:GetName() .. "MainDisplay", remXP, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayXP = CreateFrame("Frame", mainDisplay:GetName() .. "XP", mainDisplay, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayRested = CreateFrame("Frame", mainDisplay:GetName() .. "Rested", mainDisplay, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayOverlay = CreateFrame("Frame", mainDisplay:GetName() .. "Text", mainDisplay, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayText = mainDisplayOverlay:CreateFontString(mainDisplay:GetName() .. "Value", "OVERLAY")

--Registering events
remXP:RegisterEvent("ADDON_LOADED")
remXP:RegisterEvent("PLAYER_ENTERING_WORLD")
remXP:RegisterEvent("QUEST_LOG_UPDATE")
remXP:RegisterEvent("PLAYER_XP_UPDATE")
remXP:RegisterEvent("PLAYER_LEVEL_UP")
remXP:RegisterEvent("UPDATE_EXHAUSTION")
remXP:RegisterEvent("PLAYER_UPDATE_RESTING")

--Event handler
remXP:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)

--[ Integrated Display ]

--Create frames
local integratedDisplay = CreateFrame("Frame", remXP:GetName() .. "IntegratedDisplay", UIParent)
local integratedDisplayText = integratedDisplay:CreateFontString(integratedDisplay:GetName() .. "Text", "OVERLAY", "TextStatusBarText")

--[ Custom Tooltip ]

ns.tooltip = wt.CreateGameTooltip(addonNameSpace)


--[[ UTILITIES ]]

--Current max level
local max = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

---Find the ID of the font provided
---@param fontPath string
---@return integer
local function GetFontID(fontPath)
	local id = 0
	for i = 0, #ns.fonts do
		if ns.fonts[i].path == fontPath then
			id = i
			break
		end
	end
	return id
end

--[ DB Management ]

--Check the validity of the provided key value pair
local function CheckValidity(k, v)
	if type(v) == "number" then
		--Non-negative
		if k == "size" then return v > 0 end
		--Range constraint: 0 - 1
		if k == "r" or k == "g" or k == "b" or k == "a" or k == "text" or k == "background" then return v >= 0 and v <= 1 end
	end return true
end

---Restore old data to an account-wide and character-specific DB by matching removed items to known old keys
---@param data table
---@param characterData table
---@param recoveredData? table
---@param recoveredCharacterData? table
local function RestoreOldData(data, characterData, recoveredData, recoveredCharacterData)
	if recoveredData ~= nil then for k, v in pairs(recoveredData) do
		if k == "customPreset.position.point" then data.customPreset.position.anchor = v
		elseif k == "position.point" or k == "display.position.point" then data.display.position.anchor = v
		elseif k == "appearance.frameStrata" then data.display.visibility.frameStrata = v
		elseif k == "appearance.backdrop.visible" then data.display.background.visible = v
		elseif k == "appearance.backdrop.color.r" then data.display.background.colors.bg.r = v
		elseif k == "appearance.backdrop.color.g" then data.display.background.colors.bg.g = v
		elseif k == "appearance.backdrop.color.b" then data.display.background.colors.bg.b = v
		elseif k == "appearance.backdrop.color.a" then data.display.background.colors.bg.a = v
		elseif k == "font.family" then data.display.text.font.family = v
		elseif k == "font.size" then data.display.text.font.size = v
		elseif k == "font.color.r" then data.display.text.font.color.r = v
		elseif k == "font.color.g" then data.display.text.font.color.g = v
		elseif k == "font.color.b" then data.display.text.font.color.b = v
		elseif k == "font.color.a" then data.display.text.font.color.a = v
		elseif k == "notifications.maxReminder" then data.notifications.statusNotice.maxReminder = v
		elseif k == "notifications.maxReminder" then data.notifications.statusNotice.maxReminder = v
		-- elseif k == "" then data. = v
		end
	end end
	if recoveredCharacterData ~= nil then for k, v in pairs(recoveredCharacterData) do
		if k == "mouseover" then data.display.visibility.fade.enabled = v
	-- 	elseif k == "" then characterData. = v
		end
	end end
end

---Check the display visibility values
---@param data table
---@param characterData table
local function VisibilityCheckup(data, characterData)
	if not data.display.text.visible and not data.display.background.visible then
		data.display.text.visible = true
		data.display.background.visible = true
		characterData.hidden = true
	end
end

---Load the addon databases from the SavedVariables tables specified in the TOC
---@return boolean firstLoad True is returned when the addon SavedVariables tabled didn't exist prior to loading, false otherwise
local function LoadDBs()
	local firstLoad = false
	--First load
	if RemainingXPDB == nil then
		RemainingXPDB = wt.Clone(dbDefault)
		firstLoad = true
	end
	if RemainingXPDBC == nil then RemainingXPDBC = wt.Clone(dbcDefault) end
	if RemainingXPCS == nil then RemainingXPCS = {} end
	if RemainingXPCSC == nil then RemainingXPCSC = {} end
	--Load the DBs
	db = wt.Clone(RemainingXPDB) --Account-wide options DB copy
	dbc = wt.Clone(RemainingXPDBC) --Character-specific options DB copy
	cs = RemainingXPCSC --Cross-session account-wide data direct reference
	csc = RemainingXPCSC --Cross-session character-specific data direct reference
	--DB checkup & fix
	wt.RemoveEmpty(db, CheckValidity)
	wt.RemoveEmpty(dbc, CheckValidity)
	wt.AddMissing(db, dbDefault)
	wt.AddMissing(dbc, dbcDefault)
	RestoreOldData(db, dbc, wt.RemoveMismatch(db, dbDefault), wt.RemoveMismatch(dbc, dbcDefault))
	VisibilityCheckup(db, dbc)
	--Apply any potential fixes to the SavedVariables DBs
	RemainingXPDB = wt.Clone(db)
	RemainingXPDBC = wt.Clone(dbc)
	return firstLoad
end

--[ XP Update ]

---Initiate or remove the cross-session variable storing the Rested XP accumulation while inside a Rested Area
---@param enabled boolean
local function SetRestedAccumulation(enabled)
	if not IsResting() then
		--Remove cross-session variable
		csc.xp.accumulatedRested = nil
	else
		--Initiate cross-session variable
		if csc.xp.accumulatedRested == nil then csc.xp.accumulatedRested = 0 end
		--Chat notification
		if enabled then
			print(
				wt.Color(
					ns.strings.chat.notifications.restedXPAccumulated.feels, ns.colors.purple[0]
				) .. " " .. wt.Color(
					ns.strings.chat.notifications.restedXPAccumulated.resting, ns.colors.blue[0]
				)
			)
		end
	end
end

---Update the XP values, calculate and return gained values and old values
---@return integer gainedXP
---@return integer gainedRestedXP
---@return integer oldXP
---@return integer oldRestedXP
---@return integer oldNeededXP
local function UpdateXPValues()
	--Save old XP values
	local oldXP = csc.xp.current or UnitXP("player")
	local oldNeededXP = csc.xp.needed or UnitXPMax("player")
	local oldRestedXP = csc.xp.rested or GetXPExhaustion() or 0
	--Update the XP values
	csc.xp.current = UnitXP("player")
	csc.xp.needed = UnitXPMax("player")
	csc.xp.rested = GetXPExhaustion() or 0
	csc.xp.remaining = csc.xp.needed - csc.xp.current
	--Calculate the gained XP values
	local gainedXP = oldXP < csc.xp.current and csc.xp.current - oldXP or oldNeededXP - oldXP + csc.xp.current
	local gainedRestedXP = csc.xp.rested - oldRestedXP
	--Accumulating Rested XP
	if gainedRestedXP > 0 and csc.xp.accumulatedRested ~= nil and IsResting() then csc.xp.accumulatedRested = csc.xp.accumulatedRested + gainedRestedXP end
	return gainedXP, gainedRestedXP, oldXP, oldRestedXP, oldNeededXP
end

--Update the position, width and visibility of the main XP display bar segments with the current XP values
local function UpdateXPDisplaySegments()
	--Current XP segment
	mainDisplayXP:SetWidth(csc.xp.current / csc.xp.needed * mainDisplay:GetWidth())
	--Rested XP segment
	if csc.xp.rested == 0 then mainDisplayRested:Hide() else
		mainDisplayRested:Show()
		if mainDisplayXP:GetWidth() == 0 then mainDisplayRested:SetPoint("LEFT") else mainDisplayRested:SetPoint("LEFT", mainDisplayXP, "RIGHT") end
		mainDisplayRested:SetWidth((csc.xp.current + csc.xp.rested > csc.xp.needed and csc.xp.needed - csc.xp.current or csc.xp.rested) / csc.xp.needed * mainDisplay:GetWidth())
	end
end

--Update the main XP display bar segments and text with the current XP values
local function UpdateXPDisplayText()
	local text = ""
	if db.display.text.details then
		text = wt.FormatThousands(csc.xp.current) .. " / " .. wt.FormatThousands(csc.xp.needed) .. " (" .. wt.FormatThousands(csc.xp.remaining) .. ")"
		text = text .. (csc.xp.rested > 0 and " + " .. wt.FormatThousands(csc.xp.rested) .. " (" .. wt.FormatThousands(
			math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100
		) .. "%)" or "")
	else
		text = wt.FormatThousands(csc.xp.remaining)
	end
	mainDisplayText:SetText(text)
end

---Update the default XP bar enhancement display with the current XP values
---@param remaining boolean Whether or not only the remaining XP should be visible when the text is always shown
local function UpdateIntegratedDisplay(remaining)
	if not integratedDisplay:IsVisible() or not integratedDisplayText:IsVisible() then return end
	if remaining and not integratedDisplay:IsMouseOver() then
		integratedDisplayText:SetText(wt.FormatThousands(csc.xp.remaining))
	else
		integratedDisplayText:SetText(
			ns.strings.xpBar.text:gsub(
				"#CURRENT", wt.FormatThousands(csc.xp.current)
			):gsub(
				"#NEEDED", wt.FormatThousands(csc.xp.needed)
			):gsub(
				"#REMAINING", wt.FormatThousands(csc.xp.remaining)
			) .. (
				csc.xp.rested > 0 and " + " .. ns.strings.xpBar.rested:gsub(
					"#RESTED", wt.FormatThousands(csc.xp.rested)
				):gsub(
					"#PERCENT", wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100) .. "%%"
				) or ""
			)
		)
	end
end

---Assemble the detailed text lines for xp tooltip
---@return table textLines Table containing text lines to be added to the tooltip [indexed, 0-based]
--- - **text** string ― Text to be added to the line
--- - **font**? string | FontObject *optional* ― The FontObject to set for this line [Default: GameTooltipTextSmall]
--- - **color**? table *optional* ― Table containing the RGB values to color this line with [Default: HIGHLIGHT_FONT_COLOR (white)]
--- 	- **r** number ― Red [Range: 0 - 1]
--- 	- **g** number ― Green [Range: 0 - 1]
--- 	- **b** number ― Blue [Range: 0 - 1]
--- - **wrap**? boolean *optional* ― Allow this line to be wrapped [Default: true]
local function GetXPTooltipDetails()
	local textLines = {
		[0] = { text = ns.strings.xpTooltip.text, },
		--Current XP
		[1] = {
			text = "\n" .. ns.strings.xpTooltip.current:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.current), ns.colors.purple[1])
			),
			color = ns.colors.purple[0],
		},
		[2] = {
			text = ns.strings.xpTooltip.percentTotal:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.current / csc.xp.needed * 10000) / 100) .. "%%", ns.colors.purple[1])
			),
			color = ns.colors.purple[2],
		},
		--Remaining XP
		[3] = {
			text = "\n" .. ns.strings.xpTooltip.remaining:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.remaining), ns.colors.rose[1])
			),
			color = ns.colors.rose[0],
		},
		[4] = {
			text = ns.strings.xpTooltip.percentTotal:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor((csc.xp.remaining / csc.xp.needed) * 10000) / 100) .. "%%", ns.colors.rose[1])
			),
			color = ns.colors.rose[2],
		},
		--Max needed XP
		[5] = {
			text = "\n" .. ns.strings.xpTooltip.needed:gsub(
				"#DATA", wt.Color(ns.strings.xpTooltip.valueNeeded:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(csc.xp.needed), ns.colors.peach[1])
				):gsub(
					"#LEVEL", wt.Color(UnitLevel("player"), ns.colors.peach[1])
				), ns.colors.peach[2])
			),
			color = ns.colors.peach[0],
		},
		--Playtime --TODO: Add time played info
		-- [6] = {
		-- 	text = "\n" .. ns.strings.xpTooltip.timeSpent:gsub("#TIME", "?") .. " (Soon™)",
		-- },
	}
	--Current Rested XP
	if csc.xp.rested > 0 then
		textLines[#textLines + 1] = {
			text = "\n" .. ns.strings.xpTooltip.rested:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.rested), ns.colors.blue[1])
			),
			color = ns.colors.blue[0],
		}
		textLines[#textLines + 1] = {
			text = ns.strings.xpTooltip.percentRemaining:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100) .. "%%", ns.colors.blue[1])
			),
			color = ns.colors.blue[2],
		}
		--Description
		textLines[#textLines + 1] = {
			text = "\n" .. ns.strings.xpTooltip.restedStatus:gsub(
				"#PERCENT", wt.Color("200%%", ns.colors.blue[1])
			),
			color = ns.colors.blue[2],
		}
	end
	--Resting status
	if IsResting() then
		textLines[#textLines + 1] = {
			text = "\n" .. ns.strings.chat.notifications.restedXPAccumulated.feels,
			color = ns.colors.blue[0],
		}
	end
	--Accumulated Rested XP
	if (csc.xp.accumulatedRested or 0) > 0 then
		textLines[#textLines + 1] = {
			text = ns.strings.xpTooltip.accumulated:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.accumulatedRested or 0), ns.colors.blue[1])
			),
			color = ns.colors.blue[2],
		}
	end
	--Hints
	textLines[#textLines + 1] = {
		text = "\n" .. ns.strings.xpTooltip.hintOptions,
		font = GameFontNormalTiny,
		color = ns.colors.grey[0],
	}
	if mainDisplay:IsMouseOver() then
		textLines[#textLines + 1] = {
			text = ns.strings.xpTooltip.hintMove:gsub("#SHIFT", ns.strings.keys.shift),
			font = GameFontNormalTiny,
			color = ns.colors.grey[0],
		}
	end
	return textLines
end

--Update the text of the xp tooltip
local function UpdateXPTooltip()
	if not integratedDisplay:IsMouseOver() and not mainDisplay:IsMouseOver() then return end
	wt.UpdateTooltip({
		parent = ns.tooltip:GetOwner(),
		tooltip = ns.tooltip,
		title = ns.strings.xpTooltip.title,
		lines = GetXPTooltipDetails(),
		flipColors = true,
		anchor = "ANCHOR_PRESERVE",
	})
end

--[ Main XP Display ]

---Fade the main display in or out
---@param state? boolean Decides whether to fade our or fade in the display [Default: db.display.visibility.fade.enabled]
---@param textColor? table Table containing the text color values [Default: db.display.text.font.color]
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity [Range: 0 - 1, Default: 1]
---@param bgColor? table Table containing the backdrop background color values [Default: db.display.background.bg]
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity [Range: 0 - 1, Default: 1]
---@param xpColor? table Table containing the backdrop background color values [Default: db.display.background.xp]
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity [Range: 0 - 1, Default: 1]
---@param restedColor? table Table containing the backdrop background color values [Default: db.display.background.rested]
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity [Range: 0 - 1, Default: 1]
---@param borderColor? table Table containing the backdrop border color values [Default: db.display.background.border]
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity [Range: 0 - 1, Default: 1]
---@param textIntensity? number Value determining how much to fade out the text [Range: 0 - 1, Default: db.display.visibility.fade.text]
---@param backdropIntensity? number Value determining how much to fade out the backdrop elements [Range: 0 - 1, Default: db.display.visibility.fade.background]
local function Fade(state, textColor, bgColor, borderColor, xpColor, restedColor, textIntensity, backdropIntensity)
	if state == nil then state = db.display.visibility.fade.enabled end
	--Text
	local r, g, b, a = wt.UnpackColor(textColor or db.display.text.font.color)
	mainDisplayText:SetTextColor(r, g, b, (a or 1) * (state and 1 - (textIntensity or db.display.visibility.fade.text) or 1))
	--Background
	if db.display.background.visible then
		backdropIntensity = backdropIntensity or db.display.visibility.fade.background
		--Backdrop
		r, g, b, a = wt.UnpackColor(bgColor or db.display.background.colors.bg)
		mainDisplay:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))
		--Current XP segment
		r, g, b, a = wt.UnpackColor(xpColor or db.display.background.colors.xp)
		mainDisplayXP:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))
		--Rested XP segment
		r, g, b, a = wt.UnpackColor(restedColor or db.display.background.colors.rested)
		mainDisplayRested:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))
		--Border & Text holder
		r, g, b, a = wt.UnpackColor(borderColor or db.display.background.colors.border)
		mainDisplayOverlay:SetBackdropBorderColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))
	end
end

---Set the size of the main display elements
---@param width number
---@param height number
local function ResizeDisplay(width, height)
	--Background
	mainDisplay:SetSize(width, height)
	--XP bar segments
	mainDisplayXP:SetHeight(height)
	mainDisplayRested:SetHeight(height)
	UpdateXPDisplaySegments()
	--Border & Text holder
	mainDisplayOverlay:SetSize(width, height)
end

---Set the backdrop of the main display elements
---@param enabled boolean Whether to add or remove the backdrop elements of the main display
---@param backdropColors table Table containing the backdrop color values of all main display elements
--- - **bg** table
--- 	- **r** number ― Red (Range: 0 - 1)
--- 	- **g** number ― Green (Range: 0 - 1)
--- 	- **b** number ― Blue (Range: 0 - 1)
--- 	- **a** number ― Opacity (Range: 0 - 1)
--- - **xp** table
--- 	- **r** number ― Red (Range: 0 - 1)
--- 	- **g** number ― Green (Range: 0 - 1)
--- 	- **b** number ― Blue (Range: 0 - 1)
--- 	- **a** number ― Opacity (Range: 0 - 1)
--- - **rested** table
--- 	- **r** number ― Red (Range: 0 - 1)
--- 	- **g** number ― Green (Range: 0 - 1)
--- 	- **b** number ― Blue (Range: 0 - 1)
--- 	- **a** number ― Opacity (Range: 0 - 1)
--- - **border** table
--- 	- **r** number ― Red (Range: 0 - 1)
--- 	- **g** number ― Green (Range: 0 - 1)
--- 	- **b** number ― Blue (Range: 0 - 1)
--- 	- **a** number ― Opacity (Range: 0 - 1)
local function SetDisplayBackdrop(enabled, backdropColors)
	if not enabled then
		mainDisplay:SetBackdrop(nil)
		mainDisplayXP:SetBackdrop(nil)
		mainDisplayRested:SetBackdrop(nil)
		mainDisplayOverlay:SetBackdrop(nil)
	else
		--Background
		mainDisplay:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		mainDisplay:SetBackdropColor(wt.UnpackColor(backdropColors.bg))
		--Current XP segment
		mainDisplayXP:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		mainDisplayXP:SetBackdropColor(wt.UnpackColor(backdropColors.xp))
		--Rested XP segment
		mainDisplayRested:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		mainDisplayRested:SetBackdropColor(wt.UnpackColor(backdropColors.rested))
		--Border & Text holder
		mainDisplayOverlay:SetBackdrop({
			edgeFile = "Interface/ChatFrame/ChatFrameBackground",
			edgeSize = 1,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		mainDisplayOverlay:SetBackdropBorderColor(wt.UnpackColor(backdropColors.border))
	end
end

---Set the visibility, backdrop, font family, size and color of the main display to the currently saved values
---@param data table Account-wide data table to set the main display values from
---@param characterData table Character-specific data table to set the main display values from
local function SetDisplayValues(data, characterData)
	--Visibility
	remXP:SetFrameStrata(data.display.visibility.frameStrata)
	wt.SetVisibility(remXP, not (characterData.hidden or characterData.disabled))
	--Display
	ResizeDisplay(data.display.background.size.width, data.display.background.size.height)
	SetDisplayBackdrop(data.display.background.visible, data.display.background.colors)
	--Font & text
	mainDisplayText:SetFont(data.display.text.font.family, data.display.text.font.size, "THINOUTLINE")
	mainDisplayText:SetTextColor(wt.UnpackColor(data.display.text.font.color))
	--Fade
	Fade(data.display.visibility.fade.enabled)
end

--[ Integrated Display ]

---Set the visibility of the integrated display text
---@param keep boolean Whether or not the text is set to be always shown
---@param remaining boolean Whether or not only the remaining XP should be visible when the text is always shown
local function SetIntegrationTextVisibility(keep, remaining)
	if keep then
		integratedDisplayText:Show()
		UpdateIntegratedDisplay(remaining)
	else
		integratedDisplayText:Hide()
	end
end

---Set the visibility of the integrated display frame
---@param enabled boolean Whether or not the default XP bar integration is enabled
---@param keep boolean Whether or not the text is set to be always shown
---@param remaining boolean Whether or not only the remaining XP should be visible when the text is always shown
---@param cvar boolean Whether or not to turn off the always shown property of the default XP bar text if false
---@param notice boolean Whether or not to show a reload notice when the always shown property of the default XP bar text is changed if true
local function SetIntegrationVisibility(enabled, keep, remaining, cvar, notice)
	if enabled and not dbc.disabled then
		integratedDisplay:Show()
		SetIntegrationTextVisibility(keep, remaining)
		--Turning off the always shown property of the default XP bar text
		if cvar and C_CVar.GetCVarBool("xpBarText") then
			C_CVar.SetCVar("xpBarText", 0)
			--Reload notice
			if notice then
				print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.integration.notice, ns.colors.blue[0]))
				wt.CreateReloadNotice()
			end
		end
	else integratedDisplay:Hide() end
end


--[[ INTERFACE OPTIONS ]]

--Options frame references
local options = {
	about = {},
	presets = {},
	position = {},
	visibility = {
		fade = {},
	},
	background = {
		colors = {},
		size = {},
	},
	text = {
		font = {},
	},
	enhancement = {},
	removals = {},
	notifications = {},
	backup = {},
}

--[ Options Widgets ]

--Main page
local function CreateOptionsShortcuts(parentFrame)
	--Button: Display page
	local display = wt.CreateButton({
		parent = parentFrame,
		name = "DisplayPage",
		title = ns.strings.options.display.title,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.description:gsub("#ADDON", addonTitle), }, } },
		position = { offset = { x = 10, y = -30 } },
		size = { width = 120, },
		events = { OnClick = function() options.displayOptions.open() end, },
	})
	--Button: Integration page
	local integration = wt.CreateButton({
		parent = parentFrame,
		name = "IntegrationPage",
		title = ns.strings.options.integration.title,
		tooltip = { lines = { [0] = { text = ns.strings.options.integration.description:gsub("#ADDON", addonTitle), }, } },
		position = {
			relativeTo = display,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		size = { width = 120, },
		events = { OnClick = function() options.integrationOptions.open() end, },
	})
	--Button: Notifications page
	wt.CreateButton({
		parent = parentFrame,
		name = "NotificationsPage",
		title = ns.strings.options.events.title,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.description:gsub("#ADDON", addonTitle), }, } },
		position = {
			relativeTo = integration,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		size = { width = 120, },
		events = { OnClick = function() options.notificationsOptions.open() end, },
	})
	--Button: Advanced page
	wt.CreateButton({
		parent = parentFrame,
		name = "AdvancedPage",
		title = ns.strings.options.advanced.title,
		tooltip = { lines = { [0] = { text = ns.strings.options.advanced.description:gsub("#ADDON", addonTitle), }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -30 }
		},
		size = { width = 120, },
		events = { OnClick = function() options.advancedOptions.open() end, },
	})
end
local function CreateAboutInfo(parentFrame)
	--Text: Version
	local version = wt.CreateText({
		parent = parentFrame,
		name = "Version",
		position = { offset = { x = 16, y = -33 } },
		width = 84,
		text = ns.strings.options.main.about.version:gsub("#VERSION", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Version"), "FFFFFFFF")),
		justify = "LEFT",
		template = "GameFontNormalSmall",
	})
	--Text: Date
	local date = wt.CreateText({
		parent = parentFrame,
		name = "Date",
		position = {
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 102,
		text = ns.strings.options.main.about.date:gsub(
			"#DATE", WrapTextInColorCode(ns.strings.misc.date:gsub(
				"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
			):gsub(
				"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
			):gsub(
				"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
			), "FFFFFFFF")
		),
		justify = "LEFT",
		template = "GameFontNormalSmall",
	})
	--Text: Author
	local author = wt.CreateText({
		parent = parentFrame,
		name = "Author",
		position = {
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 186,
		text = ns.strings.options.main.about.author:gsub("#AUTHOR", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Author"), "FFFFFFFF")),
		justify = "LEFT",
		template = "GameFontNormalSmall",
	})
	--Text: License
	wt.CreateText({
		parent = parentFrame,
		name = "License",
		position = {
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 156,
		text = ns.strings.options.main.about.license:gsub("#LICENSE", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "X-License"), "FFFFFFFF")),
		justify = "LEFT",
		template = "GameFontNormalSmall",
	})
	--EditScrollBox: Changelog
	options.about.changelog = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "Changelog",
		title = ns.strings.options.main.about.changelog.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.main.about.changelog.tooltip, }, } },
		position = {
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -12 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 139 },
		text = ns.GetChangelog(),
		font = "GameFontDisableSmall",
		scrollSpeed = 45,
		readOnly = true,
	})
end
local function CreateSupportInfo(parentFrame)
	--Copybox: CurseForge
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "CurseForge",
		title = ns.strings.options.main.support.curseForge .. ":",
		position = { offset = { x = 16, y = -33 } },
		size = { width = parentFrame:GetWidth() / 2 - 22, },
		text = "curseforge.com/wow/addons/remaining-xp",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Wago
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Wago",
		title = ns.strings.options.main.support.wago .. ":",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -33 }
		},
		size = { width = parentFrame:GetWidth() / 2 - 22, },
		text = "addons.wago.io/addons/remaining-xp",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Repository
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Repository",
		title = ns.strings.options.main.support.repository .. ":",
		position = { offset = { x = 16, y = -70 } },
		size = { width = parentFrame:GetWidth() / 2 - 22, },
		text = "github.com/Arxareon/RemainingXP",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Issues
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Issues",
		title = ns.strings.options.main.support.issues .. ":",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -70 }
		},
		size = { width = parentFrame:GetWidth() / 2 - 22, },
		text = "github.com/Arxareon/RemainingXP/issues",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
end
local function CreateMainCategoryPanels(parentFrame) --Add the main page widgets to the category panel frame
	--Shortcuts
	local shortcutsPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "Shortcuts",
		title = ns.strings.options.main.shortcuts.title,
		description = ns.strings.options.main.shortcuts.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateOptionsShortcuts(shortcutsPanel)
	--About
	local aboutPanel = wt.CreatePanel({
		parent = parentFrame,
		title = ns.strings.options.main.about.title,
		description = ns.strings.options.main.about.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = shortcutsPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 231 },
	})
	CreateAboutInfo(aboutPanel)
	--Support
	local supportPanel = wt.CreatePanel({
		parent = parentFrame,
		title = ns.strings.options.main.support.title,
		description = ns.strings.options.main.support.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = aboutPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 111 },
	})
	CreateSupportInfo(supportPanel)
end

--Display page
local function CreateQuickOptions(parentFrame)
	--Checkbox: Hidden
	options.visibility.hidden = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Hidden",
		title = ns.strings.options.display.quick.hidden.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.quick.hidden.tooltip:gsub("#ADDON", addonTitle), }, } },
		position = { offset = { x = 8, y = -30 } },
		events = { OnClick = function(_, state) wt.SetVisibility(remXP, not (state or dbc.disabled)) end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = dbc,
			storageKey = "hidden",
		},
	})
	--Dropdown: Apply a preset
	local presetItems = {}
	for i = 0, #presets do
		presetItems[i] = {}
		presetItems[i].title = presets[i].name
		presetItems[i].onSelect = function()
			if not dbc.disabled then
				--Update the display
				remXP:Show()
				remXP:SetFrameStrata(presets[i].data.visibility.frameStrata)
				ResizeDisplay(presets[i].data.background.size.width, presets[i].data.background.size.height)
				wt.SetPosition(remXP, presets[i].data.position)
				if not presets[i].data.background.visible then wt.SetVisibility(mainDisplayText, true) end
				SetDisplayBackdrop(presets[i].data.background.visible, {
					bg = wt.PackColor(options.background.colors.bg.getColor()),
					xp = wt.PackColor(options.background.colors.xp.getColor()),
					rested = wt.PackColor(options.background.colors.rested.getColor()),
					border = wt.PackColor(options.background.colors.border.getColor()),
				})
				Fade(options.visibility.fade.toggle:GetChecked())
				--Update the options
				options.position.anchor.setSelected(presets[i].data.position.anchor)
				options.position.xOffset:SetValue(presets[i].data.position.offset.x)
				options.position.yOffset:SetValue(presets[i].data.position.offset.y)
				if not presets[i].data.background.visible then
					options.text.visible:SetChecked(true)
					options.text.visible:SetAttribute("loaded", true) --Update dependent widgets
				end
				options.background.visible:SetChecked(presets[i].data.background.visible)
				options.background.visible:SetAttribute("loaded", true) --Update dependent widgets
				options.background.size.width:SetValue(presets[i].data.background.size.width)
				options.background.size.height:SetValue(presets[i].data.background.size.height)
				options.visibility.raise:SetChecked(presets[i].data.visibility.frameStrata == "HIGH")
				--Update the DBs
				if not presets[i].data.background.visible then db.display.text.visible = true end
				db.display.background.visible = presets[i].data.background.visible
				db.display.background.size = presets[i].data.background.size
				db.display.visibility.frameStrata = presets[i].data.visibility.frameStrata
			end
		end
	end
	options.visibility.presets = wt.CreateDropdown({
		parent = parentFrame,
		name = "ApplyPreset",
		title = ns.strings.options.display.quick.presets.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.quick.presets.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		width = 180,
		items = presetItems,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			onLoad = function(self) self.setSelected(nil, ns.strings.options.display.quick.presets.select) end,
		},
	})
	--Button & Popup: Save Custom preset
	local savePopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "SAVEPRESET",
		text = ns.strings.options.display.quick.savePreset.warning,
		accept = ns.strings.misc.override,
		onAccept = function()
			--Update the Custom preset
			presets[0].data.position.anchor, _, _, presets[0].data.position.offset.x, presets[0].data.position.offset.y = remXP:GetPoint()
			presets[0].data.visibility.frameStrata = options.visibility.raise:GetChecked() and "HIGH" or "MEDIUM"
			presets[0].data.background.visible = options.background.visible:GetChecked()
			presets[0].data.background.size = { width = options.background.size.width:GetValue(), height = options.background.size.height:GetValue() }
			--Save the Custom preset
			db.customPreset = presets[0].data
			--Response
			print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.save.response, ns.colors.blue[0]))
		end,
	})
	wt.CreateButton({
		parent = parentFrame,
		name = "SavePreset",
		title = ns.strings.options.display.quick.savePreset.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.quick.savePreset.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -43 }
		},
		size = { width = 160, },
		events = { OnClick = function() StaticPopup_Show(savePopup) end, },
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
	})
end
local function CreatePositionOptions(parentFrame)
	--Selector: Anchor point
	options.position.anchor = wt.CreateAnchorSelector({
		parent = parentFrame,
		name = "AnchorPoint",
		title = ns.strings.options.display.position.anchor.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.position.anchor.tooltip, }, } },
		position = { offset = { x = 8, y = -30 } },
		width = 140,
		onSelection = function(point)
			--Update the main display position
			wt.SetPosition(remXP, wt.PackPosition(point, nil, nil, options.position.xOffset:GetValue(), options.position.yOffset:GetValue()))
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.position,
			storageKey = "anchor",
		},
	})
	--Slider: X offset
	options.position.xOffset = wt.CreateSlider({
		parent = parentFrame,
		name = "OffsetX",
		title = ns.strings.options.display.position.xOffset.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.position.xOffset.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		value = { min = -500, max = 500, fractional = 2 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			--Update the main display position
			wt.SetPosition(remXP, wt.PackPosition(options.position.anchor.getSelected(), nil, nil, value, options.position.yOffset:GetValue()))
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.position.offset,
			storageKey = "x",
		},
	}).slider
	--Slider: Y offset
	options.position.yOffset = wt.CreateSlider({
		parent = parentFrame,
		name = "OffsetY",
		title = ns.strings.options.display.position.yOffset.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.position.yOffset.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -30 }
		},
		value = { min = -500, max = 500, fractional = 2 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			--Update the main display position
			wt.SetPosition(remXP, wt.PackPosition(options.position.anchor.getSelected(), nil, nil, options.position.xOffset:GetValue(), value))
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.position.offset,
			storageKey = "y",
		},
	}).slider
end
local function CreateTextOptions(parentFrame)
	--Checkbox: Visible
	options.text.visible = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Visible",
		title = ns.strings.options.display.text.visible.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.text.visible.tooltip, }, } },
		position = { offset = { x = 8, y = -30 } },
		events = { OnClick = function(_, state)
			--Flip the background visibility on if it was hidden
			if not state and not options.background.visible:GetChecked() then options.background.visible:Click() end
			--Update the text visibility
			wt.SetVisibility(mainDisplayText, state)
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.text,
			storageKey = "visible",
		},
	})
	--Checkbox: Details
	options.text.details = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Details",
		title = ns.strings.options.display.text.details.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.text.details.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		autoOffset = true,
		events = { OnClick = function(_, state)
			db.display.text.details = state
			UpdateXPDisplayText()
		end, },
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.text,
			storageKey = "details",
		},
	})
	--Dropdown: Font family
	local fontItems = {}
	for i = 0, #ns.fonts do
		fontItems[i] = {}
		fontItems[i].title = ns.fonts[i].name
		fontItems[i].onSelect = function()
			mainDisplayText:SetFont(ns.fonts[i].path, options.text.font.size:GetValue(), "THINOUTLINE")
			--Refresh the text so the font will be applied even the first time as well not just subsequent times
			local text = mainDisplayText:GetText()
			mainDisplayText:SetText("")
			mainDisplayText:SetText(text)
		end
	end
	options.text.font.family = wt.CreateDropdown({
		parent = parentFrame,
		name = "FontFamily",
		title = ns.strings.options.display.text.font.family.label,
		tooltip = { lines = {
			[0] = { text = ns.strings.options.display.text.font.family.tooltip[0], },
			[1] = { text = ns.strings.options.display.text.font.family.tooltip[1], },
			[2] = { text = "\n" .. ns.strings.options.display.text.font.family.tooltip[2]:gsub("#OPTION_CUSTOM", ns.strings.misc.custom):gsub("#FILE_CUSTOM", "CUSTOM.ttf"), },
			[3] = { text = "[WoW]\\Interface\\AddOns\\" .. addonNameSpace .. "\\Fonts\\", color = { r = 0.185, g = 0.72, b = 0.84 }, wrap = false },
			[4] = { text = ns.strings.options.display.text.font.family.tooltip[3]:gsub("#FILE_CUSTOM", "CUSTOM.ttf"), },
			[5] = { text = ns.strings.options.display.text.font.family.tooltip[4], color = { r = 0.89, g = 0.65, b = 0.40 }, },
		} },
		position = { offset = { x = 8, y = -60 } },
		items = fontItems,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.text.font,
			storageKey = "family",
			convertSave = function(value) return ns.fonts[value].path end,
			convertLoad = function(font) return GetFontID(font) end,
		},
	})
	--Slider: Font size
	options.text.font.size = wt.CreateSlider({
		parent = parentFrame,
		name = "FontSize",
		title = ns.strings.options.display.text.font.size.label,
		tooltip = { lines = {
			[0] = { text = ns.strings.options.display.text.font.size.tooltip .. "\n\n" .. ns.strings.misc.default .. ": " .. dbDefault.display.text.font.size, },
		} },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
		value = { min = 8, max = 64, step = 1 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			mainDisplayText:SetFont(mainDisplayText:GetFont(), value, "THINOUTLINE") end,
		},
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.text.font,
			storageKey = "size",
		},
	}).slider
	--Color Picker: Font color
	options.text.font.color = wt.CreateColorPicker({
		parent = parentFrame,
		name = "FontColor",
		title = ns.strings.options.display.text.font.color.label,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -12, y = -60 }
		},
		opacity = true,
		setColors = function() return mainDisplayText:GetTextColor() end,
		onColorUpdate = function(r, g, b, a)
			mainDisplayText:SetTextColor(r, g, b, a)
			db.display.text.font.color = wt.PackColor(options.text.font.color.getColor())
			Fade()
		end,
		onCancel = function(r, g, b, a)
			mainDisplayText:SetTextColor(r, g, b, a)
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.text.font,
			storageKey = "color",
		},
	})
end
local  function CreateBackgroundOptions(parentFrame)
	--Checkbox: Visible
	options.background.visible = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Visible",
		title = ns.strings.options.display.background.visible.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.background.visible.tooltip, }, } },
		position = { offset = { x = 8, y = -30 } },
		events = { OnClick = function(_, state)
			--Flip the text visibility on if it was hidden
			if not state and not options.text.visible:GetChecked() then options.text.visible:Click() end
			--Update the main display backdrop
			SetDisplayBackdrop(state, {
				bg = wt.PackColor(options.background.colors.bg.getColor()),
				xp = wt.PackColor(options.background.colors.xp.getColor()),
				rested = wt.PackColor(options.background.colors.rested.getColor()),
				border = wt.PackColor(options.background.colors.border.getColor()),
			})
			Fade()
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background,
			storageKey = "visible",
		},
	})
	--Slider: Background width
	options.background.size.width = wt.CreateSlider({
		parent = parentFrame,
		name = "Width",
		title = ns.strings.options.display.background.size.width.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.background.size.width.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -32 }
		},
		value = { min = 64, max = UIParent:GetWidth() - math.fmod(UIParent:GetWidth(), 1) , step = 2 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			--Update the main display size
			ResizeDisplay(value, options.background.size.height:GetValue())
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background.size,
			storageKey = "width",
		},
	}).slider
	--Slider: Background height
	options.background.size.height = wt.CreateSlider({
		parent = parentFrame,
		name = "Height",
		title = ns.strings.options.display.background.size.height.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.background.size.height.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -32 }
		},
		value = { min = 2, max = 80, step = 2 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			--Update the main display size
			ResizeDisplay(options.background.size.width:GetValue(), value)
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background.size,
			storageKey = "height",
		},
	}).slider
	--Color Picker: Background color
	options.background.colors.bg = wt.CreateColorPicker({
		parent = parentFrame,
		name = "Color",
		title = ns.strings.options.display.background.colors.bg.label,
		position = { offset = { x = 12, y = -90 } },
		opacity = true,
		setColors = function()
			if options.background.visible:GetChecked() then return mainDisplay:GetBackdropColor() end
			return wt.UnpackColor(db.display.background.colors.bg)
		end,
		onColorUpdate = function(r, g, b, a)
			if mainDisplay:GetBackdrop() ~= nil then mainDisplay:SetBackdropColor(r, g, b, a) end
			db.display.background.colors.bg = wt.PackColor(options.background.colors.bg.getColor())
			Fade()
		end,
		onCancel = function(r, g, b, a)
			if mainDisplay:GetBackdrop() ~= nil then mainDisplay:SetBackdropColor(r, g, b, a) end
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background.colors,
			storageKey = "bg",
		},
	})
	--Color Picker: Border color
	options.background.colors.border = wt.CreateColorPicker({
		parent = parentFrame,
		name = "BorderColor",
		title = ns.strings.options.display.background.colors.border.label,
		position = {
			anchor = "TOP",
			offset = { x = -71, y = -90 }
		},
		opacity = true,
		setColors = function()
			if options.background.visible:GetChecked() then return mainDisplay:GetBackdropBorderColor() end
			return wt.UnpackColor(db.display.background.colors.border)
		end,
		onColorUpdate = function(r, g, b, a)
			if mainDisplay:GetBackdrop() ~= nil then mainDisplayOverlay:SetBackdropBorderColor(r, g, b, a) end
			db.display.background.colors.border = wt.PackColor(options.background.colors.border.getColor())
			Fade()
		end,
		onCancel = function(r, g, b, a)
			if mainDisplay:GetBackdrop() ~= nil then mainDisplayOverlay:SetBackdropBorderColor(r, g, b, a) end
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background.colors,
			storageKey = "border",
		},
	})
	--Color Picker: XP color
	options.background.colors.xp = wt.CreateColorPicker({
		parent = parentFrame,
		name = "XPColor",
		title = ns.strings.options.display.background.colors.xp.label,
		position = {
			anchor = "TOP",
			offset = { x = 71, y = -90 }
		},
		opacity = true,
		setColors = function()
			if mainDisplayXP:GetBackdrop() ~= nil then return mainDisplayXP:GetBackdropColor() end
			return wt.UnpackColor(db.display.background.colors.xp)
		end,
		onColorUpdate = function(r, g, b, a)
			if mainDisplayXP:GetBackdrop() ~= nil then mainDisplayXP:SetBackdropColor(r, g, b, a) end
			db.display.background.colors.xp = wt.PackColor(options.background.colors.xp.getColor())
			Fade()
		end,
		onCancel = function(r, g, b, a)
			if mainDisplayXP:GetBackdrop() ~= nil then mainDisplayXP:SetBackdropColor(r, g, b, a) end
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background.colors,
			storageKey = "xp",
		},
	})
	--Color Picker: Rested color
	options.background.colors.rested = wt.CreateColorPicker({
		parent = parentFrame,
		name = "RestedColor",
		title = ns.strings.options.display.background.colors.rested.label,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -12, y = -90 }
		},
		opacity = true,
		setColors = function()
			if mainDisplayRested:GetBackdrop() ~= nil then return mainDisplayRested:GetBackdropColor() end
			return wt.UnpackColor(db.display.background.colors.rested)
		end,
		onColorUpdate = function(r, g, b, a)
			if mainDisplayRested:GetBackdrop() ~= nil then mainDisplayRested:SetBackdropColor(r, g, b, a) end
			db.display.background.colors.rested = wt.PackColor(options.background.colors.rested.getColor())
			Fade()
		end,
		onCancel = function(r, g, b, a)
			if mainDisplayRested:GetBackdrop() ~= nil then mainDisplayRested:SetBackdropColor(r, g, b, a) end
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.background.colors,
			storageKey = "rested",
		},
	})
end
local function CreateVisibilityOptions(parentFrame)
	--Checkbox: Raise
	options.visibility.raise = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Raise",
		title = ns.strings.options.display.visibility.raise.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.visibility.raise.tooltip, }, } },
		position = { offset = { x = 8, y = -30 } },
		autoOffset = true,
		events = { OnClick = function(_, state)
			remXP:SetFrameStrata(state and "HIGH" or "MEDIUM")
			--Clear the presets dropdown selection
			options.visibility.presets.setSelected(nil, ns.strings.options.display.quick.presets.select)
		end, },
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.visibility,
			storageKey = "frameStrata",
			convertSave = function(enabled) return enabled and "HIGH" or "MEDIUM" end,
			convertLoad = function(strata) return strata == "HIGH" end,
		},
	})
	--Checkbox: Fade toggle
	options.visibility.fade.toggle = wt.CreateCheckbox({
		parent = parentFrame,
		name = "FadeToggle",
		title = ns.strings.options.display.visibility.fade.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.visibility.fade.tooltip, }, } },
		position = {
			relativeTo = options.visibility.raise,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
		events = { OnClick = function(_, state)
			db.display.visibility.fade.enabled = state
			Fade()
		end, },
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.text.visible, evaluate = function(state) return state or options.background.visible:GetChecked() end },
			[2] = { frame = options.background.visible, evaluate = function(state) return state or options.text.visible:GetChecked() end },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.visibility.fade,
			storageKey = "enabled",
		},
	})
	--Slider: Text fade intensity
	options.visibility.fade.text = wt.CreateSlider({
		parent = parentFrame,
		name = " TextFade",
		title = ns.strings.options.display.visibility.fade.text.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.visibility.fade.text.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
		value = { min = 0, max = 1, step = 0.05 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			db.display.visibility.fade.text = value
			Fade()
		end, },
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.text.visible, },
			[2] = { frame = options.visibility.fade.toggle, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.visibility.fade,
			storageKey = "text",
		},
	}).slider
	--Slider: Background fade intensity
	options.visibility.fade.background = wt.CreateSlider({
		parent = parentFrame,
		name = "BackgroundFade",
		title = ns.strings.options.display.visibility.fade.background.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.display.visibility.fade.background.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -60 }
		},
		value = { min = 0, max = 1, step = 0.05 },
		events = { OnValueChanged = function(_, value, user)
			if not user then return end
			db.display.visibility.fade.background = value
			Fade()
		end, },
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end },
			[1] = { frame = options.background.visible, },
			[2] = { frame = options.visibility.fade.toggle, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.display.visibility.fade,
			storageKey = "background",
		},
	}).slider
end
local function CreateDisplayCategoryPanels(parentFrame) --Add the display page widgets to the category panel frame
	--Quick settings
	local quickOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "QuickSettings",
		title = ns.strings.options.display.quick.title,
		description = ns.strings.options.display.quick.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -78 } },
		size = { height = 77 },
	})
	CreateQuickOptions(quickOptions)
	--Position
	local positionOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Position",
		title = ns.strings.options.display.position.title,
		description = ns.strings.options.display.position.description:gsub("#SHIFT", ns.strings.keys.shift),
		position = {
			relativeTo = quickOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 103 },
	})
	CreatePositionOptions(positionOptions)
	--Text
	local textOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Text",
		title = ns.strings.options.display.text.title,
		description = ns.strings.options.display.text.description,
		position = {
			relativeTo = positionOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 118 },
	})
	CreateTextOptions(textOptions)
	--Background
	local backgroundOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Background",
		title = ns.strings.options.display.background.title,
		description = ns.strings.options.display.background.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = textOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 140 },
	})
	CreateBackgroundOptions(backgroundOptions)
	--Visibility
	local visibilityOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Visibility",
		title = ns.strings.options.display.visibility.title,
		description = ns.strings.options.display.visibility.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = backgroundOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 118 },
	})
	CreateVisibilityOptions(visibilityOptions)
end

--Integration page
local function CreateEnhancementOptions(parentFrame)
	--Checkbox: Enable integration
	options.enhancement.toggle = wt.CreateCheckbox({
		parent = parentFrame,
		name = "EnableIntegration",
		title = ns.strings.options.integration.enhancement.toggle.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.integration.enhancement.toggle.tooltip, }, } },
		position = { offset = { x = 8, y = -30 } },
		events = { OnClick = function(_, state)
			SetIntegrationVisibility(state, options.enhancement.keep:GetChecked(), options.enhancement.remaining:GetChecked(), false, false)
			db.enhancement.enabled = state
		end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.enhancement,
			storageKey = "enabled",
		},
	})
	--Checkbox: Keep text
	options.enhancement.keep = wt.CreateCheckbox({
		parent = parentFrame,
		name = "KeepText",
		title = ns.strings.options.integration.enhancement.keep.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.integration.enhancement.keep.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		autoOffset = true,
		events = { OnClick = function(_, state)
			SetIntegrationTextVisibility(state, options.enhancement.remaining:GetChecked())
			db.enhancement.keep = state
		end, },
		dependencies = { [0] = { frame = options.enhancement.toggle, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.enhancement,
			storageKey = "keep",
		},
	})
	--Checkbox: Keep only remaining XP text
	options.enhancement.remaining = wt.CreateCheckbox({
		parent = parentFrame,
		name = "RemainingOnly",
		title = ns.strings.options.integration.enhancement.remaining.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.integration.enhancement.remaining.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { y = -30 }
		},
		autoOffset = true,
		events = { OnClick = function(_, state)
			SetIntegrationTextVisibility(options.enhancement.keep:GetChecked(), state)
			db.enhancement.remaining = state
		end, },
		dependencies = {
			[0] = { frame = options.enhancement.toggle, },
			[1] = { frame = options.enhancement.keep, },
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.enhancement,
			storageKey = "remaining",
		},
	})
end
local function CreateRemovalsOptions(parentFrame)
	--Checkbox: Hide the status bars
	options.removals.statusBars = wt.CreateCheckbox({
		parent = parentFrame,
		name = "HideStatusBars",
		title = ns.strings.options.integration.removals.statusBars.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.integration.removals.statusBars.tooltip[0]:gsub("#ADDON", addonTitle), }, } },
		position = { offset = { x = 8, y = -30 } },
		autoOffset = true,
		events = { OnClick = function(_, state) wt.SetVisibility(MainMenuExpBar, not state) end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.removals,
			storageKey = "statusBars",
		},
	})
end
local function CreateIntegrationCategoryPanels(parentFrame) --Add the notification page widgets to the category panel frame
	--Enhancement
	local enhancementOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Enhancement",
		title = ns.strings.options.integration.enhancement.title,
		description = ns.strings.options.integration.enhancement.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateEnhancementOptions(enhancementOptions)
	--Removals
	local removalsOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Removals",
		title = ns.strings.options.integration.removals.title,
		description = ns.strings.options.integration.removals.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = enhancementOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 64 },
	})
	CreateRemovalsOptions(removalsOptions)
end

--Notifications page
local function CreateNotificationsOptions(parentFrame)
	--Checkbox: XP gained
	options.notifications.xpGained = wt.CreateCheckbox({
		parent = parentFrame,
		name = "XPGained",
		title = ns.strings.options.events.notifications.xpGained.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.xpGained.tooltip, }, } },
		position = { offset = { x = 8, y = -30 } },
		events = { OnClick = function(_, state) db.notifications.xpGained = state end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications,
			storageKey = "xpGained",
		},
	})
	--Checkbox: Rested XP gained
	options.notifications.restedXPGained = wt.CreateCheckbox({
		parent = parentFrame,
		name = "RestedXPGained",
		title = ns.strings.options.events.notifications.restedXPGained.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.restedXPGained.tooltip, }, } },
		position = {
			relativeTo = options.notifications.xpGained,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
		events = { OnClick = function(_, state) db.notifications.restedXP.gained = state end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications.restedXP,
			storageKey = "gained",
		},
	})
	--Checkbox: Significant Rested XP updates only
	options.notifications.significantRestedOnly = wt.CreateCheckbox({
		parent = parentFrame,
		name = "SignificantRestedOnly",
		title = ns.strings.options.events.notifications.restedXPGained.significantOnly.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.restedXPGained.significantOnly.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
		autoOffset = true,
		events = { OnClick = function(_, state) db.notifications.restedXP.significantOnly = state end, },
		dependencies = { [0] = { frame = options.notifications.restedXPGained, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications.restedXP,
			storageKey = "significantOnly",
		},
	})
	--Checkbox: Accumulated Rested XP
	options.notifications.restedXPAccumulated = wt.CreateCheckbox({
		parent = parentFrame,
		name = "AccumulatedRestedXP",
		title = ns.strings.options.events.notifications.restedXPGained.accumulated.label,
		tooltip = { lines = {
			[0] = { text = ns.strings.options.events.notifications.restedXPGained.accumulated.tooltip[0], },
			[1] = {
				text = ns.strings.options.events.notifications.restedXPGained.accumulated.tooltip[1]:gsub("#ADDON", addonTitle),
				color = { r = 0.89, g = 0.65, b = 0.40 },
			},
		} },
		position = {
			anchor = "TOPRIGHT",
			offset = { y = -60 }
		},
		autoOffset = true,
		events = { OnClick = function(_, state)
			SetRestedAccumulation(options.notifications.restedXPGained:GetChecked() and state and dbc.disabled)
			db.notifications.restedXP.accumulated = state
		end, },
		dependencies = { [0] = { frame = options.notifications.restedXPGained, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications.restedXP,
			storageKey = "accumulated",
		},
	})
	--Checkbox: Level up
	options.notifications.lvlUp = wt.CreateCheckbox({
		parent = parentFrame,
		name = "LevelUp",
		position = {
			relativeTo = options.notifications.restedXPGained,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
		label = ns.strings.options.events.notifications.lvlUp.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.lvlUp.tooltip, }, } },
		events = { OnClick = function(_, state) db.notifications.lvlUp.congrats = state end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications.lvlUp,
			storageKey = "congrats",
		},
	})
	--Checkbox: Time played
	options.notifications.timePlayed = wt.CreateCheckbox({
		parent = parentFrame,
		name = "TimePlayed",
		title = ns.strings.options.events.notifications.lvlUp.timePlayed.label .. " (Soon™)",
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.lvlUp.timePlayed.tooltip, }, } },
		position = {
			anchor = "TOP",
			offset = { y = -90 }
		},
		autoOffset = true,
		events = { OnClick = function(_, state) db.notifications.lvlUp.timePlayed = state end, },
		disabled = true --TODO: Add time played notifications
		-- dependencies = { [0] = { frame = options.notifications.lvlUp, }, },
		-- optionsData = {
		-- 	optionsKey = addonNameSpace,
		-- 	storageTable = db.notifications.lvlUp,
		-- 	storageKey = "timePlayed",
		-- },
	})
	--Checkbox: Status notice
	options.notifications.status = wt.CreateCheckbox({
		parent = parentFrame,
		name = " StatusNotice",
		title = ns.strings.options.events.notifications.statusNotice.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.statusNotice.tooltip:gsub("#ADDON", addonTitle), }, } },
		position = {
			relativeTo = options.notifications.lvlUp,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications.statusNotice,
			storageKey = "enabled",
		},
	})
	--Checkbox: Max reminder
	options.notifications.maxReminder = wt.CreateCheckbox({
		parent = parentFrame,
		name = "MaxReminder",
		title = ns.strings.options.events.notifications.statusNotice.maxReminder.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.events.notifications.statusNotice.maxReminder.tooltip:gsub("#ADDON", addonTitle), }, } },
		position = {
			anchor = "TOP",
			offset = { y = -120 }
		},
		autoOffset = true,
		dependencies = { [0] = { frame = options.notifications.status, }, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = db.notifications.statusNotice,
			storageKey = "maxReminder",
		},
	})
end
local function CreateLogsOptions(parentFrame)
	--TODO: Add logs widgets
end
local function CreateEventsCategoryPanels(parentFrame) --Add the events page widgets to the category panel frame
	--Chat notifications
	local notificationsOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "ChatNotifications",
		title = ns.strings.options.events.notifications.title,
		description = ns.strings.options.events.notifications.description,
		position = { offset = { x = 16, y = -82 } },
		size = { height = 154 },
	})
	CreateNotificationsOptions(notificationsOptions)
	---Logs
	local logsOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Logs",
		title = ns.strings.options.events.logs.title,
		description = ns.strings.options.events.logs.description,
		position = {
			relativeTo = notificationsOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 64 },
	})
	CreateLogsOptions(logsOptions)
end

--Advanced page
local function CreateOptionsProfiles(parentFrame)
	--TODO: Add profiles handler widgets
end
local function CreateBackupOptions(parentFrame)
	--EditScrollBox & Popup: Import & Export
	local importPopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "IMPORT",
		text = ns.strings.options.advanced.backup.warning,
		accept = ns.strings.options.advanced.backup.import,
		onAccept = function()
			--Load from string to a temporary table
			local success, t = pcall(loadstring("return " .. wt.Clear(options.backup.string:GetText())))
			if success and type(t) == "table" then
				--Run DB checkup on the loaded table
				wt.RemoveEmpty(t.account, CheckValidity)
				wt.RemoveEmpty(t.character, CheckValidity)
				wt.AddMissing(t.account, db)
				wt.AddMissing(t.character, dbc)
				RestoreOldData(t.account, t.character, wt.RemoveMismatch(t.account, db), wt.RemoveMismatch(t.character, dbc))
				VisibilityCheckup(t.account, t.character)
				--Copy values from the loaded DBs to the addon DBs
				wt.CopyValues(t.account, db)
				wt.CopyValues(t.character, dbc)
				--Update the Custom preset
				presets[0].data = wt.Clone(db.customPreset)
				--Main display
				wt.SetPosition(remXP, db.display.position)
				SetDisplayValues(db, dbc)
				--Enhancement
				SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
				--Removals
				wt.SetVisibility(MainMenuExpBar, t.account.removals.statusBars)
				--Update the interface options
				wt.LoadOptionsData(addonNameSpace)
			else print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.options.advanced.backup.error, ns.colors.blue[0])) end
		end
	})
	local backupBox
	options.backup.string, backupBox = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "ImportExport",
		title = ns.strings.options.advanced.backup.backupBox.label,
		tooltip = { lines = {
			[0] = { text = ns.strings.options.advanced.backup.backupBox.tooltip[0], },
			[1] = { text = ns.strings.options.advanced.backup.backupBox.tooltip[1], },
			[2] = { text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[2]:gsub("#ENTER", ns.strings.keys.enter), },
			[3] = { text = ns.strings.options.advanced.backup.backupBox.tooltip[3], color = { r = 0.89, g = 0.65, b = 0.40 }, },
			[4] = { text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.92, g = 0.34, b = 0.23 }, },
		} },
		position = { offset = { x = 16, y = -30 } },
		size = { width = parentFrame:GetWidth() - 32, height = 276 },
		maxLetters = 5400,
		font = "GameFontWhiteSmall",
		scrollSpeed = 60,
		events = {
			OnEnterPressed = function() StaticPopup_Show(importPopup) end,
			OnEscapePressed = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
		},
		optionsData = {
			optionsKey = addonNameSpace,
			onLoad = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
		},
	})
	--Checkbox: Compact
	options.backup.compact = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Compact",
		title = ns.strings.options.advanced.backup.compact.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.advanced.backup.compact.tooltip, }, } },
		position = {
			relativeTo = backupBox,
			relativePoint = "BOTTOMLEFT",
			offset = { x = -8, y = -13 }
		},
		events = { OnClick = function(_, state)
			options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, state, true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			options.backup.string:SetFocus()
			options.backup.string:ClearFocus()
		end, },
		optionsData = {
			optionsKey = addonNameSpace,
			storageTable = cs,
			storageKey = "compactBackup",
		},
	})
	--Button: Load
	local load = wt.CreateButton({
		parent = parentFrame,
		name = "Load",
		title = ns.strings.options.advanced.backup.load.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.advanced.backup.load.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMRIGHT",
			offset = { x = 6, y = -13 }
		},
		events = { OnClick = function() StaticPopup_Show(importPopup) end, },
	})
	--Button: Reset
	wt.CreateButton({
		parent = parentFrame,
		name = "Reset",
		title = ns.strings.options.advanced.backup.reset.label,
		tooltip = { lines = { [0] = { text = ns.strings.options.advanced.backup.reset.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = load,
			relativePoint = "TOPLEFT",
			offset = { x = -10, }
		},
		events = { OnClick = function()
			options.backup.string:SetText("") --Remove text to make sure OnTextChanged will get called
			options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			options.backup.string:SetFocus()
			options.backup.string:ClearFocus()
		end, },
	})
end
local function CreateAdvancedCategoryPanels(parentFrame) --Add the advanced page widgets to the category panel frame
	--Profiles
	local profilesPanel = wt.CreatePanel({
		parent = parentFrame,
		name = "Profiles",
		title = ns.strings.options.advanced.profiles.title,
		description = ns.strings.options.advanced.profiles.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateOptionsProfiles(profilesPanel)
	---Backup
	local backupOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Backup",
		title = ns.strings.options.advanced.backup.title,
		description = ns.strings.options.advanced.backup.description:gsub("#ADDON", addonTitle),
		position = {
			relativeTo = profilesPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -32 }
		},
		size = { height = 374 },
	})
	CreateBackupOptions(backupOptions)
end

--[ Options Category Panels ]

--Save the pending changes
local function SaveOptions()
	--Removals
	db.removals.statusBars = not MainMenuExpBar:IsVisible()
	--Update the SavedVariabes DBs
	RemainingXPDB = wt.Clone(db)
	RemainingXPDBC = wt.Clone(dbc)
end
--Cancel all potential changes made in all option categories
local function CancelChanges()
	LoadDBs()
	--Display
	wt.SetPosition(remXP, db.display.position)
	SetDisplayValues(db, dbc)
	--Enhancement
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, false)
	--Removals
	wt.SetVisibility(MainMenuExpBar, db.removals.statusBars)
end
--Restore all the settings under the main option category to their default values
local function DefaultOptions()
	if db.enhancement.enabled ~= dbDefault.enhancement.enabled then
		wt.CreateReloadNotice()
		print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.integration.notice, ns.colors.blue[0]))
	end
	--Reset the DBs
	RemainingXPDB = wt.Clone(dbDefault)
	RemainingXPDBC = wt.Clone(dbcDefault)
	wt.CopyValues(dbDefault, db)
	wt.CopyValues(dbcDefault, dbc)
	--Reset the Custom preset
	presets[0].data = wt.Clone(db.customPreset)
	--Reset the main display
	wt.SetPosition(remXP, db.display.position)
	SetDisplayValues(db, dbc)
	--Update the enhancement
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
	--Update the removals
	wt.SetVisibility(MainMenuExpBar, db.removals.statusBars)
	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated and dbc.disabled)
	--Update the interface options
	wt.LoadOptionsData(addonNameSpace)
	--Set the preset selection to Custom
	options.visibility.presets.setSelected(0)
	--Notification
	print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.options.defaults, ns.colors.blue[0]))
end

--Create and add the options category panel frames to the WoW Interface Options
local function LoadInterfaceOptions()
	--Main options panel
	options.mainOptions = wt.CreateOptionsCategory({
		addon = addonNameSpace,
		name = "Main",
		description = ns.strings.options.main.description:gsub("#ADDON", addonTitle):gsub("#KEYWORD", ns.strings.chat.keyword),
		logo = ns.textures.logo,
		titleLogo = true,
		save = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
		optionsKey = addonNameSpace,
	})
	CreateMainCategoryPanels(options.mainOptions.canvas) --Add categories & GUI elements to the panel
	--Display options panel
	options.displayOptions = wt.CreateOptionsCategory({
		parent = options.mainOptions.category,
		addon = addonNameSpace,
		name = "Display",
		title = ns.strings.options.display.title,
		description = ns.strings.options.display.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		scroll = {
			height = 695,
			speed = 75,
		},
		save = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
		optionsKey = addonNameSpace,
		autoSave = false,
		autoLoad = false,
	})
	CreateDisplayCategoryPanels(options.displayOptions.scrollChild) --Add categories & GUI elements to the panel
	--Integration options panel
	options.integrationOptions = wt.CreateOptionsCategory({
		parent = options.mainOptions.category,
		addon = addonNameSpace,
		name = "Integration",
		title = ns.strings.options.integration.title,
		description = ns.strings.options.integration.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		save = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
		optionsKey = addonNameSpace,
		autoSave = false,
		autoLoad = false,
	})
	CreateIntegrationCategoryPanels(options.integrationOptions.canvas) --Add categories & GUI elements to the panel
	--Notifications options panel
	options.notificationsOptions = wt.CreateOptionsCategory({
		parent = options.mainOptions.category,
		addon = addonNameSpace,
		name = "Notifications",
		title = ns.strings.options.events.title,
		description = ns.strings.options.events.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		save = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
		optionsKey = addonNameSpace,
		autoSave = false,
		autoLoad = false,
	})
	CreateEventsCategoryPanels(options.notificationsOptions.canvas) --Add categories & GUI elements to the panel
	--Advanced options panel
	options.advancedOptions = wt.CreateOptionsCategory({
		parent = options.mainOptions.category,
		addon = addonNameSpace,
		name = "Advanced",
		title = ns.strings.options.advanced.title,
		description = ns.strings.options.advanced.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		save = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
		optionsKey = addonNameSpace,
		autoSave = false,
		autoLoad = false,
	})
	CreateAdvancedCategoryPanels(options.advancedOptions.canvas) --Add categories & GUI elements to the panel
end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load boolean [Default: false]
local function PrintStatus(load)
	if load == true and not db.notifications.statusNotice.enabled then return end
	local status = wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(
		remXP:IsVisible() and ns.strings.chat.status.visible or ns.strings.chat.status.hidden, ns.colors.blue[0]
	):gsub(
		"#FADE", wt.Color(ns.strings.chat.status.fade:gsub(
			"#STATE", wt.Color(db.display.visibility.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[1])
		), ns.colors.blue[1])
	)
	if dbc.disabled then
		if db.notifications.statusNotice.maxReminder then
			status = wt.Color(ns.strings.chat.status.disabled:gsub(
				"#ADDON", wt.Color(addonTitle, ns.colors.purple[0])
			) .." " ..  wt.Color(ns.strings.chat.status.max:gsub(
				"#MAX", wt.Color(max, ns.colors.purple[1])
			), ns.colors.blue[1]), ns.colors.blue[0])
		else return end
	end
	print(status)
end
--Print help info
local function PrintInfo()
	print(wt.Color(ns.strings.chat.help.thanks:gsub("#ADDON", wt.Color(addonTitle, ns.colors.purple[0])), ns.colors.blue[0]))
	PrintStatus()
	print(wt.Color(ns.strings.chat.help.hint:gsub( "#HELP_COMMAND", wt.Color(ns.strings.chat.keyword .. " " .. ns.strings.chat.help.command, ns.colors.purple[2])), ns.colors.blue[2]))
	print(wt.Color(ns.strings.chat.help.move:gsub("#SHIFT", wt.Color(ns.strings.keys.shift, ns.colors.purple[2])):gsub("#ADDON", addonTitle), ns.colors.blue[2]))
end
--Print the command list with basic functionality info
local function PrintCommands()
	print(wt.Color(addonTitle, ns.colors.purple[0]) .. " ".. wt.Color(ns.strings.chat.help.list .. ":", ns.colors.blue[0]))
	--Index the commands (skipping the help command) and put replacement code segments in place
	local commands = {
		[0] = {
			command = ns.strings.chat.options.command,
			description = ns.strings.chat.options.description:gsub("#ADDON", addonTitle)
		},
		[1] = {
			command = ns.strings.chat.save.command,
			description = ns.strings.chat.save.description
		},
		[2] = {
			command = ns.strings.chat.preset.command,
			description = ns.strings.chat.preset.description:gsub(
				"#INDEX", wt.Color(ns.strings.chat.preset.command .. " " .. 0, ns.colors.purple[2])
			)
		},
		[3] = {
			command = ns.strings.chat.toggle.command,
			description = ns.strings.chat.toggle.description:gsub(
				"#HIDDEN", wt.Color(dbc.hidden and ns.strings.chat.toggle.hidden or ns.strings.chat.toggle.shown, ns.colors.purple[2])
			)
		},
		[4] = {
			command = ns.strings.chat.fade.command,
			description = ns.strings.chat.fade.description:gsub(
				"#STATE", wt.Color(db.display.visibility.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
			)
		},
		[5] = {
			command = ns.strings.chat.size.command,
			description =  ns.strings.chat.size.description:gsub(
				"#SIZE", wt.Color(ns.strings.chat.size.command .. " " .. dbDefault.display.text.font.size, ns.colors.purple[2])
			)
		},
		[6] = {
			command = ns.strings.chat.integration.command,
			description =  ns.strings.chat.integration.description
		},
		[7] = {
			command = ns.strings.chat.reset.command,
			description =  ns.strings.chat.reset.description
		},
	}
	--Print the list
	for i = 0, #commands do
		print("    " .. wt.Color(ns.strings.chat.keyword .. " " .. commands[i].command, ns.colors.purple[2]) .. wt.Color(" - " .. commands[i].description, ns.colors.blue[2]))
	end
end
--Reset to defaults confirmation
local resetPopup = wt.CreatePopup({
	addon = addonNameSpace,
	name = "DefaultOptions",
	text = (wt.GetStrings("warning") or ""):gsub("#TITLE", wt.Clear(addonTitle)),
	onAccept = DefaultOptions,
})

--[ Slash Command Handlers ]

local function SaveCommand()
	--Update the custom preset
	presets[0].data.position.anchor, _, _, presets[0].data.position.offset.x, presets[0].data.position.offset.y = remXP:GetPoint()
	presets[0].data.visibility.frameStrata = options.visibility.raise:GetChecked() and "HIGH" or "MEDIUM"
	presets[0].data.background.visible = options.background.visible:GetChecked()
	presets[0].data.background.size = { width = options.background.size.width:GetValue(), height = options.background.size.height:GetValue() }
	--Save the Custom preset
	wt.CopyValues(presets[0].data, db.customPreset)
	--Update in the SavedVariabes DB
	RemainingXPDB.customPreset = wt.Clone(db.customPreset)
	--Response
	print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.save.response, ns.colors.blue[0]))
end
local function PresetCommand(parameter)
	local i = tonumber(parameter)
	if i ~= nil and i >= 0 and i <= #presets then
		if not dbc.disabled then
			--Update the display
			remXP:Show()
			remXP:SetFrameStrata(presets[i].data.visibility.frameStrata)
			ResizeDisplay(presets[i].data.background.size.width, presets[i].data.background.size.height)
			wt.SetPosition(remXP, presets[i].data.position)
			if not presets[i].data.background.visible then wt.SetVisibility(mainDisplayText, true) end
			SetDisplayBackdrop(presets[i].data.background.visible, db.display.background.colors)
			Fade(db.display.visibility.fade.enable)
			--Update the GUI options in case the window was open
			options.visibility.hidden:SetChecked(false)
			options.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
			options.position.anchor.setSelected(presets[i].data.position.anchor)
			options.position.xOffset:SetValue(presets[i].data.position.offset.x)
			options.position.yOffset:SetValue(presets[i].data.position.offset.y)
			if not presets[i].data.background.visible then
				options.text.visible:SetChecked(true)
				options.text.visible:SetAttribute("loaded", true) --Update dependent widgets
			end
			options.background.visible:SetChecked(presets[i].data.background.visible)
			options.background.visible:SetAttribute("loaded", true) --Update dependent widgets
			options.background.size.width:SetValue(presets[i].data.background.size.width)
			options.background.size.height:SetValue(presets[i].data.background.size.height)
			options.visibility.raise:SetChecked(presets[i].data.visibility.frameStrata == "HIGH")
			--Update the DBs
			dbc.hidden = false
			wt.CopyValues(presets[i].data.position, db.display.position)
			if not presets[i].data.background.visible then db.display.text.visible = true end
			db.display.background.visible = presets[i].data.background.visible
			db.display.background.size = presets[i].data.background.size
			db.display.visibility.frameStrata = presets[i].data.visibility.frameStrata
			--Update in the SavedVariabes DB
			RemainingXPDBC.hidden = false
			RemainingXPDB.display.position = wt.Clone(db.display.position)
			if not presets[i].data.background.visible then RemainingXPDB.display.text.visible = true end
			RemainingXPDB.display.background.visible = db.display.background.visible
			RemainingXPDB.display.background.size = wt.Clone(db.display.background.size)
			RemainingXPDB.display.visibility.frameStrata = db.display.visibility.frameStrata
			--Response
			print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.preset.response:gsub(
				"#PRESET", wt.Color(presets[i].name, ns.colors.purple[1])
			), ns.colors.blue[0]))
		else
			PrintStatus()
		end
	else
		--Error
		print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.preset.unchanged, ns.colors.blue[0]))
		print(wt.Color(ns.strings.chat.preset.error:gsub("#INDEX", wt.Color(ns.strings.chat.preset.command .. " " .. 0, ns.colors.purple[1])), ns.colors.blue[1]))
		print(wt.Color(ns.strings.chat.preset.list, ns.colors.purple[2]))
		for j = 0, #presets, 2 do
			local list = "    " .. wt.Color(j, ns.colors.purple[2]) .. wt.Color(" - " .. presets[j].name, ns.colors.blue[2])
			if j + 1 <= #presets then list = list .. "    " .. wt.Color(j + 1, ns.colors.purple[2]) .. wt.Color(" - " .. presets[j + 1].name, ns.colors.blue[2]) end
			print(list)
		end
	end
end
local function ToggleCommand()
	--Update the DBs
	dbc.hidden = not dbc.hidden
	RemainingXPDBC.hidden = dbc.hidden
	--Update the GUI option in case it was open
	options.visibility.hidden:SetChecked(dbc.hidden)
	options.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
	--Update the visibility
	wt.SetVisibility(remXP, not (dbc.hidden or dbc.disabled))
	--Response
	print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.toggle.response:gsub(
		"#STATE", wt.Color(dbc.hidden and ns.strings.chat.toggle.hidden or ns.strings.chat.toggle.shown, ns.colors.purple[1])
	), ns.colors.blue[0]))
	if dbc.disabled then PrintStatus() end
end
local function FadeCommand()
	--Update the DBs
	db.display.visibility.fade.enabled = not db.display.visibility.fade.enabled
	RemainingXPDB.display.visibility.fade.enabled = db.display.visibility.fade.enabled
	--Update the GUI option in case it was open
	options.visibility.fade.toggle:SetChecked(db.display.visibility.fade.enabled)
	options.visibility.fade.toggle:SetAttribute("loaded", true) --Update dependent widgets
	--Update the main display fade
	Fade(db.display.visibility.fade.enabled)
	--Response
	print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.fade.response:gsub(
		"#STATE", wt.Color(db.display.visibility.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[1])
	), ns.colors.blue[0]))
	if dbc.disabled then PrintStatus() end
end
local function SizeCommand(parameter)
	local size = tonumber(parameter)
	if size ~= nil then
		--Update the DBs
		db.display.text.font.size = size
		RemainingXPDB.display.text.font.size = db.display.text.font.size
		--Update the GUI option in case it was open
		options.text.font.size:SetValue(size)
		--Update the font
		mainDisplayText:SetFont(db.display.text.font.family, db.display.text.font.size, "THINOUTLINE")
		--Response
		print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.size.response:gsub("#VALUE", wt.Color(size, ns.colors.purple[1])), ns.colors.blue[0]))
	else
		--Error
		print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.size.unchanged, ns.colors.blue[0]))
		print(wt.Color(ns.strings.chat.size.error:gsub(
			"#SIZE", wt.Color(ns.strings.chat.size.command .. " " .. dbDefault.display.text.font.size, ns.colors.purple[1])
		), ns.colors.blue[1]))
	end
	if dbc.disabled then PrintStatus() end
end
local function IntegrationCommand()
	--Update the DBs
	db.enhancement.enabled = not db.enhancement.enabled
	RemainingXPDB.enhancement.enabled = db.enhancement.enabled
	--Update the GUI option in case it was open
	options.enhancement.toggle:SetChecked(db.enhancement.enabled)
	options.enhancement.toggle:SetAttribute("loaded", true) --Update dependent widgets
	--Update the integration
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
	--Response
	print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.integration.response:gsub(
		"#STATE", wt.Color(db.enhancement.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[1])
	), ns.colors.blue[0]))
	if dbc.disabled then PrintStatus() end
end
local function ResetCommand()
	StaticPopup_Show(resetPopup)
end

SLASH_REMXP1 = ns.strings.chat.keyword
function SlashCmdList.REMXP(line)
	local command, parameter = strsplit(" ", line)
	if command == ns.strings.chat.help.command then PrintCommands()
	elseif command == ns.strings.chat.options.command then options.mainOptions.open()
	elseif command == ns.strings.chat.save.command then SaveCommand()
	elseif command == ns.strings.chat.preset.command then PresetCommand(parameter)
	elseif command == ns.strings.chat.toggle.command then ToggleCommand()
	elseif command == ns.strings.chat.fade.command then FadeCommand()
	elseif command == ns.strings.chat.size.command then SizeCommand(parameter)
	elseif command == ns.strings.chat.integration.command then IntegrationCommand()
	elseif command == ns.strings.chat.reset.command then ResetCommand()
	else PrintInfo() end
end


--[[ INITIALIZATION ]]

local function CreateContextMenuItems()
	return {
		{
			text = ns.strings.options.name:gsub("#ADDON", addonTitle),
			isTitle = true,
			notCheckable = true,
		},
		{
			text = ns.strings.options.main.name,
			notCheckable = true,
			func = function() options.mainOptions.open() end,
		},
		{
			text = ns.strings.options.display.title,
			notCheckable = true,
			func = function() options.displayOptions.open() end,
		},
		{
			text = ns.strings.options.integration.title,
			notCheckable = true,
			func = function() options.integrationOptions.open() end,
		},
		{
			text = ns.strings.options.events.title,
			notCheckable = true,
			func = function() options.notificationsOptions.open() end,
		},
		{
			text = ns.strings.options.advanced.title,
			notCheckable = true,
			func = function() options.advancedOptions.open() end,
		},
	}
end

--[ Main XP Display Setup ]

--Set frame parameters
local function SetUpMainDisplayFrame()
	--Main frame
	remXP:SetToplevel(true)
	remXP:SetSize(114, 14)
	wt.SetPosition(remXP, db.display.position)
	--Main display elements
	mainDisplay:SetPoint("CENTER")
	mainDisplayXP:SetPoint("LEFT")
	mainDisplayRested:SetPoint("LEFT", mainDisplayXP, "RIGHT")
	mainDisplayOverlay:SetPoint("CENTER")
	mainDisplayText:SetPoint("CENTER") --TODO: Add font offset option to fine-tune the position (AND/OR, ad pre-tested offsets to keep each font in the center)
	SetDisplayValues(db, dbc)
	--Make movable
	wt.SetMovability(remXP, true, "SHIFT", mainDisplay, {
		onStop = function()
			--Save the position (for account-wide use)
			db.display.position.anchor, _, _, db.display.position.offset.x, db.display.position.offset.y = remXP:GetPoint()
			--Update in the SavedVariabes DB
			RemainingXPDB.display.position = wt.Clone(db.display.position)
			--Update the GUI options in case the window was open
			options.position.anchor.setSelected(db.display.position.anchor)
			options.position.xOffset:SetValue(db.display.position.offset.x)
			options.position.yOffset:SetValue(db.display.position.offset.y)
			--Chat response
			print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.position.save, ns.colors.blue[0]))
		end,
		onCancel = function()
			--Reset the position
			wt.SetPosition(remXP, db.display.position)
			--Chat response
			print(wt.Color(addonTitle .. ":", ns.colors.purple[0]) .. " " .. wt.Color(ns.strings.chat.position.cancel, ns.colors.blue[0]))
			print(wt.Color(ns.strings.chat.position.error:gsub("#SHIFT", ns.strings.keys.shift), ns.colors.blue[1]))
		end
	})
	--Context menu
	wt.CreateClassicContextMenu({
		parent = mainDisplay,
		menu = CreateContextMenuItems(),
	})
	--Tooltip
	wt.AddTooltip({
		parent = mainDisplay,
		tooltip = ns.tooltip,
		title = ns.strings.xpTooltip.title,
		lines = GetXPTooltipDetails(),
		flipColors = true,
		anchor = "ANCHOR_BOTTOMRIGHT",
		offset = { y = mainDisplay:GetHeight() },
	})
	--Toggling the main display fade on mouseover
	mainDisplay:HookScript('OnEnter', function() if db.display.visibility.fade.enabled then Fade(false) end end)
	mainDisplay:HookScript('OnLeave', function() if db.display.visibility.fade.enabled then Fade(true) end end)
end

--Hide during Pet Battle
function remXP:PET_BATTLE_OPENING_START()
	mainDisplay:Hide()
end
function remXP:PET_BATTLE_CLOSE()
	mainDisplay:Show()
end

--[ Integrated Display Setup ]

--Set up the integrated frame
local function SetUpIntegratedFrame()
	if dbc.disabled then return end
	--Frame & Text
	integratedDisplay:SetPoint("CENTER", MainMenuExpBar, "CENTER", 0, 0)
	integratedDisplay:SetFrameStrata("HIGH")
	integratedDisplay:SetToplevel(true)
	integratedDisplayText:SetPoint("CENTER", 0, 1)
	integratedDisplay:SetSize(MainMenuExpBar:GetWidth(), MainMenuExpBar:GetHeight())
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, false)
	--Context menu
	wt.CreateClassicContextMenu({
		parent = integratedDisplay,
		menu = CreateContextMenuItems(),
	})
end

--Set up the OnEnter and OnLeave functions for the custom integrated frame
integratedDisplay:SetScript("OnEnter", function()
	--Show the enhanced XP text on the default XP bar
	integratedDisplayText:Show()
	UpdateIntegratedDisplay(false)
	--Show the custom tooltip
	wt.AddTooltip({
		parent = integratedDisplay,
		tooltip = ns.tooltip,
		title = ns.strings.xpTooltip.title,
		lines = GetXPTooltipDetails(),
		flipColors = true,
		anchor = "ANCHOR_NONE",
		offset = { x = -11, y = 115 },
		position = { anchor = "BOTTOMRIGHT" },
	})
end)
integratedDisplay:SetScript("OnLeave", function()
	--Hide the enhanced XP text on the default XP bar
	SetIntegrationTextVisibility(db.enhancement.keep, db.enhancement.remaining)
end)

--[ Loading ]

function remXP:ADDON_LOADED(name)
	if name ~= addonNameSpace then return end
	remXP:UnregisterEvent("ADDON_LOADED")
	--Load & check the DBs
	if LoadDBs() then PrintInfo() end
	--Create cross-session character-specific variables
	if csc.xp == nil then csc.xp = {} end
	if cs.compactBackup == nil then cs.compactBackup = true end
	--Load the custom preset
	presets[0].data = wt.Clone(db.customPreset)
	--Set up the interface options
	LoadInterfaceOptions()
end
function remXP:PLAYER_ENTERING_WORLD()
	--Update the XP values
	csc.xp.needed = UnitXPMax("player")
	csc.xp.current = UnitXP("player")
	csc.xp.rested = GetXPExhaustion() or 0
	csc.xp.remaining = csc.xp.needed - csc.xp.current
	--Set up the main frame & text
	SetUpMainDisplayFrame()
	--Set up the integrated frame & text
	SetUpIntegratedFrame()
	--Check max level, update XP texts
	dbc.disabled = UnitLevel("player") >= max
	if not dbc.disabled then
		--Main display
		UpdateXPDisplayText()
		--Integration
		if db.enhancement.enabled then UpdateIntegratedDisplay(db.enhancement.remaining) end
	end
	--Visibility notice
	if not remXP:IsVisible() then PrintStatus(true) end
end
function remXP:QUEST_LOG_UPDATE()
	--Hide the enabled removals
	if db.removals.statusBars then MainMenuExpBar:Hide() end
end


--[[ XP UPDATE EVENTS ]]

--XP update
function remXP:PLAYER_XP_UPDATE(unit)
	if unit ~= "player" then return end
	local gainedXP, _, oldXP = UpdateXPValues()
	--Update XP
	UpdateXPValues()
	if oldXP == csc.xp.current then return end --The event fired without actual XP gain
	--Update UI elements
	UpdateXPDisplayText()
	UpdateXPDisplaySegments()
	UpdateIntegratedDisplay(db.enhancement.remaining)
	--Notification
	if db.notifications.xpGained then
		print(wt.Color(ns.strings.chat.notifications.xpGained.text:gsub(
			"#AMOUNT", wt.Color(wt.FormatThousands(gainedXP), ns.colors.purple[0])
		):gsub(
			"#REMAINING", wt.Color(ns.strings.chat.notifications.xpGained.remaining:gsub(
				"#AMOUNT", wt.Color(wt.FormatThousands(csc.xp.remaining), ns.colors.purple[2])
			):gsub(
				"#NEXT", UnitLevel("player") + 1
			), ns.colors.blue[2])
		), ns.colors.blue[0]))
	end
	--Tooltip
	UpdateXPTooltip()
end

--Level up update
function remXP:PLAYER_LEVEL_UP(newLevel)
	dbc.disabled = newLevel >= max
	if dbc.disabled then
		--Hide the displays
		remXP:hide()
		integratedDisplay:hide()
		--Notification
		print(wt.Color(ns.strings.chat.notifications.lvlUp.disabled.text:gsub(
			"#ADDON", wt.Color(addonTitle, ns.colors.purple[0])
		):gsub(
			"#REASON", wt.Color(ns.strings.chat.notifications.lvlUp.disabled.reason:gsub(
				"#MAX", max
			), ns.colors.blue[2])
		) .. " " .. ns.strings.chat.notifications.lvlUp.congrats, ns.colors.blue[0]))
	else
		--Notification
		if db.notifications.lvlUp.congrats then
			print(wt.Color(ns.strings.chat.notifications.lvlUp.text:gsub(
				"#LEVEL", wt.Color(newLevel, ns.colors.purple[0])
			) .. " " .. wt.Color(ns.strings.chat.notifications.lvlUp.congrats, ns.colors.purple[2]), ns.colors.blue[0]))
			if db.notifications.lvlUp.timePlayed then RequestTimePlayed() end
		end
		--Tooltip
		UpdateXPTooltip()
	end
end

--Rested XP update
function remXP:UPDATE_EXHAUSTION()
	--Update Rested XP
	local _, gainedRestedXP = UpdateXPValues()
	if gainedRestedXP <= 0 then return end
	--Update UI elements
	UpdateXPDisplayText()
	UpdateXPDisplaySegments()
	UpdateIntegratedDisplay(db.enhancement.remaining)
	--Notification
	if db.notifications.restedXP.gained and not (db.notifications.restedXP.significantOnly and gainedRestedXP < 10) then
		print(wt.Color(ns.strings.chat.notifications.restedXPGained.text:gsub(
				"#AMOUNT", wt.Color(gainedRestedXP, ns.colors.purple[0])
			):gsub(
				"#TOTAL", wt.Color(wt.FormatThousands(csc.xp.rested), ns.colors.purple[0])
			):gsub(
				"#PERCENT", wt.Color(ns.strings.chat.notifications.restedXPGained.percent:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 100000) / 1000, 3) .. "%%%%", ns.colors.purple[2])
				), ns.colors.blue[2])
			), ns.colors.blue[0])
		)
	end
	--Tooltip
	UpdateXPTooltip()
end

--Rested status update
function remXP:PLAYER_UPDATE_RESTING()
	if dbc.disabled then return end
	--Notification
	if db.notifications.restedXP.gained and db.notifications.restedXP.accumulated and not IsResting() then
		local s = wt.Color(ns.strings.chat.notifications.restedXPAccumulated.leave, ns.colors.purple[0])
		if (csc.xp.accumulatedRested or 0) > 0 then s = s .. " " .. wt.Color(ns.strings.chat.notifications.restedXPAccumulated.accumulated:gsub(
				"#AMOUNT", wt.Color(wt.FormatThousands(csc.xp.accumulatedRested), ns.colors.purple[0])
			):gsub(
				"#TOTAL", wt.Color(wt.FormatThousands(csc.xp.rested), ns.colors.purple[0])
			):gsub(
				"#PERCENT", wt.Color(ns.strings.chat.notifications.restedXPAccumulated.percent:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 1000000) / 10000, 4) .. "%%%%", ns.colors.purple[2])
				):gsub(
					"#NEXT", wt.Color(UnitLevel("player") + 1, ns.colors.purple[2])
				), ns.colors.blue[2])
			), ns.colors.blue[0])
		else s = s .. " " .. wt.Color(ns.strings.chat.notifications.restedXPAccumulated.noAccumulation, ns.colors.blue[0]) end
		print(s)
	end
	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated)
	--Update XP
	UpdateXPValues()
	--Tooltip
	UpdateXPTooltip()
end