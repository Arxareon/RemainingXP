--[[ RESOURCES ]]

---Addon namespace
---@class ns
local addonNameSpace, ns = ...

---WidgetTools toolbox
---@class wt
local wt = ns.WidgetToolbox

--Addon title
local addonTitle = wt.Clear(select(2, GetAddOnInfo(addonNameSpace))):gsub("^%s*(.-)%s*$", "%1")

--Custom Tooltip
ns.tooltip = wt.CreateGameTooltip(addonNameSpace)

--[ Data Tables ]

local db = {} --Account-wide options
local dbc = {} --Character-specific options
local cs --Cross-session account-wide data
local csc --Cross-session character-specific data

--Default values
local dbDefault = {
	display = {
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -120 }
		},
		layer = {
			strata = "HIGH",
		},
		fade = {
			enabled = false,
			text = 1,
			background = 0.6,
		},
		text = {
			visible = true,
			details = false,
			font = {
				family = ns.fonts[1].path,
				size = 11,
				color = { r = 1, g = 1, b = 1, a = 1 },
			},
			alignment = "CENTER",
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
		remaining = true,
	},
	removals = {
		xpBar = false,
	},
	notifications = {
		xpGained = true,
		restedXP = {
			gained = true,
			significantOnly = true,
			accumulated = true,
		},
		restedStatus = {
			update = true,
			maxReminder = true,
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
}

--Preset data
local presets = {
	{
		name = ns.strings.misc.custom, --Custom
		data = {
			position = dbDefault.display.position,
			layer = {
				strata = dbDefault.display.layer.strata,
			},
			background = {
				visible = dbDefault.display.background.visible,
				size = dbDefault.display.background.size,
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[1], --XP Bar Replacement
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = 0, y = 40.25 }
			},
			layer = {
				strata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 1014, height = 10 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[2], --XP Bar Left Text
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = -485, y = 40.25 }
			},
			layer = {
				strata = "HIGH"
			},
			background = {
				visible = false,
				size = { width = 64, height = 10 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[3], --XP Bar Right Text
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = 485, y = 40.25 }
			},
			layer = {
				strata = "HIGH"
			},
			background = {
				visible = false,
				size = { width = 64, height = 10 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[4], --Player Frame Bar Above
		data = {
			position = {
				anchor = "TOPLEFT",
				offset = { x = 92, y = -10 }
			},
			layer = {
				strata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 122, height = 16 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[5], --Player Frame Text Under
		data = {
			position = {
				anchor = "TOPLEFT",
				offset = { x = 0, y = -86 }
			},
			layer = {
				strata = "MEDIUM"
			},
			background = {
				visible = false,
				size = { width = 104, height = 16 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[7], --Bottom-Left Chunky Bar
		data = {
			position = {
				anchor = "BOTTOMLEFT",
				offset = { x = 63, y = 10 }
			},
			layer = {
				strata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 240, height = 34 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[8], --Bottom-Right Chunky Bar
		data = {
			position = {
				anchor = "BOTTOMRIGHT",
				offset = { x = -63, y = 10 }
			},
			layer = {
				strata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 240, height = 34 },
			},
		},
	},
	{
		name = ns.strings.options.display.position.presets.list[9], --Top-Center Long Bar
		data = {
			position = {
				anchor = "TOP",
				offset = { x = 0, y = 3 }
			},
			layer = {
				strata = "MEDIUM"
			},
			background = {
				visible = true,
				size = { width = 980, height = 8 },
			},
		},
	},
}

--Add custom preset to DB
dbDefault.customPreset = wt.Clone(presets[1].data)

--[ References ]

--Local frame references
local frames = {
	display = { bg = {} },
	integration = {},
	options = {
		main = {},
		display = {
			position = {},
			visibility = {},
			text = {
				font = {},
			},
			background = {
				colors = {},
				size = {},
			},
			fade = {},
		},
		integration = {
			enhancement = {},
			removals = {},
		},
		events = {
			notifications = {},
		},
		advanced = {
			backup = {},
		},
	}
}

--Check max level
local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
local max = UnitLevel("player") >= maxLevel

local alwaysShow = C_CVar.GetCVar("xpBarText")


--[[ UTILITIES ]]

--[ Resource Management ]

---Find the ID of the font provided
---@param fontPath string
---@return integer
local function GetFontID(fontPath)
	local id = 1

	for i = 1, #ns.fonts do
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
		if k == "r" or k == "g" or k == "b" or k == "a" then return v >= 0 and v <= 1 end
		--Corrupt Anchor Points
		if k == "anchor" then return false end
	end return true
end

--Check & fix the account-wide & character-specific DBs
---@param dbCheck table
---@param dbSample table
---@param dbcCheck table
---@param dbcSample table
local function CheckDBs(dbCheck, dbSample, dbcCheck, dbcSample)
	wt.RemoveEmpty(dbCheck, CheckValidity)
	wt.RemoveEmpty(dbcCheck, CheckValidity)
	wt.AddMissing(dbCheck, dbSample)
	wt.AddMissing(dbcCheck, dbcSample)
	wt.RemoveMismatch(dbCheck, dbSample, {
		["customPreset.position.point"] = { saveTo = dbCheck.customPreset.position, saveKey = "anchor" },
		["position.point"] = { saveTo = dbCheck.display.position, saveKey = "anchor" },
		["display.position.point"] = { saveTo = dbCheck.display.position, saveKey = "anchor" },
		["appearance.frameStrata"] = { saveTo = dbCheck.display.layer, saveKey = "strata" },
		["display.visibility.frameStrata"] = { saveTo = dbCheck.display.layer, saveKey = "strata" },
		["display.visibility.fade"] = { saveTo = dbCheck.display, saveKey = "fade" },
		["appearance.backdrop.visible"] = { saveTo = dbCheck.display.background, saveKey = "visible" },
		["appearance.backdrop.color.r"] = { saveTo = dbCheck.display.background.colors.bg, saveKey = "r" },
		["appearance.backdrop.color.g"] = { saveTo = dbCheck.display.background.colors.bg, saveKey = "g" },
		["appearance.backdrop.color.b"] = { saveTo = dbCheck.display.background.colors.bg, saveKey = "b" },
		["appearance.backdrop.color.a"] = { saveTo = dbCheck.display.background.colors.bg, saveKey = "a" },
		["font.family"] = { saveTo = dbCheck.display.text.font, saveKey = "family" },
		["font.size"] = { saveTo = dbCheck.display.text.font, saveKey = "size" },
		["font.color.r"] = { saveTo = dbCheck.display.text.font.color, saveKey = "r" },
		["font.color.g"] = { saveTo = dbCheck.display.text.font.color, saveKey = "g" },
		["font.color.b"] = { saveTo = dbCheck.display.text.font.color, saveKey = "b" },
		["font.color.a"] = { saveTo = dbCheck.display.text.font.color, saveKey = "a" },
		["removals.statusBars"] = { saveTo = dbCheck.removals, saveKey = "xpBar" },
		["notifications.maxReminder"] = { saveTo = dbCheck.notifications.statusNotice, saveKey = "maxReminder" },
		["mouseover"] = { saveTo = dbCheck.display.fade, saveKey = "enabled" },
	})
	wt.RemoveMismatch(dbcCheck, dbcSample, {
		["mouseover"] = { saveTo = dbCheck.display.fade, saveKey = "enabled" },
	})

	--Check the display visibility values
	if not dbCheck.display.text.visible and not dbCheck.display.background.visible then
		dbCheck.display.text.visible = true
		dbCheck.display.background.visible = true
		dbcCheck.hidden = true
	end
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
			local atMax = wt.Round(csc.xp.rested / csc.xp.needed, 3) >= 1.5
			local atMaxLast = UnitLevel("player") == maxLevel - 1 and wt.Round(csc.xp.rested / csc.xp.remaining, 3) >= 1

			--Stared resting status update
			if db.notifications.restedStatus.update then
				print(wt.Color(ns.strings.chat.restedStatus.resting, ns.colors.purple[1]) .. " " .. wt.Color(
					(atMax or atMaxLast) and ns.strings.chat.restedStatus.notAccumulating or ns.strings.chat.restedStatus.accumulating, ns.colors.blue[1]
				))

				--Max Rested XP reminder
				if db.notifications.restedStatus.maxReminder then if atMax then
					print(wt.Color(ns.strings.chat.restedStatus.atMax:gsub("#PERCENT", wt.Color("150%%", ns.colors.purple[2])), ns.colors.blue[2]))
				elseif atMaxLast then
					print(wt.Color(ns.strings.chat.restedStatus.atMaxLast:gsub("#PERCENT", wt.Color("100%%", ns.colors.purple[2])), ns.colors.blue[2]))
				end end
			end
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
	frames.display.xp:SetWidth(csc.xp.current / csc.xp.needed * frames.display.bg:GetWidth())

	--Rested XP segment
	if csc.xp.rested == 0 then frames.display.rested:Hide() else
		frames.display.rested:Show()
		if frames.display.xp:GetWidth() == 0 then frames.display.rested:SetPoint("LEFT") else frames.display.rested:SetPoint("LEFT", frames.display.xp, "RIGHT") end
		frames.display.rested:SetWidth((csc.xp.current + csc.xp.rested > csc.xp.needed and csc.xp.needed - csc.xp.current or csc.xp.rested) / csc.xp.needed * frames.display.bg:GetWidth())
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
	else text = wt.FormatThousands(csc.xp.remaining) end

	frames.display.text:SetText(text)
end

---Update the default XP bar enhancement display with the current XP values
---@param remaining boolean Whether or not only the remaining XP should be visible when the text is always shown
local function UpdateIntegrationText(keep, remaining)
	if not frames.integration.frame:IsVisible() then return end

	--Text base visibility
	wt.SetVisibility(frames.integration.text, keep)

	--Text content
	if remaining and not frames.integration.frame:IsMouseOver() then frames.integration.text:SetText(wt.FormatThousands(csc.xp.remaining))
	else frames.integration.text:SetText(
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
	) end
end

---Assemble the detailed text lines for xp tooltip
---@return table textLines Table containing text lines to be added to the tooltip [indexed, 0-based]
--- - **text** string ― Text to be added to the line
--- - **font**? string|FontObject *optional* ― The FontObject to set for this line ***Default:*** GameTooltipTextSmall
--- - **color**? table *optional* ― Table containing the RGB values to color this line with ***Default:*** HIGHLIGHT_FONT_COLOR (white)
--- 	- **r** number ― Red ***Range:*** (0, 1)
--- 	- **g** number ― Green ***Range:*** (0, 1)
--- 	- **b** number ― Blue ***Range:*** (0, 1)
--- - **wrap**? boolean *optional* ― Allow this line to be wrapped ***Default:*** true
local function GetXPTooltipTextlines()
	local textLines = {
		--Description
		{ text = ns.strings.xpTooltip.text, },

		--Current XP
		{
			text = "\n" .. ns.strings.xpTooltip.current:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.current), ns.colors.purple[2])
			),
			font = GameTooltipText,
			color = ns.colors.purple[1],
		},
		{
			text = ns.strings.xpTooltip.percentRequired:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.current / csc.xp.needed * 10000) / 100, 3) .. "%%", ns.colors.purple[2])
			),
			color = ns.colors.purple[3],
		},

		--Remaining XP
		{
			text = "\n" .. ns.strings.xpTooltip.remaining:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.remaining), ns.colors.rose[2])
			),
			font = GameTooltipText,
			color = ns.colors.rose[1],
		},
		{
			text = ns.strings.xpTooltip.percentRequired:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor((csc.xp.remaining / csc.xp.needed) * 10000) / 100, 3) .. "%%", ns.colors.rose[2])
			),
			color = ns.colors.rose[3],
		},

		--Required XP
		{
			text = "\n" .. ns.strings.xpTooltip.required:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.needed), ns.colors.peach[2])
			),
			font = GameTooltipText,
			color = ns.colors.peach[1],
		},
		{
			text = ns.strings.xpTooltip.requiredLevelUp:gsub(
				"#LEVEL", wt.Color(UnitLevel("player") + 1, ns.colors.peach[2])
			),
			color = ns.colors.peach[3],
		},

		--Playtime --TODO: Add time played info
		-- {
		-- 	text = "\n" .. ns.strings.xpTooltip.timeSpent:gsub("#TIME", "?") .. " (Soon™)",
		-- },
	}

	--Current Rested XP
	if csc.xp.rested > 0 then
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.rested:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.rested), ns.colors.blue[2])
			),
			font = GameTooltipText,
			color = ns.colors.blue[1],
		})
		table.insert(textLines, {
			text = ns.strings.xpTooltip.percentRemaining:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 10000) / 100, 3) .. "%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
		table.insert(textLines, {
			text = ns.strings.xpTooltip.percentRequired:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / csc.xp.needed * 10000) / 100, 3) .. "%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})

		--Description
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.restedMax:gsub(
				"#PERCENT_MAX", wt.Color("150%%", ns.colors.blue[2])
			):gsub(
				"#PERCENT_REMAINING", wt.Color("100%%", ns.colors.blue[2])
			):gsub(
				"#LEVEL", wt.Color(maxLevel - 1, ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.restedDescription:gsub(
				"#PERCENT", wt.Color("200%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
	end

	--Resting status
	if IsResting() then
		table.insert(textLines, {
			text = "\n" .. ns.strings.chat.restedStatus.resting,
			font = GameTooltipText,
			color = ns.colors.blue[1],
		})
		local atMax = wt.Round(csc.xp.rested / csc.xp.needed, 3) >= 1.5
		local atMaxLast = UnitLevel("player") == maxLevel - 1 and wt.Round(csc.xp.rested / csc.xp.remaining, 3) >= 1
		table.insert(textLines, {
			text = (atMax or atMaxLast) and (ns.strings.xpTooltip.restedAtMax) or ns.strings.chat.restedStatus.accumulating,
			color = ns.colors.blue[2],
		})
	end

	--Accumulated Rested XP
	if (csc.xp.accumulatedRested or 0) > 0 then
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.accumulated:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(csc.xp.accumulatedRested or 0), ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
	end

	--Hints
	table.insert(textLines, {
		text = "\n" .. ns.strings.xpTooltip.hintOptions,
		font = GameFontNormalTiny,
		color = ns.colors.grey[1],
	})
	if frames.display.overlay:IsMouseOver() then
		table.insert(textLines, {
			text = ns.strings.xpTooltip.hintMove:gsub("#SHIFT", ns.strings.keys.shift),
			font = GameFontNormalTiny,
			color = ns.colors.grey[1],
		})
	end

	return textLines
end

--Update the text of the xp tooltip
local function UpdateXPTooltip()
	if not ns.tooltip:IsVisible() then return end

	--Find the active owner & update
	local owner = frames.integration.frame:IsMouseOver() and frames.integration.frame or frames.display.overlay:IsMouseOver() and frames.display.overlay or nil
	if owner then wt.UpdateTooltip(owner, { lines = GetXPTooltipTextlines(), }) end
end

--[ Main XP Display ]

---Fade the main display in or out
---@param state? boolean Decides whether to fade our or fade in the display ***Default:*** db.display.fade.enabled
---@param textColor? table Table containing the text color values ***Default:*** db.display.text.font.color
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity ***Range:*** (0, 1) | ***Default:*** 1
---@param bgColor? table Table containing the backdrop background color values ***Default:*** db.display.background.bg
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity ***Range:*** (0, 1) | ***Default:*** 1
---@param xpColor? table Table containing the backdrop background color values ***Default:*** db.display.background.xp
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity ***Range:*** (0, 1) | ***Default:*** 1
---@param restedColor? table Table containing the backdrop background color values ***Default:*** db.display.background.rested
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity ***Range:*** (0, 1) | ***Default:*** 1
---@param borderColor? table Table containing the backdrop border color values ***Default:*** db.display.background.border
--- - **r** number ― Red (Range: 0 - 1)
--- - **g** number ― Green (Range: 0 - 1)
--- - **b** number ― Blue (Range: 0 - 1)
--- - **a**? number *optional* ― Opacity ***Range:*** (0, 1) | ***Default:*** 1
---@param textIntensity? number Value determining how much to fade out the text ***Range:*** (0, 1) | ***Default:*** db.display.fade.text
---@param backdropIntensity? number Value determining how much to fade out the backdrop elements ***Range:*** (0, 1) | ***Default:*** db.display.fade.background
local function Fade(state, textColor, bgColor, borderColor, xpColor, restedColor, textIntensity, backdropIntensity)
	if state == nil then state = db.display.fade.enabled end

	--Text
	local r, g, b, a = wt.UnpackColor(textColor or db.display.text.font.color)
	frames.display.text:SetTextColor(r, g, b, (a or 1) * (state and 1 - (textIntensity or db.display.fade.text) or 1))

	--Background
	if db.display.background.visible then
		backdropIntensity = backdropIntensity or db.display.fade.background

		--Backdrop
		r, g, b, a = wt.UnpackColor(bgColor or db.display.background.colors.bg)
		frames.display.bg:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))

		--Current XP segment
		r, g, b, a = wt.UnpackColor(xpColor or db.display.background.colors.xp)
		frames.display.xp:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))

		--Rested XP segment
		r, g, b, a = wt.UnpackColor(restedColor or db.display.background.colors.rested)
		frames.display.rested:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))

		--Border & Text holder
		r, g, b, a = wt.UnpackColor(borderColor or db.display.background.colors.border)
		frames.display.overlay:SetBackdropBorderColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))
	end
end

---Set the size of the main display elements
---@param width number
---@param height number
local function ResizeDisplay(width, height)
	--Background
	frames.display.bg:SetSize(width, height)

	--XP bar segments
	frames.display.xp:SetHeight(height)
	frames.display.rested:SetHeight(height)
	UpdateXPDisplaySegments()

	--Border & Text holder
	frames.display.overlay:SetSize(width, height)
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
		frames.display.bg:SetBackdrop(nil)
		frames.display.xp:SetBackdrop(nil)
		frames.display.rested:SetBackdrop(nil)
		frames.display.overlay:SetBackdrop(nil)
	else
		--Background
		frames.display.bg:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		frames.display.bg:SetBackdropColor(wt.UnpackColor(backdropColors.bg))

		--Current XP segment
		frames.display.xp:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		frames.display.xp:SetBackdropColor(wt.UnpackColor(backdropColors.xp))

		--Rested XP segment
		frames.display.rested:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		frames.display.rested:SetBackdropColor(wt.UnpackColor(backdropColors.rested))

		--Border & Text holder
		frames.display.overlay:SetBackdrop({
			edgeFile = "Interface/ChatFrame/ChatFrameBackground",
			edgeSize = 1,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		frames.display.overlay:SetBackdropBorderColor(wt.UnpackColor(backdropColors.border))
	end
end

---Set the visibility, backdrop, font family, size and color of the main display to the currently saved values
---@param data table Account-wide data table to set the main display values from
---@param characterData table Character-specific data table to set the main display values from
local function SetDisplayValues(data, characterData)
	--Visibility
	frames.main:SetFrameStrata(data.display.layer.strata)
	wt.SetVisibility(frames.main, not (characterData.hidden or characterData.disabled))

	--Backdrop elements
	SetDisplayBackdrop(data.display.background.visible, data.display.background.colors)

	--Font & text
	frames.display.text:SetFont(data.display.text.font.family, data.display.text.font.size, "THINOUTLINE")
	frames.display.text:SetTextColor(wt.UnpackColor(data.display.text.font.color))

	--Fade
	Fade(data.display.fade.enabled)
end

---Apply a specific display preset
---@param i integer Index of the preset
local function ApplyPreset(i)
	if max then return end

	--Update the display
	frames.main:Show()
	wt.SetPosition(frames.main, presets[i].data.position)
	frames.main:SetFrameStrata(presets[i].data.layer.strata)
	ResizeDisplay(presets[i].data.background.size.width, presets[i].data.background.size.height)
	if not presets[i].data.background.visible then wt.SetVisibility(frames.display.text, true) end
	SetDisplayBackdrop(presets[i].data.background.visible, db.display.background.colors)
	Fade(db.display.fade.enable)

	--Convert to absolute position
	wt.ConvertToAbsolutePosition(frames.main)

	--Update the DBs
	dbc.hidden = false
	wt.CopyValues(wt.PackPosition(frames.main:GetPoint()), db.display.position)
	db.display.layer.strata = presets[i].data.layer.strata
	if not presets[i].data.background.visible then db.display.text.visible = true end
	db.display.background.visible = presets[i].data.background.visible
	wt.CopyValues(presets[i].data.background.size, db.display.background.size)

	--Update the options widgets
	frames.options.display.visibility.hidden.setState(false)
	frames.options.display.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
	frames.options.display.position.anchor.setSelected(db.display.position.anchor)
	frames.options.display.position.xOffset.setValue(db.display.position.offset.x)
	frames.options.display.position.yOffset.setValue(db.display.position.offset.y)
	frames.options.display.position.frameStrata.setSelected(db.display.layer.strata)
	if not db.display.background.visible then
		frames.options.display.text.visible.setState(true)
		frames.options.display.text.visible:SetAttribute("loaded", true) --Update dependent widgets
	end
	frames.options.display.background.visible.setState(db.display.background.visible)
	frames.options.display.background.visible:SetAttribute("loaded", true) --Update dependent widgets
	frames.options.display.background.size.width.setValue(db.display.background.size.width)
	frames.options.display.background.size.height.setValue(db.display.background.size.height)
end

--Save the current display position & visibility to the custom preset
local function UpdateCustomPreset()
	--Update the Custom preset
	presets[1].data.position = wt.PackPosition(frames.main:GetPoint())
	presets[1].data.layer.strata = frames.main:GetFrameStrata()
	presets[1].data.background.visible = frames.options.display.background.visible.getState()
	presets[1].data.background.size = { width = frames.options.display.background.size.width.getValue(), height = frames.options.display.background.size.height.getValue() }
	wt.CopyValues(presets[1].data, db.customPreset) --Update the DB
	RemainingXPDB.customPreset = wt.Clone(db.customPreset) --Commit to the SavedVariables DB

	--Update the presets widget
	frames.options.display.position.presets.setSelected(1)
end

--Reset the custom preset to its default state
local function ResetCustomPreset()
	--Reset the Custom preset
	presets[1].data = wt.Clone(dbDefault.customPreset)
	wt.CopyValues(presets[1].data, db.customPreset) --Update the DB
	RemainingXPDB.customPreset = wt.Clone(db.customPreset) --Commit to the SavedVariables DB

	--Apply the Custom preset
	ApplyPreset(1)
	frames.options.display.position.presets.setSelected(1) --Update the presets widget
end


--[ Integrated Display ]

--Turn off the integrated display and hide the frame
local function TurnOffIntegration()
	frames.integration.frame:Hide()
	C_CVar.SetCVar("xpBarText", alwaysShow)
end

---Set the visibility of the integrated display frame
---@param enabled boolean Whether or not the default XP bar integration is enabled
local function SetIntegrationVisibility(enabled)
	if enabled and not max then
		frames.integration.frame:Show()
		C_CVar.SetCVar("xpBarText", 0)
	else TurnOffIntegration() end
end


--[[ INTERFACE OPTIONS ]]

--[ Main ]

--Create the widgets
local function CreateOptionsShortcuts(panel)
	--Button: Display page
	wt.CreateButton({
		parent = panel,
		name = "DisplayPage",
		title = ns.strings.options.display.title,
		tooltip = { lines = { { text = ns.strings.options.display.description:gsub("#ADDON", addonTitle), }, } },
		arrange = {},
		size = { width = 120, },
		events = { OnClick = function() frames.options.display.page.open() end, },
	})

	--Button: Integration page
	wt.CreateButton({
		parent = panel,
		name = "IntegrationPage",
		title = ns.strings.options.integration.title,
		tooltip = { lines = { { text = ns.strings.options.integration.description:gsub("#ADDON", addonTitle), }, } },
		position = { offset = { x = 140, y = -30 } },
		size = { width = 120, },
		events = { OnClick = function() frames.options.integration.page.open() end, },
	})

	--Button: Notifications page
	wt.CreateButton({
		parent = panel,
		name = "NotificationsPage",
		title = ns.strings.options.events.title,
		tooltip = { lines = { { text = ns.strings.options.events.description:gsub("#ADDON", addonTitle), }, } },
		position = { offset = { x = 270, y = -30 } },
		size = { width = 120, },
		events = { OnClick = function() frames.options.events.page.open() end, },
	})

	--Button: Advanced page
	wt.CreateButton({
		parent = panel,
		name = "AdvancedPage",
		title = ns.strings.options.advanced.title,
		tooltip = { lines = { { text = ns.strings.options.advanced.description:gsub("#ADDON", addonTitle), }, } },
		position = {
			anchor = "TOPRIGHT",
			offset = { x = -12, y = -30 }
		},
		size = { width = 120, },
		events = { OnClick = function() frames.options.advanced.page.open() end, },
	})
end
local function CreateAboutInfo(panel)
	--Text: Version
	local version = wt.CreateText({
		parent = panel,
		name = "VersionTitle",
		position = { offset = { x = 16, y = -32 } },
		width = 45,
		text = ns.strings.options.main.about.version .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "Version",
		position = {
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = GetAddOnMetadata(addonNameSpace, "Version"),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Text: Date
	local date = wt.CreateText({
		parent = panel,
		name = "DateTitle",
		position = {
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		width = 45,
		text = ns.strings.options.main.about.date .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "Date",
		position = {
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = ns.strings.misc.date:gsub(
			"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
		):gsub(
			"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
		):gsub(
			"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
		),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Text: Author
	local author = wt.CreateText({
		parent = panel,
		name = "AuthorTitle",
		position = {
			relativeTo = date,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		width = 45,
		text = ns.strings.options.main.about.author .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "Author",
		position = {
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = GetAddOnMetadata(addonNameSpace, "Author"),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Text: License
	local license = wt.CreateText({
		parent = panel,
		name = "LicenseTitle",
		position = {
			relativeTo = author,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		width = 45,
		text = ns.strings.options.main.about.license .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "License",
		position = {
			relativeTo = license,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = GetAddOnMetadata(addonNameSpace, "X-License"),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Copybox: CurseForge
	local curse = wt.CreateCopyBox({
		parent = panel,
		name = "CurseForge",
		title = ns.strings.options.main.about.curseForge .. ":",
		position = {
			relativeTo = license,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -11 }
		},
		size = { width = 190, },
		text = "curseforge.com/wow/addons/remaining-xp",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--Copybox: Wago
	local wago = wt.CreateCopyBox({
		parent = panel,
		name = "Wago",
		title = ns.strings.options.main.about.wago .. ":",
		position = {
			relativeTo = curse,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		size = { width = 190, },
		text = "addons.wago.io/addons/remaining-xp",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--Copybox: Repository
	local repo = wt.CreateCopyBox({
		parent = panel,
		name = "Repository",
		title = ns.strings.options.main.about.repository .. ":",
		position = {
			relativeTo = wago,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		size = { width = 190, },
		text = "github.com/Arxareon/RemainingXP",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--Copybox: Issues
	wt.CreateCopyBox({
		parent = panel,
		name = "Issues",
		title = ns.strings.options.main.about.issues .. ":",
		position = {
			relativeTo = repo,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		size = { width = 190, },
		text = "github.com/Arxareon/RemainingXP/issues",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--EditScrollBox: Changelog
	local changelog = wt.CreateEditScrollBox({
		parent = panel,
		name = "Changelog",
		title = ns.strings.options.main.about.changelog.label,
		tooltip = { lines = { { text = ns.strings.options.main.about.changelog.tooltip, }, } },
		arrange = {},
		size = { width = panel:GetWidth() - 225, height = panel:GetHeight() - 42 },
		text = ns.GetChangelog(true),
		font = { normal = "GameFontDisableSmall", },
		color = ns.colors.grey[2],
		readOnly = true,
		scrollSpeed = 50,
	})

	--Button: Full changelog
	local changelogFrame
	wt.CreateButton({
		parent = panel,
		name = "OpenFullChangelog",
		title = ns.strings.options.main.about.openFullChangelog.label,
		tooltip = { lines = { { text = ns.strings.options.main.about.openFullChangelog.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = changelog,
			relativePoint = "TOPRIGHT",
			offset = { x = -3, y = 2 }
		},
		size = { width = 176, height = 14 },
		font = {
			normal = "GameFontNormalSmall",
			highlight = "GameFontHighlightSmall",
		},
		events = { OnClick = function()
			if changelogFrame then changelogFrame:Show()
			else
				--Panel: Changelog frame
				changelogFrame = wt.CreatePanel({
					parent = UIParent,
					name = addonNameSpace .. "Changelog",
					append = false,
					title = ns.strings.options.main.about.fullChangelog.label:gsub("#ADDON", addonTitle),
					position = { anchor = "CENTER", },
					keepInBounds = true,
					size = { width = 740, height = 560 },
					background = { color = { a = 0.9 }, },
					initialize = function(windowPanel)
						--EditScrollBox: Full changelog
						wt.CreateEditScrollBox({
							parent = windowPanel,
							name = "FullChangelog",
							title = ns.strings.options.main.about.fullChangelog.label:gsub("#ADDON", addonTitle),
							label = false,
							tooltip = { lines = { { text = ns.strings.options.main.about.fullChangelog.tooltip, }, } },
							arrange = {},
							size = { width = windowPanel:GetWidth() - 32, height = windowPanel:GetHeight() - 88 },
							text = ns.GetChangelog(),
							font = { normal = "GameFontDisable", },
							color = ns.colors.grey[2],
							readOnly = true,
							scrollSpeed = 120,
						})

						--Button: Close
						wt.CreateButton({
							parent = windowPanel,
							name = "CancelButton",
							title = wt.GetStrings("close"),
							arrange = {},
							events = { OnClick = function() windowPanel:Hide() end },
						})
					end,
					arrangement = {
						margins = { l = 16, r = 16, t = 42, b = 16 },
						flip = true,
					}
				})
				_G[changelogFrame:GetName() .. "Title"]:SetPoint("TOPLEFT", 18, -18)
				wt.SetMovability(changelogFrame, true)
				changelogFrame:SetFrameStrata("DIALOG")
				changelogFrame:IsToplevel(true)
			end
		end, },
	}):SetFrameLevel(changelog:GetFrameLevel() + 1) --Make sure it's on top to be clickable
end

--Create the category page
local function CreateMainOptions()
	---@type optionsPage
	frames.options.main.page = wt.CreateOptionsCategory({
		addon = addonNameSpace,
		name = "Main",
		description = ns.strings.options.main.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		titleLogo = true,
		initialize = function(canvas)
			--Panel: Shortcuts
			wt.CreatePanel({
				parent = canvas,
				name = "Shortcuts",
				title = ns.strings.options.main.shortcuts.title,
				description = ns.strings.options.main.shortcuts.description:gsub("#ADDON", addonTitle),
				arrange = {},
				initialize = CreateOptionsShortcuts,
				arrangement = {}
			})

			--Panel: About
			wt.CreatePanel({
				parent = canvas,
				name = "About",
				title = ns.strings.options.main.about.title,
				description = ns.strings.options.main.about.description:gsub("#ADDON", addonTitle),
				arrange = {},
				size = { height = 258 },
				initialize = CreateAboutInfo,
				arrangement = {
					flip = true,
					resize = false
				}
			})

			--Panel: Sponsors
			local top = GetAddOnMetadata(addonNameSpace, "X-TopSponsors")
			local normal = GetAddOnMetadata(addonNameSpace, "X-Sponsors")
			if top or normal then
				local sponsorsPanel = wt.CreatePanel({
					parent = canvas,
					name = "Sponsors",
					title = ns.strings.options.main.sponsors.title,
					description = ns.strings.options.main.sponsors.description,
					arrange = {},
					size = { height = 64 + (top and normal and 24 or 0) },
					initialize = function(panel)
						if top then
							wt.CreateText({
								parent = panel,
								name = "Top",
								position = { offset = { x = 16, y = -33 } },
								width = panel:GetWidth() - 32,
								text = top:gsub("|", " • "),
								font = "GameFontNormalLarge",
								justify = { h = "LEFT", },
							})
						end
						if normal then
							wt.CreateText({
								parent = panel,
								name = "Normal",
								position = { offset = { x = 16, y = -33 -(top and 24 or 0) } },
								width = panel:GetWidth() - 32,
								text = normal:gsub("|", " • "),
								font = "GameFontHighlightMedium",
								justify = { h = "LEFT", },
							})
						end
					end,
				})
				wt.CreateText({
					parent = sponsorsPanel,
					name = "DescriptionHeart",
					position = { offset = { x = _G[sponsorsPanel:GetName() .. "Description"]:GetStringWidth() + 16, y = -10 } },
					text = "♥",
					font = "ChatFontSmall",
					justify = { h = "LEFT", },
				})
			end
		end,
		arrangement = {}
	})
end

--[ Display ]

--Create the widgets
local function CreateVisibilityOptions(panel)
	--Checkbox: Hidden
	---@type checkbox
	frames.options.display.visibility.hidden = wt.CreateCheckbox({
		parent = panel,
		name = "Hidden",
		title = ns.strings.options.display.visibility.hidden.label,
		tooltip = { lines = { { text = ns.strings.options.display.visibility.hidden.tooltip:gsub("#ADDON", addonTitle), }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = dbc,
			storageKey = "hidden",
			onChange = {
				DisplayToggle = function() wt.SetVisibility(frames.main, not (dbc.hidden or max)) end,
				EnsureVisibility = function()
					if not db.display.background.visible then
						frames.options.display.text.visible.checkbox:SetButtonState("DISABLED")
						frames.options.display.text.visible.checkbox:UnlockHighlight()
						frames.options.display.text.visible:SetAlpha(0.4)
					else
						if not dbc.hidden then frames.options.display.text.visible.checkbox:SetButtonState("NORMAL") end
						frames.options.display.text.visible:SetAlpha(1)
					end
					if not db.display.text.visible then
						frames.options.display.background.visible.checkbox:SetButtonState("DISABLED")
						frames.options.display.background.visible.checkbox:UnlockHighlight()
						frames.options.display.background.visible:SetAlpha(0.4)
					else
						if not dbc.hidden then frames.options.display.background.visible.checkbox:SetButtonState("NORMAL") end
						frames.options.display.background.visible:SetAlpha(1)
					end
				end,
			}
		}
	})

	--Checkbox: Status notice
	---@type checkbox
	frames.options.display.visibility.status = wt.CreateCheckbox({
		parent = panel,
		name = " StatusNotice",
		title = ns.strings.options.display.visibility.statusNotice.label,
		tooltip = { lines = { { text = ns.strings.options.display.visibility.statusNotice.tooltip:gsub("#ADDON", addonTitle), }, } },
		arrange = { newRow = false, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.notifications.statusNotice,
			storageKey = "enabled",
		}
	})

	--Checkbox: Max reminder
	---@type checkbox
	frames.options.display.visibility.maxReminder = wt.CreateCheckbox({
		parent = panel,
		name = "MaxReminder",
		title = ns.strings.options.display.visibility.maxReminder.label,
		tooltip = { lines = { { text = ns.strings.options.display.visibility.maxReminder.tooltip:gsub("#ADDON", addonTitle), }, } },
		arrange = { newRow = false, },
		dependencies = { { frame = frames.options.display.visibility.status, }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.notifications.statusNotice,
			storageKey = "maxReminder",
		}
	})
end
local function CreatePositionOptions(panel)
	--Dropdown: Apply a preset
	local presetItems = {}
	for i = 1, #presets do
		presetItems[i] = {}
		presetItems[i].title = presets[i].name
		presetItems[i].onSelect = function() ApplyPreset(i) end
	end
	---@type dropdown
	frames.options.display.position.presets = wt.CreateDropdown({
		parent = panel,
		name = "ApplyPreset",
		title = ns.strings.options.display.position.presets.label,
		tooltip = { lines = { { text = ns.strings.options.display.position.presets.tooltip, }, } },
		arrange = {},
		width = 180,
		items = presetItems,
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			onLoad = function(self) self.setSelected(nil, ns.strings.options.display.position.presets.select) end,
		}
	})

	--Button & Popup: Save Custom preset
	local savePopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "SAVEPRESET",
		text = ns.strings.options.display.position.savePreset.warning:gsub("#CUSTOM", presets[1].name),
		accept = ns.strings.misc.override,
		onAccept = function()
			UpdateCustomPreset()

			--Notification
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.save.response:gsub(
				"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3])
			), ns.colors.blue[3]))
		end,
	})
	wt.CreateButton({
		parent = panel,
		name = "SavePreset",
		title = ns.strings.options.display.position.savePreset.label:gsub("#CUSTOM", presets[1].name),
		tooltip = { lines = { { text = ns.strings.options.display.position.savePreset.tooltip:gsub("#CUSTOM", presets[1].name), }, } },
		arrange = { newRow = false, },
		size = { width = 170, height = 26 },
		events = { OnClick = function() StaticPopup_Show(savePopup) end, },
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
	})

	--Button & Popup: Reset Custom preset
	local resetPopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "RESETPRESET",
		text = ns.strings.options.display.position.resetPreset.warning:gsub("#CUSTOM", presets[1].name),
		accept = ns.strings.misc.override,
		onAccept = function()
			ResetCustomPreset()

			--Notification
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.reset.response:gsub(
				"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3])
			), ns.colors.blue[3]))
		end,
	})
	wt.CreateButton({
		parent = panel,
		name = "ResetPreset",
		title = ns.strings.options.display.position.resetPreset.label:gsub("#CUSTOM", presets[1].name),
		tooltip = { lines = { { text = ns.strings.options.display.position.resetPreset.tooltip:gsub("#CUSTOM", presets[1].name), }, } },
		arrange = { newRow = false, },
		size = { width = 170, height = 26 },
		events = { OnClick = function() StaticPopup_Show(resetPopup) end, },
	})

	--Selector: Anchor point
	---@type specialSelector
	frames.options.display.position.anchor = wt.CreateSpecialSelector({
		parent = panel,
		name = "AnchorPoint",
		title = ns.strings.options.display.position.anchor.label,
		tooltip = { lines = { { text = ns.strings.options.display.position.anchor.tooltip, }, } },
		arrange = {},
		width = 140,
		itemset = "anchor",
		onSelection = function(point) frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end,
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.position,
			storageKey = "anchor",
			onChange = { UpdateDisplayPosition = function() wt.SetPosition(frames.main, db.display.position) end, }
		}
	})

	--Slider: X offset
	---@type slider
	frames.options.display.position.xOffset = wt.CreateSlider({
		parent = panel,
		name = "OffsetX",
		title = ns.strings.options.display.position.xOffset.label,
		tooltip = { lines = { { text = ns.strings.options.display.position.xOffset.tooltip, }, } },
		arrange = { newRow = false, },
		value = { min = -500, max = 500, fractional = 2 },
		step = 1,
		altStep = 25,
		events = { OnValueChanged = function(_, _, user) if user then
			frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select)
		end end, },
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.position.offset,
			storageKey = "x",
			onChange = { "UpdateDisplayPosition", }
		}
	})

	--Slider: Y offset
	---@type slider
	frames.options.display.position.yOffset = wt.CreateSlider({
		parent = panel,
		name = "OffsetY",
		title = ns.strings.options.display.position.yOffset.label,
		tooltip = { lines = { { text = ns.strings.options.display.position.yOffset.tooltip, }, } },
		arrange = { newRow = false, },
		value = { min = -500, max = 500, fractional = 2 },
		step = 1,
		altStep = 25,
		events = { OnValueChanged = function(_, _, user) if user then
			frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select)
		end end, },
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.position.offset,
			storageKey = "y",
			onChange = { "UpdateDisplayPosition", }
		},
	})

	--Checkbox: Frame Strata
	---@type specialSelector
	frames.options.display.position.frameStrata = wt.CreateSpecialSelector({
		parent = panel,
		name = "FrameStrata",
		title = ns.strings.options.display.position.strata.label,
		tooltip = { lines = { { text = ns.strings.options.display.position.strata.tooltip, }, } },
		arrange = {},
		width = 140,
		itemset = "frameStrata",
		onSelection = function() frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end,
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.layer,
			storageKey = "strata",
			onChange = { UpdateDisplayFrameStrata = function() frames.main:SetFrameStrata(db.display.layer.strata) end, }
		}
	})
end
local function CreateTextOptions(panel)
	--Checkbox: Visible
	---@type checkbox
	frames.options.display.text.visible = wt.CreateCheckbox({
		parent = panel,
		name = "Visible",
		title = ns.strings.options.display.text.visible.label,
		tooltip = { lines = { { text = ns.strings.options.display.text.visible.tooltip, }, } },
		arrange = {},
		events = { OnClick = function(_, state) frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.text,
			storageKey = "visible",
			onChange = {
				ToggleDisplayText = function() wt.SetVisibility(frames.display.text, db.display.text.visible) end,
				"EnsureVisibility",
			}
		}
	})

	--Checkbox: Details
	---@type checkbox
	frames.options.display.text.details = wt.CreateCheckbox({
		parent = panel,
		name = "Details",
		title = ns.strings.options.display.text.details.label,
		tooltip = { lines = { { text = ns.strings.options.display.text.details.tooltip, }, } },
		arrange = { newRow = false, },
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.text,
			storageKey = "details",
			onChange = { UpdateDisplayText = function() UpdateXPDisplayText() end, }
		}
	})

	--Dropdown: Font family
	local fontItems = {}
	for i = 1, #ns.fonts do
		fontItems[i] = {}
		fontItems[i].title = ns.fonts[i].name
		fontItems[i].tooltip = {
			title = ns.fonts[i].name,
			lines = i == 1 and { { text = ns.strings.options.display.text.font.family.default, }, } or (i == #ns.fonts and {
				{ text = ns.strings.options.display.text.font.family.custom[1]:gsub("#OPTION_CUSTOM", ns.strings.misc.custom):gsub("#FILE_CUSTOM", "CUSTOM.ttf"), },
				{ text = "[WoW]\\Interface\\AddOns\\" .. addonNameSpace .. "\\Fonts\\", color = { r = 0.185, g = 0.72, b = 0.84 }, wrap = false },
				{ text = ns.strings.options.display.text.font.family.custom[2]:gsub("#FILE_CUSTOM", "CUSTOM.ttf"), },
				{ text = "\n" .. ns.strings.options.display.text.font.family.custom[3], color = { r = 0.89, g = 0.65, b = 0.40 }, },
			} or nil),
		}
	end
	---@type dropdown
	frames.options.display.text.font.family = wt.CreateDropdown({
		parent = panel,
		name = "FontFamily",
		title = ns.strings.options.display.text.font.family.label,
		tooltip = { lines = { { text = ns.strings.options.display.text.font.family.tooltip, }, } },
		arrange = {},
		items = fontItems,
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.text.font,
			storageKey = "family",
			convertSave = function(value) return ns.fonts[value].path end,
			convertLoad = function(font) return GetFontID(font) end,
			onChange = {
				UpdateDisplayFont = function() frames.display.text:SetFont(db.display.text.font.family, db.display.text.font.size, "THINOUTLINE") end,
				RefreshDisplayText = function() --Refresh the text so the font will be applied even the first time as well not just subsequent times
					local text = frames.display.text:GetText()
					frames.display.text:SetText("")
					frames.display.text:SetText(text)
				end,
				UpdateFontFamilyDropdownText = function()
					--Update the font of the dropdown toggle button label
					local label = _G[frames.options.display.text.font.family.toggle:GetName() .. "Text"]
					local _, size, flags = label:GetFont()
					label:SetFont(ns.fonts[frames.options.display.text.font.family.getSelected()].path, size, flags)

					--Refresh the text so the font will be applied right away (if the font is loaded)
					local text = label:GetText()
					label:SetText("")
					label:SetText(text)
				end,
			}
		}
	})
	for i = 1, #frames.options.display.text.font.family.selector.items do
		--Update fonts of the dropdown options
		local label = _G[frames.options.display.text.font.family.selector.items[i]:GetName() .. "RadioButtonText"]
		local _, size, flags = label:GetFont()
		label:SetFont(ns.fonts[i].path, size, flags)
	end

	--Slider: Font size
	---@type slider
	frames.options.display.text.font.size = wt.CreateSlider({
		parent = panel,
		name = "FontSize",
		title = ns.strings.options.display.text.font.size.label,
		tooltip = { lines = { { text = ns.strings.options.display.text.font.size.tooltip .. "\n\n" .. ns.strings.misc.default .. ": " .. dbDefault.display.text.font.size, }, } },
		arrange = { newRow = false, },
		value = { min = 8, max = 64, increment = 1 },
		altStep = 3,
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.text.font,
			storageKey = "size",
			onChange = { "UpdateDisplayFont", }
		}
	})

	--Selector: Text alignment
	---@type specialSelector
	frames.options.display.text.alignment = wt.CreateSpecialSelector({
		parent = panel,
		name = "Alignment",
		title = ns.strings.options.display.text.alignment.label,
		tooltip = { lines = { { text = ns.strings.options.display.text.alignment.tooltip, }, } },
		arrange = { newRow = false, },
		width = 140,
		itemset = "justifyH",
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.text,
			storageKey = "alignment",
			onChange = { UpdateDisplayTextAlignment = function()
				frames.display.text:SetJustifyH(db.display.text.alignment)
				wt.SetPosition(frames.display.text, { anchor = db.display.text.alignment, })
			end, }
		}
	})

	--Color Picker: Font color
	---@type colorPicker
	frames.options.display.text.font.color = wt.CreateColorPicker({
		parent = panel,
		name = "FontColor",
		title = ns.strings.options.display.text.font.color.label,
		arrange = {},
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.text.font,
			storageKey = "color",
			onChange = {
				UpdateDisplayFontColor = function() frames.display.text:SetTextColor(wt.UnpackColor(db.display.text.font.color)) end,
				UpdateFade = Fade,
			}
		}
	})
end
local  function CreateBackgroundOptions(panel)
	--Checkbox: Visible
	---@type checkbox
	frames.options.display.background.visible = wt.CreateCheckbox({
		parent = panel,
		name = "Visible",
		title = ns.strings.options.display.background.visible.label,
		tooltip = { lines = { { text = ns.strings.options.display.background.visible.tooltip, }, } },
		arrange = {},
		events = { OnClick = function(_, state) frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background,
			storageKey = "visible",
			onChange = {
				ToggleDisplayBackdrop = function() SetDisplayBackdrop(db.display.background.visible, db.display.background.colors) end,
				"EnsureVisibility",
				"UpdateFade",
			}
		}
	})

	--Slider: Background width
	---@type slider
	frames.options.display.background.size.width = wt.CreateSlider({
		parent = panel,
		name = "Width",
		title = ns.strings.options.display.background.size.width.label,
		tooltip = { lines = { { text = ns.strings.options.display.background.size.width.tooltip, }, } },
		arrange = { newRow = false, },
		value = { min = 64, max = UIParent:GetWidth() - math.fmod(UIParent:GetWidth(), 1) , increment = 2 },
		altStep = 8,
		events = { OnValueChanged = function() frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background.size,
			storageKey = "width",
			onChange = { UpdateDisplaySize = function() ResizeDisplay(db.display.background.size.width, db.display.background.size.height) end, }
		}
	})

	--Slider: Background height
	---@type slider
	frames.options.display.background.size.height = wt.CreateSlider({
		parent = panel,
		name = "Height",
		title = ns.strings.options.display.background.size.height.label,
		tooltip = { lines = { { text = ns.strings.options.display.background.size.height.tooltip, }, } },
		arrange = { newRow = false, },
		value = { min = 2, max = 80, increment = 2 },
		altStep = 8,
		events = { OnValueChanged = function() frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background.size,
			storageKey = "height",
			onChange = { "UpdateDisplaySize", }
		}
	})

	--Color Picker: Background color
	---@type colorPicker
	frames.options.display.background.colors.bg = wt.CreateColorPicker({
		parent = panel,
		name = "Color",
		title = ns.strings.options.display.background.colors.bg.label,
		arrange = {},
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background.colors,
			storageKey = "bg",
			onChange = {
				UpdateDisplayBackgroundColor = function()
					if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(db.display.background.colors.bg)) end
				end,
				"UpdateFade",
			}
		}
	})
	--Color Picker: Border color
	---@type colorPicker
	frames.options.display.background.colors.border = wt.CreateColorPicker({
		parent = panel,
		name = "BorderColor",
		title = ns.strings.options.display.background.colors.border.label,
		arrange = { newRow = false, },
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background.colors,
			storageKey = "border",
			onChange = {
				UpdateDisplayBorderColor = function()
					if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(db.display.background.colors.border)) end
				end,
				"UpdateFade",
			}
		}
	})

	--Color Picker: XP color
	---@type colorPicker
	frames.options.display.background.colors.xp = wt.CreateColorPicker({
		parent = panel,
		name = "XPColor",
		title = ns.strings.options.display.background.colors.xp.label,
		arrange = { newRow = false, },
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background.colors,
			storageKey = "xp",
			onChange = {
				UpdateDisplayXPColor = function()
					if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(db.display.background.colors.xp)) end 
				end,
				"UpdateFade",
			}
		}
	})

	--Color Picker: Rested color
	---@type colorPicker
	frames.options.display.background.colors.rested = wt.CreateColorPicker({
		parent = panel,
		name = "RestedColor",
		title = ns.strings.options.display.background.colors.rested.label,
		arrange = { newRow = false, },
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.background.colors,
			storageKey = "rested",
			onChange = {
				UpdateDisplayBorderColor = function()
					if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(db.display.background.colors.rested)) end
				end,
				"UpdateFade",
			}
		}
	})
end
local function CreateFadeOptions(panel)
	--Checkbox: Fade toggle
	---@type checkbox
	frames.options.display.fade.toggle = wt.CreateCheckbox({
		parent = panel,
		name = "FadeToggle",
		title = ns.strings.options.display.fade.toggle.label,
		tooltip = { lines = { { text = ns.strings.options.display.fade.toggle.tooltip, }, } },
		arrange = { newRow = false, },
		dependencies = { { frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.fade,
			storageKey = "enabled",
			onChange = { "UpdateFade", }
		}
	})

	--Slider: Text fade intensity
	---@type slider
	frames.options.display.fade.text = wt.CreateSlider({
		parent = panel,
		name = " TextFade",
		title = ns.strings.options.display.fade.text.label,
		tooltip = { lines = { { text = ns.strings.options.display.fade.text.tooltip, }, } },
		arrange = { newRow = false, },
		value = { min = 0, max = 1, increment = 0.05 },
		altStep = 0.2,
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.fade.toggle, },
			{ frame = frames.options.display.text.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.fade,
			storageKey = "text",
			onChange = { "UpdateFade", }
		}
	})

	--Slider: Background fade intensity
	---@type slider
	frames.options.display.fade.background = wt.CreateSlider({
		parent = panel,
		name = "BackgroundFade",
		title = ns.strings.options.display.fade.background.label,
		tooltip = { lines = { { text = ns.strings.options.display.fade.background.tooltip, }, } },
		arrange = { newRow = false, },
		value = { min = 0, max = 1, increment = 0.05 },
		altStep = 0.2,
		dependencies = {
			{ frame = frames.options.display.visibility.hidden, evaluate = function(state) return not state end },
			{ frame = frames.options.display.fade.toggle, },
			{ frame = frames.options.display.background.visible, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Display",
			workingTable = db.display.fade,
			storageKey = "background",
			onChange = { "UpdateFade", }
		}
	})
end

--Create the category page
local function CreateDisplayOptions()
	---@type optionsPage
	frames.options.display.page = wt.CreateOptionsCategory({
		parent = frames.options.main.page.category,
		addon = addonNameSpace,
		name = "Display",
		title = ns.strings.options.display.title,
		description = ns.strings.options.display.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		scroll = { speed = 103, },
		optionsKeys = { addonNameSpace .. "Display" },
		storage = {
			{
				workingTable =  dbc,
				storageTable = RemainingXPDBC,
				defaultsTable = dbcDefault,
			},
			{
				workingTable =  db.display,
				storageTable = RemainingXPDB.display,
				defaultsTable = dbDefault.display,
			},
		},
		onSave = function() RemainingXPDB = wt.Clone(db) end,
		onDefault = function(user)
			ResetCustomPreset()

			if not user then return end

			--Notification
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.reset.response:gsub(
				"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3])
			), ns.colors.blue[3]))
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
				"#CATEGORY", wt.Color(ns.strings.options.display.title, ns.colors.purple[3])
			), ns.colors.blue[3]))
		end,
		initialize = function(canvas)
			--Panel: Visibility
			wt.CreatePanel({
				parent = canvas,
				name = "Visibility",
				title = ns.strings.options.display.title,
				description = ns.strings.options.display.description:gsub("#ADDON", addonTitle),
				arrange = {},
				initialize = CreateVisibilityOptions,
				arrangement = {}
			})

			--Panel: Position
			wt.CreatePanel({
				parent = canvas,
				name = "Position",
				title = ns.strings.options.display.position.title,
				description = ns.strings.options.display.position.description:gsub("#SHIFT", ns.strings.keys.shift),
				arrange = {},
				initialize = CreatePositionOptions,
				arrangement = {}
			})

			--Panel: Text
			wt.CreatePanel({
				parent = canvas,
				name = "Text",
				title = ns.strings.options.display.text.title,
				description = ns.strings.options.display.text.description,
				arrange = {},
				initialize = CreateTextOptions,
				arrangement = {}
			})

			--Panel: Background
			wt.CreatePanel({
				parent = canvas,
				name = "Background",
				title = ns.strings.options.display.background.title,
				description = ns.strings.options.display.background.description:gsub("#ADDON", addonTitle),
				arrange = {},
				initialize = CreateBackgroundOptions,
				arrangement = {}
			})

			--Panel: Fade
			wt.CreatePanel({
				parent = canvas,
				name = "Fade",
				title = ns.strings.options.display.fade.title,
				description = ns.strings.options.display.fade.description:gsub("#ADDON", addonTitle),
				arrange = {},
				initialize = CreateFadeOptions,
				arrangement = {}
			})
		end,
		arrangement = {}
	})
end

--[ Integration ]

--Create the widgets
local function CreateEnhancementOptions(panel)
	--Checkbox: Enable integration
	---@type checkbox
	frames.options.integration.enhancement.toggle = wt.CreateCheckbox({
		parent = panel,
		name = "EnableIntegration",
		title = ns.strings.options.integration.enhancement.toggle.label,
		tooltip = { lines = { { text = ns.strings.options.integration.enhancement.toggle.tooltip, }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Integration",
			workingTable = db.enhancement,
			storageKey = "enabled",
			onChange = { ToggleIntegration = function()
				SetIntegrationVisibility(db.enhancement.enabled)
				UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining)
			end, }
		}
	})

	--Checkbox: Keep text
	---@type checkbox
	frames.options.integration.enhancement.keep = wt.CreateCheckbox({
		parent = panel,
		name = "KeepText",
		title = ns.strings.options.integration.enhancement.keep.label,
		tooltip = { lines = { { text = ns.strings.options.integration.enhancement.keep.tooltip, }, } },
		arrange = { newRow = false, },
		dependencies = { { frame = frames.options.integration.enhancement.toggle, }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Integration",
			workingTable = db.enhancement,
			storageKey = "keep",
			onChange = { UpdateIntegrationText = function() UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining) end, }
		}
	})

	--Checkbox: Keep only remaining XP text
	---@type checkbox
	frames.options.integration.enhancement.remaining = wt.CreateCheckbox({
		parent = panel,
		name = "RemainingOnly",
		title = ns.strings.options.integration.enhancement.remaining.label,
		tooltip = { lines = { { text = ns.strings.options.integration.enhancement.remaining.tooltip, }, } },
		arrange = { newRow = false, },
		dependencies = {
			{ frame = frames.options.integration.enhancement.toggle, },
			{ frame = frames.options.integration.enhancement.keep, },
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Integration",
			workingTable = db.enhancement,
			storageKey = "remaining",
			onChange = { "UpdateIntegrationText", }
		}
	})
end
local function CreateRemovalsOptions(panel)
	--Checkbox: Hide the status bars
	---@type checkbox
	frames.options.integration.removals.xpBar = wt.CreateCheckbox({
		parent = panel,
		name = "HideXPBar",
		title = ns.strings.options.integration.removals.xpBar.label,
		tooltip = { lines = { { text = ns.strings.options.integration.removals.xpBar.tooltip:gsub("#ADDON", addonTitle), }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Integration",
			workingTable = db.removals,
			storageKey = "xpBar",
			onChange = { ToggleXPBar = function() wt.SetVisibility(MainMenuExpBar, not db.removals.xpBar) end, }
		}
	})
end

--Create the category page
local function CreateIntegrationOptions()
	---@type optionsPage
	frames.options.integration.page = wt.CreateOptionsCategory({
		parent = frames.options.main.page.category,
		addon = addonNameSpace,
		name = "Integration",
		title = ns.strings.options.integration.title,
		description = ns.strings.options.integration.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		optionsKeys = { addonNameSpace .. "Integration" },
		storage = {
			{
				workingTable =  db.enhancement,
				storageTable = RemainingXPDB.enhancement,
				defaultsTable = dbDefault.enhancement,
			},
			{
				workingTable =  db.removals,
				storageTable = RemainingXPDB.removals,
				defaultsTable = dbDefault.removals,
			},
		},
		onDefault = function(user)
			if not user then return end

			--Notification
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
				"#CATEGORY", wt.Color(ns.strings.options.integration.title, ns.colors.purple[3])
			), ns.colors.blue[3]))
		end,
		initialize = function(canvas)
			--Panel: Enhancement
			wt.CreatePanel({
				parent = canvas,
				name = "Enhancement",
				title = ns.strings.options.integration.enhancement.title,
				description = ns.strings.options.integration.enhancement.description:gsub("#ADDON", addonTitle),
				arrange = {},
				initialize = CreateEnhancementOptions,
				arrangement = {}
			})

			--Panel: Removals
			wt.CreatePanel({
				parent = canvas,
				name = "Removals",
				title = ns.strings.options.integration.removals.title,
				description = ns.strings.options.integration.removals.description:gsub("#ADDON", addonTitle),
				arrange = {},
				initialize = CreateRemovalsOptions,
				arrangement = {}
			})
		end,
		arrangement = {}
	})
end

--[ Events ]

--Create the widgets

local function CreateNotificationsOptions(panel)
	--Checkbox: XP gained
	---@type checkbox
	frames.options.events.xpGained = wt.CreateCheckbox({
		parent = panel,
		name = "XPGained",
		title = ns.strings.options.events.notifications.xpGained.label,
		tooltip = { lines = { { text = ns.strings.options.events.notifications.xpGained.tooltip, }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications,
			storageKey = "xpGained",
		}
	})

	--Checkbox: Rested XP gained
	---@type checkbox
	frames.options.events.restedXPGained = wt.CreateCheckbox({
		parent = panel,
		name = "RestedXPGained",
		title = ns.strings.options.events.notifications.restedXP.gained.label,
		tooltip = { lines = { { text = ns.strings.options.events.notifications.restedXP.gained.tooltip, }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications.restedXP,
			storageKey = "gained",
		}
	})

	--Checkbox: Significant Rested XP updates only
	---@type checkbox
	frames.options.events.significantRestedOnly = wt.CreateCheckbox({
		parent = panel,
		name = "SignificantRestedOnly",
		title = ns.strings.options.events.notifications.restedXP.significantOnly.label,
		tooltip = { lines = { { text = ns.strings.options.events.notifications.restedXP.significantOnly.tooltip, }, } },
		arrange = { newRow = false, },
		dependencies = { { frame = frames.options.events.restedXPGained, }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications.restedXP,
			storageKey = "significantOnly",
		}
	})

	--Checkbox: Accumulated Rested XP
	---@type checkbox
	frames.options.events.restedXPAccumulated = wt.CreateCheckbox({
		parent = panel,
		name = "AccumulatedRestedXP",
		title = ns.strings.options.events.notifications.restedXP.accumulated.label,
		tooltip = { lines = {
			{ text = ns.strings.options.events.notifications.restedXP.accumulated.tooltip[1], },
			{
				text = ns.strings.options.events.notifications.restedXP.accumulated.tooltip[2]:gsub("#ADDON", addonTitle),
				color = { r = 0.89, g = 0.65, b = 0.40 },
			},
		} },
		arrange = { newRow = false, },
		dependencies = { { frame = frames.options.events.restedXPGained, }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications.restedXP,
			storageKey = "accumulated",
			onChange = { UpdateRestedAccumulation = function() SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated and max) end, }
		}
	})

	--Checkbox: Rested status update
	---@type checkbox
	frames.options.events.restedStatusUpdate = wt.CreateCheckbox({
		parent = panel,
		name = "RestedStatusUpdate",
		title = ns.strings.options.events.notifications.restedStatus.update.label,
		tooltip = { lines = { { text = ns.strings.options.events.notifications.restedStatus.update.tooltip, }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications.restedStatus,
			storageKey = "update",
		}
	})

	--Checkbox: Max Rested XP reminder
	---@type checkbox
	frames.options.events.maxRestedXPReminder = wt.CreateCheckbox({
		parent = panel,
		name = "MaxRestedXPReminder",
		title = ns.strings.options.events.notifications.restedStatus.maxReminder.label,
		tooltip = { lines = { { text = ns.strings.options.events.notifications.restedStatus.maxReminder.tooltip, }, } },
		arrange = { newRow = false, },
		dependencies = { { frame = frames.options.events.restedStatusUpdate, }, },
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications.restedStatus,
			storageKey = "maxReminder",
		}
	})

	--Checkbox: Level up
	---@type checkbox
	frames.options.events.lvlUp = wt.CreateCheckbox({
		parent = panel,
		name = "LevelUp",
		title = ns.strings.options.events.notifications.lvlUp.congrats.label,
		tooltip = { lines = { { text = ns.strings.options.events.notifications.lvlUp.congrats.tooltip, }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Events",
			workingTable = db.notifications.lvlUp,
			storageKey = "congrats",
		}
	})

	--Checkbox: Time played
	---@type checkbox
	frames.options.events.timePlayed = wt.CreateCheckbox({
		parent = panel,
		name = "TimePlayed",
		title = ns.strings.options.events.notifications.lvlUp.timePlayed.label .. " (Soon™)",
		tooltip = { lines = { { text = ns.strings.options.events.notifications.lvlUp.timePlayed.tooltip, }, } },
		arrange = { newRow = false, },
		disabled = true --TODO: Add time played notifications
		-- dependencies = { { frame = options.notifications.lvlUp, }, },
		-- optionsData = {
		-- 	optionsKey = addonNameSpace .. "Events",
		-- 	workingTable = db.notifications.lvlUp,
		-- 	storageKey = "timePlayed",
		-- }
	})
end
local function CreateLogsOptions(panel)
	--TODO: Add logs widgets
end

--Create the category page
local function CreateEventsOptions()
	---@type optionsPage
	frames.options.events.page = wt.CreateOptionsCategory({
		parent = frames.options.main.page.category,
		addon = addonNameSpace,
		name = "Events",
		title = ns.strings.options.events.title,
		description = ns.strings.options.events.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		optionsKeys = { addonNameSpace .. "Events" },
		storage = { {
			workingTable =  db.notifications,
			storageTable = RemainingXPDB.notifications,
			defaultsTable = dbDefault.notifications,
		}, },
		onDefault = function(user)
			if not user then return end

			--Notification
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
				"#CATEGORY", wt.Color(ns.strings.options.events.title, ns.colors.purple[3])
			), ns.colors.blue[3]))
		end,
		initialize = function(canvas)
			--Panel: Chat notifications
			wt.CreatePanel({
				parent = canvas,
				name = "ChatNotifications",
				title = ns.strings.options.events.notifications.title,
				description = ns.strings.options.events.notifications.description,
				arrange = {},
				initialize = CreateNotificationsOptions,
				arrangement = {}
			})

			--Panel: Logs
			wt.CreatePanel({
				parent = canvas,
				name = "Logs",
				title = ns.strings.options.events.logs.title,
				description = ns.strings.options.events.logs.description,
				arrange = {},
				size = { height = 64 },
				initialize = CreateLogsOptions,
			})
		end,
		arrangement = {}
	})
end

--[ Advanced ]

--Create the widgets
local function CreateOptionsProfiles(panel)
	--TODO: Add profiles handler widgets
end
local function CreateBackupOptions(panel)
	--EditScrollBox & Popup: Import & Export
	local importPopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "IMPORT",
		text = ns.strings.options.advanced.backup.warning,
		accept = ns.strings.options.advanced.backup.import,
		onAccept = function()
			--Load from string to a temporary table
			local success, t = pcall(loadstring("return " .. wt.Clear(frames.options.advanced.backup.string.getText())))
			if success and type(t) == "table" then
				--Run DB checkup on the loaded table
				CheckDBs(t.account, db, t.character, dbc)

				--Copy values from the loaded DBs to the addon DBs
				wt.CopyValues(t.account, db)
				wt.CopyValues(t.character, dbc)

				--Load the Custom preset
				presets[1].data = wt.Clone(db.customPreset)

				--Load the options data & update the interface options
				frames.options.display.page.load(true)
				frames.options.integration.page.load(true)
				frames.options.events.page.load(true)
				frames.options.advanced.page.load(true)
			else print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.options.advanced.backup.error, ns.colors.blue[1])) end
		end
	})
	frames.options.advanced.backup.string = wt.CreateEditScrollBox({
		parent = panel,
		name = "ImportExport",
		title = ns.strings.options.advanced.backup.backupBox.label,
		tooltip = { lines = {
			{ text = ns.strings.options.advanced.backup.backupBox.tooltip[1], },
			{ text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[2], },
			{ text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[3], },
			{ text = ns.strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.89, g = 0.65, b = 0.40 }, },
			{ text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[5], color = { r = 0.92, g = 0.34, b = 0.23 }, },
		} },
		arrange = {},
		size = { width = panel:GetWidth() - 24, height = panel:GetHeight() - 76 },
		font = { normal = "GameFontWhiteSmall", },
		maxLetters = 5500,
		scrollSpeed = 60,
		events = {
			OnEnterPressed = function() StaticPopup_Show(importPopup) end,
			OnEscapePressed = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, frames.options.advanced.backup.compact.getState(), true)) end,
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Advanced",
			onLoad = function(self) self:SetText(wt.TableToString({ account = db, character = dbc }, frames.options.advanced.backup.compact.getState(), true)) end,
		}
	})

	--Checkbox: Compact
	---@type checkbox
	frames.options.advanced.backup.compact = wt.CreateCheckbox({
		parent = panel,
		name = "Compact",
		title = ns.strings.options.advanced.backup.compact.label,
		tooltip = { lines = { { text = ns.strings.options.advanced.backup.compact.tooltip, }, } },
		position = {
			anchor = "BOTTOMLEFT",
			offset = { x = 12, y = 12 }
		},
		events = { OnClick = function(_, state)
			frames.options.advanced.backup.string.setText(wt.TableToString({ account = db, character = dbc }, state, true))

			--Set focus after text change to set the scroll to the top and refresh the position character counter
			frames.options.advanced.backup.string.scrollFrame.EditBox:SetFocus()
			frames.options.advanced.backup.string.scrollFrame.EditBox:ClearFocus()
		end, },
		optionsData = {
			optionsKey = addonNameSpace .. "Advanced",
			storageTable = cs,
			storageKey = "compactBackup",
		}
	})

	--Button: Load
	wt.CreateButton({
		parent = panel,
		name = "Load",
		title = ns.strings.options.advanced.backup.load.label,
		tooltip = { lines = { { text = ns.strings.options.advanced.backup.load.tooltip, }, } },
		arrange = {},
		size = { height = 26 },
		events = { OnClick = function() StaticPopup_Show(importPopup) end, },
	})

	--Button: Reset
	wt.CreateButton({
		parent = panel,
		name = "Reset",
		title = ns.strings.options.advanced.backup.reset.label,
		tooltip = { lines = { { text = ns.strings.options.advanced.backup.reset.tooltip, }, } },
		position = {
			anchor = "BOTTOMRIGHT",
			offset = { x = -100, y = 12 }
		},
		size = { height = 26 },
		events = { OnClick = function()
			frames.options.advanced.backup.string.setText(wt.TableToString({ account = db, character = dbc }, frames.options.advanced.backup.compact.getState(), true))

			--Set focus after text change to set the scroll to the top and refresh the position character counter
			frames.options.advanced.backup.string.scrollFrame.EditBox:SetFocus()
			frames.options.advanced.backup.string.scrollFrame.EditBox:ClearFocus()
		end, },
	})
end

--Create the category page
local function CreateAdvancedOptions()
	---@type optionsPage
	frames.options.advanced.page = wt.CreateOptionsCategory({
		parent = frames.options.main.page.category,
		addon = addonNameSpace,
		name = "Advanced",
		title = ns.strings.options.advanced.title,
		description = ns.strings.options.advanced.description:gsub("#ADDON", addonTitle),
		logo = ns.textures.logo,
		optionsKeys = { addonNameSpace .. "Advanced" },
		onDefault = function()
			ResetCustomPreset()

			--Notification
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.reset.response:gsub(
				"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3])
			), ns.colors.blue[3]))
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
				"#CATEGORY", wt.Color(ns.strings.options.advanced.title, ns.colors.purple[3])
			), ns.colors.blue[3]))
		end,
		initialize = function(canvas)
			--Panel: Profiles
			wt.CreatePanel({
				parent = canvas,
				name = "Profiles",
				title = ns.strings.options.advanced.profiles.title,
				description = ns.strings.options.advanced.profiles.description:gsub("#ADDON", addonTitle),
				arrange = {},
				size = { height = 64 },
				initialize = CreateOptionsProfiles,
			})

			--Panel: Backup
			wt.CreatePanel({
				parent = canvas,
				name = "Backup",
				title = ns.strings.options.advanced.backup.title,
				description = ns.strings.options.advanced.backup.description:gsub("#ADDON", addonTitle),
				arrange = {},
				size = { height = canvas:GetHeight() - 200 },
				initialize = CreateBackupOptions,
				arrangement = {
					flip = true,
					resize = false
				}
			})
		end,
		arrangement = {}
	})
end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load boolean ***Default:*** false
local function PrintStatus(load)
	if load == true and not db.notifications.statusNotice.enabled then return end

	local status = wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(
		frames.main:IsVisible() and ns.strings.chat.status.visible or ns.strings.chat.status.hidden, ns.colors.blue[1]
	):gsub(
		"#FADE", wt.Color(ns.strings.chat.status.fade:gsub(
			"#STATE", wt.Color(db.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
		), ns.colors.blue[2])
	)

	if max then if db.notifications.statusNotice.maxReminder then
		status = wt.Color(ns.strings.chat.status.disabled:gsub(
			"#ADDON", wt.Color(addonTitle, ns.colors.purple[1])
		) .." " ..  wt.Color(ns.strings.chat.status.max:gsub(
			"#MAX", wt.Color(maxLevel, ns.colors.purple[2])
		), ns.colors.blue[2]), ns.colors.blue[1])
	else return end end

	print(status)
end

--Print help info
local function PrintInfo()
	print(wt.Color(ns.strings.chat.help.thanks:gsub("#ADDON", wt.Color(addonTitle, ns.colors.purple[1])), ns.colors.blue[1]))
	PrintStatus()
	print(wt.Color(ns.strings.chat.help.hint:gsub("#HELP_COMMAND", wt.Color("/" .. ns.chat.keyword .. " " .. ns.chat.commands.help, ns.colors.purple[3])), ns.colors.blue[3]))
	print(wt.Color(ns.strings.chat.help.move:gsub("#ADDON", addonTitle), ns.colors.blue[3]))
end

---Format and print a command description
---@param command string Command name
---@param description string Command description text
local function PrintCommand(command, description)
	print("    " .. wt.Color("/" .. ns.chat.keyword .. " " .. command, ns.colors.purple[3])  .. wt.Color(" - " .. description, ns.colors.blue[3]))
end

--Reset to defaults confirmation
local resetDefaultsPopup = wt.CreatePopup({
	addon = addonNameSpace,
	name = "DefaultOptions",
	text = (wt.GetStrings("warning") or ""):gsub("#TITLE", wt.Clear(addonTitle)),
	onAccept = function()
		--Reset the options data & update the interface options
		frames.options.display.page.default()
		frames.options.integration.page.default()
		frames.options.events.page.default()
		frames.options.advanced.page.default(true)
	end,
})

--[ Commands ]

--Register handlers
local commandManager = wt.RegisterChatCommands(addonNameSpace, { ns.chat.keyword }, {
	{
		command = ns.chat.commands.help,
		handler = function() print(wt.Color(addonTitle .. " ", ns.colors.purple[1]) .. wt.Color(ns.strings.chat.help.list .. ":", ns.colors.blue[1])) end,
		help = true,
	},
	{
		command = ns.chat.commands.options,
		handler = function() frames.options.main.page.open() end,
		onHelp = function() PrintCommand(ns.chat.commands.options, ns.strings.chat.options.description:gsub("#ADDON", addonTitle)) end
	},
	{
		command = ns.chat.commands.preset,
		handler = function(parameter)
			local i = tonumber(parameter)

			if not i or i < 1 or i > #presets then return false end

			if max then
				PrintStatus()
				return nil
			end

			ApplyPreset(i)

			--Update in the SavedVariables DB
			RemainingXPDBC.hidden = false
			RemainingXPDB.display.position = wt.Clone(db.display.position)
			RemainingXPDB.display.layer.strate = db.display.layer.strata
			if not presets[i].data.background.visible then RemainingXPDB.display.text.visible = true end
			RemainingXPDB.display.background.visible = db.display.background.visible
			RemainingXPDB.display.background.size = wt.Clone(db.display.background.size)

			--Update the options widget
			frames.options.display.position.presets.setSelected(i)

			return true, i
		end,
		onSuccess = function(i)
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.preset.response:gsub(
				"#PRESET", wt.Color(presets[i].name, ns.colors.purple[2])
			), ns.colors.blue[2]))
		end,
		onError = function()
			--Error
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.preset.unchanged, ns.colors.blue[1]))
			print(wt.Color(ns.strings.chat.preset.error:gsub("#INDEX", wt.Color(ns.chat.commands.preset .. " " .. 1, ns.colors.purple[2])), ns.colors.blue[2]))
			print(wt.Color(ns.strings.chat.preset.list, ns.colors.purple[2]))
			for j = 1, #presets, 2 do
				local list = "    " .. wt.Color(j, ns.colors.purple[3]) .. wt.Color(" - " .. presets[j].name, ns.colors.blue[3])
				if j + 1 <= #presets then list = list .. "    " .. wt.Color(j + 1, ns.colors.purple[3]) .. wt.Color(" - " .. presets[j + 1].name, ns.colors.blue[3]) end
				print(list)
			end
		end,
		onHelp = function() PrintCommand(ns.chat.commands.preset, ns.strings.chat.preset.description:gsub(
			"#INDEX", wt.Color(ns.chat.commands.preset .. " " .. 1, ns.colors.purple[3])
		)) end
	},
	{
		command = ns.chat.commands.save,
		handler = function()
			UpdateCustomPreset()

			return true
		end,
		onSuccess = function() print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.save.response:gsub(
			"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[2])
		), ns.colors.blue[2])) end,
		onHelp = function() PrintCommand(ns.chat.commands.save, ns.strings.chat.save.description:gsub("#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3]))) end
	},
	{
		command = ns.chat.commands.reset,
		handler = function()
			ResetCustomPreset()

			return true
		end,
		onSuccess = function() print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.reset.response:gsub(
			"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[2])
		), ns.colors.blue[2])) end,
		onHelp = function() PrintCommand(ns.chat.commands.reset, ns.strings.chat.reset.description:gsub("#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3]))) end
	},
	{
		command = ns.chat.commands.toggle,
		handler = function()
			--Update the DBs
			dbc.hidden = not dbc.hidden
			RemainingXPDBC.hidden = dbc.hidden

			--Update the GUI option in case it was open
			frames.options.display.visibility.hidden.setState(dbc.hidden)
			frames.options.display.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets

			--Update the visibility
			wt.SetVisibility(frames.main, not (dbc.hidden or max))

			return true
		end,
		onSuccess = function()
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(
				dbc.hidden and ns.strings.chat.toggle.hiding or ns.strings.chat.toggle.unhiding, ns.colors.blue[2])
			)
			if max then PrintStatus() end
		end,
		onHelp = function() PrintCommand(ns.chat.commands.toggle, ns.strings.chat.toggle.description:gsub(
			"#HIDDEN", wt.Color(dbc.hidden and ns.strings.chat.toggle.hidden or ns.strings.chat.toggle.notHidden, ns.colors.purple[3])
		)) end
	},
	{
		command = ns.chat.commands.fade,
		handler = function()
			--Update the DBs
			db.display.fade.enabled = not db.display.fade.enabled
			RemainingXPDB.display.fade.enabled = db.display.fade.enabled

			--Update the GUI option in case it was open
			frames.options.display.fade.toggle.setState(db.display.fade.enabled)
			frames.options.display.fade.toggle:SetAttribute("loaded", true) --Update dependent widgets

			--Update the main display fade
			Fade(db.display.fade.enabled)

			return true
		end,
		onSuccess = function()
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.fade.response:gsub(
				"#STATE", wt.Color(db.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
			), ns.colors.blue[2]))
			if max then PrintStatus() end
		end,
		onHelp = function() PrintCommand(ns.chat.commands.fade, ns.strings.chat.fade.description:gsub(
			"#STATE", wt.Color(db.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[3])
		)) end
	},
	{
		command = ns.chat.commands.size,
		handler = function(parameter)
			local size = tonumber(parameter)
			if not size then return false end

			--Update the DBs
			db.display.text.font.size = size
			RemainingXPDB.display.text.font.size = db.display.text.font.size

			--Update the GUI option in case it was open
			frames.options.display.text.font.size.setValue(size)

			--Update the font
			frames.display.text:SetFont(db.display.text.font.family, db.display.text.font.size, "THINOUTLINE")

			return true, size
		end,
		onSuccess = function(size)
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.size.response:gsub(
				"#VALUE", wt.Color(size, ns.colors.purple[2])
			), ns.colors.blue[2]))
			if max then PrintStatus() end
		end,
		onError = function()
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.size.unchanged, ns.colors.blue[1]))
			print(wt.Color(ns.strings.chat.size.error:gsub(
				"#SIZE", wt.Color(ns.chat.commands.size .. " " .. dbDefault.display.text.font.size, ns.colors.purple[2])
			), ns.colors.blue[2]))
		end,
		onHelp = function() PrintCommand(ns.chat.commands.size, ns.strings.chat.size.description:gsub(
			"#SIZE", wt.Color(ns.chat.commands.size .. " " .. dbDefault.display.text.font.size, ns.colors.purple[3])
		)) end
	},
	{
		command = ns.chat.commands.integration,
		handler = function()
			--Update the DBs
			db.enhancement.enabled = not db.enhancement.enabled
			RemainingXPDB.enhancement.enabled = db.enhancement.enabled

			--Update the GUI option in case it was open
			frames.options.integration.enhancement.toggle.setState(db.enhancement.enabled)
			frames.options.integration.enhancement.toggle:SetAttribute("loaded", true) --Update dependent widgets

			--Update the integration
			SetIntegrationVisibility(db.enhancement.enabled)
			UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining)

			return true
		end,
		onSuccess = function()
			print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.integration.response:gsub(
				"#STATE", wt.Color(db.enhancement.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
			), ns.colors.blue[2]))
			if max then PrintStatus() end
		end,
		onHelp = function() PrintCommand(ns.chat.commands.integration, ns.strings.chat.integration.description) end
	},
	{
		command = ns.chat.commands.defaults,
		handler = function() StaticPopup_Show(resetDefaultsPopup) end,
		onHelp = function() PrintCommand(ns.chat.commands.defaults, ns.strings.chat.defaults.description) end
	},
}, PrintInfo)


--[[ INITIALIZATION ]]

--[ Event Handlers ]

--Main frame
local AddonLoaded = function(self, addon)
	if addon ~= addonNameSpace then return end

	self:UnregisterEvent("ADDON_LOADED")

	--[ DBs ]

	local firstLoad = not RemainingXPDB

	--Load storage DBs
	RemainingXPDB = RemainingXPDB or wt.Clone(dbDefault)
	RemainingXPDBC = RemainingXPDBC or wt.Clone(dbcDefault)

	--DB checkup & fix
	CheckDBs(RemainingXPDB, dbDefault, RemainingXPDBC, dbcDefault)

	--Load working DBs
	db = wt.Clone(RemainingXPDB)
	dbc = wt.Clone(RemainingXPDBC)

	--Load cross-session DBs
	RemainingXPCS = RemainingXPCS or {}
	RemainingXPCSC = RemainingXPCSC or {}
	cs = RemainingXPCSC
	csc = RemainingXPCSC

	--Load the custom preset
	presets[1].data = wt.Clone(db.customPreset)

	--Welcome message
	if firstLoad then PrintInfo() end

	--[ Settings Setup ]

	--Load cross-session data
	if cs.compactBackup == nil then cs.compactBackup = true end

	--Set up the interface options
	CreateMainOptions()
	CreateDisplayOptions()
	CreateIntegrationOptions()
	CreateEventsOptions()
	CreateAdvancedOptions()

	--[ Frame & Display Setup ]

	if max then
		--Hide displays
		self:Hide()
		TurnOffIntegration()

		--Disable events
		self:UnregisterAllEvents()
	else
		--Load cross-session character data
		csc.xp = csc.xp or {}

		--Position
		wt.SetPosition(self, db.display.position)

		--Make movable
		wt.SetMovability(self, true, "SHIFT", { frames.display.overlay, }, {
			onStop = function()
				--Save the position (for account-wide use)
				wt.CopyValues(wt.PackPosition(self:GetPoint()), db.display.position)

				--Update in the SavedVariables DB
				RemainingXPDB.display.position = wt.Clone(db.display.position)

				--Update the GUI options in case the window was open
				frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select)
				frames.options.display.position.anchor.setSelected(db.display.position.anchor)
				frames.options.display.position.xOffset.setValue(db.display.position.offset.x)
				frames.options.display.position.yOffset.setValue(db.display.position.offset.y)

				--Chat response
				print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.position.save, ns.colors.blue[1]))
			end,
			onCancel = function()
				--Reset the position
				wt.SetPosition(self, db.display.position)

				--Chat response
				print(wt.Color(addonTitle .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.position.cancel, ns.colors.blue[1]))
				print(wt.Color(ns.strings.chat.position.error, ns.colors.blue[2]))
			end
		})

		--Main display
		SetDisplayValues(db, dbc)

		--Integrated display
		SetIntegrationVisibility(db.enhancement.enabled)
	end

	--Visibility notice
	if not self:IsVisible() then PrintStatus(true) end
end
local PlayerEnteringWorld = function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	--XP update
	UpdateXPValues()

	--Set up displays
	ResizeDisplay(db.display.background.size.width, db.display.background.size.height)
	UpdateXPDisplayText()
	UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining)

	--Initialize display tooltips
	wt.AddTooltip(frames.display.overlay, {
		tooltip = ns.tooltip,
		title = ns.strings.xpTooltip.title,
		anchor = "ANCHOR_BOTTOMRIGHT",
		offset = { y = frames.display.overlay:GetHeight() },
		flipColors = true,
	})
	frames.display.overlay:HookScript("OnEnter", UpdateXPTooltip)
	wt.AddTooltip(frames.integration.frame, {
		tooltip = ns.tooltip,
		title = ns.strings.xpTooltip.title,
		anchor = "ANCHOR_NONE",
		offset = { x = -11, y = 115 },
		position = { anchor = "BOTTOMRIGHT" },
		flipColors = true,
	})
	frames.integration.frame:HookScript("OnEnter", UpdateXPTooltip)

	--Removals
	if db.removals.xpBar then MainMenuExpBar:Hide() end
end
local PlayerXPUpdate = function(_, unit)
	if unit ~= "player" then return end

	--XP update
	local gainedXP, _, oldXP = UpdateXPValues()
	if oldXP == csc.xp.current then return end --The event fired without actual XP gain

	--Update UI elements
	UpdateXPDisplayText()
	UpdateXPDisplaySegments()
	UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining)

	--Notification
	if db.notifications.xpGained then
		print(wt.Color(ns.strings.chat.xpGained.text:gsub(
			"#AMOUNT", wt.Color(wt.FormatThousands(gainedXP), ns.colors.purple[1])
		):gsub(
			"#REMAINING", wt.Color(max and ns.strings.chat.lvlUp.disabled.reason:gsub(
				"#MAX", maxLevel
			) or ns.strings.chat.xpGained.remaining:gsub(
				"#AMOUNT", wt.Color(wt.FormatThousands(csc.xp.remaining), ns.colors.purple[3])
			):gsub(
				"#NEXT", UnitLevel("player") + 1
			), ns.colors.blue[3])
		), ns.colors.blue[1]))
	end

	--Tooltip update
	UpdateXPTooltip()
end
local PlayerLevelUp = function(self, newLevel)
	max = newLevel >= maxLevel

	if max then
		self:Hide()
		TurnOffIntegration()

		--Notification
		print(wt.Color(ns.strings.chat.lvlUp.disabled.text:gsub(
			"#ADDON", wt.Color(addonTitle, ns.colors.purple[1])
		):gsub(
			"#REASON", wt.Color(ns.strings.chat.lvlUp.disabled.reason:gsub(
				"#MAX", maxLevel
			), ns.colors.blue[3])
		) .. " " .. ns.strings.chat.lvlUp.congrats, ns.colors.blue[1]))
	else
		--Notification
		if db.notifications.lvlUp.congrats then
			print(wt.Color(ns.strings.chat.lvlUp.text:gsub(
				"#LEVEL", wt.Color(newLevel, ns.colors.purple[1])
			) .. " " .. wt.Color(ns.strings.chat.lvlUp.congrats, ns.colors.purple[3]), ns.colors.blue[1]))
			if db.notifications.lvlUp.timePlayed then RequestTimePlayed() print('HEY') end
		end

		--Tooltip update
		UpdateXPTooltip()
	end
end
local UpdateExhaustion = function()
	--Update Rested XP
	local _, gainedRestedXP = UpdateXPValues()
	if gainedRestedXP <= 0 then return end

	--Update UI elements
	UpdateXPDisplayText()
	UpdateXPDisplaySegments()
	UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining)

	--Notification
	if db.notifications.restedXP.gained and not (db.notifications.restedXP.significantOnly and gainedRestedXP <= math.ceil(csc.xp.needed / 1000)) then
		print(wt.Color(ns.strings.chat.restedXPGained.text:gsub(
				"#AMOUNT", wt.Color(gainedRestedXP, ns.colors.purple[1])
			):gsub(
				"#TOTAL", wt.Color(wt.FormatThousands(csc.xp.rested), ns.colors.purple[1])
			):gsub(
				"#PERCENT", wt.Color(ns.strings.chat.restedXPGained.percent:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 100000) / 1000, 3) .. "%%%%", ns.colors.purple[3])
				), ns.colors.blue[3])
			), ns.colors.blue[1])
		)
	end

	--Tooltip update
	UpdateXPTooltip()
end
local PlayerUpdateResting = function()
	--Notification
	if db.notifications.restedXP.gained and db.notifications.restedXP.accumulated and not IsResting() then
		print((db.notifications.restedStatus.update and (wt.Color(ns.strings.chat.restedStatus.notResting, ns.colors.purple[1]) .. " ") or "") .. (
			(csc.xp.accumulatedRested or 0) > 0 and wt.Color(ns.strings.chat.restedXPAccumulated.text:gsub(
				"#AMOUNT", wt.Color(wt.FormatThousands(csc.xp.accumulatedRested), ns.colors.purple[1])
			):gsub(
				"#TOTAL", wt.Color(wt.FormatThousands(csc.xp.rested), ns.colors.purple[1])
			):gsub(
				"#PERCENT", wt.Color(ns.strings.chat.restedXPAccumulated.percent:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(math.floor(csc.xp.rested / (csc.xp.needed - csc.xp.current) * 1000000) / 10000, 4) .. "%%%%", ns.colors.purple[3])
				):gsub(
					"#NEXT", wt.Color(UnitLevel("player") + 1, ns.colors.purple[3])
				), ns.colors.blue[3])
			), ns.colors.blue[1]) or wt.Color(ns.strings.chat.restedXPAccumulated.zero, ns.colors.blue[1])
		))
	end

	--Initiate or remove the cross-session Rested XP accumulation tracking variable
	SetRestedAccumulation(db.notifications.restedXP.gained and db.notifications.restedXP.accumulated)

	--Tooltip update
	UpdateXPTooltip()
end

--[ Frames ]

--Set up a display context menu
local function _CreateContextMenu(parent)
	---@type contextMenu
	local contextMenu = wt.CreateContextMenu({ parent = parent, })

	--[ Items ]

	wt.AddContextLabel(contextMenu, { text = addonTitle, })

	--Options submenu
	-- local optionsMenu = wt.AddContextSubmenu(contextMenu, { --FIXME: Restore the submenu and the buttons once opening settings subcategories programmatically is once again supported in Dragonflight
	-- 	title = ns.strings.misc.options,
	-- })

	-- wt.AddContextButton(optionsMenu, contextMenu, {
	wt.AddContextButton(contextMenu, nil, {
		-- title = ns.strings.options.main.name,
		title = ns.strings.misc.options,
		tooltip = { lines = { { text = ns.strings.options.main.description:gsub("#ADDON", addonTitle), }, } },
		events = { OnClick = function() frames.options.main.page.open() end, },
	})
	-- wt.AddContextButton(optionsMenu, contextMenu, {
	-- 	title = ns.strings.options.display.title,
	-- 	tooltip = { lines = { { text = ns.strings.options.display.description:gsub("#ADDON", addonTitle), }, } },
	-- 	events = { OnClick = function() frames.options.display.page.open() end, },
	-- })
	-- wt.AddContextButton(optionsMenu, contextMenu, {
	-- 	title = ns.strings.options.integration.title,
	-- 	tooltip = { lines = { { text = ns.strings.options.integration.description:gsub("#ADDON", addonTitle), }, } },
	-- 	events = { OnClick = function() frames.options.integration.page.open() end, },
	-- })
	-- wt.AddContextButton(optionsMenu, contextMenu, {
	-- 	title = ns.strings.options.events.title,
	-- 	tooltip = { lines = { { text = ns.strings.options.events.description:gsub("#ADDON", addonTitle), }, } },
	-- 	events = { OnClick = function() frames.options.events.page.open() end, },
	-- })
	-- wt.AddContextButton(optionsMenu, contextMenu, {
	-- 	title = ns.strings.options.advanced.title,
	-- 	tooltip = { lines = { { text = ns.strings.options.advanced.description:gsub("#ADDON", addonTitle), }, } },
	-- 	events = { OnClick = function() frames.options.advanced.page.open() end, },
	-- })

	--Presets submenu
	local presetsMenu = wt.AddContextSubmenu(contextMenu, {
		title = ns.strings.options.display.position.presets.label,
		tooltip = { lines = { { text = ns.strings.options.display.position.presets.tooltip, }, } },
		width = 160,
	})
	for i = 1, #presets do wt.AddContextButton(presetsMenu, contextMenu, {
		title = presets[i].name,
		events = { OnClick = function() commandManager.handleCommand(ns.chat.commands.preset, i) end, },
	}) end
end --TODO: Reinstate after fix or delete
local function CreateContextMenu(parent)
	local menu = {
		{
			text = addonTitle,
			isTitle = true,
			notCheckable = true,
		},
		{
			text = ns.strings.misc.options,
			hasArrow = true,
			menuList = {
				{
					text = ns.strings.options.main.name,
					func = function() frames.options.main.page.open() end,
					notCheckable = true,
				},
				{
					text = ns.strings.options.display.title,
					func = function() frames.options.display.page.open() end,
					notCheckable = true,
				},
				{
					text = ns.strings.options.integration.title,
					func = function() frames.options.integration.page.open() end,
					notCheckable = true,
				},
				{
					text = ns.strings.options.events.title,
					func = function() frames.options.events.page.open() end,
					notCheckable = true,
				},
				{
					text = ns.strings.options.advanced.title,
					func = function() frames.options.advanced.page.open() end,
					notCheckable = true,
				},
			},
			notCheckable = true,
		},
		{
			text = ns.strings.options.display.position.presets.label,
			hasArrow = true,
			menuList = {},
			notCheckable = true,
		},
	}

	--Insert presets
	for i = 1, #presets do table.insert(menu[3].menuList, {
		text = presets[i].name,
		func = function() commandManager.handleCommand(ns.chat.commands.preset, i) end,
		notCheckable = true,
	}) end

	wt.CreateClassicContextMenu({
		parent = parent,
		menu = menu
	})
end

--Create main addon frame & display frames
frames.main = wt.CreateFrame({
	parent = UIParent,
	name = addonNameSpace,
	keepInBounds = true,
	size = { width = 114, height = 14 },
	keepOnTop = true,
	onEvent = {
		ADDON_LOADED = AddonLoaded,
		PLAYER_ENTERING_WORLD = PlayerEnteringWorld,
		PLAYER_XP_UPDATE = PlayerXPUpdate,
		PLAYER_LEVEL_UP = PlayerLevelUp,
		UPDATE_EXHAUSTION = UpdateExhaustion,
		PLAYER_UPDATE_RESTING = PlayerUpdateResting,
	},
	initialize = function(frame)
		--Main display
		frames.display.bg = wt.CreateFrame({
			parent = frame,
			name = "MainDisplay",
			customizable = true,
			position = { anchor = "CENTER", },
			keepInBounds = true,
			initialize = function(display)
				--Background: Current XP segment
				frames.display.xp = wt.CreateFrame({
					parent = display,
					name = "XP",
					customizable = true,
					position = { anchor = "LEFT", },
				})

				--Background: Rested XP segment
				frames.display.rested = wt.CreateFrame({
					parent = display,
					name = "Rested",
					customizable = true,
					position = {
						anchor = "LEFT",
						relativeTo = frames.display.xp,
						relativePoint = "RIGHT",
					},
				})

				--Background: Border overplay
				frames.display.overlay = wt.CreateFrame({
					parent = display,
					name = "Overlay",
					customizable = true,
					position = { anchor = "CENTER", },
					events = {
						OnEnter = function() if db.display.fade.enabled then Fade(false) end end,
						onLeave = function() if db.display.fade.enabled then Fade(true) end end,
					},
				})

				--Text
				frames.display.text = wt.CreateText({
					parent = frames.display.overlay,
					name = "Text",
					position = { anchor = "CENTER", },
					layer = "OVERLAY",
					wrap = false,
				})

				--Context menu
				CreateContextMenu(frames.display.overlay)
			end,
		})

		--Integrated display
		frames.integration.frame = wt.CreateFrame({
			parent = UIParent,
			name = frame:GetName() .. "IntegratedDisplay",
			customizable = true,
			position = {
				anchor = "BOTTOM",
				relativeTo = MainMenuExpBar,
				relativePoint = "BOTTOM",
			},
			keepInBounds = true,
			frameStrata = "HIGH",
			keepOnTop = true,
			size = { width = MainMenuExpBar:GetWidth(), height = MainMenuExpBar:GetHeight() },
			events = {
				OnEnter = function()
					--Show the enhanced XP text on the default XP bar
					UpdateIntegrationText(true, false)

					--Handling trial accounts & Banked XP
					local label = XPBAR_LABEL
					if GameLimitedMode_IsActive() then
						local rLevel = GetRestrictedAccountData()
						if UnitLevel("player") >= rLevel then
							if csc.xp.banked > 0 then
								GameTooltip:SetOwner(MainMenuExpBar, "ANCHOR_RIGHT", 0, -14)
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
				end,
				onLeave = function()
					--Hide the enhanced XP text on the default XP bar
					UpdateIntegrationText(db.enhancement.keep, db.enhancement.remaining)

					--Default trial tooltip
					if GameLimitedMode_IsActive() and IsTrialAccount() then
						--Stop the store button from flashing
						MicroButtonPulseStop(StoreMicroButton)

						--Hide the default trial tooltip
						GameTooltip:Hide()
					end
				end,
			},
			initialize = function(display)
				--Text
				frames.integration.text = wt.CreateText({
					parent = display,
					name = "Text",
					position = {
						anchor = "CENTER",
						offset = { y = 1 }
					},
					layer = "OVERLAY",
					font = "TextStatusBarText",
					wrap = false,
				})

				--Context menu
				CreateContextMenu(display)
			end,
		})
	end
})