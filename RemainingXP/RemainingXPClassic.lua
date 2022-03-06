--Addon name, namespace
local addonNameSpace, ns = ...
local _, addon = GetAddOnInfo(addonNameSpace)

--WidgetTools reference
local wt = WidgetToolbox[ns.WidgetToolsVersion]


--[[ ASSETS & RESOURCES ]]

--Strings & Localization
local strings = ns.LoadLocale()
strings.chat.keyword = "/remxp"

--Colors
local colors = {
	grey = {
		[0] = { r = 0.54, g = 0.54, b = 0.54 },
		[1] = { r = 0.69, g = 0.69, b = 0.69 },
		[2] = { r = 0.79, g = 0.79, b = 0.79 },
	},
	purple = {
		[0] = { r = 0.83, g = 0.11, b = 0.79 },
		[1] = { r = 0.82, g = 0.34, b = 0.80 },
		[2] = { r = 0.88, g = 0.56, b = 0.86 },
	},
	blue = {
		[0] = { r = 0.06, g = 0.54, b = 1 },
		[1] = { r = 0.46, g = 0.70, b = 0.94 },
		[2] = { r = 0.64, g = 0.80, b = 0.96 },
	},
	rose = {
		[0] = { r = 0.69, g = 0.21, b = 0.47 },
		[1] = { r = 0.84, g = 0.25, b = 0.58 },
		[2] = { r = 0.80, g = 0.47, b = 0.65 },
	},
	peach = {
		[0] = { r = 0.95, g = 0.58, b = 0.52 },
		[1] = { r = 0.96, g = 0.72, b = 0.68 },
		[2] = { r = 0.98, g = 0.81, b = 0.78 },
	}
}

--Fonts
local fonts = {
	[0] = { name = strings.misc.default, path = strings.options.display.text.font.family.default },
	[1] = { name = "Arbutus Slab", path = "Interface/AddOns/RemainingXP/Fonts/ArbutusSlab.ttf" },
	[2] = { name = "Caesar Dressing", path = "Interface/AddOns/RemainingXP/Fonts/CaesarDressing.ttf" },
	[3] = { name = "Germania One", path = "Interface/AddOns/RemainingXP/Fonts/GermaniaOne.ttf" },
	[4] = { name = "Mitr", path = "Interface/AddOns/RemainingXP/Fonts/Mitr.ttf" },
	[5] = { name = "Oxanium", path = "Interface/AddOns/RemainingXP/Fonts/Oxanium.ttf" },
	[6] = { name = "Pattaya", path = "Interface/AddOns/RemainingXP/Fonts/Pattaya.ttf" },
	[7] = { name = "Reem Kufi", path = "Interface/AddOns/RemainingXP/Fonts/ReemKufi.ttf" },
	[8] = { name = "Source Code Pro", path = "Interface/AddOns/RemainingXP/Fonts/SourceCodePro.ttf" },
	[9] = { name = strings.misc.custom, path = "Interface/AddOns/RemainingXP/Fonts/CUSTOM.ttf" },
}

--Textures
local textures = {
	logo = "Interface/AddOns/RemainingXP/Textures/Logo.tga",
}

--Anchor Points
local anchors = {
	[0] = { name = strings.points.top.center, point = "TOP" },
	[1] = { name = strings.points.top.left, point = "TOPLEFT" },
	[2] = { name = strings.points.top.right, point = "TOPRIGHT" },
	[3] = { name = strings.points.bottom.center, point = "BOTTOM" },
	[4] = { name = strings.points.bottom.left, point = "BOTTOMLEFT" },
	[5] = { name = strings.points.bottom.right, point = "BOTTOMRIGHT" },
	[6] = { name = strings.points.left, point = "LEFT" },
	[7] = { name = strings.points.right, point = "RIGHT" },
	[8] = { name = strings.points.center, point = "CENTER" },
}


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
			point = "TOP",
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
		text = {
			visible = true,
			details = false,
			font = {
				family = fonts[0].path,
				size = 11,
				color = { r = 1, g = 1, b = 1, a = 1 },
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
		maxReminder = true,
	},
}
local dbcDefault = {
	hidden = false,
	disabled = false,
}

--[ Preset data ]

local presets = {
	[0] = {
		name = strings.misc.custom, --Custom
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
		name = strings.options.display.quick.presets.list[0], --XP Bar Replacement
		data = {
			position = {
				point = "BOTTOM",
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
		name = strings.options.display.quick.presets.list[1], --XP Bar Left Text
		data = {
			position = {
				point = "BOTTOM",
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
		name = strings.options.display.quick.presets.list[2], --XP Bar Right Text
		data = {
			position = {
				point = "BOTTOM",
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
		name = strings.options.display.quick.presets.list[3], --Player Frame Bar Above
		data = {
			position = {
				point = "TOPLEFT",
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
		name = strings.options.display.quick.presets.list[4], --Player Frame Text Under
		data = {
			position = {
				point = "TOPLEFT",
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
		name = strings.options.display.quick.presets.list[7], --Bottom-Left Chunky Bar
		data = {
			position = {
				point = "BOTTOMLEFT",
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
		name = strings.options.display.quick.presets.list[9], --Bottom-Right Chunky Bar
		data = {
			position = {
				point = "BOTTOMRIGHT",
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
		name = strings.options.display.quick.presets.list[8], --Top-Center Long Bar
		data = {
			position = {
				point = "TOP",
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
dbDefault.customPreset = presets[0].data


--[[ FRAMES & EVENTS ]]

--[ Creating Frames ]

--Main XP display
local remXP = CreateFrame("Frame", addon:gsub("%s+", ""), UIParent) --Main addon frame
local mainDisplay = CreateFrame("Frame", remXP:GetName() .. "MainDisplay", remXP, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayXP = CreateFrame("Frame", mainDisplay:GetName() .. "XP", mainDisplay, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayRested = CreateFrame("Frame", mainDisplay:GetName() .. "Rested", mainDisplay, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayOverlay = CreateFrame("Frame", mainDisplay:GetName() .. "Text", mainDisplay, BackdropTemplateMixin and "BackdropTemplate")
local mainDisplayText = mainDisplayOverlay:CreateFontString(mainDisplay:GetName() .. "Value", "OVERLAY")

--Integrated display
local integratedDisplay = CreateFrame("Frame", remXP:GetName() .. "IntegratedDisplay", UIParent)
local integratedDisplayText = integratedDisplay:CreateFontString(integratedDisplay:GetName() .. "Text", "OVERLAY", "TextStatusBarText")

--[ Registering Events ]

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


--[[ UTILITIES ]]

---Add coloring escape sequences to a string
---@param text string Text to add coloring to
---@param color table Table containing the color values
--- - **r** number ― Red [Range: 0 - 1]
--- - **g** number ― Green [Range: 0 - 1]
--- - **b** number ― Blue [Range: 0 - 1]
--- - **a**? number *optional* ― Opacity [Range: 0 - 1, Default: 1]
---@return string
local function Color(text, color)
	local r, g, b, a = wt.UnpackColor(color)
	return WrapTextInColorCode(text, wt.ColorToHex(r, g, b, a, true, false))
end

---Find the ID of the font provided
---@param fontPath string
---@return integer
local function GetFontID(fontPath)
	local id = 0
	for i = 0, #fonts do
		if fonts[i].path == fontPath then
			id = i
			break
		end
	end
	return id
end

---Find the ID of the anchor point provided
---@param point AnchorPoint
---@return integer
local function GetAnchorID(point)
	local id = 0
	for i = 0, #anchors do
		if anchors[i].point == point then
			id = i
			break
		end
	end
	return id
end

---Set the visibility of a frame based on the value provided
---@param frame Frame
---@param visible boolean
local function SetVisibility(frame, visible)
	if visible then frame:Show() else frame:Hide() end
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

--Restore old data to an account-wide and character-specific DB by matching removed items to known old keys
local function RestoreOldData(data, characterData)
	-- if (wt[addonNameSpace] or {}).recoveredData == nil then return end
	-- for k, v in pairs(wt[addonNameSpace].recoveredData) do
	-- 	if k == "" then data. = v
	-- 	elseif k == "" then characterData. = v
	-- 	end
	-- end
	-- -- Delete the recovery table
	-- wt[addonNameSpace].recoveredData = nil
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
	wt.RemoveMismatch(db, dbDefault)
	wt.RemoveMismatch(dbc, dbcDefault)
	RestoreOldData(db, dbc)
	--Apply any potential fixes to the SavedVariables DBs
	RemainingXPDB = wt.Clone(db)
	RemainingXPDBC = wt.Clone(dbc)
	return firstLoad
end

--[ Max Level ]

--Disable the frame and display if the player is max level
local function CheckMax(level)
	if level >= MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] then
		remXP:Hide()
		dbc.disabled = true
	else dbc.disabled = false end
	return dbc.disabled
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
				Color(
					strings.chat.notifications.restedXPAccumulated.feels, colors.purple[0]
				) .. " " .. Color(
					strings.chat.notifications.restedXPAccumulated.resting, colors.blue[0]
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
			strings.xpBar.text:gsub(
				"#CURRENT", wt.FormatThousands(csc.xp.current)
			):gsub(
				"#NEEDED", wt.FormatThousands(csc.xp.needed)
			):gsub(
				"#REMAINING", wt.FormatThousands(csc.xp.remaining)
			) .. (
				csc.xp.rested > 0 and " + " .. strings.xpBar.rested:gsub(
					"#RESTED", wt.FormatThousands(csc.xp.rested)
				):gsub(
					"#PERCENT", wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100) .. "%%"
				) or ""
			)
		)
	end
end

---Assemble the detailed text lines for xp tooltip
---@return table extraLines Table containing additional string lines to be added to the tooltip text [indexed, 0-based]
--- - **text** string ― Text to be added to the line
--- - **color**? table *optional* ― RGB colors line
--- 	- **r** number ― Red [Range: 0 - 1]
--- 	- **g** number ― Green [Range: 0 - 1]
--- 	- **b** number ― Blue [Range: 0 - 1]
--- - **wrap**? boolean *optional* ― Allow wrapping the line [Default: true]
local function CreateXPTooltipDetails()
	local extraLines = {
		--Current XP
		[0] = {
			text = strings.xpTooltip.current:gsub(
				"#VALUE", Color(wt.FormatThousands(csc.xp.current), colors.purple[1])
			),
			color = colors.purple[0],
		},
		[1] = {
			text = strings.xpTooltip.percentTotal:gsub(
				"#PERCENT", Color(wt.FormatThousands(math.floor(csc.xp.current / csc.xp.needed * 10000) / 100) .. "%%", colors.purple[1])
			),
			color = colors.purple[2],
		},
		--Remaining XP
		[2] = {
			text = "\n" .. strings.xpTooltip.remaining:gsub(
				"#VALUE", Color(wt.FormatThousands(csc.xp.remaining), colors.rose[1])
			),
			color = colors.rose[0],
		},
		[3] = {
			text = strings.xpTooltip.percentTotal:gsub(
				"#PERCENT", Color(wt.FormatThousands(math.floor((csc.xp.remaining / csc.xp.needed) * 10000) / 100) .. "%%", colors.rose[1])
			),
			color = colors.rose[2],
		},
		--Max needed XP
		[4] = {
			text = "\n" .. strings.xpTooltip.needed:gsub(
				"#DATA", Color(strings.xpTooltip.valueNeeded:gsub(
					"#VALUE", Color(wt.FormatThousands(csc.xp.needed), colors.peach[1])
				):gsub(
					"#LEVEL", Color(UnitLevel("player"), colors.peach[1])
				), colors.peach[2])
			),
			color = colors.peach[0],
		},
		--Playtime --TODO: Add time played info
		-- [5] = {
		-- 	text = "\n" .. strings.xpTooltip.timeSpent:gsub("#TIME", "?") .. " (Soon™)",
		-- },
	}
	--Current Rested XP
	if csc.xp.rested > 0 then
		extraLines[#extraLines + 1] = {
			text = "\n" .. strings.xpTooltip.rested:gsub(
				"#VALUE", Color(wt.FormatThousands(csc.xp.rested), colors.blue[1])
			),
			color = colors.blue[0],
		}
		extraLines[#extraLines + 1] = {
			text = strings.xpTooltip.percentRemaining:gsub(
				"#PERCENT", Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100) .. "%%", colors.blue[1])
			),
			color = colors.blue[2],
		}
		--Description
		extraLines[#extraLines + 1] = {
			text = "\n" .. strings.xpTooltip.restedStatus:gsub(
				"#PERCENT", Color("200%%", colors.blue[1])
			),
			color = colors.blue[2],
		}
	end
	--Resting status
	if IsResting() then
		extraLines[#extraLines + 1] = {
			text = "\n" .. strings.chat.notifications.restedXPAccumulated.feels,
			color = colors.blue[0],
		}
	end
	--Accumulated Rested XP
	if (csc.xp.accumulatedRested or 0) > 0 then
		extraLines[#extraLines + 1] = {
			text = strings.xpTooltip.accumulated:gsub(
				"#VALUE", Color(wt.FormatThousands(csc.xp.accumulatedRested or 0), colors.blue[1])
			),
			color = colors.blue[2],
		}
	end
	return extraLines
end

--Update the text of the xp tooltip
local function UpdateXPTooltip()
	if not integratedDisplay:IsMouseOver() and not mainDisplay:IsMouseOver() then return end
	ns.tooltip = wt.AddTooltip(nil, integratedDisplay, "ANCHOR_PRESERVE", strings.xpTooltip.title, strings.xpTooltip.text, CreateXPTooltipDetails())
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

---Move the main display to a location
---@param point AnchorPoint
---@param offsetX number
---@param offsetY number
local function MoveDisplay(point, offsetX, offsetY)
	remXP:ClearAllPoints()
	remXP:SetUserPlaced(false)
	remXP:SetPoint(point, offsetX, offsetY)
	remXP:SetUserPlaced(true)
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
---@param data table DB table to set the main display values from
local function SetDisplayValues(data, characterData)
	--Visibility
	remXP:SetFrameStrata(data.display.visibility.frameStrata)
	SetVisibility(remXP, not (characterData.hidden or characterData.disabled))
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
---@param cvar boolean Whether or not turn off the always shown property of the default XP bar text if false
---@param notice boolean Whether or not show a reload notice when the always shown property of the default XP bar text is changed if true
local function SetIntegrationVisibility(enabled, keep, remaining, cvar, notice)
	if enabled and not dbc.disabled then
		integratedDisplay:Show()
		SetIntegrationTextVisibility(keep, remaining)
		--Turning off the always shown property of the default XP bar text
		if cvar and C_CVar.GetCVarBool("xpBarText") then
			C_CVar.SetCVar("xpBarText", 0)
			--Reload notice
			if notice then
				print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.integration.notice, colors.blue[0]))
				wt.CreateReloadNotice()
			end
		end
	else
		integratedDisplay:Hide()
	end
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
		position = {
			anchor = "TOPLEFT",
			offset = { x = 10, y = -30 }
		},
		width = 120,
		label = strings.options.display.title,
		tooltip = strings.options.display.description:gsub("#ADDON", addon),
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.displayOptionsPage) end,
	})
	--Button: Integration page
	local integration = wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = display,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 120,
		label = strings.options.integration.title,
		tooltip = strings.options.integration.description:gsub("#ADDON", addon),
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.integrationOptionsPage) end,
	})
	--Button: Notifications page
	wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = integration,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 120,
		label = strings.options.events.title,
		tooltip = strings.options.events.description:gsub("#ADDON", addon),
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.notificationsOptionsPage) end,
	})
	--Button: Advanced page
	wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -30 }
		},
		width = 120,
		label = strings.options.advanced.title,
		tooltip = strings.options.advanced.description:gsub("#ADDON", addon),
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.advancedOptionsPage) end,
	})
end
local function CreateAboutInfo(parentFrame)
	--Text: Version
	local version = wt.CreateText({
		frame = parentFrame,
		name = "Version",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -33 }
		},
		width = 84,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.version:gsub("#VERSION", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Version"), "FFFFFFFF")),
	})
	--Text: Date
	local date = wt.CreateText({
		frame = parentFrame,
		name = "Date",
		position = {
			anchor = "TOPLEFT",
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 102,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.date:gsub(
			"#DATE", WrapTextInColorCode(strings.misc.date:gsub(
				"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
			):gsub(
				"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
			):gsub(
				"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
			), "FFFFFFFF")
		),
	})
	--Text: Author
	local author = wt.CreateText({
		frame = parentFrame,
		name = "Author",
		position = {
			anchor = "TOPLEFT",
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 186,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.author:gsub("#AUTHOR", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Author"), "FFFFFFFF")),
	})
	--Text: License
	wt.CreateText({
		frame = parentFrame,
		name = "License",
		position = {
			anchor = "TOPLEFT",
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, y = 0 }
		},
		width = 156,
		justify = "LEFT",
		template = "GameFontNormalSmall",
		text = strings.options.main.about.license:gsub("#LICENSE", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "X-License"), "FFFFFFFF")),
	})
	--EditScrollBox: Changelog
	options.about.changelog = wt.CreateEditScrollBox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -12 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 139 },
		fontObject = "GameFontDisableSmall",
		text = ns.GetChangelog(),
		label = strings.options.main.about.changelog.label,
		tooltip = strings.options.main.about.changelog.tooltip,
		scrollSpeed = 45,
		readOnly = true,
	})
end
local function CreateSupportInfo(parentFrame)
	--Copybox: CurseForge
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "CurseForge",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -33 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "curseforge.com/wow/addons/remaining-xp",
		label = strings.options.main.support.curseForge .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Wago
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Wago",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -33 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "addons.wago.io/addons/remaining-xp",
		label = strings.options.main.support.wago .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: BitBucket
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "BitBucket",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -70 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "bitbucket.org/Arxareon/remaining-xp",
		label = strings.options.main.support.bitBucket .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Issues
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Issues",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -70 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		text = "bitbucket.org/Arxareon/remaining-xp/issues",
		label = strings.options.main.support.issues .. ":",
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
end
local function CreateMainCategoryPanels(parentFrame) --Add the main page widgets to the category panel frame
	--Shortcuts
	local shortcutsPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 64 },
		title = strings.options.main.shortcuts.title,
		description = strings.options.main.shortcuts.description:gsub("#ADDON", addon),
	})
	CreateOptionsShortcuts(shortcutsPanel)
	--About
	local aboutPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = shortcutsPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 231 },
		title = strings.options.main.about.title,
		description = strings.options.main.about.description:gsub("#ADDON", addon),
	})
	CreateAboutInfo(aboutPanel)
	--Support
	local supportPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = aboutPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 111 },
		title = strings.options.main.support.title,
		description = strings.options.main.support.description:gsub("#ADDON", addon),
	})
	CreateSupportInfo(supportPanel)
end

--Display page
local function CreateQuickOptions(parentFrame)
	--Checkbox: Hidden
	options.visibility.hidden = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		label = strings.options.display.quick.hidden.label,
		tooltip = strings.options.display.quick.hidden.tooltip:gsub("#ADDON", addon),
		onClick = function(self) SetVisibility(remXP, not (self:GetChecked() or dbc.disabled)) end,
		optionsData = {
			storageTable = dbc,
			key = "hidden",
		},
	})
	--Dropdown: Apply a preset
	local presetItems = {}
	for i = 0, #presets do
		presetItems[i] = {}
		presetItems[i].text = presets[i].name
		presetItems[i].onSelect = function()
			if not dbc.disabled then
				--Update the display
				remXP:Show()
				remXP:SetFrameStrata(presets[i].data.visibility.frameStrata)
				ResizeDisplay(presets[i].data.background.size.width, presets[i].data.background.size.height)
				MoveDisplay(presets[i].data.position.point, presets[i].data.position.offset.x, presets[i].data.position.offset.y)
				SetDisplayBackdrop(presets[i].data.background.visible, {
					bg = wt.PackColor(options.background.colors.bg.getColor()),
					xp = wt.PackColor(options.background.colors.xp.getColor()),
					rested = wt.PackColor(options.background.colors.rested.getColor()),
					border = wt.PackColor(options.background.colors.border.getColor()),
				})
				Fade(options.visibility.fade.toggle:GetChecked())
				--Update the options
				options.visibility.hidden:SetChecked(false)
				UIDropDownMenu_SetSelectedValue(options.position.anchor, GetAnchorID(presets[i].data.position.point))
				UIDropDownMenu_SetText(options.position.anchor, anchors[GetAnchorID(presets[i].data.position.point)].name)
				options.position.xOffset:SetValue(presets[i].data.position.offset.x)
				options.position.yOffset:SetValue(presets[i].data.position.offset.y)
				options.background.visible:SetChecked(presets[i].data.background.visible)
				options.background.visible:SetAttribute("loaded", true) --Update dependent widgets
				options.background.size.width:SetValue(presets[i].data.background.size.width)
				options.background.size.height:SetValue(presets[i].data.background.size.height)
				options.visibility.raise:SetChecked(presets[i].data.visibility.frameStrata == "HIGH")
				--Update the DBs
				db.display.background.visible = presets[i].data.background.visible
				db.display.background.size.width = presets[i].data.background.size.width
				db.display.background.size.height = presets[i].data.background.size.height
				db.display.visibility.frameStrata = presets[i].data.visibility.frameStrata
			end
		end
	end
	options.visibility.presets = wt.CreateDropdown({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -30 }
		},
		width = 160,
		label = strings.options.display.quick.presets.label,
		tooltip = strings.options.display.quick.presets.tooltip,
		items = presetItems,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		onLoad = function(self)
			UIDropDownMenu_SetSelectedValue(self, nil)
			UIDropDownMenu_SetText(self, strings.options.display.quick.presets.select)
		end,
	})
	--Button & Popup: Save Custom preset
	local savePopup = wt.CreatePopup({
		name = "SAVEPRESET",
		text = strings.options.display.quick.savePreset.warning,
		accept = strings.misc.override,
		onAccept = function()
			--Update the Custom preset
			presets[0].data.position.point, _, _, presets[0].data.position.offset.x, presets[0].data.position.offset.y = remXP:GetPoint()
			presets[0].data.visibility.frameStrata = options.visibility.raise:GetChecked() and "HIGH" or "MEDIUM"
			presets[0].data.background.visible = options.background.visible:GetChecked()
			presets[0].data.background.size = { width = options.background.size.width:GetValue(), height = options.background.size.height:GetValue() }
			--Save the Custom preset
			db.customPreset = presets[0].data
			--Response
			print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.save.response, colors.blue[0]))
		end,
	})
	wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -50 }
		},
		width = 160,
		label = strings.options.display.quick.savePreset.label,
		tooltip = strings.options.display.quick.savePreset.tooltip,
		onClick = function() StaticPopup_Show(savePopup) end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
	})
end
local function CreatePositionOptions(parentFrame)
	--Dropdown: Anchor Point
	local anchorItems = {}
	for i = 0, #anchors do
		anchorItems[i] = {}
		anchorItems[i].text = anchors[i].name
		anchorItems[i].onSelect = function() MoveDisplay(anchors[i].point, options.position.xOffset:GetValue(), options.position.yOffset:GetValue()) end
	end
	options.position.anchor = wt.CreateDropdown({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = -6, y = -30 }
		},
		label = strings.options.display.position.anchor.label,
		tooltip = strings.options.display.position.anchor.tooltip,
		items = anchorItems,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		optionsData = {
			storageTable = db.display.position,
			key = "point",
			convertSave = function(value) return anchors[value].point end,
			convertLoad = function(point) return GetAnchorID(point) end,
		},
	})
	--Slider: X Offset
	options.position.xOffset = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -30 }
		},
		label = strings.options.display.position.xOffset.label,
		tooltip = strings.options.display.position.xOffset.tooltip,
		value = { min = -500, max = 500, fractional = 2 },
		onValueChanged = function(_, value)
			MoveDisplay(anchors[UIDropDownMenu_GetSelectedValue(options.position.anchor)].point, value, options.position.yOffset:GetValue())
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		optionsData = {
			storageTable = db.display.position.offset,
			key = "x",
		},
	})
	--Slider: Y Offset
	options.position.yOffset = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -30 }
		},
		label = strings.options.display.position.yOffset.label,
		tooltip = strings.options.display.position.yOffset.tooltip,
		value = { min = -500, max = 500, fractional = 2 },
		onValueChanged = function(_, value)
			MoveDisplay(anchors[UIDropDownMenu_GetSelectedValue(options.position.anchor)].point, options.position.xOffset:GetValue(), value)
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		optionsData = {
			storageTable = db.display.position.offset,
			key = "y",
		},
	})
end
local function CreateTextOptions(parentFrame)
	--Checkbox: Visible
	options.text.visible = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		label = strings.options.display.text.visible.label,
		tooltip = strings.options.display.text.visible.tooltip,
		onClick = function(self) SetVisibility(mainDisplayText, self:GetChecked()) end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		optionsData = {
			storageTable = db.display.text,
			key = "visible",
		},
	})
	--Checkbox: Details
	options.text.details = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -30 }
		},
		autoOffset = true,
		label = strings.options.display.text.details.label,
		tooltip = strings.options.display.text.details.tooltip,
		onClick = function(self)
			db.display.text.details = self:GetChecked()
			UpdateXPDisplayText()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.text.visible },
		},
		optionsData = {
			storageTable = db.display.text,
			key = "details",
		},
	})
	--Dropdown: Font family
	local fontItems = {}
	for i = 0, #fonts do
		fontItems[i] = {}
		fontItems[i].text = fonts[i].name
		fontItems[i].onSelect = function()
			mainDisplayText:SetFont(fonts[i].path, options.text.font.size:GetValue(), "THINOUTLINE")
			--Refresh the text so the font will be applied even the first time as well not just subsequent times
			local text = mainDisplayText:GetText()
			mainDisplayText:SetText("")
			mainDisplayText:SetText(text)
		end
	end
	options.text.font.family = wt.CreateDropdown({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = -6, y = -60 }
		},
		label = strings.options.display.text.font.family.label,
		tooltip = strings.options.display.text.font.family.tooltip[0],
		tooltipExtra = {
			[0] = { text = strings.options.display.text.font.family.tooltip[1] },
			[1] = { text = "\n" .. strings.options.display.text.font.family.tooltip[2]:gsub("#OPTION_CUSTOM", strings.misc.custom):gsub("#FILE_CUSTOM", "CUSTOM.ttf") },
			[2] = { text = "[WoW]\\Interface\\AddOns\\" .. addonNameSpace .. "\\Fonts\\", color = { r = 0.185, g = 0.72, b = 0.84 }, wrap = false },
			[3] = { text = strings.options.display.text.font.family.tooltip[3]:gsub("#FILE_CUSTOM", "CUSTOM.ttf") },
			[4] = { text = strings.options.display.text.font.family.tooltip[4], color = { r = 0.89, g = 0.65, b = 0.40 } },
		},
		items = fontItems,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.text.visible },
		},
		optionsData = {
			storageTable = db.display.text.font,
			key = "family",
			convertSave = function(value) return fonts[value].path end,
			convertLoad = function(font) return GetFontID(font) end,
		},
	})
	--Slider: Font size
	options.text.font.size = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -60 }
		},
		label = strings.options.display.text.font.size.label,
		tooltip = strings.options.display.text.font.size.tooltip .. "\n\n" .. strings.misc.default .. ": " .. dbDefault.display.text.font.size,
		value = { min = 8, max = 64, step = 1 },
		onValueChanged = function(_, value) mainDisplayText:SetFont(mainDisplayText:GetFont(), value, "THINOUTLINE") end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.text.visible },
		},
		optionsData = {
			storageTable = db.display.text.font,
			key = "size",
		},
	})
	--Color Picker: Font color
	options.text.font.color = wt.CreateColorPicker({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -12, y = -60 }
		},
		label = strings.options.display.text.font.color.label,
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
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.text.visible },
		},
		optionsData = {
			storageTable = db.display.text.font,
			key = "color",
		},
	})
end
local  function CreateBackgroundOptions(parentFrame)
	--Checkbox: Visible
	options.background.visible = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		label = strings.options.display.background.visible.label,
		tooltip = strings.options.display.background.visible.tooltip,
		onClick = function(self)
			SetDisplayBackdrop(self:GetChecked(), {
				bg = wt.PackColor(options.background.colors.bg.getColor()),
				xp = wt.PackColor(options.background.colors.xp.getColor()),
				rested = wt.PackColor(options.background.colors.rested.getColor()),
				border = wt.PackColor(options.background.colors.border.getColor()),
			})
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		optionsData = {
			storageTable = db.display.background,
			key = "visible",
		},
	})
	--Slider: Background Width
	options.background.size.width = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -32 }
		},
		label = strings.options.display.background.size.width.label,
		tooltip = strings.options.display.background.size.width.tooltip,
		value = { min = 64, max = UIParent:GetWidth() - math.fmod(UIParent:GetWidth(), 1) , step = 2 },
		onValueChanged = function(_, value) ResizeDisplay(value, options.background.size.height:GetValue()) end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.size,
			key = "width",
		},
	})
	--Slider: Background Height
	options.background.size.height = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -32 }
		},
		label = strings.options.display.background.size.height.label,
		tooltip = strings.options.display.background.size.height.tooltip,
		value = { min = 2, max = 80, step = 2 },
		onValueChanged = function(_, value) ResizeDisplay(options.background.size.width:GetValue(), value) end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.size,
			key = "height",
		},
	})
	--Color Picker: Background color
	options.background.colors.bg = wt.CreateColorPicker({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 12, y = -90 }
		},
		label = strings.options.display.background.colors.bg.label,
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
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.colors,
			key = "bg",
		},
	})
	--Color Picker: Border color
	options.background.colors.border = wt.CreateColorPicker({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = -71, y = -90 }
		},
		label = strings.options.display.background.colors.border.label,
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
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.colors,
			key = "border",
		},
	})
	--Color Picker: XP color
	options.background.colors.xp = wt.CreateColorPicker({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 71, y = -90 }
		},
		label = strings.options.display.background.colors.xp.label,
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
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.colors,
			key = "xp",
		},
	})
	--Color Picker: Rested color
	options.background.colors.rested = wt.CreateColorPicker({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -12, y = -90 }
		},
		label = strings.options.display.background.colors.rested.label,
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
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.colors,
			key = "rested",
		},
	})
end
local function CreateVisibilityOptions(parentFrame)
	--Checkbox: Raise
	options.visibility.raise = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		autoOffset = true,
		label = strings.options.display.visibility.raise.label,
		tooltip = strings.options.display.visibility.raise.tooltip,
		onClick = function(self) remXP:SetFrameStrata(self:GetChecked() and "HIGH" or "MEDIUM") end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
		},
		optionsData = {
			storageTable = db.display.visibility,
			key = "frameStrata",
			convertSave = function(enabled) return enabled and "HIGH" or "MEDIUM" end,
			convertLoad = function(strata) return strata == "HIGH" end,
		},
	})
	--Checkbox: Fade toggle
	options.visibility.fade.toggle = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = options.visibility.raise,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -4 }
		},
		label = strings.options.display.visibility.fade.label,
		tooltip = strings.options.display.visibility.fade.tooltip,
		onClick = function(self)
			db.display.visibility.fade.enabled = self:GetChecked()
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.text.visible, evaluate = function(state) return state or options.background.visible:GetChecked() end, },
			[2] = { frame = options.background.visible, evaluate = function(state) return state or options.text.visible:GetChecked() end, },
		},
		optionsData = {
			storageTable = db.display.visibility.fade,
			key = "enabled",
		},
	})
	--Slider: Text Fade Intensity
	options.visibility.fade.text = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -60 }
		},
		label = strings.options.display.visibility.fade.text.label,
		tooltip = strings.options.display.visibility.fade.text.tooltip,
		value = { min = 0, max = 1, step = 0.05 },
		onValueChanged = function(_, value)
			db.display.visibility.fade.text = value
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.text.visible },
			[2] = { frame = options.visibility.fade.toggle },
		},
		optionsData = {
			storageTable = db.display.visibility.fade,
			key = "text",
		},
	})
	--Slider: Background Fade Intensity
	options.visibility.fade.background = wt.CreateSlider({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -60 }
		},
		label = strings.options.display.visibility.fade.background.label,
		tooltip = strings.options.display.visibility.fade.background.tooltip,
		value = { min = 0, max = 1, step = 0.05 },
		onValueChanged = function(_, value)
			db.display.visibility.fade.background = value
			Fade()
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
			[2] = { frame = options.visibility.fade.toggle },
		},
		optionsData = {
			storageTable = db.display.visibility.fade,
			key = "background",
		},
	})
end
local function CreateDisplayCategoryPanels(parentFrame) --Add the display page widgets to the category panel frame
	--Quick settings
	local quickOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -78 }
		},
		size = { height = 84 },
		title = strings.options.display.quick.title,
		description = strings.options.display.quick.description:gsub("#ADDON", addon),
	})
	CreateQuickOptions(quickOptions)
	--Position
	local positionOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = quickOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 88 },
		title = strings.options.display.position.title,
		description = strings.options.display.position.description,
	})
	CreatePositionOptions(positionOptions)
	--Text
	local textOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = positionOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 118 },
		title = strings.options.display.text.title,
		description = strings.options.display.text.description,
	})
	CreateTextOptions(textOptions)
	--Background
	local backgroundOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Background",
		position = {
			anchor = "TOPLEFT",
			relativeTo = textOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 140 },
		title = strings.options.display.background.title,
		description = strings.options.display.background.description:gsub("#ADDON", addon),
	})
	CreateBackgroundOptions(backgroundOptions)
	--Visibility
	local visibilityOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = backgroundOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 118 },
		title = strings.options.display.visibility.title,
		description = strings.options.display.visibility.description:gsub("#ADDON", addon),
	})
	CreateVisibilityOptions(visibilityOptions)
end

--Integration page
local function CreateEnhancementOptions(parentFrame)
	--Checkbox: Enable integration
	options.enhancement.toggle = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		label = strings.options.integration.enhancement.toggle.label,
		tooltip = strings.options.integration.enhancement.toggle.tooltip,
		onClick = function(self)
			local value = self:GetChecked()
			SetIntegrationVisibility(value, options.enhancement.keep:GetChecked(), options.enhancement.remaining:GetChecked(), false, false)
			db.enhancement.enabled = value
		end,
		optionsData = {
			storageTable = db.enhancement,
			key = "enabled",
		},
	})
	--Checkbox: Keep text
	options.enhancement.keep = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -30 }
		},
		autoOffset = true,
		label = strings.options.integration.enhancement.keep.label,
		tooltip = strings.options.integration.enhancement.keep.tooltip,
		onClick = function(self)
			local value = self:GetChecked()
			SetIntegrationTextVisibility(value, options.enhancement.remaining:GetChecked())
			db.enhancement.keep = value
		end,
		dependencies = {
			[0] = { frame = options.enhancement.toggle },
		},
		optionsData = {
			storageTable = db.enhancement,
			key = "keep",
		},
	})
	--Checkbox: Keep only remaining XP text
	options.enhancement.remaining = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = 0, y = -30 }
		},
		autoOffset = true,
		label = strings.options.integration.enhancement.remaining.label,
		tooltip = strings.options.integration.enhancement.remaining.tooltip,
		onClick = function(self)
			local value = self:GetChecked()
			SetIntegrationTextVisibility(options.enhancement.keep:GetChecked(), value)
			db.enhancement.remaining = value
		end,
		dependencies = {
			[0] = { frame = options.enhancement.toggle },
			[1] = { frame = options.enhancement.keep },
		},
		optionsData = {
			storageTable = db.enhancement,
			key = "remaining",
		},
	})
end
local function CreateRemovalsOptions(parentFrame)
	--Checkbox: Hide the status bars
	options.removals.statusBars = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		autoOffset = true,
		label = strings.options.integration.removals.statusBars.labelClassic,
		tooltip = strings.options.integration.removals.statusBars.tooltipClassic:gsub("#ADDON", addon),
		onClick = function(self) SetVisibility(MainMenuExpBar, not self:GetChecked()) end,
		optionsData = {
			storageTable = db.removals,
			key = "statusBars",
		},
	})
end
local function CreateIntegrationCategoryPanels(parentFrame) --Add the notification page widgets to the category panel frame
	--Enhancement
	local enhancementOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Enhancement",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 64 },
		title = strings.options.integration.enhancement.title,
		description = strings.options.integration.enhancement.description:gsub("#ADDON", addon),
	})
	CreateEnhancementOptions(enhancementOptions)
	--Removals
	local removalsOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Removals",
		position = {
			anchor = "TOPLEFT",
			relativeTo = enhancementOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 64 },
		title = strings.options.integration.removals.title,
		description = strings.options.integration.removals.description:gsub("#ADDON", addon),
	})
	CreateRemovalsOptions(removalsOptions)
end

--Notifications page
local function CreateNotificationsOptions(parentFrame)
	--Checkbox: XP gained
	options.notifications.xpGained = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 8, y = -30 }
		},
		label = strings.options.events.notifications.xpGained.label,
		tooltip = strings.options.events.notifications.xpGained.tooltip,
		onClick = function(self) db.notifications.xpGained = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications,
			key = "xpGained",
		},
	})
	--Checkbox: Rested XP gained
	options.notifications.restedXPGained = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = options.notifications.xpGained,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -4 }
		},
		label = strings.options.events.notifications.restedXPGained.label,
		tooltip = strings.options.events.notifications.restedXPGained.tooltip,
		onClick = function(self) db.notifications.restedXP.gained = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications.restedXP,
			key = "gained",
		},
	})
	--Checkbox: Significant Rested XP Updates Only
	options.notifications.significantRestedOnly = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -60 }
		},
		autoOffset = true,
		label = strings.options.events.notifications.restedXPGained.significantOnly.label,
		tooltip = strings.options.events.notifications.restedXPGained.significantOnly.tooltip,
		onClick = function(self) db.notifications.restedXP.significantOnly = self:GetChecked() end,
		dependencies = {
			[0] = { frame = options.notifications.restedXPGained },
		},
		optionsData = {
			storageTable = db.notifications.restedXP,
			key = "significantOnly",
		},
	})
	--Checkbox: Accumulated Rested XP
	options.notifications.restedXPAccumulated = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			offset = { x = 0, y = -60 }
		},
		autoOffset = true,
		label = strings.options.events.notifications.restedXPGained.accumulated.label,
		tooltip = strings.options.events.notifications.restedXPGained.accumulated.tooltip[0],
		tooltipExtra = {
			[0] = { text = strings.options.events.notifications.restedXPGained.accumulated.tooltip[1]:gsub(
				"#ADDON", addon
			), color = { r = 0.89, g = 0.65, b = 0.40 } },
		},
		onClick = function(self)
			local value = self:GetChecked()
			SetRestedAccumulation(options.notifications.restedXPGained:GetChecked() and value and dbc.disabled)
			db.notifications.restedXP.accumulated = value
		end,
		dependencies = {
			[0] = { frame = options.notifications.restedXPGained },
		},
		optionsData = {
			storageTable = db.notifications.restedXP,
			key = "accumulated",
		},
	})
	--Checkbox: Level up
	options.notifications.lvlUp = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = options.notifications.restedXPGained,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -4 }
		},
		label = strings.options.events.notifications.lvlUp.label,
		tooltip = strings.options.events.notifications.lvlUp.tooltip,
		onClick = function(self) db.notifications.lvlUp.congrats = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications.lvlUp,
			key = "congrats",
		},
	})
	--Checkbox: Time played
	options.notifications.timePlayed = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -90 }
		},
		autoOffset = true,
		label = strings.options.events.notifications.lvlUp.timePlayed.label .. " (Soon™)",
		tooltip = strings.options.events.notifications.lvlUp.timePlayed.tooltip,
		onClick = function(self) db.notifications.lvlUp.timePlayed = self:GetChecked() end,
		disabled = true --TODO: Add time played notifications
		-- dependencies = {
		-- 	[0] = { frame = options.notifications.lvlUp },
		-- },
		-- optionsData = {
		-- 	storageTable = db.notifications.lvlUp,
		-- 	key = "timePlayed",
		-- },
	})
	--Checkbox: Level up
	options.notifications.maxReminder = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = options.notifications.lvlUp,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -4 }
		},
		label = strings.options.events.notifications.maxReminder.label,
		tooltip = strings.options.events.notifications.maxReminder.tooltip:gsub("#ADDON", addon),
		onClick = function(self) db.notifications.maxReminder = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications,
			key = "maxReminder",
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
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 154 },
		title = strings.options.events.notifications.title,
		description = strings.options.events.notifications.description,
	})
	CreateNotificationsOptions(notificationsOptions)
	---Logs
	local logsOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = notificationsOptions,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 64 },
		title = strings.options.events.logs.title,
		description = strings.options.events.logs.description,
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
		name = "IMPORT",
		text = strings.options.advanced.backup.warning,
		accept = strings.options.advanced.backup.import,
		onAccept = function()
			--Load from string to a temporary table
			local success, t = pcall(loadstring("return " .. wt.ClearFormatting(options.backup.string:GetText())))
			if success and type(t) == "table" then
				--Run DB checkup on the loaded table
				wt.RemoveEmpty(t.account, CheckValidity)
				wt.RemoveEmpty(t.character, CheckValidity)
				wt.AddMissing(t.account, db)
				wt.AddMissing(t.character, dbc)
				wt.RemoveMismatch(t.account, db)
				wt.RemoveMismatch(t.character, dbc)
				RestoreOldData(t.account, t.character)
				--Copy values from the loaded DBs to the addon DBs
				wt.CopyValues(t.account, db)
				wt.CopyValues(t.character, dbc)
				--Update the Custom preset
				presets[0].data = db.customPreset
				--Main display
				MoveDisplay(db.display.position.point, db.display.position.offset.x, db.display.position.offset.y)
				SetDisplayValues(db, dbc)
				--Enhancement
				SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
				--Removals
				if t.account.removals.statusBars then MainMenuExpBar:Hide() else MainMenuExpBar:Show() end
				--Update the interface options
				wt.LoadOptionsData()
			else print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.options.advanced.backup.error, colors.blue[0])) end
		end
	})
	local backupBox
	options.backup.string, backupBox = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "ImportExport",
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -30 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 276 },
		maxLetters = 5400,
		fontObject = "GameFontWhiteSmall",
		label = strings.options.advanced.backup.backupBox.label,
		tooltip = strings.options.advanced.backup.backupBox.tooltip[0],
		tooltipExtra = {
			[0] = { text = strings.options.advanced.backup.backupBox.tooltip[1] },
			[1] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[2]:gsub("#ENTER", strings.keys.enter) },
			[2] = { text = strings.options.advanced.backup.backupBox.tooltip[3], color = { r = 0.89, g = 0.65, b = 0.40 } },
			[3] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.92, g = 0.34, b = 0.23 } },
		},
		scrollSpeed = 60,
		onEnterPressed = function() StaticPopup_Show(importPopup) end,
		onEscapePressed = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
		onLoad = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
	})
	--Checkbox: Compact
	options.backup.compact = wt.CreateCheckbox({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMLEFT",
			offset = { x = -8, y = -13 }
		},
		label = strings.options.advanced.backup.compact.label,
		tooltip = strings.options.advanced.backup.compact.tooltip,
		onClick = function(self)
			options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, self:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			options.backup.string:SetFocus()
			options.backup.string:ClearFocus()
		end,
		optionsData = {
			storageTable = cs,
			key = "compactBackup",
		},
	})
	--Button: Load
	local load = wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMRIGHT",
			offset = { x = 6, y = -13 }
		},
		width = 80,
		label = strings.options.advanced.backup.load.label,
		tooltip = strings.options.advanced.backup.load.tooltip,
		onClick = function() StaticPopup_Show(importPopup) end,
	})
	--Button: Reset
	wt.CreateButton({
		parent = parentFrame,
		position = {
			anchor = "TOPRIGHT",
			relativeTo = load,
			relativePoint = "TOPLEFT",
			offset = { x = -10, y = 0 }
		},
		width = 80,
		label = strings.options.advanced.backup.reset.label,
		tooltip = strings.options.advanced.backup.reset.tooltip,
		onClick = function()
			options.backup.string:SetText("") --Remove text to make sure OnTextChanged will get called
			options.backup.string:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true))
			--Set focus after text change to set the scroll to the top and refresh the position character counter
			options.backup.string:SetFocus()
			options.backup.string:ClearFocus()
		end,
	})
end
local function CreateAdvancedCategoryPanels(parentFrame) --Add the advanced page widgets to the category panel frame
	--Profiles
	local profilesPanel = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			offset = { x = 16, y = -82 }
		},
		size = { height = 64 },
		title = strings.options.advanced.profiles.title,
		description = strings.options.advanced.profiles.description:gsub("#ADDON", addon),
	})
	CreateOptionsProfiles(profilesPanel)
	---Backup
	local backupOptions = wt.CreatePanel({
		parent = parentFrame,
		position = {
			anchor = "TOPLEFT",
			relativeTo = profilesPanel,
			relativePoint = "BOTTOMLEFT",
			offset = { x = 0, y = -32 }
		},
		size = { height = 374 },
		title = strings.options.advanced.backup.title,
		description = strings.options.advanced.backup.description:gsub("#ADDON", addon),
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
	MoveDisplay(db.display.position.point, db.display.position.offset.x, db.display.position.offset.y)
	SetDisplayValues(db, dbc)
	--Enhancement
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, false)
	--Removals
	if db.removals.statusBars then MainMenuExpBar:Hide() else MainMenuExpBar:Show() end
end
--Restore all the settings under the main option category to their default values
local function DefaultOptions()
	if db.enhancement.enabled ~= dbDefault.enhancement.enabled then
		wt.CreateReloadNotice()
		print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.integration.notice, colors.blue[0]))
	end
	--Reset the DBs
	RemainingXPDB = wt.Clone(dbDefault)
	RemainingXPDBC = wt.Clone(dbcDefault)
	wt.CopyValues(dbDefault, db)
	wt.CopyValues(dbcDefault, dbc)
	--Reset the Custom preset
	presets[0].data = db.customPreset
	--Reset the main display
	MoveDisplay(db.display.position.point, db.display.position.offset.x, db.display.position.offset.y)
	SetDisplayValues(db, dbc)
	--Update the enhancement
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
	--Update the removals
	if db.removals.statusBars then MainMenuExpBar:Hide() else MainMenuExpBar:Show() end
	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated and dbc.disabled)
	--Update the interface options
	wt.LoadOptionsData()
	--Set the preset selection to Custom
	UIDropDownMenu_SetSelectedValue(options.visibility.presets, 0)
	UIDropDownMenu_SetText(options.visibility.presets, presets[0].name)
	--Notification
	print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.options.defaults, colors.blue[0]))
end

--Create and add the options category panel frames to the WoW Interface Options
local function LoadInterfaceOptions()
	--Main options panel
	options.mainOptionsPage = wt.CreateOptionsPanel({
		name = addon:gsub("%s+", "") .. "Main",
		title = addon,
		description = strings.options.main.description:gsub("#ADDON", addon):gsub("#KEYWORD", strings.chat.keyword),
		logo = textures.logo,
		titleLogo = true,
		okay = SaveOptions,
		cancel = CancelChanges,
		default = DefaultOptions,
	})
	CreateMainCategoryPanels(options.mainOptionsPage) --Add categories & GUI elements to the panel
	--Display options panel
	local displayOptionsScrollFrame
	options.displayOptionsPage, displayOptionsScrollFrame = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		name = addon:gsub("%s+", "") .. "Display",
		title = strings.options.display.title,
		description = strings.options.display.description:gsub("#ADDON", addon),
		logo = textures.logo,
		scroll = {
			height = 766,
			speed = 42,
		},
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateDisplayCategoryPanels(displayOptionsScrollFrame) --Add categories & GUI elements to the panel
	--Integration options panel
	options.integrationOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		name = addon:gsub("%s+", "") .. "Integration",
		title = strings.options.integration.title,
		description = strings.options.integration.description:gsub("#ADDON", addon),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateIntegrationCategoryPanels(options.integrationOptionsPage) --Add categories & GUI elements to the panel
	--Notifications options panel
	options.notificationsOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		name = addon:gsub("%s+", "") .. "Notifications",
		title = strings.options.events.title,
		description = strings.options.events.description:gsub("#ADDON", addon),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateEventsCategoryPanels(options.notificationsOptionsPage) --Add categories & GUI elements to the panel
	--Advanced options panel
	options.advancedOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		name = addon:gsub("%s+", "") .. "Advanced",
		title = strings.options.advanced.title,
		description = strings.options.advanced.description:gsub("#ADDON", addon),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateAdvancedCategoryPanels(options.advancedOptionsPage) --Add categories & GUI elements to the panel
end


--[[ CHAT CONTROL ]]

--Chat control utilities
local function PrintStatus()
	local status
	if dbc.disabled and db.notifications.maxReminder then
		status = Color(strings.chat.status.disabled:gsub(
			"#ADDON", Color(addon, colors.purple[0])
		) .." " ..  Color(strings.chat.status.max:gsub(
			"#MAX", MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
		), colors.blue[2]), colors.blue[0])
	else
		status = Color(addon .. ":", colors.purple[0]) .. " " .. Color(
			remXP:IsVisible() and strings.chat.status.visible or strings.chat.status.hidden, colors.blue[0]
		):gsub(
			"#FADE", Color(strings.chat.status.fade:gsub(
				"#STATE", Color(db.display.visibility.fade.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[1])
			), colors.blue[1])
		)
	end
	print(status)
end
local function PrintInfo()
	print(Color(strings.chat.help.thanks:gsub("#ADDON", Color(addon, colors.purple[0])), colors.blue[0]))
	PrintStatus()
	print(Color(strings.chat.help.hint:gsub( "#HELP_COMMAND", Color(strings.chat.keyword .. " " .. strings.chat.help.command, colors.purple[2])), colors.blue[2]))
	print(Color(strings.chat.help.move:gsub("#SHIFT", Color(strings.keys.shift, colors.purple[2])):gsub("#ADDON", addon), colors.blue[2]))
end
local function PrintCommands()
	print(Color(addon, colors.purple[0]) .. " ".. Color(strings.chat.help.list .. ":", colors.blue[0]))
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
			description = strings.chat.preset.description:gsub(
				"#INDEX", Color(strings.chat.preset.command .. " " .. 0, colors.purple[2])
			)
		},
		[3] = {
			command = strings.chat.toggle.command,
			description = strings.chat.toggle.description:gsub(
				"#HIDDEN", Color(dbc.hidden and strings.chat.toggle.hidden or strings.chat.toggle.notHidden, colors.purple[2])
			)
		},
		[4] = {
			command = strings.chat.fade.command,
			description = strings.chat.fade.description:gsub(
				"#STATE", Color(db.display.visibility.fade.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[2])
			)
		},
		[5] = {
			command = strings.chat.size.command,
			description =  strings.chat.size.description:gsub(
				"#SIZE", Color(strings.chat.size.command .. " " .. dbDefault.display.text.font.size, colors.purple[2])
			)
		},
		[6] = {
			command = strings.chat.integration.command,
			description =  strings.chat.integration.description
		},
	}
	--Print the list
	for i = 0, #commands do
		print("    " .. Color(strings.chat.keyword .. " " .. commands[i].command, colors.purple[2]) .. Color(" - " .. commands[i].description, colors.blue[2]))
	end
end

--[ Slash command handler ]

local function SaveCommand()
	--Update the custom preset
	presets[0].data.position.point, _, _, presets[0].data.position.offset.x, presets[0].data.position.offset.y = remXP:GetPoint()
	presets[0].data.visibility.frameStrata = options.visibility.raise:GetChecked() and "HIGH" or "MEDIUM"
	presets[0].data.background.visible = options.background.visible:GetChecked()
	presets[0].data.background.size = { width = options.background.size.width:GetValue(), height = options.background.size.height:GetValue() }
	--Save the Custom preset
	db.customPreset = presets[0].data
	--Update in the SavedVariabes DB
	RemainingXPDB.customPreset = wt.Clone(db.customPreset)
	--Response
	print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.save.response, colors.blue[0]))
end
local function PresetCommand(parameter)
	local index = tonumber(parameter)
	if index ~= nil and index >= 0 and index <= #presets then
		if not dbc.disabled then
			--Update the display
			remXP:Show()
			MoveDisplay(presets[index].data.position.point, presets[index].data.position.offset.x, presets[index].data.position.offset.y)
			ResizeDisplay(presets[index].data.background.size.width, presets[index].data.background.size.height)
			SetDisplayBackdrop(presets[index].data.background.visible, db.display.background.colors)
			--Update the GUI options in case the window was open
			options.visibility.hidden:SetChecked(false)
			options.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
			options.visibility.raise:SetChecked(presets[index].data.visibility.frameStrata == "HIGH")
			options.background.visible:SetChecked(presets[index].data.background.visible)
			options.background.visible:SetAttribute("loaded", true) --Update dependent widgets
			options.background.size.width:SetValue(presets[index].data.background.size.width)
			options.background.size.height:SetValue(presets[index].data.background.size.height)
			Fade(db.display.visibility.fade.enabled)
			--Response
			print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.preset.response, colors.blue[0]))
		else
			PrintStatus()
		end
	else
		--Error
		print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.preset.unchanged, colors.blue[0]))
		print(Color(strings.chat.preset.error:gsub("#INDEX", Color(strings.chat.preset.command .. " " .. 0, colors.purple[1])), colors.blue[1]))
		print(Color(strings.chat.preset.list, colors.purple[2]))
		for i = 0, #presets, 2 do
			local list = "    " .. Color(i, colors.purple[2]) .. Color(" - " .. presets[i].name, colors.blue[2])
			if i + 1 <= #presets then list = list .. "    " .. Color(i + 1, colors.purple[2]) .. Color(" - " .. presets[i + 1].name, colors.blue[2]) end
			print(list)
		end
	end
end
local function ToggleCommand()
	dbc.hidden = not dbc.hidden
	SetVisibility(remXP, not (dbc.hidden or dbc.disabled))
	--Update the GUI option in case it was open
	options.visibility.hidden:SetChecked(dbc.hidden)
	options.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
	--Response
	print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(dbc.hidden and strings.chat.toggle.hiding or strings.chat.toggle.unhiding, colors.blue[0]))
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDBC.hidden = wt.Clone(dbc.hidden)
end
local function FadeCommand()
	db.display.visibility.fade.enabled = not db.display.visibility.fade.enabled
	Fade(db.display.visibility.fade.enabled)
	--Update the GUI option in case it was open
	options.visibility.fade.toggle:SetChecked(db.display.visibility.fade.enabled)
	options.visibility.fade.toggle:SetAttribute("loaded", true) --Update dependent widgets
	--Response
	print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.fade.response:gsub(
		"#STATE", Color(db.display.visibility.fade.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[0])
	), colors.blue[0]))
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDB.display.visibility.fade.enabled = wt.Clone(db.display.visibility.fade.enabled)
end
local function SizeCommand(parameter)
	local size = tonumber(parameter)
	if size ~= nil then
		db.display.text.font.size = size
		mainDisplayText:SetFont(db.display.text.font.family, db.display.text.font.size, "THINOUTLINE")
		--Update the GUI option in case it was open
		options.text.font.size:SetValue(size)
		--Response
		print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.size.response:gsub("#VALUE", Color(size, colors.purple[0])), colors.blue[0]))
	else
		--Error
		print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.size.unchanged, colors.blue[0]))
		print(Color(strings.chat.size.error:gsub(
			"#SIZE", Color(strings.chat.size.command .. " " .. dbDefault.display.text.font.size, colors.purple[1])
		), colors.blue[1]))
	end
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDB.display.text.font.size = wt.Clone(db.display.text.font.size)
end
local function IntegrationCommand()
	db.enhancement.enabled = not db.enhancement.enabled
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
	--Update the GUI option in case it was open
	options.enhancement.toggle:SetChecked(db.enhancement.enabled)
	options.enhancement.toggle:SetAttribute("loaded", true) --Update dependent widgets
	--Response
	print(Color(addon .. ":", colors.purple[0]) .. " " .. Color(strings.chat.integration.response:gsub(
		"#STATE", Color(db.enhancement.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[0])
	), colors.blue[0]))
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDB.enhancement.enabled = wt.Clone(db.enhancement.enabled)
end

SLASH_REMXP1 = strings.chat.keyword
function SlashCmdList.REMXP(line)
	local command, parameter = strsplit(" ", line)
	if command == strings.chat.help.command then
		PrintCommands()
	elseif command == strings.chat.options.command then
		InterfaceOptionsFrame_OpenToCategory(options.mainOptionsPage)
		InterfaceOptionsFrame_OpenToCategory(options.mainOptionsPage) --Load twice to make sure the proper page and category is loaded
	elseif command == strings.chat.save.command then
		SaveCommand()
	elseif command == strings.chat.preset.command then
		PresetCommand(parameter)
	elseif command == strings.chat.toggle.command then
		ToggleCommand()
	elseif command == strings.chat.fade.command then
		FadeCommand()
	elseif command == strings.chat.size.command then
		SizeCommand(parameter)
	elseif command == strings.chat.integration.command then
		IntegrationCommand()
	else
		PrintInfo()
	end
end


--[[ INITIALIZATION ]]

local function CreateContextMenuItems()
	return {
		{
			text = strings.options.name:gsub("#ADDON", addon),
			isTitle = true,
			notCheckable = true,
		},
		{
			text = strings.options.main.name,
			notCheckable = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(options.mainOptionsPage)
				InterfaceOptionsFrame_OpenToCategory(options.mainOptionsPage) --Load twice to make sure the proper page and category is loaded
			end,
		},
		{
			text = strings.options.display.title,
			notCheckable = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(options.displayOptionsPage)
				InterfaceOptionsFrame_OpenToCategory(options.displayOptionsPage) --Load twice to make sure the proper page and category is loaded
			end,
		},
		{
			text = strings.options.integration.title,
			notCheckable = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(options.integrationOptionsPage)
				InterfaceOptionsFrame_OpenToCategory(options.integrationOptionsPage) --Load twice to make sure the proper page and category is loaded
			end,
		},
		{
			text = strings.options.events.title,
			notCheckable = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(options.notificationsOptionsPage)
				InterfaceOptionsFrame_OpenToCategory(options.notificationsOptionsPage) --Load twice to make sure the proper page and category is loaded
			end,
		},
		{
			text = strings.options.advanced.title,
			notCheckable = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(options.advancedOptionsPage)
				InterfaceOptionsFrame_OpenToCategory(options.advancedOptionsPage) --Load twice to make sure the proper page and category is loaded
			end,
		},
	}
end

--[ Main XP Display Setup ]

--Set frame parameters
local function SetUpMainDisplayFrame()
	--Main frame
	remXP:SetToplevel(true)
	remXP:SetSize(114, 14)
	MoveDisplay(db.display.position.point, db.display.position.offset.x, db.display.position.offset.y)
	--Main display
	mainDisplay:SetPoint("CENTER")
	mainDisplayXP:SetPoint("LEFT")
	mainDisplayRested:SetPoint("LEFT", mainDisplayXP, "RIGHT")
	mainDisplayOverlay:SetPoint("CENTER")
	mainDisplayText:SetPoint("CENTER") --TODO: Add font offset option to fine-tune the position (AND/OR, ad pre-tested offsets to keep each font in the center)
	SetDisplayValues(db, dbc)
	--Context menu
	wt.CreateContextMenu({
		parent = mainDisplay,
		menu = CreateContextMenuItems(),
	})
end

--Making the frame moveable
remXP:SetMovable(true)
mainDisplay:SetScript("OnMouseDown", function()
	if IsShiftKeyDown() and not remXP.isMoving then
		remXP:StartMoving()
		remXP.isMoving = true
	end
end)
mainDisplay:SetScript("OnMouseUp", function()
	if remXP.isMoving then
		remXP:StopMovingOrSizing()
		remXP.isMoving = false
	end
	--Save the position (for account-wide use)
	db.display.position.point, _, _, db.display.position.offset.x, db.display.position.offset.y = remXP:GetPoint()
	RemainingXPDB.display.position = wt.Clone(db.display.position) --Update in the SavedVariabes DB
	--Update the GUI options in case the window was open
	UIDropDownMenu_SetSelectedValue(options.position.anchor, GetAnchorID(db.display.position.point))
	options.position.xOffset:SetValue(db.display.position.offset.x)
	options.position.yOffset:SetValue(db.display.position.offset.y)
end)

--Toggling the main display tooltip and fade on mouseover
mainDisplay:SetScript('OnEnter', function()
	--Show tooltip
	ns.tooltip = wt.AddTooltip(nil, mainDisplay, "ANCHOR_BOTTOMRIGHT", strings.xpTooltip.title, strings.xpTooltip.text, CreateXPTooltipDetails(), 0, mainDisplay:GetHeight())
	--Fade toggle
	if db.display.visibility.fade.enabled then Fade(false) end
end)
mainDisplay:SetScript('OnLeave', function()
	--Hide tooltip
	ns.tooltip:Hide()
	--Fade toggle
	if db.display.visibility.fade.enabled then Fade(true) end
end)

--[ Integrated Display Setup ]

--Set up the integrated frame
local function SetUpIntegratedFrame()
	if dbc.disabled then return end
	--Frame & Text
	integratedDisplay:SetPoint("CENTER", MainMenuExpBar, "CENTER", 0, 0)
	integratedDisplay:SetFrameStrata("HIGH")
	integratedDisplay:SetToplevel(true)
	integratedDisplay:SetSize(MainMenuExpBar:GetWidth(), MainMenuExpBar:GetHeight())
	integratedDisplayText:SetPoint("CENTER", 0, 1)
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, false)
	--Context menu
	wt.CreateContextMenu({
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
	ns.tooltip = wt.AddTooltip(nil, integratedDisplay, "ANCHOR_NONE", strings.xpTooltip.title, strings.xpTooltip.text, CreateXPTooltipDetails())
	ns.tooltip:SetPoint("BOTTOMRIGHT", -11, 115)
end)
integratedDisplay:SetScript("OnLeave", function()
	--Hide the enhanced XP text on the default XP bar
	SetIntegrationTextVisibility(db.enhancement.keep, db.enhancement.remaining)
	--Hide the custom tooltip
	ns.tooltip:Hide()
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
	presets[0].data = db.customPreset
	--Set up the interface options
	LoadInterfaceOptions()
end
function remXP:PLAYER_ENTERING_WORLD()
	local max = CheckMax(UnitLevel("player"))
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
	if not max then
		--Main display
		UpdateXPDisplayText()
		--Integration
		if db.enhancement.enabled then UpdateIntegratedDisplay(db.enhancement.remaining) end
	end
	--Visibility notice
	if not remXP:IsVisible() then PrintStatus() end
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
		print(Color(strings.chat.notifications.xpGained.text:gsub(
			"#AMOUNT", Color(wt.FormatThousands(gainedXP), colors.purple[0])
		):gsub(
			"#REMAINING", Color(strings.chat.notifications.xpGained.remaining:gsub(
				"#AMOUNT", Color(wt.FormatThousands(csc.xp.remaining), colors.purple[2])
			):gsub(
				"#NEXT", UnitLevel("player") + 1
			), colors.blue[2])
		), colors.blue[0]))
	end
	--Tooltip
	UpdateXPTooltip()
end

--Level up update
function remXP:PLAYER_LEVEL_UP(newLevel)
	if CheckMax(newLevel) then
		print(Color(strings.chat.notifications.lvlUp.disabled.text:gsub(
			"#ADDON", Color(addon, colors.purple[0])
		):gsub(
			"#REASON", Color(strings.chat.notifications.lvlUp.disabled.reason:gsub(
				"#MAX", MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
			), colors.blue[2])
		) .. " " .. strings.chat.notifications.lvlUp.congrats, colors.blue[0]))
	else
		--Notification
		if db.notifications.lvlUp.congrats then
			print(Color(strings.chat.notifications.lvlUp.text:gsub(
				"#LEVEL", Color(newLevel, colors.purple[0])
			) .. " " .. Color(strings.chat.notifications.lvlUp.congrats, colors.purple[2]), colors.blue[0]))
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
		print(Color(strings.chat.notifications.restedXPGained.text:gsub(
				"#AMOUNT", Color(gainedRestedXP, colors.purple[0])
			):gsub(
				"#TOTAL", Color(wt.FormatThousands(csc.xp.rested), colors.purple[0])
			):gsub(
				"#PERCENT", Color(strings.chat.notifications.restedXPGained.percent:gsub(
					"#VALUE", Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 100000) / 1000, 3) .. "%%%%", colors.purple[2])
				), colors.blue[2])
			), colors.blue[0])
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
		local s = Color(strings.chat.notifications.restedXPAccumulated.leave, colors.purple[0])
		if (csc.xp.accumulatedRested or 0) > 0 then s = s .. " " .. Color(strings.chat.notifications.restedXPAccumulated.accumulated:gsub(
				"#AMOUNT", Color(wt.FormatThousands(csc.xp.accumulatedRested), colors.purple[0])
			):gsub(
				"#TOTAL", Color(wt.FormatThousands(csc.xp.rested), colors.purple[0])
			):gsub(
				"#PERCENT", Color(strings.chat.notifications.restedXPAccumulated.percent:gsub(
					"#VALUE", Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 1000000) / 10000, 4) .. "%%%%", colors.purple[2])
				):gsub(
					"#NEXT", Color(UnitLevel("player") + 1, colors.purple[2])
				), colors.blue[2])
			), colors.blue[0])
		else s = s .. " " .. Color(strings.chat.notifications.restedXPAccumulated.noAccumulation, colors.blue[0]) end
		print(s)
	end
	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated)
	--Update XP
	UpdateXPValues()
	--Tooltip
	UpdateXPTooltip()
end