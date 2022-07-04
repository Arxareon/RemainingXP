--[[ ADDON INFO ]]

--Addon namespace string & table
local addonNameSpace, ns = ...

--Addon display name
local _, addonTitle = GetAddOnInfo(addonNameSpace)

--Addon root folder
local root = "Interface/AddOns/" .. addonNameSpace .. "/"


--[[ ASSETS & RESOURCES ]]

--WidgetTools reference
local wt = WidgetToolbox[ns.WidgetToolsVersion]

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
	[1] = { name = "Arbutus Slab", path = root .. "Fonts/ArbutusSlab.ttf" },
	[2] = { name = "Caesar Dressing", path = root .. "Fonts/CaesarDressing.ttf" },
	[3] = { name = "Germania One", path = root .. "Fonts/GermaniaOne.ttf" },
	[4] = { name = "Mitr", path = root .. "Fonts/Mitr.ttf" },
	[5] = { name = "Oxanium", path = root .. "Fonts/Oxanium.ttf" },
	[6] = { name = "Pattaya", path = root .. "Fonts/Pattaya.ttf" },
	[7] = { name = "Reem Kufi", path = root .. "Fonts/ReemKufi.ttf" },
	[8] = { name = "Source Code Pro", path = root .. "Fonts/SourceCodePro.ttf" },
	[9] = { name = strings.misc.custom, path = root .. "Fonts/CUSTOM.ttf" },
}

--Textures
local textures = {
	logo = root .. "Textures/Logo.tga",
}

--Anchor Points
local anchors = {
	[0] = { name = strings.points.top.left, point = "TOPLEFT" },
	[1] = { name = strings.points.top.center, point = "TOP" },
	[2] = { name = strings.points.top.right, point = "TOPRIGHT" },
	[3] = { name = strings.points.left, point = "LEFT" },
	[4] = { name = strings.points.center, point = "CENTER" },
	[5] = { name = strings.points.right, point = "RIGHT" },
	[6] = { name = strings.points.bottom.left, point = "BOTTOMLEFT" },
	[7] = { name = strings.points.bottom.center, point = "BOTTOM" },
	[8] = { name = strings.points.bottom.right, point = "BOTTOMRIGHT" },
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
		text = {
			visible = true,
			details = false,
			font = {
				family = fonts[0].path,
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
				offset = { x = 0, y = 0, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 800, height = 13, },
			},
		},
	},
	[2] = {
		name = strings.options.display.quick.presets.list[1], --XP Bar Left Text
		data = {
			position = {
				point = "BOTTOM",
				offset = { x = -380, y = 1, },
			},
			visibility = {
				frameStrata = "HIGH"
			},
			background = {
				visible = false,
				size = { width = 116, height = 16, },
			},
		},
	},
	[3] = {
		name = strings.options.display.quick.presets.list[2], --XP Bar Right Text
		data = {
			position = {
				point = "BOTTOM",
				offset = { x = 380, y = 1, },
			},
			visibility = {
				frameStrata = "HIGH"
			},
			background = {
				visible = false,
				size = { width = 116, height = 16, },
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
		name = strings.options.display.quick.presets.list[5], --Objective Tracker Bar
		data = {
			position = {
				point = "TOPRIGHT",
				offset = { x = -62, y = -197, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 158, height = 22, },
			},
		},
	},
	[7] = {
		name = strings.options.display.quick.presets.list[6], --Menu & Bags Small Bar
		data = {
			position = {
				point = "BOTTOMRIGHT",
				offset = { x = -179, y = 45, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 116, height = 18, },
			},
		},
	},
	[8] = {
		name = strings.options.display.quick.presets.list[7], --Bottom-Left Chunky Bar
		data = {
			position = {
				point = "BOTTOMLEFT",
				offset = { x = 90, y = 12, },
			},
			visibility = {
				frameStrata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 294, height = 38, },
			},
		},
	},
	[9] = {
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
remXP:RegisterEvent("PLAYER_XP_UPDATE")
remXP:RegisterEvent("PLAYER_LEVEL_UP")
remXP:RegisterEvent("UPDATE_EXHAUSTION")
remXP:RegisterEvent("PLAYER_UPDATE_RESTING")
remXP:RegisterEvent("PET_BATTLE_OPENING_START")
remXP:RegisterEvent("PET_BATTLE_CLOSE")

--Event handler
remXP:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)

--[ Integrated Display ]

--Create frames
local integratedDisplay = CreateFrame("Frame", remXP:GetName() .. "IntegratedDisplay", UIParent)
local integratedDisplayText = integratedDisplay:CreateFontString(integratedDisplay:GetName() .. "Text", "OVERLAY", "TextStatusBarText")


--[[ UTILITIES ]]

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

--Returns the current max level
local function GetMax()
	return GetMaxLevelForPlayerExpansion()
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
		if k == "maxReminder" then data.notifications.statusNotice.maxReminder = v
		-- elseif k == "" then data. = v
		end
	end end
	-- if recoveredCharacterData ~= nil then for k, v in pairs(recoveredCharacterData) do
	-- 	if k == "" then characterData. = v
	-- 	elseif k == "" then characterData. = v
	-- 	end
	-- end end
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
					strings.chat.notifications.restedXPAccumulated.feels, colors.purple[0]
				) .. " " .. wt.Color(
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
	--Trial account
	if GameLimitedMode_IsActive() then
		csc.xp.banked = UnitTrialXP("player")
		csc.xp.bankedLevels = UnitTrialBankedLevels("player")
	end
	--Calculate the gained XP values
	local gainedXP = oldXP < csc.xp.current and csc.xp.current - oldXP or oldNeededXP - oldXP + csc.xp.current
	local gainedRestedXP = csc.xp.rested - oldRestedXP
	--Accumulating Rested XP
	if gainedRestedXP > 0 and csc.xp.accumulatedRested ~= nil and IsResting() then csc.xp.accumulatedRested = csc.xp.accumulatedRested + gainedRestedXP end
	return gainedXP, gainedRestedXP, oldXP, oldRestedXP, oldNeededXP
end

--Assemble the text containing the Banked XP details
local function GetBankedText()
	return (GameLimitedMode_IsActive() and csc.xp.banked > 0) and " + " .. strings.xpBar.banked:gsub(
		"#VALUE", wt.FormatThousands(csc.xp.banked)
	):gsub(
		"#LEVELS", csc.xp.bankedLevels
	) or ""
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
		) .. "%)" or "") .. GetBankedText()
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
			) .. GetBankedText()
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
		[0] = { text = strings.xpTooltip.text, },
		--Current XP
		[1] = {
			text = "\n" .. strings.xpTooltip.current:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.current), colors.purple[1])
			),
			color = colors.purple[0],
		},
		[2] = {
			text = strings.xpTooltip.percentTotal:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.current / csc.xp.needed * 10000) / 100) .. "%%", colors.purple[1])
			),
			color = colors.purple[2],
		},
		--Remaining XP
		[3] = {
			text = "\n" .. strings.xpTooltip.remaining:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.remaining), colors.rose[1])
			),
			color = colors.rose[0],
		},
		[4] = {
			text = strings.xpTooltip.percentTotal:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor((csc.xp.remaining / csc.xp.needed) * 10000) / 100) .. "%%", colors.rose[1])
			),
			color = colors.rose[2],
		},
		--Max needed XP
		[5] = {
			text = "\n" .. strings.xpTooltip.needed:gsub(
				"#DATA", wt.Color(strings.xpTooltip.valueNeeded:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(csc.xp.needed), colors.peach[1])
				):gsub(
					"#LEVEL", wt.Color(UnitLevel("player"), colors.peach[1])
				), colors.peach[2])
			),
			color = colors.peach[0],
		},
		--Playtime --TODO: Add time played info
		-- [6] = {
		-- 	text = "\n" .. strings.xpTooltip.timeSpent:gsub("#TIME", "?") .. " (Soon™)",
		-- },
	}
	--Current Rested XP
	if csc.xp.rested > 0 then
		textLines[#textLines + 1] = {
			text = "\n" .. strings.xpTooltip.rested:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.rested), colors.blue[1])
			),
			color = colors.blue[0],
		}
		textLines[#textLines + 1] = {
			text = strings.xpTooltip.percentRemaining:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100) .. "%%", colors.blue[1])
			),
			color = colors.blue[2],
		}
		--Description
		textLines[#textLines + 1] = {
			text = "\n" .. strings.xpTooltip.restedStatus:gsub(
				"#PERCENT", wt.Color("200%%", colors.blue[1])
			),
			color = colors.blue[2],
		}
	end
	--Resting status
	if IsResting() then
		textLines[#textLines + 1] = {
			text = "\n" .. strings.chat.notifications.restedXPAccumulated.feels,
			color = colors.blue[0],
		}
	end
	--Accumulated Rested XP
	if (csc.xp.accumulatedRested or 0) > 0 then
		textLines[#textLines + 1] = {
			text = strings.xpTooltip.accumulated:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.accumulatedRested or 0), colors.blue[1])
			),
			color = colors.blue[2],
		}
	end
	--Banked XP & levels
	if GameLimitedMode_IsActive() and csc.xp.banked > 0 then
		textLines[#textLines + 1] = {
			text = "\n" .. strings.xpTooltip.banked:gsub(
				"#DATA", wt.Color(strings.xpTooltip.valueBanked:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(csc.xp.banked), colors.grey[1])
				):gsub(
					"#LEVELS", wt.Color(csc.xp.bankedLevels, colors.grey[1])
				), colors.grey[2])
			),
			color = colors.grey[0],
		}
	end
	--Hints
	textLines[#textLines + 1] = {
		text = "\n" .. strings.xpTooltip.hintOptions,
		font = GameFontNormalTiny,
		color = colors.grey[0],
	}
	if mainDisplay:IsMouseOver() then
		textLines[#textLines + 1] = {
			text = strings.xpTooltip.hintMove:gsub("#SHIFT", strings.keys.shift),
			font = GameFontNormalTiny,
			color = colors.grey[0],
		}
	end
	return textLines
end

--Update the text of the xp tooltip
local function UpdateXPTooltip()
	if not integratedDisplay:IsMouseOver() and not mainDisplay:IsMouseOver() then return end
	ns.tooltip = wt.AddTooltip(nil, integratedDisplay, "ANCHOR_PRESERVE", strings.xpTooltip.title, GetXPTooltipDetails())
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
				print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.integration.notice, colors.blue[0]))
				wt.CreateReloadNotice()
			end
		end
	else
		integratedDisplay:Hide()
	end
end

---Check whether a reputation is being tracked or not
---@return boolean
local function CheckRepBarStatus()
	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionIndex = FauxScrollFrame_GetOffset(ReputationListScrollFrame) + i
		if factionIndex <= GetNumFactions() then
			local _, _, _, _, _, _, _, _, _, _, _, isWatched = GetFactionInfo(factionIndex)
			if isWatched == true then return true end
		end
	end
	return false
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
		title = strings.options.display.title,
		tooltip = { [0] = { text = strings.options.display.description:gsub("#ADDON", addonTitle) }, },
		position = { offset = { x = 10, y = -30 } },
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.displayOptionsPage) end,
	})
	--Button: Integration page
	local integration = wt.CreateButton({
		parent = parentFrame,
		name = "IntegrationPage",
		title = strings.options.integration.title,
		tooltip = { [0] = { text = strings.options.integration.description:gsub("#ADDON", addonTitle) }, },
		position = {
			relativeTo = display,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.integrationOptionsPage) end,
	})
	--Button: Notifications page
	wt.CreateButton({
		parent = parentFrame,
		name = "NotificationsPage",
		title = strings.options.events.title,
		tooltip = { [0] = { text = strings.options.events.description:gsub("#ADDON", addonTitle) }, },
		position = {
			relativeTo = integration,
			relativePoint = "TOPRIGHT",
			offset = { x = 10, }
		},
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.notificationsOptionsPage) end,
	})
	--Button: Advanced page
	wt.CreateButton({
		parent = parentFrame,
		name = "AdvancedPage",
		title = strings.options.advanced.title,
		tooltip = { [0] = { text = strings.options.advanced.description:gsub("#ADDON", addonTitle) }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -30 }
		},
		width = 120,
		onClick = function() InterfaceOptionsFrame_OpenToCategory(options.advancedOptionsPage) end,
	})
end
local function CreateAboutInfo(parentFrame)
	--Text: Version
	local version = wt.CreateText({
		parent = parentFrame,
		name = "Version",
		position = { offset = { x = 16, y = -33 } },
		width = 84,
		text = strings.options.main.about.version:gsub("#VERSION", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Version"), "FFFFFFFF")),
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
		text = strings.options.main.about.date:gsub(
			"#DATE", WrapTextInColorCode(strings.misc.date:gsub(
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
		text = strings.options.main.about.author:gsub("#AUTHOR", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "Author"), "FFFFFFFF")),
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
		text = strings.options.main.about.license:gsub("#LICENSE", WrapTextInColorCode(GetAddOnMetadata(addonNameSpace, "X-License"), "FFFFFFFF")),
		justify = "LEFT",
		template = "GameFontNormalSmall",
	})
	--EditScrollBox: Changelog
	options.about.changelog = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "Changelog",
		title = strings.options.main.about.changelog.label,
		tooltip = { [0] = { text = strings.options.main.about.changelog.tooltip }, },
		position = {
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -12 }
		},
		size = { width = parentFrame:GetWidth() - 32, height = 139 },
		text = ns.GetChangelog(),
		fontObject = "GameFontDisableSmall",
		scrollSpeed = 45,
		readOnly = true,
	})
end
local function CreateSupportInfo(parentFrame)
	--Copybox: CurseForge
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "CurseForge",
		title = strings.options.main.support.curseForge .. ":",
		position = { offset = { x = 16, y = -33 } },
		width = parentFrame:GetWidth() / 2 - 22,
		text = "curseforge.com/wow/addons/remaining-xp",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Wago
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Wago",
		title = strings.options.main.support.wago .. ":",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -33 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		text = "addons.wago.io/addons/remaining-xp",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: BitBucket
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "BitBucket",
		title = strings.options.main.support.bitBucket .. ":",
		position = { offset = { x = 16, y = -70 } },
		width = parentFrame:GetWidth() / 2 - 22,
		text = "bitbucket.org/Arxareon/remaining-xp",
		template = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.75, g = 0.95, b = 1, a = 1 },
	})
	--Copybox: Issues
	wt.CreateCopyBox({
		parent = parentFrame,
		name = "Issues",
		title = strings.options.main.support.issues .. ":",
		position = {
			anchor = "TOP",
			offset = { x = (parentFrame:GetWidth() / 2 - 22) / 2 + 8, y = -70 }
		},
		width = parentFrame:GetWidth() / 2 - 22,
		text = "bitbucket.org/Arxareon/remaining-xp/issues",
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
		title = strings.options.main.shortcuts.title,
		description = strings.options.main.shortcuts.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateOptionsShortcuts(shortcutsPanel)
	--About
	local aboutPanel = wt.CreatePanel({
		parent = parentFrame,
		title = strings.options.main.about.title,
		description = strings.options.main.about.description:gsub("#ADDON", addonTitle),
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
		title = strings.options.main.support.title,
		description = strings.options.main.support.description:gsub("#ADDON", addonTitle),
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
		title = strings.options.display.quick.hidden.label,
		tooltip = { [0] = { text = strings.options.display.quick.hidden.tooltip:gsub("#ADDON", addonTitle) }, },
		position = { offset = { x = 8, y = -30 } },
		onClick = function(self) wt.SetVisibility(remXP, not (self:GetChecked() or dbc.disabled)) end,
		optionsData = {
			storageTable = dbc,
			key = "hidden",
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
				wt.PositionFrame(remXP, presets[i].data.position.point, nil, nil, presets[i].data.position.offset.x, presets[i].data.position.offset.y)
				if not presets[i].data.background.visible then wt.SetVisibility(mainDisplayText, true) end
				SetDisplayBackdrop(presets[i].data.background.visible, {
					bg = wt.PackColor(options.background.colors.bg.getColor()),
					xp = wt.PackColor(options.background.colors.xp.getColor()),
					rested = wt.PackColor(options.background.colors.rested.getColor()),
					border = wt.PackColor(options.background.colors.border.getColor()),
				})
				Fade(options.visibility.fade.toggle:GetChecked())
				--Update the options
				options.position.anchor.setSelected(GetAnchorID(presets[i].data.position.point))
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
		title = strings.options.display.quick.presets.label,
		tooltip = { [0] = { text = strings.options.display.quick.presets.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		width = 160,
		items = presetItems,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
		onLoad = function(self)
			UIDropDownMenu_SetSelectedValue(self, nil)
			UIDropDownMenu_SetText(self, strings.options.display.quick.presets.select)
		end,
	})
	--Button & Popup: Save Custom preset
	local savePopup = wt.CreatePopup({
		addon = addonNameSpace,
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
			print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.save.response, colors.blue[0]))
		end,
	})
	wt.CreateButton({
		parent = parentFrame,
		name = "SavePreset",
		title = strings.options.display.quick.savePreset.label,
		tooltip = { [0] = { text = strings.options.display.quick.savePreset.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -10, y = -50 }
		},
		width = 160,
		onClick = function() StaticPopup_Show(savePopup) end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
	})
end
local function CreatePositionOptions(parentFrame)
	--Selector: Anchor point
	local anchorItems = {}
	for i = 0, #anchors do
		anchorItems[i] = {}
		anchorItems[i].label = anchors[i].name
		anchorItems[i].onSelect = function()
			wt.PositionFrame(remXP, anchors[i].point, nil, nil, options.position.xOffset:GetValue(), options.position.yOffset:GetValue())
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end
	end
	options.position.anchor = wt.CreateSelector({
		parent = parentFrame,
		name = "AnchorPoint",
		title = strings.options.display.position.anchor.label,
		tooltip = { [0] = { text = strings.options.display.position.anchor.tooltip }, },
		position = { offset = { x = 8, y = -30 } },
		items = anchorItems,
		labels = false,
		columns = 3,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
		optionsData = {
			storageTable = db.display.position,
			key = "point",
			convertSave = function(value) return anchors[value].point end,
			convertLoad = function(point) return GetAnchorID(point) end,
		},
	})
	--Slider: X offset
	options.position.xOffset = wt.CreateSlider({
		parent = parentFrame,
		name = "OffsetX",
		title = strings.options.display.position.xOffset.label,
		tooltip = { [0] = { text = strings.options.display.position.xOffset.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		value = { min = -500, max = 500, fractional = 2 },
		onValueChanged = function(_, value)
			wt.PositionFrame(remXP, anchors[options.position.anchor.getSelected()].point, nil, nil, value, options.position.yOffset:GetValue())
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
		optionsData = {
			storageTable = db.display.position.offset,
			key = "x",
		},
	})
	--Slider: Y offset
	options.position.yOffset = wt.CreateSlider({
		parent = parentFrame,
		name = "OffsetY",
		title = strings.options.display.position.yOffset.label,
		tooltip = { [0] = { text = strings.options.display.position.yOffset.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -30 }
		},
		value = { min = -500, max = 500, fractional = 2 },
		onValueChanged = function(_, value)
			wt.PositionFrame(remXP, anchors[options.position.anchor.getSelected()].point, nil, nil, options.position.xOffset:GetValue(), value)
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
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
		name = "Visible",
		title = strings.options.display.text.visible.label,
		tooltip = { [0] = { text = strings.options.display.text.visible.tooltip }, },
		position = { offset = { x = 8, y = -30 } },
		onClick = function(self)
			local value = self:GetChecked()
			--Flip the background visibility on if it was hidden
			if not value and not options.background.visible:GetChecked() then options.background.visible:Click() end
			--Update the text visibility
			wt.SetVisibility(mainDisplayText, value)
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
		optionsData = {
			storageTable = db.display.text,
			key = "visible",
		},
	})
	--Checkbox: Details
	options.text.details = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Details",
		title = strings.options.display.text.details.label,
		tooltip = { [0] = { text = strings.options.display.text.details.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		autoOffset = true,
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
		fontItems[i].title = fonts[i].name
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
		name = "FontFamily",
		title = strings.options.display.text.font.family.label,
		tooltip = {
			[0] = { text = strings.options.display.text.font.family.tooltip[0] },
			[1] = { text = strings.options.display.text.font.family.tooltip[1] },
			[2] = { text = "\n" .. strings.options.display.text.font.family.tooltip[2]:gsub("#OPTION_CUSTOM", strings.misc.custom):gsub("#FILE_CUSTOM", "CUSTOM.ttf") },
			[3] = { text = "[WoW]\\Interface\\AddOns\\" .. addonNameSpace .. "\\Fonts\\", color = { r = 0.185, g = 0.72, b = 0.84 }, wrap = false },
			[4] = { text = strings.options.display.text.font.family.tooltip[3]:gsub("#FILE_CUSTOM", "CUSTOM.ttf") },
			[5] = { text = strings.options.display.text.font.family.tooltip[4], color = { r = 0.89, g = 0.65, b = 0.40 } },
		},
		position = { offset = { x = -6, y = -60 } },
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
		name = "FontSize",
		title = strings.options.display.text.font.size.label,
		tooltip = { [0] = { text = strings.options.display.text.font.size.tooltip .. "\n\n" .. strings.misc.default .. ": " .. dbDefault.display.text.font.size }, },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
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
		name = "FontColor",
		title = strings.options.display.text.font.color.label,
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
		name = "Visible",
		title = strings.options.display.background.visible.label,
		tooltip = { [0] = { text = strings.options.display.background.visible.tooltip }, },
		position = { offset = { x = 8, y = -30 } },
		onClick = function(self)
			local value = self:GetChecked()
			--Flip the text visibility on if it was hidden
			if not value and not options.text.visible:GetChecked() then options.text.visible:Click() end
			--Update the display backdrop
			SetDisplayBackdrop(value, {
				bg = wt.PackColor(options.background.colors.bg.getColor()),
				xp = wt.PackColor(options.background.colors.xp.getColor()),
				rested = wt.PackColor(options.background.colors.rested.getColor()),
				border = wt.PackColor(options.background.colors.border.getColor()),
			})
			Fade()
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
		optionsData = {
			storageTable = db.display.background,
			key = "visible",
		},
	})
	--Slider: Background width
	options.background.size.width = wt.CreateSlider({
		parent = parentFrame,
		name = "Width",
		title = strings.options.display.background.size.width.label,
		tooltip = { [0] = { text = strings.options.display.background.size.width.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -32 }
		},
		value = { min = 64, max = UIParent:GetWidth() - math.fmod(UIParent:GetWidth(), 1) , step = 2 },
		onValueChanged = function(_, value)
			ResizeDisplay(value, options.background.size.height:GetValue())
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
		dependencies = {
			[0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, },
			[1] = { frame = options.background.visible },
		},
		optionsData = {
			storageTable = db.display.background.size,
			key = "width",
		},
	})
	--Slider: Background height
	options.background.size.height = wt.CreateSlider({
		parent = parentFrame,
		name = "Height",
		title = strings.options.display.background.size.height.label,
		tooltip = { [0] = { text = strings.options.display.background.size.height.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -32 }
		},
		value = { min = 2, max = 80, step = 2 },
		onValueChanged = function(_, value)
			ResizeDisplay(options.background.size.width:GetValue(), value)
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
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
		name = "Color",
		title = strings.options.display.background.colors.bg.label,
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
		name = "BorderColor",
		title = strings.options.display.background.colors.border.label,
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
		name = "XPColor",
		title = strings.options.display.background.colors.xp.label,
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
		name = "RestedColor",
		title = strings.options.display.background.colors.rested.label,
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
		name = "Raise",
		title = strings.options.display.visibility.raise.label,
		tooltip = { [0] = { text = strings.options.display.visibility.raise.tooltip }, },
		position = { offset = { x = 8, y = -30 } },
		autoOffset = true,
		onClick = function(self)
			remXP:SetFrameStrata(self:GetChecked() and "HIGH" or "MEDIUM")
			--Clear the presets dropdown selection
			UIDropDownMenu_SetSelectedValue(options.visibility.presets, nil)
			UIDropDownMenu_SetText(options.visibility.presets, strings.options.display.quick.presets.select)
		end,
		dependencies = { [0] = { frame = options.visibility.hidden, evaluate = function(state) return not state end, }, },
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
		name = "FadeToggle",
		title = strings.options.display.visibility.fade.label,
		tooltip = { [0] = { text = strings.options.display.visibility.fade.tooltip }, },
		position = {
			relativeTo = options.visibility.raise,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
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
	--Slider: Text fade intensity
	options.visibility.fade.text = wt.CreateSlider({
		parent = parentFrame,
		name = " TextFade",
		title = strings.options.display.visibility.fade.text.label,
		tooltip = { [0] = { text = strings.options.display.visibility.fade.text.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
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
	--Slider: Background fade intensity
	options.visibility.fade.background = wt.CreateSlider({
		parent = parentFrame,
		name = "BackgroundFade",
		title = strings.options.display.visibility.fade.background.label,
		tooltip = { [0] = { text = strings.options.display.visibility.fade.background.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -14, y = -60 }
		},
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
		name = "QuickSettings",
		title = strings.options.display.quick.title,
		description = strings.options.display.quick.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -78 } },
		size = { height = 84 },
	})
	CreateQuickOptions(quickOptions)
	--Position
	local positionOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Position",
		title = strings.options.display.position.title,
		description = strings.options.display.position.description:gsub("#SHIFT", strings.keys.shift),
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
		title = strings.options.display.text.title,
		description = strings.options.display.text.description,
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
		title = strings.options.display.background.title,
		description = strings.options.display.background.description:gsub("#ADDON", addonTitle),
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
		title = strings.options.display.visibility.title,
		description = strings.options.display.visibility.description:gsub("#ADDON", addonTitle),
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
		title = strings.options.integration.enhancement.toggle.label,
		tooltip = { [0] = { text = strings.options.integration.enhancement.toggle.tooltip }, },
		position = { offset = { x = 8, y = -30 } },
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
		name = "KeepText",
		title = strings.options.integration.enhancement.keep.label,
		tooltip = { [0] = { text = strings.options.integration.enhancement.keep.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -30 }
		},
		autoOffset = true,
		onClick = function(self)
			local value = self:GetChecked()
			SetIntegrationTextVisibility(value, options.enhancement.remaining:GetChecked())
			db.enhancement.keep = value
		end,
		dependencies = { [0] = { frame = options.enhancement.toggle }, },
		optionsData = {
			storageTable = db.enhancement,
			key = "keep",
		},
	})
	--Checkbox: Keep only remaining XP text
	options.enhancement.remaining = wt.CreateCheckbox({
		parent = parentFrame,
		name = "RemainingOnly",
		title = strings.options.integration.enhancement.remaining.label,
		tooltip = { [0] = { text = strings.options.integration.enhancement.remaining.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			offset = { y = -30 }
		},
		autoOffset = true,
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
		name = "HideStatusBars",
		title = strings.options.integration.removals.statusBars.label,
		tooltip = { [0] = { text = strings.options.integration.removals.statusBars.tooltip:gsub("#ADDON", addonTitle) }, },
		position = { offset = { x = 8, y = -30 } },
		autoOffset = true,
		onClick = function(self) wt.SetVisibility(StatusTrackingBarManager, not self:GetChecked()) end,
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
		title = strings.options.integration.enhancement.title,
		description = strings.options.integration.enhancement.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateEnhancementOptions(enhancementOptions)
	--Removals
	local removalsOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Removals",
		title = strings.options.integration.removals.title,
		description = strings.options.integration.removals.description:gsub("#ADDON", addonTitle),
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
		title = strings.options.events.notifications.xpGained.label,
		tooltip = { [0] = { text = strings.options.events.notifications.xpGained.tooltip }, },
		position = { offset = { x = 8, y = -30 } },
		onClick = function(self) db.notifications.xpGained = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications,
			key = "xpGained",
		},
	})
	--Checkbox: Rested XP gained
	options.notifications.restedXPGained = wt.CreateCheckbox({
		parent = parentFrame,
		name = "RestedXPGained",
		title = strings.options.events.notifications.restedXPGained.label,
		tooltip = { [0] = { text = strings.options.events.notifications.restedXPGained.tooltip }, },
		position = {
			relativeTo = options.notifications.xpGained,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
		onClick = function(self) db.notifications.restedXP.gained = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications.restedXP,
			key = "gained",
		},
	})
	--Checkbox: Significant Rested XP updates only
	options.notifications.significantRestedOnly = wt.CreateCheckbox({
		parent = parentFrame,
		name = "SignificantRestedOnly",
		title = strings.options.events.notifications.restedXPGained.significantOnly.label,
		tooltip = { [0] = { text = strings.options.events.notifications.restedXPGained.significantOnly.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -60 }
		},
		autoOffset = true,
		onClick = function(self) db.notifications.restedXP.significantOnly = self:GetChecked() end,
		dependencies = { [0] = { frame = options.notifications.restedXPGained }, },
		optionsData = {
			storageTable = db.notifications.restedXP,
			key = "significantOnly",
		},
	})
	--Checkbox: Accumulated Rested XP
	options.notifications.restedXPAccumulated = wt.CreateCheckbox({
		parent = parentFrame,
		name = "AccumulatedRestedXP",
		title = strings.options.events.notifications.restedXPGained.accumulated.label,
		tooltip = {
			[0] = { text = strings.options.events.notifications.restedXPGained.accumulated.tooltip[0] },
			[1] = {
				text = strings.options.events.notifications.restedXPGained.accumulated.tooltip[1]:gsub("#ADDON", addonTitle),
				color = { r = 0.89, g = 0.65, b = 0.40 }
			},
		},
		position = {
			anchor = "TOPRIGHT",
			offset = { y = -60 }
		},
		autoOffset = true,
		onClick = function(self)
			local value = self:GetChecked()
			SetRestedAccumulation(options.notifications.restedXPGained:GetChecked() and value and dbc.disabled)
			db.notifications.restedXP.accumulated = value
		end,
		dependencies = { [0] = { frame = options.notifications.restedXPGained }, },
		optionsData = {
			storageTable = db.notifications.restedXP,
			key = "accumulated",
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
		label = strings.options.events.notifications.lvlUp.label,
		tooltip = { [0] = { text = strings.options.events.notifications.lvlUp.tooltip }, },
		onClick = function(self) db.notifications.lvlUp.congrats = self:GetChecked() end,
		optionsData = {
			storageTable = db.notifications.lvlUp,
			key = "congrats",
		},
	})
	--Checkbox: Time played
	options.notifications.timePlayed = wt.CreateCheckbox({
		parent = parentFrame,
		name = "TimePlayed",
		title = strings.options.events.notifications.lvlUp.timePlayed.label .. " (Soon™)",
		tooltip = { [0] = { text = strings.options.events.notifications.lvlUp.timePlayed.tooltip }, },
		position = {
			anchor = "TOP",
			offset = { y = -90 }
		},
		autoOffset = true,
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
	--Checkbox: Status notice
	options.notifications.status = wt.CreateCheckbox({
		parent = parentFrame,
		name = " StatusNotice",
		title = strings.options.events.notifications.statusNotice.label,
		tooltip = { [0] = { text = strings.options.events.notifications.statusNotice.tooltip:gsub("#ADDON", addonTitle) }, },
		position = {
			relativeTo = options.notifications.lvlUp,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -4 }
		},
		optionsData = {
			storageTable = db.notifications.statusNotice,
			key = "enabled",
		},
	})
	--Checkbox: Max reminder
	options.notifications.maxReminder = wt.CreateCheckbox({
		parent = parentFrame,
		name = "MaxReminder",
		title = strings.options.events.notifications.statusNotice.maxReminder.label,
		tooltip = { [0] = { text = strings.options.events.notifications.statusNotice.maxReminder.tooltip:gsub("#ADDON", addonTitle) }, },
		position = {
			anchor = "TOP",
			offset = { y = -120 }
		},
		autoOffset = true,
		dependencies = { [0] = { frame = options.notifications.status }, },
		optionsData = {
			storageTable = db.notifications.statusNotice,
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
		name = "ChatNotifications",
		title = strings.options.events.notifications.title,
		description = strings.options.events.notifications.description,
		position = { offset = { x = 16, y = -82 } },
		size = { height = 154 },
	})
	CreateNotificationsOptions(notificationsOptions)
	---Logs
	local logsOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Logs",
		title = strings.options.events.logs.title,
		description = strings.options.events.logs.description,
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
		text = strings.options.advanced.backup.warning,
		accept = strings.options.advanced.backup.import,
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
				presets[0].data = db.customPreset
				--Main display
				wt.PositionFrame(remXP, db.display.position.point, nil, nil, db.display.position.offset.x, db.display.position.offset.y)
				SetDisplayValues(db, dbc)
				--Enhancement
				SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
				--Removals
				if t.account.removals.statusBars then StatusTrackingBarManager:Hide() else StatusTrackingBarManager:Show() end
				--Update the interface options
				wt.LoadOptionsData()
			else print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.options.advanced.backup.error, colors.blue[0])) end
		end
	})
	local backupBox
	options.backup.string, backupBox = wt.CreateEditScrollBox({
		parent = parentFrame,
		name = "ImportExport",
		title = strings.options.advanced.backup.backupBox.label,
		tooltip = {
			[0] = { text = strings.options.advanced.backup.backupBox.tooltip[0] },
			[1] = { text = strings.options.advanced.backup.backupBox.tooltip[1] },
			[2] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[2]:gsub("#ENTER", strings.keys.enter) },
			[3] = { text = strings.options.advanced.backup.backupBox.tooltip[3], color = { r = 0.89, g = 0.65, b = 0.40 } },
			[4] = { text = "\n" .. strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.92, g = 0.34, b = 0.23 } },
		},
		position = { offset = { x = 16, y = -30 } },
		size = { width = parentFrame:GetWidth() - 32, height = 276 },
		maxLetters = 5400,
		fontObject = "GameFontWhiteSmall",
		scrollSpeed = 60,
		onEnterPressed = function() StaticPopup_Show(importPopup) end,
		onEscapePressed = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
		onLoad = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, options.backup.compact:GetChecked(), true)) end,
	})
	--Checkbox: Compact
	options.backup.compact = wt.CreateCheckbox({
		parent = parentFrame,
		name = "Compact",
		title = strings.options.advanced.backup.compact.label,
		tooltip = { [0] = { text = strings.options.advanced.backup.compact.tooltip }, },
		position = {
			relativeTo = backupBox,
			relativePoint = "BOTTOMLEFT",
			offset = { x = -8, y = -13 }
		},
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
		name = "Load",
		title = strings.options.advanced.backup.load.label,
		tooltip = { [0] = { text = strings.options.advanced.backup.load.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = backupBox,
			relativePoint = "BOTTOMRIGHT",
			offset = { x = 6, y = -13 }
		},
		width = 80,
		onClick = function() StaticPopup_Show(importPopup) end,
	})
	--Button: Reset
	wt.CreateButton({
		parent = parentFrame,
		name = "Reset",
		title = strings.options.advanced.backup.reset.label,
		tooltip = { [0] = { text = strings.options.advanced.backup.reset.tooltip }, },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = load,
			relativePoint = "TOPLEFT",
			offset = { x = -10, }
		},
		width = 80,
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
		name = "Profiles",
		title = strings.options.advanced.profiles.title,
		description = strings.options.advanced.profiles.description:gsub("#ADDON", addonTitle),
		position = { offset = { x = 16, y = -82 } },
		size = { height = 64 },
	})
	CreateOptionsProfiles(profilesPanel)
	---Backup
	local backupOptions = wt.CreatePanel({
		parent = parentFrame,
		name = "Backup",
		title = strings.options.advanced.backup.title,
		description = strings.options.advanced.backup.description:gsub("#ADDON", addonTitle),
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
	db.removals.statusBars = not StatusTrackingBarManager:IsVisible()
	--Update the SavedVariabes DBs
	RemainingXPDB = wt.Clone(db)
	RemainingXPDBC = wt.Clone(dbc)
end
--Cancel all potential changes made in all option categories
local function CancelChanges()
	LoadDBs()
	--Display
	wt.PositionFrame(remXP, db.display.position.point, nil, nil, db.display.position.offset.x, db.display.position.offset.y)
	SetDisplayValues(db, dbc)
	--Enhancement
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, false)
	--Removals
	if db.removals.statusBars then StatusTrackingBarManager:Hide() else StatusTrackingBarManager:Show() end
end
--Restore all the settings under the main option category to their default values
local function DefaultOptions()
	if db.enhancement.enabled ~= dbDefault.enhancement.enabled then
		wt.CreateReloadNotice()
		print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.integration.notice, colors.blue[0]))
	end
	--Reset the DBs
	RemainingXPDB = wt.Clone(dbDefault)
	RemainingXPDBC = wt.Clone(dbcDefault)
	wt.CopyValues(dbDefault, db)
	wt.CopyValues(dbcDefault, dbc)
	--Reset the Custom preset
	presets[0].data = db.customPreset
	--Reset the main display
	wt.PositionFrame(remXP, db.display.position.point, nil, nil, db.display.position.offset.x, db.display.position.offset.y)
	SetDisplayValues(db, dbc)
	--Update the enhancement
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
	--Update the removals
	if db.removals.statusBars then StatusTrackingBarManager:Hide() else StatusTrackingBarManager:Show() end
	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated and dbc.disabled)
	--Update the interface options
	wt.LoadOptionsData()
	--Set the preset selection to Custom
	UIDropDownMenu_SetSelectedValue(options.visibility.presets, 0)
	UIDropDownMenu_SetText(options.visibility.presets, presets[0].name)
	--Notification
	print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.options.defaults, colors.blue[0]))
end

--Create and add the options category panel frames to the WoW Interface Options
local function LoadInterfaceOptions()
	--Main options panel
	options.mainOptionsPage = wt.CreateOptionsPanel({
		addon = addonNameSpace,
		name = "Main",
		title = addonTitle,
		description = strings.options.main.description:gsub("#ADDON", addonTitle):gsub("#KEYWORD", strings.chat.keyword),
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
		addon = addonNameSpace,
		name = "Display",
		title = strings.options.display.title,
		description = strings.options.display.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		scroll = {
			height = 782,
			speed = 45,
		},
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateDisplayCategoryPanels(displayOptionsScrollFrame) --Add categories & GUI elements to the panel
	--Integration options panel
	options.integrationOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "Integration",
		title = strings.options.integration.title,
		description = strings.options.integration.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateIntegrationCategoryPanels(options.integrationOptionsPage) --Add categories & GUI elements to the panel
	--Notifications options panel
	options.notificationsOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "Notifications",
		title = strings.options.events.title,
		description = strings.options.events.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateEventsCategoryPanels(options.notificationsOptionsPage) --Add categories & GUI elements to the panel
	--Advanced options panel
	options.advancedOptionsPage = wt.CreateOptionsPanel({
		parent = options.mainOptionsPage.name,
		addon = addonNameSpace,
		name = "Advanced",
		title = strings.options.advanced.title,
		description = strings.options.advanced.description:gsub("#ADDON", addonTitle),
		logo = textures.logo,
		default = DefaultOptions,
		autoSave = false,
		autoLoad = false,
	})
	CreateAdvancedCategoryPanels(options.advancedOptionsPage) --Add categories & GUI elements to the panel
end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load boolean [Default: false]
local function PrintStatus(load)
	if load == true and not db.notifications.statusNotice.enabled then return end
	local status = wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(
		remXP:IsVisible() and strings.chat.status.visible or strings.chat.status.hidden, colors.blue[0]
	):gsub(
		"#FADE", wt.Color(strings.chat.status.fade:gsub(
			"#STATE", wt.Color(db.display.visibility.fade.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[1])
		), colors.blue[1])
	)
	if dbc.disabled then
		if db.notifications.statusNotice.maxReminder then
			status = wt.Color(strings.chat.status.disabled:gsub(
				"#ADDON", wt.Color(addonTitle, colors.purple[0])
			) .." " ..  wt.Color(strings.chat.status.max:gsub(
				"#MAX", wt.Color(GetMax(), colors.purple[1])
			), colors.blue[1]), colors.blue[0])
		else return end
	end
	print(status)
end
--Print help info
local function PrintInfo()
	print(wt.Color(strings.chat.help.thanks:gsub("#ADDON", wt.Color(addonTitle, colors.purple[0])), colors.blue[0]))
	PrintStatus()
	print(wt.Color(strings.chat.help.hint:gsub( "#HELP_COMMAND", wt.Color(strings.chat.keyword .. " " .. strings.chat.help.command, colors.purple[2])), colors.blue[2]))
	print(wt.Color(strings.chat.help.move:gsub("#SHIFT", wt.Color(strings.keys.shift, colors.purple[2])):gsub("#ADDON", addonTitle), colors.blue[2]))
end
--Print the command list with basic functionality info
local function PrintCommands()
	print(wt.Color(addonTitle, colors.purple[0]) .. " ".. wt.Color(strings.chat.help.list .. ":", colors.blue[0]))
	--Index the commands (skipping the help command) and put replacement code segments in place
	local commands = {
		[0] = {
			command = strings.chat.options.command,
			description = strings.chat.options.description:gsub("#ADDON", addonTitle)
		},
		[1] = {
			command = strings.chat.save.command,
			description = strings.chat.save.description
		},
		[2] = {
			command = strings.chat.preset.command,
			description = strings.chat.preset.description:gsub(
				"#INDEX", wt.Color(strings.chat.preset.command .. " " .. 0, colors.purple[2])
			)
		},
		[3] = {
			command = strings.chat.toggle.command,
			description = strings.chat.toggle.description:gsub(
				"#HIDDEN", wt.Color(dbc.hidden and strings.chat.toggle.hidden or strings.chat.toggle.shown, colors.purple[2])
			)
		},
		[4] = {
			command = strings.chat.fade.command,
			description = strings.chat.fade.description:gsub(
				"#STATE", wt.Color(db.display.visibility.fade.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[2])
			)
		},
		[5] = {
			command = strings.chat.size.command,
			description =  strings.chat.size.description:gsub(
				"#SIZE", wt.Color(strings.chat.size.command .. " " .. dbDefault.display.text.font.size, colors.purple[2])
			)
		},
		[6] = {
			command = strings.chat.integration.command,
			description =  strings.chat.integration.description
		},
	}
	--Print the list
	for i = 0, #commands do
		print("    " .. wt.Color(strings.chat.keyword .. " " .. commands[i].command, colors.purple[2]) .. wt.Color(" - " .. commands[i].description, colors.blue[2]))
	end
end

--[ Slash Command Handlers ]

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
	print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.save.response, colors.blue[0]))
end
local function PresetCommand(parameter)
	local i = tonumber(parameter)
	if i ~= nil and i >= 0 and i <= #presets then
		if not dbc.disabled then
			--Update the display
			remXP:Show()
			remXP:SetFrameStrata(presets[i].data.visibility.frameStrata)
			ResizeDisplay(presets[i].data.background.size.width, presets[i].data.background.size.height)
			wt.PositionFrame(remXP, presets[i].data.position.point, nil, nil, presets[i].data.position.offset.x, presets[i].data.position.offset.y)
			if not presets[i].data.background.visible then wt.SetVisibility(mainDisplayText, true) end
			SetDisplayBackdrop(presets[i].data.background.visible, db.display.background.colors)
			Fade(db.display.visibility.fade.enable)
			--Update the GUI options in case the window was open
			options.visibility.hidden:SetChecked(false)
			options.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
			options.position.anchor.setSelected(GetAnchorID(presets[i].data.position.point))
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
			db.display.position = presets[i].data.position
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
			print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.preset.response:gsub(
				"#PRESET", wt.Color(presets[i].name, colors.purple[1])
			), colors.blue[0]))
		else
			PrintStatus()
		end
	else
		--Error
		print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.preset.unchanged, colors.blue[0]))
		print(wt.Color(strings.chat.preset.error:gsub("#INDEX", wt.Color(strings.chat.preset.command .. " " .. 0, colors.purple[1])), colors.blue[1]))
		print(wt.Color(strings.chat.preset.list, colors.purple[2]))
		for i = 0, #presets, 2 do
			local list = "    " .. wt.Color(i, colors.purple[2]) .. wt.Color(" - " .. presets[i].name, colors.blue[2])
			if i + 1 <= #presets then list = list .. "    " .. wt.Color(i + 1, colors.purple[2]) .. wt.Color(" - " .. presets[i + 1].name, colors.blue[2]) end
			print(list)
		end
	end
end
local function ToggleCommand()
	dbc.hidden = not dbc.hidden
	wt.SetVisibility(remXP, not (dbc.hidden or dbc.disabled))
	--Update the GUI option in case it was open
	options.visibility.hidden:SetChecked(dbc.hidden)
	options.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
	--Response
	print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.toggle.response:gsub(
		"#STATE", wt.Color(dbc.hidden and strings.chat.toggle.hidden or strings.chat.toggle.shown, colors.purple[1])
	), colors.blue[0]))
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDBC.hidden = dbc.hidden
end
local function FadeCommand()
	db.display.visibility.fade.enabled = not db.display.visibility.fade.enabled
	Fade(db.display.visibility.fade.enabled)
	--Update the GUI option in case it was open
	options.visibility.fade.toggle:SetChecked(db.display.visibility.fade.enabled)
	options.visibility.fade.toggle:SetAttribute("loaded", true) --Update dependent widgets
	--Response
	print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.fade.response:gsub(
		"#STATE", wt.Color(db.display.visibility.fade.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[1])
	), colors.blue[0]))
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDB.display.visibility.fade.enabled = db.display.visibility.fade.enabled
end
local function SizeCommand(parameter)
	local size = tonumber(parameter)
	if size ~= nil then
		db.display.text.font.size = size
		mainDisplayText:SetFont(db.display.text.font.family, db.display.text.font.size, "THINOUTLINE")
		--Update the GUI option in case it was open
		options.text.font.size:SetValue(size)
		--Response
		print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.size.response:gsub("#VALUE", wt.Color(size, colors.purple[1])), colors.blue[0]))
	else
		--Error
		print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.size.unchanged, colors.blue[0]))
		print(wt.Color(strings.chat.size.error:gsub(
			"#SIZE", wt.Color(strings.chat.size.command .. " " .. dbDefault.display.text.font.size, colors.purple[1])
		), colors.blue[1]))
	end
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDB.display.text.font.size = db.display.text.font.size
end
local function IntegrationCommand()
	db.enhancement.enabled = not db.enhancement.enabled
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, true)
	--Update the GUI option in case it was open
	options.enhancement.toggle:SetChecked(db.enhancement.enabled)
	options.enhancement.toggle:SetAttribute("loaded", true) --Update dependent widgets
	--Response
	print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.integration.response:gsub(
		"#STATE", wt.Color(db.enhancement.enabled and strings.misc.enabled or strings.misc.disabled, colors.purple[1])
	), colors.blue[0]))
	if dbc.disabled then PrintStatus() end
	--Update in the SavedVariabes DB
	RemainingXPDB.enhancement.enabled = db.enhancement.enabled
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
			text = strings.options.name:gsub("#ADDON", addonTitle),
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
	wt.PositionFrame(remXP, db.display.position.point, nil, nil, db.display.position.offset.x, db.display.position.offset.y)
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
		--Stop moving when SHIFT is released
		mainDisplay:SetScript("OnUpdate", function ()
			if IsShiftKeyDown() then return end
			remXP:StopMovingOrSizing()
			remXP.isMoving = false
			--Reset the position
			wt.PositionFrame(remXP, db.display.position.point, nil, nil, db.display.position.offset.x, db.display.position.offset.y)
			--Chat response
			print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.position.cancel, colors.blue[0]))
			print(wt.Color(strings.chat.position.error:gsub("#SHIFT", strings.keys.shift), colors.blue[1]))
			--Stop checking if SHIFT is pressed
			mainDisplay:SetScript("OnUpdate", nil)
		end)
	end
end)
mainDisplay:SetScript("OnMouseUp", function()
	if not remXP.isMoving then return end
	remXP:StopMovingOrSizing()
	remXP.isMoving = false
	--Save the position (for account-wide use)
	db.display.position.point, _, _, db.display.position.offset.x, db.display.position.offset.y = remXP:GetPoint()
	RemainingXPDB.display.position = wt.Clone(db.display.position) --Update in the SavedVariabes DB
	--Update the GUI options in case the window was open
	options.position.anchor.setSelected(GetAnchorID(db.display.position.point))
	options.position.xOffset:SetValue(db.display.position.offset.x)
	options.position.yOffset:SetValue(db.display.position.offset.y)
	--Chat response
	print(wt.Color(addonTitle .. ":", colors.purple[0]) .. " " .. wt.Color(strings.chat.position.save, colors.blue[0]))
	--Stop checking if SHIFT is pressed
	mainDisplay:SetScript("OnUpdate", nil)
end)

--Toggling the main display tooltip and fade on mouseover
mainDisplay:SetScript('OnEnter', function()
	--Show tooltip
	ns.tooltip = wt.AddTooltip(nil, mainDisplay, "ANCHOR_BOTTOMRIGHT", strings.xpTooltip.title, GetXPTooltipDetails(), 0, mainDisplay:GetHeight())
	--Fade toggle
	if db.display.visibility.fade.enabled then Fade(false) end
end)
mainDisplay:SetScript('OnLeave', function()
	--Hide tooltip
	ns.tooltip:Hide()
	--Fade toggle
	if db.display.visibility.fade.enabled then Fade(true) end
end)

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
	integratedDisplay:SetPoint("BOTTOM")
	integratedDisplay:SetFrameStrata("HIGH")
	integratedDisplay:SetToplevel(true)
	integratedDisplay:SetSize(MainMenuBarArtFrame:GetWidth(), CheckRepBarStatus() and 10 or 14)
	integratedDisplayText:SetPoint("CENTER", 0, 1)
	SetIntegrationVisibility(db.enhancement.enabled, db.enhancement.keep, db.enhancement.remaining, true, false)
	--Size updates
	InterfaceOptionsActionBarsPanelBottomRight:HookScript("OnClick", function() integratedDisplay:SetWidth(MainMenuBarArtFrame:GetWidth()) end)
	ReputationDetailMainScreenCheckBox:HookScript("OnClick", function() integratedDisplay:SetHeight(ReputationDetailMainScreenCheckBox:GetChecked() and 10 or 14) end)
	if IsAddOnLoaded("RepHelper") then RPH_ReputationDetailMainScreenCheckBox:HookScript("OnClick", function()
		integratedDisplay:SetHeight(not RPH_ReputationDetailMainScreenCheckBox:GetChecked() and 10 or 14) --TODO: Only works when flipped, look into it
	end) end
	if IsActiveBattlefieldArena() then integratedDisplay:SetHeight(10) end
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
	ns.tooltip = wt.AddTooltip(nil, integratedDisplay, "ANCHOR_NONE", strings.xpTooltip.title, GetXPTooltipDetails())
	ns.tooltip:SetPoint("BOTTOMRIGHT", -11, 115)
	--Handling trial accounts & Banked XP
	local label = XPBAR_LABEL
	if GameLimitedMode_IsActive() then
		local rLevel = GetRestrictedAccountData()
		if UnitLevel("player") >= rLevel then
			if csc.xp.banked > 0 then
				GameTooltip:SetOwner(StatusTrackingBarManager, "ANCHOR_RIGHT", 0, CheckRepBarStatus() and -19 or -14)
				local text = TRIAL_CAP_BANKED_XP_TOOLTIP
				if csc.xp.bankedLevels > 0 then text = TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(csc.xp.bankedLevels) end
				GameTooltip:SetText(text, nil, nil, nil, nil, true)
				GameTooltip:Show()
				--Flash the store button
				if IsTrialAccount() then MicroButtonPulse(StoreMicroButton) end
				return --Don't show the normal tooltip
			else label = label .. " " .. RED_FONT_COLOR_CODE .. CAP_REACHED_TRIAL .. "|r" end
		end
	end
	-- ExhaustionTickMixin:ExhaustionToolTipText() --Show the default Rested XP tooltip
end)
integratedDisplay:SetScript("OnLeave", function()
	--Hide the enhanced XP text on the default XP bar
	SetIntegrationTextVisibility(db.enhancement.keep, db.enhancement.remaining)
	--Hide the custom tooltip
	ns.tooltip:Hide()
	--Default trial tooltip
	if GameLimitedMode_IsActive() and IsTrialAccount() then
		--Stop the store button from flashing
		MicroButtonPulseStop(StoreMicroButton)
		--Hide the default trial tooltip
		GameTooltip:Hide()
	end
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
	dbc.disabled = UnitLevel("player") >= GetMax()
	--Update the XP values
	UpdateXPValues()
	--Set up the main frame & text
	SetUpMainDisplayFrame()
	--Set up the integrated frame & text
	SetUpIntegratedFrame()
	--Check max level, update XP texts
	if not dbc.disabled then
		--Main display
		UpdateXPDisplayText()
		--Integration
		if db.enhancement.enabled then UpdateIntegratedDisplay(db.enhancement.remaining) end
	end
	--Hide the enabled removals
	if db.removals.statusBars then StatusTrackingBarManager:Hide() end
	--Visibility notice
	if not remXP:IsVisible() then PrintStatus(true) end
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
		print(wt.Color(strings.chat.notifications.xpGained.text:gsub(
			"#AMOUNT", wt.Color(wt.FormatThousands(gainedXP), colors.purple[0])
		):gsub(
			"#REMAINING", wt.Color(strings.chat.notifications.xpGained.remaining:gsub(
				"#AMOUNT", wt.Color(wt.FormatThousands(csc.xp.remaining), colors.purple[2])
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
	local max = GetMax()
	dbc.disabled = newLevel >= max
	if dbc.disabled then
		--Hide the displays
		remXP:hide()
		integratedDisplay:hide()
		--Notification
		print(wt.Color(strings.chat.notifications.lvlUp.disabled.text:gsub(
			"#ADDON", wt.Color(addonTitle, colors.purple[0])
		):gsub(
			"#REASON", wt.Color(strings.chat.notifications.lvlUp.disabled.reason:gsub(
				"#MAX", max
			), colors.blue[2])
		) .. " " .. strings.chat.notifications.lvlUp.congrats, colors.blue[0]))
	else
		--Notification
		if db.notifications.lvlUp.congrats then
			print(wt.Color(strings.chat.notifications.lvlUp.text:gsub(
				"#LEVEL", wt.Color(newLevel, colors.purple[0])
			) .. " " .. wt.Color(strings.chat.notifications.lvlUp.congrats, colors.purple[2]), colors.blue[0]))
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
		print(wt.Color(strings.chat.notifications.restedXPGained.text:gsub(
				"#AMOUNT", wt.Color(gainedRestedXP, colors.purple[0])
			):gsub(
				"#TOTAL", wt.Color(wt.FormatThousands(csc.xp.rested), colors.purple[0])
			):gsub(
				"#PERCENT", wt.Color(strings.chat.notifications.restedXPGained.percent:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 100000) / 1000, 3) .. "%%%%", colors.purple[2])
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
		local s = wt.Color(strings.chat.notifications.restedXPAccumulated.leave, colors.purple[0])
		if (csc.xp.accumulatedRested or 0) > 0 then s = s .. " " .. wt.Color(strings.chat.notifications.restedXPAccumulated.accumulated:gsub(
				"#AMOUNT", wt.Color(wt.FormatThousands(csc.xp.accumulatedRested), colors.purple[0])
			):gsub(
				"#TOTAL", wt.Color(wt.FormatThousands(csc.xp.rested), colors.purple[0])
			):gsub(
				"#PERCENT", wt.Color(strings.chat.notifications.restedXPAccumulated.percent:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 1000000) / 10000, 4) .. "%%%%", colors.purple[2])
				):gsub(
					"#NEXT", wt.Color(UnitLevel("player") + 1, colors.purple[2])
				), colors.blue[2])
			), colors.blue[0])
		else s = s .. " " .. wt.Color(strings.chat.notifications.restedXPAccumulated.noAccumulation, colors.blue[0]) end
		print(s)
	end
	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated)
	--Tooltip
	UpdateXPTooltip()
end