--[[ NAMESPACE ]]

---@class RemainingXPNamespace
local ns = select(2, ...)


--[[ REFERENCES ]]

---@class wt
local wt = ns.WidgetToolbox

local frames = {
	display = { bg = {} },
	integration = {},
}

local options = {
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
	dataManagement = {
		backup = {},
	},
}

--Custom Tooltip
ns.tooltip = wt.CreateGameTooltip(ns.name)

---@type chatCommandManager
local chatCommands

--Check max level
local maxLevel = GetMaxLevelForPlayerExpansion()
local max = UnitLevel("player") >= maxLevel

local alwaysShow = C_CVar.GetCVar("xpBarText")


--[[ UTILITIES ]]

--[ Resource Management ]

---Find the ID of the font provided
---@param fontPath string
---@return integer id ***Default:*** 1 *(if* **fontPath** *isn't found)*
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

--[ XP Update ]

---Initiate or remove the cross-session variable storing the Rested XP accumulation while inside a Rested Area
---@param enabled boolean
local function SetRestedAccumulation(enabled)
	if not IsResting() then
		--Remove cross-session variable
		RemainingXPCSC.xp.accumulatedRested = nil
	else
		--Initiate cross-session variable
		if RemainingXPCSC.xp.accumulatedRested == nil then RemainingXPCSC.xp.accumulatedRested = 0 end

		--Chat notification
		if enabled then
			local atMax = wt.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.needed, 3) >= 1.5
			local atMaxLast = UnitLevel("player") == maxLevel - 1 and wt.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.remaining, 3) >= 1

			--Stared resting status update
			if RemainingXPDB.notifications.restedStatus.update then
				print(wt.Color(ns.strings.chat.restedStatus.resting, ns.colors.purple[1]) .. " " .. wt.Color(
					(atMax or atMaxLast) and ns.strings.chat.restedStatus.notAccumulating or ns.strings.chat.restedStatus.accumulating, ns.colors.blue[1]
				))

				--Max Rested XP reminder
				if RemainingXPDB.notifications.restedStatus.maxReminder then if atMax then
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
	local oldXP = RemainingXPCSC.xp.current or UnitXP("player")
	local oldNeededXP = RemainingXPCSC.xp.needed or UnitXPMax("player")
	local oldRestedXP = RemainingXPCSC.xp.rested or GetXPExhaustion() or 0

	--Update the XP values
	RemainingXPCSC.xp.current = UnitXP("player")
	RemainingXPCSC.xp.needed = UnitXPMax("player")
	RemainingXPCSC.xp.rested = GetXPExhaustion() or 0
	RemainingXPCSC.xp.remaining = RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current

	--Trial account
	if GameLimitedMode_IsActive() then
		RemainingXPCSC.xp.banked = UnitTrialXP("player")
		RemainingXPCSC.xp.bankedLevels = UnitTrialBankedLevels("player")
	end

	--Calculate the gained XP values
	local gainedXP = oldXP < RemainingXPCSC.xp.current and RemainingXPCSC.xp.current - oldXP or oldNeededXP - oldXP + RemainingXPCSC.xp.current
	local gainedRestedXP = RemainingXPCSC.xp.rested - oldRestedXP

	--Accumulating Rested XP
	if gainedRestedXP > 0 and RemainingXPCSC.xp.accumulatedRested ~= nil and IsResting() then RemainingXPCSC.xp.accumulatedRested = RemainingXPCSC.xp.accumulatedRested + gainedRestedXP end
	return gainedXP, gainedRestedXP, oldXP, oldRestedXP, oldNeededXP
end

--Assemble the text containing the Banked XP details
local function GetBankedText()
	return (GameLimitedMode_IsActive() and RemainingXPCSC.xp.banked > 0) and " + " .. ns.strings.xpBar.banked:gsub(
		"#VALUE", wt.FormatThousands(RemainingXPCSC.xp.banked)
	):gsub(
		"#LEVELS", RemainingXPCSC.xp.bankedLevels
	) or ""
end

--Update the position, width and visibility of the main XP display bar segments with the current XP values
local function UpdateXPDisplaySegments()
	--Current XP segment
	frames.display.xp:SetWidth(RemainingXPCSC.xp.current / RemainingXPCSC.xp.needed * frames.display.bg:GetWidth())

	--Rested XP segment
	if RemainingXPCSC.xp.rested == 0 then frames.display.rested:Hide() else
		frames.display.rested:Show()
		if frames.display.xp:GetWidth() == 0 then frames.display.rested:SetPoint("LEFT") else frames.display.rested:SetPoint("LEFT", frames.display.xp, "RIGHT") end
		frames.display.rested:SetWidth((RemainingXPCSC.xp.current + RemainingXPCSC.xp.rested > RemainingXPCSC.xp.needed and RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current or RemainingXPCSC.xp.rested) / RemainingXPCSC.xp.needed * frames.display.bg:GetWidth())
	end
end

--Update the main XP display bar segments and text with the current XP values
local function UpdateXPDisplayText()
	local text = ""

	if RemainingXPDB.display.text.details then
		text = wt.FormatThousands(RemainingXPCSC.xp.current) .. " / " .. wt.FormatThousands(RemainingXPCSC.xp.needed) .. " (" .. wt.FormatThousands(RemainingXPCSC.xp.remaining) .. ")"
		text = text .. (RemainingXPCSC.xp.rested > 0 and " + " .. wt.FormatThousands(RemainingXPCSC.xp.rested) .. " (" .. wt.FormatThousands(
			math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current) * 10000) / 100
		) .. "%)" or "") .. GetBankedText()
	else text = wt.FormatThousands(RemainingXPCSC.xp.remaining) end

	frames.display.text:SetText(text)
end

---Update the default XP bar enhancement display with the current XP values
---@param remaining boolean Whether or not only the remaining XP should be visible when the text is always shown
local function UpdateIntegrationText(keep, remaining)
	if not frames.integration.frame:IsVisible() then return end

	--Text base visibility
	wt.SetVisibility(frames.integration.text, keep)

	--Text content
	if remaining and not frames.integration.frame:IsMouseOver() then frames.integration.text:SetText(wt.FormatThousands(RemainingXPCSC.xp.remaining))
	else frames.integration.text:SetText(
		ns.strings.xpBar.text:gsub(
			"#CURRENT", wt.FormatThousands(RemainingXPCSC.xp.current)
		):gsub(
			"#NEEDED", wt.FormatThousands(RemainingXPCSC.xp.needed)
		):gsub(
			"#REMAINING", wt.FormatThousands(RemainingXPCSC.xp.remaining)
		) .. (
			RemainingXPCSC.xp.rested > 0 and " + " .. ns.strings.xpBar.rested:gsub(
				"#RESTED", wt.FormatThousands(RemainingXPCSC.xp.rested)
			):gsub(
				"#PERCENT", wt.FormatThousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current) * 10000) / 100) .. "%%"
			) or ""
		) .. GetBankedText()
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
				"#VALUE", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.current), ns.colors.purple[2])
			),
			font = GameTooltipText,
			color = ns.colors.purple[1],
		},
		{
			text = ns.strings.xpTooltip.percentRequired:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(RemainingXPCSC.xp.current / RemainingXPCSC.xp.needed * 10000) / 100, 3) .. "%%", ns.colors.purple[2])
			),
			color = ns.colors.purple[3],
		},

		--Remaining XP
		{
			text = "\n" .. ns.strings.xpTooltip.remaining:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.remaining), ns.colors.rose[2])
			),
			font = GameTooltipText,
			color = ns.colors.rose[1],
		},
		{
			text = ns.strings.xpTooltip.percentRequired:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor((RemainingXPCSC.xp.remaining / RemainingXPCSC.xp.needed) * 10000) / 100, 3) .. "%%", ns.colors.rose[2])
			),
			color = ns.colors.rose[3],
		},

		--Required XP
		{
			text = "\n" .. ns.strings.xpTooltip.required:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.needed), ns.colors.peach[2])
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

		--Playtime --ADD time played info
		-- {
		-- 	text = "\n" .. ns.strings.xpTooltip.timeSpent:gsub("#TIME", "?") .. " (Soon™)",
		-- },
	}

	--Current Rested XP
	if RemainingXPCSC.xp.rested > 0 then
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.rested:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.rested), ns.colors.blue[2])
			),
			font = GameTooltipText,
			color = ns.colors.blue[1],
		})
		table.insert(textLines, {
			text = ns.strings.xpTooltip.percentRemaining:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current) * 10000) / 100, 3) .. "%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
		table.insert(textLines, {
			text = ns.strings.xpTooltip.percentRequired:gsub(
				"#PERCENT", wt.Color(wt.FormatThousands(math.floor(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.needed * 10000) / 100, 3) .. "%%", ns.colors.blue[2])
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
		local atMax = wt.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.needed, 3) >= 1.5
		local atMaxLast = UnitLevel("player") == maxLevel - 1 and wt.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.remaining, 3) >= 1
		table.insert(textLines, {
			text = (atMax or atMaxLast) and (ns.strings.xpTooltip.restedAtMax) or ns.strings.chat.restedStatus.accumulating,
			color = ns.colors.blue[2],
		})
	end

	--Accumulated Rested XP
	if (RemainingXPCSC.xp.accumulatedRested or 0) > 0 then
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.accumulated:gsub(
				"#VALUE", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.accumulatedRested or 0), ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
	end

	--Banked XP & levels
	if GameLimitedMode_IsActive() and RemainingXPCSC.xp.banked > 0 then
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.banked:gsub(
				"#VALUE", wt.Color(ns.strings.xpTooltip.bankedValue:gsub(
					"#VALUE", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.banked), ns.colors.grey[2])
				):gsub(
					"#LEVELS", wt.Color(RemainingXPCSC.xp.bankedLevels, ns.colors.grey[2])
				), ns.colors.grey[3])
			),
			font = GameTooltipText,
			color = ns.colors.grey[1],
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
	if state == nil then state = RemainingXPDB.display.fade.enabled end

	--Text
	local r, g, b, a = wt.UnpackColor(textColor or RemainingXPDB.display.text.font.color)
	frames.display.text:SetTextColor(r, g, b, (a or 1) * (state and 1 - (textIntensity or RemainingXPDB.display.fade.text) or 1))

	--Background
	if RemainingXPDB.display.background.visible then
		backdropIntensity = backdropIntensity or RemainingXPDB.display.fade.background

		--Backdrop
		r, g, b, a = wt.UnpackColor(bgColor or RemainingXPDB.display.background.colors.bg)
		frames.display.bg:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))

		--Current XP segment
		r, g, b, a = wt.UnpackColor(xpColor or RemainingXPDB.display.background.colors.xp)
		frames.display.xp:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))

		--Rested XP segment
		r, g, b, a = wt.UnpackColor(restedColor or RemainingXPDB.display.background.colors.rested)
		frames.display.rested:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - backdropIntensity or 1))

		--Border & Text holder
		r, g, b, a = wt.UnpackColor(borderColor or RemainingXPDB.display.background.colors.border)
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
	frames.display.text:SetFont(data.display.text.font.family, data.display.text.font.size, "OUTLINE")
	frames.display.text:SetTextColor(wt.UnpackColor(data.display.text.font.color))

	--Fade
	Fade(data.display.fade.enabled)
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
	SetDisplayBackdrop(presets[i].data.background.visible, RemainingXPDB.display.background.colors)
	Fade(RemainingXPDB.display.fade.enable)

	--Convert to absolute position
	wt.ConvertToAbsolutePosition(frames.main)

	--Update the DBs
	RemainingXPDB.display.hidden = false
	wt.CopyValues(wt.PackPosition(frames.main:GetPoint()), RemainingXPDB.display.position)
	RemainingXPDB.display.layer.strata = presets[i].data.layer.strata
	if not presets[i].data.background.visible then RemainingXPDB.display.text.visible = true end
	RemainingXPDB.display.background.visible = presets[i].data.background.visible
	wt.CopyValues(presets[i].data.background.size, RemainingXPDB.display.background.size)

	--Update the options widgets
	options.display.visibility.hidden.setState(false)
	options.display.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets
	options.display.position.anchor.setSelected(RemainingXPDB.display.position.anchor)
	options.display.position.xOffset.setValue(RemainingXPDB.display.position.offset.x)
	options.display.position.yOffset.setValue(RemainingXPDB.display.position.offset.y)
	options.display.position.frameStrata.setSelected(RemainingXPDB.display.layer.strata)
	options.display.text.visible.setState(true)
	options.display.text.visible:SetAttribute("loaded", true) --Update dependent widgets
	options.display.background.visible.setState(RemainingXPDB.display.background.visible)
	options.display.background.visible:SetAttribute("loaded", true) --Update dependent widgets
	options.display.background.size.width.setValue(RemainingXPDB.display.background.size.width)
	options.display.background.size.height.setValue(RemainingXPDB.display.background.size.height)

	--Check the visibility options widgets
	if not RemainingXPDB.display.background.visible then
		options.display.text.visible.checkbox:SetButtonState("DISABLED")
		options.display.text.visible.checkbox:UnlockHighlight()
		options.display.text.visible:SetAlpha(0.4)
	else
		options.display.text.visible.checkbox:SetButtonState("NORMAL")
		options.display.text.visible:SetAlpha(1)
	end
end

--Save the current display position & visibility to the custom preset
local function UpdateCustomPreset()
	--Update the Custom preset
	presets[1].data.position = wt.PackPosition(frames.main:GetPoint())
	presets[1].data.layer.strata = frames.main:GetFrameStrata()
	presets[1].data.background.visible = options.display.background.visible.getState()
	presets[1].data.background.size = { width = options.display.background.size.width.getValue(), height = options.display.background.size.height.getValue() }
	wt.CopyValues(presets[1].data, RemainingXPDB.customPreset) --Update the DB
	RemainingXPDB.customPreset = wt.Clone(RemainingXPDB.customPreset) --Commit to the SavedVariables DB

	--Update the presets widget
	options.display.position.presets.setSelected(1)
end

--Reset the custom preset to its default state
local function ResetCustomPreset()
	--Reset the Custom preset
	presets[1].data = wt.Clone(ns.profileDefault.customPreset)
	wt.CopyValues(presets[1].data, RemainingXPDB.customPreset) --Update the DB
	RemainingXPDB.customPreset = wt.Clone(RemainingXPDB.customPreset) --Commit to the SavedVariables DB

	--Apply the Custom preset
	ApplyPreset(1)
	options.display.position.presets.setSelected(1) --Update the presets widget
end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load boolean ***Default:*** false
local function PrintStatus(load)
	if load == true and not RemainingXPDB.notifications.statusNotice.enabled then return end

	local status = wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(
		frames.main:IsVisible() and ns.strings.chat.status.visible or ns.strings.chat.status.hidden, ns.colors.blue[1]
	):gsub(
		"#FADE", wt.Color(ns.strings.chat.status.fade:gsub(
			"#STATE", wt.Color(RemainingXPDB.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
		), ns.colors.blue[2])
	)

	if max then if RemainingXPDB.notifications.statusNotice.maxReminder then
		status = wt.Color(ns.strings.chat.status.disabled:gsub(
			"#ADDON", wt.Color(ns.title, ns.colors.purple[1])
		) .." " ..  wt.Color(ns.strings.chat.status.max:gsub(
			"#MAX", wt.Color(maxLevel, ns.colors.purple[2])
		), ns.colors.blue[2]), ns.colors.blue[1])
	else return end end

	print(status)
end

---Format and print a command description
---@param command string Command name
---@param description string Command description text
local function PrintCommand(command, description)
	print("    " .. wt.Color("/" .. ns.chat.keyword .. " " .. command, ns.colors.purple[3])  .. wt.Color(" - " .. description, ns.colors.blue[3]))
end

--Reset to defaults confirmation
local resetDefaultsPopup = wt.CreatePopup({
	addon = ns.name,
	name = "DefaultOptions",
	text = (wt.GetStrings("warning") or ""):gsub("#TITLE", wt.Clear(ns.title)),
	onAccept = function()
		--Reset the options data & update the interface options
		options.display.page.default()
		options.integration.page.default()
		options.events.page.default()
		options.dataManagement.page.default(true)
	end,
})








--[[ INITIALIZATION ]]

local firstLoad, newCharacter

--Set up a display context menu
local function CreateContextMenu(parent)
	wt.CreateContextMenu({ parent = parent, initialize = function(menu)
		wt.CreateMenuTextline(menu, { text = ns.title, })
		wt.CreateSubmenu(menu, { title = ns.strings.misc.options, initialize = function(optionsMenu)
			wt.CreateMenuButton(optionsMenu, {
				title = wt.GetStrings("about").title,
				tooltip = { lines = { { text = ns.strings.options.main.description:gsub("#ADDON", ns.title), }, } },
				action = options.main.page.open,
			})
			wt.CreateMenuButton(optionsMenu, {
				title = ns.strings.options.display.title:gsub("#TYPE", ns.strings.options.display.title),
				tooltip = { lines = { { text = ns.strings.options.display.description, }, } },
				action = options.display.page.open,
			})
			wt.CreateMenuButton(optionsMenu, {
				title = ns.strings.options.integration.title:gsub("#TYPE", ns.strings.options.integration.title),
				tooltip = { lines = { { text = ns.strings.options.integration.description, }, } },
				action = options.integration.page.open,
			})
			wt.CreateMenuButton(optionsMenu, {
				title = ns.strings.options.events.title:gsub("#TYPE", ns.strings.options.events.title),
				tooltip = { lines = { { text = ns.strings.options.events.description, }, } },
				action = options.events.page.open,
			})
			wt.CreateMenuButton(optionsMenu, {
				title = wt.GetStrings("dataManagement").title,
				tooltip = { lines = { { text = wt.GetStrings("dataManagement").description:gsub("#ADDON", ns.title), }, } },
				action = options.dataManagement.page.open,
			})
		end })
		wt.CreateSubmenu(menu, { title = wt.GetStrings("apply").label, initialize = function(presetsMenu)
			for i = 1, #options.display.position.presetList do wt.CreateMenuButton(presetsMenu, {
				title = options.display.position.presetList[i].title,
				action = function() options.display.position.applyPreset(i) end,
			}) end
		end })
	end, })
end

--Create main addon frame & display frames
frames.main = wt.CreateFrame({
	parent = UIParent,
	name = ns.name,
	keepInBounds = true,
	size = { width = 114, height = 14 },
	keepOnTop = true,
	onEvent = {
		ADDON_LOADED = function(self, addon)
			if addon ~= ns.name then return end

			self:UnregisterEvent("ADDON_LOADED")


			--[[ DATABASES ]]

			RemainingXPDB = RemainingXPDB or {}
			RemainingXPDBC = RemainingXPDBC or {}
			RemainingXPCS = wt.AddMissing(RemainingXPCS, {
				compactBackup = true,
				keepInPlace = true,
			})
			RemainingXPCSC = RemainingXPCSC or {}


			--[[ SETTINGS ]]

			--[ Settings Pages ]

			--| Data management

			options.dataManagement, firstLoad, newCharacter = wt.CreateDataManagementPage(ns.name, {
				onDefault = function(_, category) if not category then options.dataManagement.resetProfile() end end,
				accountData = RemainingXPDB,
				characterData = RemainingXPDBC,
				settingsData = RemainingXPCS,
				defaultsTable = ns.profileDefault,
				valueChecker = function(key, value) if type(value) == "number" then
					if key == "size" then return value > 0 end
					if key == "r" or key == "g" or key == "b" or key == "a" then return value >= 0 and value <= 1 end
					if key == "anchor" then return false end
				end return true end,
				recoveryMap = function(data) return {
					["customPreset.position.point"] = { saveTo = data.customPreset.position, saveKey = "anchor" },
					["position.point"] = { saveTo = data.display.position, saveKey = "anchor" },
					["display.position.point"] = { saveTo = data.display.position, saveKey = "anchor" },
					["appearance.frameStrata"] = { saveTo = data.display.layer, saveKey = "strata" },
					["display.visibility.frameStrata"] = { saveTo = data.display.layer, saveKey = "strata" },
					["display.visibility.fade"] = { saveTo = data.display, saveKey = "fade" },
					["appearance.backdrop.visible"] = { saveTo = data.display.background, saveKey = "visible" },
					["appearance.backdrop.color.r"] = { saveTo = data.display.background.colors.bg, saveKey = "r" },
					["appearance.backdrop.color.g"] = { saveTo = data.display.background.colors.bg, saveKey = "g" },
					["appearance.backdrop.color.b"] = { saveTo = data.display.background.colors.bg, saveKey = "b" },
					["appearance.backdrop.color.a"] = { saveTo = data.display.background.colors.bg, saveKey = "a" },
					["font.family"] = { saveTo = data.display.text.font, saveKey = "family" },
					["font.size"] = { saveTo = data.display.text.font, saveKey = "size" },
					["font.color.r"] = { saveTo = data.display.text.font.color, saveKey = "r" },
					["font.color.g"] = { saveTo = data.display.text.font.color, saveKey = "g" },
					["font.color.b"] = { saveTo = data.display.text.font.color, saveKey = "b" },
					["font.color.a"] = { saveTo = data.display.text.font.color, saveKey = "a" },
					["removals.statusBars"] = { saveTo = data.removals, saveKey = "xpBar" },
					["notifications.maxReminder"] = { saveTo = data.notifications.statusNotice, saveKey = "maxReminder" },
					["mouseover"] = { saveTo = data.display.fade, saveKey = "enabled" },
					["hidden"] = { saveTo = data.display.visibility, saveKey = "hidden" },
				} end,
				onRecovery = function(data) if not data.display.text.visible and not data.display.background.visible then
					data.display.visibility.hidden = true
					data.display.text.visible = true
					data.display.background.visible = true
				end end,
				onProfileActivated = function(title)
					options.display.page.load(true)
					options.integration.page.load(true)
					options.events.page.load(true)
					options.dataManagement.page.load(true)

					chatCommands.print(ns.strings.chat.profile.response:gsub("#PROFILE", wt.Color(title, ns.colors.yellow[2])))
				end,
				onProfileDeleted = function(title) chatCommands.print(ns.strings.chat.default.response:gsub("#PROFILE", wt.Color(title, ns.colors.yellow[2]))) end,
				onProfileReset = function(title) chatCommands.print(ns.strings.chat.default.response:gsub("#PROFILE", wt.Color(title, ns.colors.yellow[2]))) end,
				onImport = function(success) if success then
					options.display.page.load(true)
					options.integration.page.load(true)
					options.events.page.load(true)
					options.dataManagement.page.load(true)
				else chatCommands.print(wt.GetStrings("backup").error) end end,
				onImportAllProfiles = function(success) if not success then chatCommands.print(wt.GetStrings("backup").error) end end,
			})

			--| Addon info

			options.main.page = wt.CreateAboutPage(ns.name, {
				name = "Main",
				description = ns.strings.options.main.description:gsub("#ADDON", ns.title),
				changelog = ns.changelog
			})

			--| Display

			options.display.page = wt.CreateSettingsPage(ns.name, {
				parent = options.main.page.category,
				addon = ns.name,
				name = "Display",
				title = ns.strings.options.display.title,
				description = ns.strings.options.display.description:gsub("#ADDON", ns.title),
				logo = ns.textures.logo,
				scroll = {},
				optionsKeys = { ns.name .. "Display" },
				storage = { {
					workingTable =  RemainingXPDB.display,
					storageTable = RemainingXPDB.display,
					defaultsTable = ns.profileDefault.display,
				}, },
				onSave = function() RemainingXPDB = wt.Clone(RemainingXPDB) end,
				onDefault = function(user)
					ResetCustomPreset()

					if not user then return end

					--Notification
					print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.reset.response:gsub(
						"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3])
					), ns.colors.blue[3]))
					print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
						"#CATEGORY", wt.Color(ns.strings.options.display.title, ns.colors.purple[3])
					), ns.colors.blue[3]))
				end,
				arrangement = {},
				initialize = function(canvas)

					--[ Visibility ]

					wt.CreatePanel({
						parent = canvas,
						name = "Visibility",
						title = ns.strings.options.display.title,
						description = ns.strings.options.display.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| Toggle

							options.display.visibility.hidden = wt.CreateCheckbox({
								parent = panel,
								name = "Hidden",
								title = ns.strings.options.display.visibility.hidden.label,
								tooltip = { lines = { { text = ns.strings.options.display.visibility.hidden.tooltip:gsub("#ADDON", ns.title), }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display,
									storageKey = "hidden",
									onChange = {
										DisplayToggle = function() wt.SetVisibility(frames.main, not (RemainingXPDB.display.hidden or max)) end,
										EnsureVisibility = function()
											if not RemainingXPDB.display.background.visible then
												options.display.text.visible.checkbox:SetButtonState("DISABLED")
												options.display.text.visible.checkbox:UnlockHighlight()
												options.display.text.visible:SetAlpha(0.4)
											else
												if not RemainingXPDB.display.hidden then options.display.text.visible.checkbox:SetButtonState("NORMAL") end
												options.display.text.visible:SetAlpha(1)
											end
											if not RemainingXPDB.display.text.visible then
												options.display.background.visible.checkbox:SetButtonState("DISABLED")
												options.display.background.visible.checkbox:UnlockHighlight()
												options.display.background.visible:SetAlpha(0.4)
											else
												if not RemainingXPDB.display.hidden then options.display.background.visible.checkbox:SetButtonState("NORMAL") end
												options.display.background.visible:SetAlpha(1)
											end
										end,
									}
								}
							})

							--| Status notice

							options.display.visibility.status = wt.CreateCheckbox({
								parent = panel,
								name = " StatusNotice",
								title = ns.strings.options.display.visibility.statusNotice.label,
								tooltip = { lines = { { text = ns.strings.options.display.visibility.statusNotice.tooltip:gsub("#ADDON", ns.title), }, } },
								arrange = { newRow = false, },
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.notifications.statusNotice,
									storageKey = "enabled",
								}
							})

							--| Max reminder

							options.display.visibility.maxReminder = wt.CreateCheckbox({
								parent = panel,
								name = "MaxReminder",
								title = ns.strings.options.display.visibility.maxReminder.label,
								tooltip = { lines = { { text = ns.strings.options.display.visibility.maxReminder.tooltip:gsub("#ADDON", ns.title), }, } },
								arrange = { newRow = false, },
								dependencies = { { frame = options.display.visibility.status, }, },
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.notifications.statusNotice,
									storageKey = "maxReminder",
								}
							})
						end,
					})

					--[ Position ]

					--Add Custom preset
					table.insert(ns.presets, 1, {
						title = ns.strings.misc.custom,
						onSelect = function() options.display.position.presetList[1].data.position.relativePoint = options.display.position.presetList[1].data.position.anchor end,
					})

					options.display.position = wt.CreatePositionOptions(ns.name, {
						canvas = canvas,
						frame = frames.display,
						frameName = ns.strings.options.display.referenceName,
						presets = {
							items = ns.presets,
							onPreset = function(i)
								-- wt.ConvertToAbsolutePosition(frames.display.display) --CHECK if needed

								--Make sure the speed display is visible
								options.display.visibility.hidden.setData(false)
								if not options.display.background.visible.getData() then options.display.text.visible.setData(true) end

								--Set background


								chatCommands.print(ns.strings.chat.preset.response:gsub(
									"#PRESET", wt.Color(options.display.position.presetList[i].title, ns.colors.yellow[2])
								):gsub(
									"#TYPE", ns.strings.options.display.title
								))
							end,
							custom = {
								getData = function() return RemainingXPDB.profiles[RemainingXPDBC.activeProfile].data.customPreset end,
								defaultsTable = ns.profileDefault.customPreset,
								onSave = function()
									chatCommands.print(ns.strings.chat.save.response:gsub(
										"#TYPE", ns.strings.options.display.title
									):gsub(
										"#CUSTOM", wt.Color(ns.strings.misc.custom, ns.colors.yellow[2])
									))
								end,
								onReset = function()
									chatCommands.print(ns.strings.chat.reset.response:gsub(
										"#CUSTOM", wt.Color(ns.strings.misc.custom, ns.colors.yellow[2])
									))
								end
							}
						},
						setMovable = { events = {
							onStop = function() chatCommands.print(ns.strings.chat.position.save:gsub(
								"#TYPE", ns.strings.options.display.title
							)) end,
							onCancel = function()
								chatCommands.print(ns.strings.chat.position.cancel:gsub(
									"#TYPE", ns.strings.options.display.title
								))
								print(wt.Color(ns.strings.chat.position.error, ns.colors.yellow[2]))
							end,
						}, },
						dependencies = { { frame = options.display.visibility.hidden, evaluate = function(state) return not state end }, },
						getData = function() return RemainingXPDB.profiles[RemainingXPDBC.activeProfile].data.display end,
						defaultsTable = ns.profileDefault.display,
						settingsData = RemainingXPCS.display,
						dataManagement = { category = ns.name .. "display", },
					})

					--[ Text ]

					wt.CreatePanel({
						parent = canvas,
						name = "Text",
						title = ns.strings.options.display.text.title,
						description = ns.strings.options.display.text.description,
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| Toggle

							options.display.text.visible = wt.CreateCheckbox({
								parent = panel,
								name = "Visible",
								title = ns.strings.options.display.text.visible.label,
								tooltip = { lines = { { text = ns.strings.options.display.text.visible.tooltip, }, } },
								arrange = {},
								events = { OnClick = function(_, state) options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
								dependencies = { { frame = options.display.visibility.hidden, evaluate = function(state) return not state end }, },
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.text,
									storageKey = "visible",
									onChange = {
										ToggleDisplayText = function() wt.SetVisibility(frames.display.text, RemainingXPDB.display.text.visible) end,
										"EnsureVisibility",
									}
								}
							})

							--| Details

							options.display.text.details = wt.CreateCheckbox({
								parent = panel,
								name = "Details",
								title = ns.strings.options.display.text.details.label,
								tooltip = { lines = { { text = ns.strings.options.display.text.details.tooltip, }, } },
								arrange = { newRow = false, },
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.text.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.text,
									storageKey = "details",
									onChange = { UpdateDisplayText = function() UpdateXPDisplayText() end, }
								}
							})

							--| Font family

							local fontItems = {}

							for i = 1, #ns.fonts do
								fontItems[i] = {}
								fontItems[i].title = ns.fonts[i].name
								fontItems[i].tooltip = {
									title = ns.fonts[i].name,
									lines = i == 1 and { { text = ns.strings.options.display.text.font.family.default, }, } or (i == #ns.fonts and {
										{ text = ns.strings.options.display.text.font.family.custom[1]:gsub("#OPTION_CUSTOM", ns.strings.misc.custom):gsub("#FILE_CUSTOM", "CUSTOM.ttf"), },
										{ text = "[WoW]\\Interface\\AddOns\\" .. ns.name .. "\\Fonts\\", color = { r = 0.185, g = 0.72, b = 0.84 }, wrap = false },
										{ text = ns.strings.options.display.text.font.family.custom[2]:gsub("#FILE_CUSTOM", "CUSTOM.ttf"), },
										{ text = "\n" .. ns.strings.options.display.text.font.family.custom[3], color = { r = 0.89, g = 0.65, b = 0.40 }, },
									} or nil),
								}
							end

							options.display.text.font.family = wt.CreateDropdownSelector({
								parent = panel,
								name = "FontFamily",
								title = ns.strings.options.display.text.font.family.label,
								tooltip = { lines = { { text = ns.strings.options.display.text.font.family.tooltip, }, } },
								arrange = {},
								items = fontItems,
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.text.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.text.font,
									storageKey = "family",
									convertSave = function(value) return ns.fonts[value].path end,
									convertLoad = function(font) return GetFontID(font) end,
									onChange = {
										UpdateDisplayFont = function() frames.display.text:SetFont(RemainingXPDB.display.text.font.family, RemainingXPDB.display.text.font.size, "OUTLINE") end,
										RefreshDisplayText = function() --Refresh the text so the font will be applied even the first time as well not just subsequent times
											local text = frames.display.text:GetText()
											frames.display.text:SetText("")
											frames.display.text:SetText(text)
										end,
										UpdateFontFamilyDropdownText = function()
											--Update the font of the dropdown toggle button label
											local label = _G[options.display.text.font.family.toggle:GetName() .. "Text"]
											local _, size, flags = label:GetFont()
											label:SetFont(ns.fonts[options.display.text.font.family.getSelected()].path, size, flags)

											--Refresh the text so the font will be applied right away (if the font is loaded)
											local text = label:GetText()
											label:SetText("")
											label:SetText(text)
										end,
									}
								}
							})

							for i = 1, #options.display.text.font.family.selector.items do
								--Update fonts of the dropdown options
								local label = _G[options.display.text.font.family.selector.items[i]:GetName() .. "RadioButtonText"]
								local _, size, flags = label:GetFont()
								label:SetFont(ns.fonts[i].path, size, flags)
							end

							--| Font size

							options.display.text.font.size = wt.CreateNumericSlider({
								parent = panel,
								name = "FontSize",
								title = ns.strings.options.display.text.font.size.label,
								tooltip = { lines = { { text = ns.strings.options.display.text.font.size.tooltip .. "\n\n" .. ns.strings.misc.default .. ": " .. ns.profileDefault.display.text.font.size, }, } },
								arrange = { newRow = false, },
								value = { min = 8, max = 64, increment = 1 },
								altStep = 3,
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.text.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.text.font,
									storageKey = "size",
									onChange = { "UpdateDisplayFont", }
								}
							})

							--| Alignment

							options.display.text.alignment = wt.CreateSpecialSelector("justifyH", {
								parent = panel,
								name = "Alignment",
								title = ns.strings.options.display.text.alignment.label,
								tooltip = { lines = { { text = ns.strings.options.display.text.alignment.tooltip, }, } },
								arrange = { newRow = false, },
								width = 140,
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.text.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.text,
									storageKey = "alignment",
									onChange = { UpdateDisplayTextAlignment = function()
										frames.display.text:SetJustifyH(RemainingXPDB.display.text.alignment)
										wt.SetPosition(frames.display.text, { anchor = RemainingXPDB.display.text.alignment, })
									end, }
								}
							})

							--| Color

							options.display.text.font.color = wt.CreateColorPicker({
								parent = panel,
								name = "FontColor",
								title = ns.strings.options.display.text.font.color.label,
								arrange = {},
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.text.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.text.font,
									storageKey = "color",
									onChange = {
										UpdateDisplayFontColor = function() frames.display.text:SetTextColor(wt.UnpackColor(RemainingXPDB.display.text.font.color)) end,
										UpdateFade = Fade,
									}
								}
							})
						end,
					})

					--[ Background ]

					wt.CreatePanel({
						parent = canvas,
						name = "Background",
						title = ns.strings.options.display.background.title,
						description = ns.strings.options.display.background.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| Toggle

							options.display.background.visible = wt.CreateCheckbox({
								parent = panel,
								name = "Visible",
								title = ns.strings.options.display.background.visible.label,
								tooltip = { lines = { { text = ns.strings.options.display.background.visible.tooltip, }, } },
								arrange = {},
								events = { OnClick = function(_, state) options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
								dependencies = { { frame = options.display.visibility.hidden, evaluate = function(state) return not state end }, },
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background,
									storageKey = "visible",
									onChange = {
										ToggleDisplayBackdrop = function() SetDisplayBackdrop(RemainingXPDB.display.background.visible, RemainingXPDB.display.background.colors) end,
										"EnsureVisibility",
										"UpdateFade",
									}
								}
							})

							--| Width

							options.display.background.size.width = wt.CreateNumericSlider({
								parent = panel,
								name = "Width",
								title = ns.strings.options.display.background.size.width.label,
								tooltip = { lines = { { text = ns.strings.options.display.background.size.width.tooltip, }, } },
								arrange = { newRow = false, },
								value = { min = 64, max = UIParent:GetWidth() - math.fmod(UIParent:GetWidth(), 1) , increment = 2 },
								altStep = 8,
								events = { OnValueChanged = function() options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background.size,
									storageKey = "width",
									onChange = { UpdateDisplaySize = function() ResizeDisplay(RemainingXPDB.display.background.size.width, RemainingXPDB.display.background.size.height) end, }
								}
							})

							--| Height

							options.display.background.size.height = wt.CreateNumericSlider({
								parent = panel,
								name = "Height",
								title = ns.strings.options.display.background.size.height.label,
								tooltip = { lines = { { text = ns.strings.options.display.background.size.height.tooltip, }, } },
								arrange = { newRow = false, },
								value = { min = 2, max = 80, increment = 2 },
								altStep = 8,
								events = { OnValueChanged = function() options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select) end, },
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background.size,
									storageKey = "height",
									onChange = { "UpdateDisplaySize", }
								}
							})

							--| Background color

							options.display.background.colors.bg = wt.CreateColorPicker({
								parent = panel,
								name = "Color",
								title = ns.strings.options.display.background.colors.bg.label,
								arrange = {},
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background.colors,
									storageKey = "bg",
									onChange = {
										UpdateDisplayBackgroundColor = function()
											if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(RemainingXPDB.display.background.colors.bg)) end
										end,
										"UpdateFade",
									}
								}
							})

							--| Border color

							options.display.background.colors.border = wt.CreateColorPicker({
								parent = panel,
								name = "BorderColor",
								title = ns.strings.options.display.background.colors.border.label,
								arrange = { newRow = false, },
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background.colors,
									storageKey = "border",
									onChange = {
										UpdateDisplayBorderColor = function()
											if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(RemainingXPDB.display.background.colors.border)) end
										end,
										"UpdateFade",
									}
								}
							})

							--| Current XP color

							options.display.background.colors.xp = wt.CreateColorPicker({
								parent = panel,
								name = "XPColor",
								title = ns.strings.options.display.background.colors.xp.label,
								arrange = { newRow = false, },
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background.colors,
									storageKey = "xp",
									onChange = {
										UpdateDisplayXPColor = function()
											if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(RemainingXPDB.display.background.colors.xp)) end 
										end,
										"UpdateFade",
									}
								}
							})

							--| Rested XP color

							options.display.background.colors.rested = wt.CreateColorPicker({
								parent = panel,
								name = "RestedColor",
								title = ns.strings.options.display.background.colors.rested.label,
								arrange = { newRow = false, },
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.background.colors,
									storageKey = "rested",
									onChange = {
										UpdateDisplayBorderColor = function()
											if frames.display.bg:GetBackdrop() ~= nil then frames.display.bg:SetBackdropColor(wt.UnpackColor(RemainingXPDB.display.background.colors.rested)) end
										end,
										"UpdateFade",
									}
								}
							})
						end,
					})

					--[ Fade ]

					wt.CreatePanel({
						parent = canvas,
						name = "Fade",
						title = ns.strings.options.display.fade.title,
						description = ns.strings.options.display.fade.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| Toggle

							options.display.fade.toggle = wt.CreateCheckbox({
								parent = panel,
								name = "FadeToggle",
								title = ns.strings.options.display.fade.toggle.label,
								tooltip = { lines = { { text = ns.strings.options.display.fade.toggle.tooltip, }, } },
								arrange = { newRow = false, },
								dependencies = { { frame = options.display.visibility.hidden, evaluate = function(state) return not state end }, },
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.fade,
									storageKey = "enabled",
									onChange = { "UpdateFade", }
								}
							})

							--| Text fade intensity

							options.display.fade.text = wt.CreateNumericSlider({
								parent = panel,
								name = " TextFade",
								title = ns.strings.options.display.fade.text.label,
								tooltip = { lines = { { text = ns.strings.options.display.fade.text.tooltip, }, } },
								arrange = { newRow = false, },
								value = { min = 0, max = 1, increment = 0.05 },
								altStep = 0.2,
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.fade.toggle, },
									{ frame = options.display.text.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.fade,
									storageKey = "text",
									onChange = { "UpdateFade", }
								}
							})

							--| Background fade intensity

							options.display.fade.background = wt.CreateNumericSlider({
								parent = panel,
								name = "BackgroundFade",
								title = ns.strings.options.display.fade.background.label,
								tooltip = { lines = { { text = ns.strings.options.display.fade.background.tooltip, }, } },
								arrange = { newRow = false, },
								value = { min = 0, max = 1, increment = 0.05 },
								altStep = 0.2,
								dependencies = {
									{ frame = options.display.visibility.hidden, evaluate = function(state) return not state end },
									{ frame = options.display.fade.toggle, },
									{ frame = options.display.background.visible, },
								},
								optionsData = {
									optionsKey = ns.name .. "Display",
									workingTable = RemainingXPDB.display.fade,
									storageKey = "background",
									onChange = { "UpdateFade", }
								}
							})
						end,
					})
				end,
			})

			--| Integration

			options.integration.page = wt.CreateSettingsPage(ns.name, {
				parent = options.main.page.category,
				addon = ns.name,
				name = "Integration",
				title = ns.strings.options.integration.title,
				description = ns.strings.options.integration.description:gsub("#ADDON", ns.title),
				logo = ns.textures.logo,
				optionsKeys = { ns.name .. "Integration" },
				storage = {
					{
						workingTable =  RemainingXPDB.enhancement,
						storageTable = RemainingXPDB.enhancement,
						defaultsTable = ns.profileDefault.enhancement,
					},
					{
						workingTable =  RemainingXPDB.removals,
						storageTable = RemainingXPDB.removals,
						defaultsTable = ns.profileDefault.removals,
					},
				},
				onDefault = function(user)
					if not user then return end

					--Notification
					print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
						"#CATEGORY", wt.Color(ns.strings.options.integration.title, ns.colors.purple[3])
					), ns.colors.blue[3]))
				end,
				arrangement = {},
				initialize = function(canvas)

					--[ Enhancement ]

					wt.CreatePanel({
						parent = canvas,
						name = "Enhancement",
						title = ns.strings.options.integration.enhancement.title,
						description = ns.strings.options.integration.enhancement.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| Toggle

							options.integration.enhancement.toggle = wt.CreateCheckbox({
								parent = panel,
								name = "EnableIntegration",
								title = ns.strings.options.integration.enhancement.toggle.label,
								tooltip = { lines = { { text = ns.strings.options.integration.enhancement.toggle.tooltip, }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Integration",
									workingTable = RemainingXPDB.enhancement,
									storageKey = "enabled",
									onChange = { ToggleIntegration = function()
										SetIntegrationVisibility(RemainingXPDB.enhancement.enabled)
										UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining)
									end, }
								},
							})

							--| Always show XP text

							options.integration.enhancement.keep = wt.CreateCheckbox({
								parent = panel,
								name = "KeepText",
								title = ns.strings.options.integration.enhancement.keep.label,
								tooltip = { lines = { { text = ns.strings.options.integration.enhancement.keep.tooltip, }, } },
								arrange = { newRow = false, },
								dependencies = { { frame = options.integration.enhancement.toggle, }, },
								optionsData = {
									optionsKey = ns.name .. "Integration",
									workingTable = RemainingXPDB.enhancement,
									storageKey = "keep",
									onChange = { UpdateIntegrationText = function() UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining) end, }
								},
							})

							--| Only show Remaining XP

							options.integration.enhancement.remaining = wt.CreateCheckbox({
								parent = panel,
								name = "RemainingOnly",
								title = ns.strings.options.integration.enhancement.remaining.label,
								tooltip = { lines = { { text = ns.strings.options.integration.enhancement.remaining.tooltip, }, } },
								arrange = { newRow = false, },
								dependencies = {
									{ frame = options.integration.enhancement.toggle, },
									{ frame = options.integration.enhancement.keep, },
								},
								optionsData = {
									optionsKey = ns.name .. "Integration",
									workingTable = RemainingXPDB.enhancement,
									storageKey = "remaining",
									onChange = { "UpdateIntegrationText", }
								},
							})
						end,
					})

					--[ Removals ]

					wt.CreatePanel({
						parent = canvas,
						name = "Removals",
						title = ns.strings.options.integration.removals.title,
						description = ns.strings.options.integration.removals.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| XP bar

							options.integration.removals.xpBar = wt.CreateCheckbox({
								parent = panel,
								name = "HideXPBar",
								title = ns.strings.options.integration.removals.xpBar.label,
								tooltip = { lines = { { text = ns.strings.options.integration.removals.xpBar.tooltip:gsub("#ADDON", ns.title), }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Integration",
									workingTable = RemainingXPDB.removals,
									storageKey = "xpBar",
									onChange = { ToggleXPBar = function() wt.SetVisibility(MainStatusTrackingBarContainer, not RemainingXPDB.removals.xpBar) end, }
								}
							})
						end,
					})
				end,
			})

			--| Events

			options.events.page = wt.CreateSettingsPage(ns.name, {
				parent = options.main.page.category,
				addon = ns.name,
				name = "Events",
				title = ns.strings.options.events.title,
				description = ns.strings.options.events.description:gsub("#ADDON", ns.title),
				logo = ns.textures.logo,
				optionsKeys = { ns.name .. "Events" },
				storage = { {
					workingTable =  RemainingXPDB.notifications,
					storageTable = RemainingXPDB.notifications,
					defaultsTable = ns.profileDefault.notifications,
				}, },
				onDefault = function(user)
					if not user then return end

					--Notification
					print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
						"#CATEGORY", wt.Color(ns.strings.options.events.title, ns.colors.purple[3])
					), ns.colors.blue[3]))
				end,
				arrangement = {},
				initialize = function(canvas)

					--[ Notifications ]

					wt.CreatePanel({
						parent = canvas,
						name = "ChatNotifications",
						title = ns.strings.options.events.notifications.title,
						description = ns.strings.options.events.notifications.description,
						arrange = {},
						arrangement = {},
						initialize = function(panel)

							--| XP gained

							options.events.xpGained = wt.CreateCheckbox({
								parent = panel,
								name = "XPGained",
								title = ns.strings.options.events.notifications.xpGained.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.xpGained.tooltip, }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications,
									storageKey = "xpGained",
								}
							})

							--| Rested XP gained

							options.events.restedXPGained = wt.CreateCheckbox({
								parent = panel,
								name = "RestedXPGained",
								title = ns.strings.options.events.notifications.restedXP.gained.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedXP.gained.tooltip, }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications.restedXP,
									storageKey = "gained",
								}
							})

							--| Significant Rested XP values only

							options.events.significantRestedOnly = wt.CreateCheckbox({
								parent = panel,
								name = "SignificantRestedOnly",
								title = ns.strings.options.events.notifications.restedXP.significantOnly.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedXP.significantOnly.tooltip, }, } },
								arrange = { newRow = false, },
								dependencies = { { frame = options.events.restedXPGained, }, },
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications.restedXP,
									storageKey = "significantOnly",
								}
							})

							--| Rested XP accumulated

							options.events.restedXPAccumulated = wt.CreateCheckbox({
								parent = panel,
								name = "AccumulatedRestedXP",
								title = ns.strings.options.events.notifications.restedXP.accumulated.label,
								tooltip = { lines = {
									{ text = ns.strings.options.events.notifications.restedXP.accumulated.tooltip[1], },
									{
										text = ns.strings.options.events.notifications.restedXP.accumulated.tooltip[2]:gsub("#ADDON", ns.title),
										color = { r = 0.89, g = 0.65, b = 0.40 },
									},
								} },
								arrange = { newRow = false, },
								dependencies = { { frame = options.events.restedXPGained, }, },
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications.restedXP,
									storageKey = "accumulated",
									onChange = { UpdateRestedAccumulation = function() SetRestedAccumulation(RemainingXPDB.notifications.restedXP.gained and RemainingXPDB.notifications.restedXP.accumulated and max) end, }
								}
							})

							--| Rested status update

							options.events.restedStatusUpdate = wt.CreateCheckbox({
								parent = panel,
								name = "RestedStatusUpdate",
								title = ns.strings.options.events.notifications.restedStatus.update.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedStatus.update.tooltip, }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications.restedStatus,
									storageKey = "update",
								}
							})

							--| Max Rested XP reminder

							options.events.maxRestedXPReminder = wt.CreateCheckbox({
								parent = panel,
								name = "MaxRestedXPReminder",
								title = ns.strings.options.events.notifications.restedStatus.maxReminder.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedStatus.maxReminder.tooltip, }, } },
								arrange = { newRow = false, },
								dependencies = { { frame = options.events.restedStatusUpdate, }, },
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications.restedStatus,
									storageKey = "maxReminder",
								}
							})

							--| Level up

							options.events.lvlUp = wt.CreateCheckbox({
								parent = panel,
								name = "LevelUp",
								title = ns.strings.options.events.notifications.lvlUp.congrats.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.lvlUp.congrats.tooltip, }, } },
								arrange = {},
								optionsData = {
									optionsKey = ns.name .. "Events",
									workingTable = RemainingXPDB.notifications.lvlUp,
									storageKey = "congrats",
								}
							})

							--| Time played

							options.events.timePlayed = wt.CreateCheckbox({
								parent = panel,
								name = "TimePlayed",
								title = ns.strings.options.events.notifications.lvlUp.timePlayed.label .. " (Soon™)",
								tooltip = { lines = { { text = ns.strings.options.events.notifications.lvlUp.timePlayed.tooltip, }, } },
								arrange = { newRow = false, },
								disabled = true --ADD time played notifications
								-- dependencies = { { frame = options.notifications.lvlUp, }, },
								-- optionsData = {
								-- 	optionsKey = addonNameSpace .. "Events",
								-- 	workingTable = db.notifications.lvlUp,
								-- 	storageKey = "timePlayed",
								-- }
							})
						end,
					})

					wt.CreatePanel({
						parent = canvas,
						name = "Logs",
						title = ns.strings.options.events.logs.title,
						description = ns.strings.options.events.logs.description,
						arrange = {},
						size = { height = 64 },
						initialize = function(panel)
							--ADD logs options
						end,
					})
				end,
			})

			--[ Addon Category ]

			options.pageManager = wt.CreateSettingsCategory(ns.name, options.main.page, {
				options.display.page,
				options.integration.page,
				options.events.page,
				options.dataManagement.page
			})


			--[[ CHAT CONTROL ]]

			chatCommands = wt.RegisterChatCommands(ns.name, { ns.chat.keyword }, {
				commands = {
					{
						command = ns.chat.commands.options,
						description = ns.strings.chat.options.description:gsub("#ADDON", ns.title),
						handler = function() options.main.page.open() end,
					},
					{
						command = ns.chat.commands.preset,
						description = ns.strings.chat.preset.description:gsub(
							"#INDEX", wt.Color(ns.chat.commands.preset .. " " .. 1, ns.colors.purple[3])
						),
						handler = function(_, parameter)
							if max then
								PrintStatus()
								return nil
							end

							return options.display.position.applyPreset(tonumber(parameter))
						end,
						onSuccess = function(i)
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.preset.response:gsub(
								"#PRESET", wt.Color(presets[i].name, ns.colors.purple[2])
							), ns.colors.blue[2]))
						end,
						onError = function()
							--Error
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.preset.unchanged, ns.colors.blue[1]))
							print(wt.Color(ns.strings.chat.preset.error:gsub("#INDEX", wt.Color(ns.chat.commands.preset .. " " .. 1, ns.colors.purple[2])), ns.colors.blue[2]))
							print(wt.Color(ns.strings.chat.preset.list, ns.colors.purple[2]))
							for j = 1, #presets, 2 do
								local list = "    " .. wt.Color(j, ns.colors.purple[3]) .. wt.Color(" - " .. presets[j].name, ns.colors.blue[3])
								if j + 1 <= #presets then list = list .. "    " .. wt.Color(j + 1, ns.colors.purple[3]) .. wt.Color(" - " .. presets[j + 1].name, ns.colors.blue[3]) end
								print(list)
							end
						end,
					},
					{
						command = ns.chat.commands.save,
						description = ns.strings.chat.reset.description:gsub("#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[3])),
						handler = function()
							UpdateCustomPreset()

							return true
						end,
						onSuccess = function() print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.save.response:gsub(
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
						onSuccess = function() print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.reset.response:gsub(
							"#CUSTOM", wt.Color(presets[1].name, ns.colors.purple[2])
						), ns.colors.blue[2])) end,
					},
					{
						command = ns.chat.commands.toggle,
						description = ns.strings.chat.toggle.description:gsub(
							"#HIDDEN", wt.Color(RemainingXPDB.display.hidden and ns.strings.chat.toggle.hidden or ns.strings.chat.toggle.notHidden, ns.colors.purple[3])
						),
						handler = function()
							--Update the DBs
							RemainingXPDB.display.hidden = not RemainingXPDB.display.hidden
							RemainingXPDB.display.hidden = RemainingXPDB.display.hidden

							--Update the GUI option in case it was open
							options.display.visibility.hidden.setState(RemainingXPDB.display.hidden)
							options.display.visibility.hidden:SetAttribute("loaded", true) --Update dependent widgets

							--Update the visibility
							wt.SetVisibility(frames.main, not (RemainingXPDB.display.hidden or max))

							return true
						end,
						onSuccess = function()
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(
								RemainingXPDB.display.hidden and ns.strings.chat.toggle.hiding or ns.strings.chat.toggle.unhiding, ns.colors.blue[2])
							)
							if max then PrintStatus() end
						end,
					},
					{
						command = ns.chat.commands.fade,
						description = ns.strings.chat.fade.description:gsub(
							"#STATE", wt.Color(RemainingXPDB.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[3])
						),
						handler = function()
							--Update the DBs
							RemainingXPDB.display.fade.enabled = not RemainingXPDB.display.fade.enabled
							RemainingXPDB.display.fade.enabled = RemainingXPDB.display.fade.enabled

							--Update the GUI option in case it was open
							options.display.fade.toggle.setState(RemainingXPDB.display.fade.enabled)
							options.display.fade.toggle:SetAttribute("loaded", true) --Update dependent widgets

							--Update the main display fade
							Fade(RemainingXPDB.display.fade.enabled)

							return true
						end,
						onSuccess = function()
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.fade.response:gsub(
								"#STATE", wt.Color(RemainingXPDB.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
							), ns.colors.blue[2]))
							if max then PrintStatus() end
						end,
					},
					{
						command = ns.chat.commands.size,
						description = ns.strings.chat.size.description:gsub(
							"#SIZE", wt.Color(ns.chat.commands.size .. " " .. ns.profileDefault.display.text.font.size, ns.colors.purple[3])
						),
						handler = function(parameter)
							local size = tonumber(parameter)
							if not size then return false end

							--Update the DBs
							RemainingXPDB.display.text.font.size = size
							RemainingXPDB.display.text.font.size = RemainingXPDB.display.text.font.size

							--Update the GUI option in case it was open
							options.display.text.font.size.setValue(size)

							--Update the font
							frames.display.text:SetFont(RemainingXPDB.display.text.font.family, RemainingXPDB.display.text.font.size, "OUTLINE")

							return true, size
						end,
						onSuccess = function(_, size)
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.size.response:gsub(
								"#VALUE", wt.Color(size, ns.colors.purple[2])
							), ns.colors.blue[2]))
							if max then PrintStatus() end
						end,
						onError = function()
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.size.unchanged, ns.colors.blue[1]))
							print(wt.Color(ns.strings.chat.size.error:gsub(
								"#SIZE", wt.Color(ns.chat.commands.size .. " " .. ns.profileDefault.display.text.font.size, ns.colors.purple[2])
							), ns.colors.blue[2]))
						end,
					},
					{
						command = ns.chat.commands.integration,
						description = ns.strings.chat.integration.description,
						handler = function()
							--Update the DBs
							RemainingXPDB.enhancement.enabled = not RemainingXPDB.enhancement.enabled
							RemainingXPDB.enhancement.enabled = RemainingXPDB.enhancement.enabled

							--Update the GUI option in case it was open
							options.integration.enhancement.toggle.setState(RemainingXPDB.enhancement.enabled)
							options.integration.enhancement.toggle:SetAttribute("loaded", true) --Update dependent widgets

							--Update the integration
							SetIntegrationVisibility(RemainingXPDB.enhancement.enabled)
							UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining)

							return true
						end,
						onSuccess = function()
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.integration.response:gsub(
								"#STATE", wt.Color(RemainingXPDB.enhancement.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
							), ns.colors.blue[2]))
							if max then PrintStatus() end
						end,
					},
					{
						command = ns.chat.commands.defaults,
						description = ns.strings.chat.defaults.description,
						handler = function() StaticPopup_Show(resetDefaultsPopup) end,
					},
				},
				colors = {
					title = ns.colors.purple[1],
					content = ns.colors.blue[1],
					command = ns.colors.purple[3],
					description = ns.colors.blue[3]
				},
				onWelcome = function()
					print(wt.Color(ns.strings.chat.help.thanks:gsub("#ADDON", wt.Color(ns.title, ns.colors.purple[1])), ns.colors.blue[1]))
					PrintStatus()
					print(wt.Color(ns.strings.chat.help.hint:gsub("#HELP_COMMAND", wt.Color("/" .. ns.chat.keyword .. " " .. ns.chat.commands.help, ns.colors.purple[3])), ns.colors.blue[3]))
					print(wt.Color(ns.strings.chat.help.move:gsub("#ADDON", ns.title), ns.colors.blue[3]))
				end,
			})

			--Welcome message
			if firstLoad then chatCommands.welcome() end


			--[[ DISPLAYS ]]

			if max then
				--Hide displays
				self:Hide()
				TurnOffIntegration()

				--Disable events
				self:UnregisterAllEvents()
			else
				--Load cross-session character data
				RemainingXPCSC.xp = RemainingXPCSC.xp or {}

				--Position
				wt.SetPosition(self, RemainingXPDB.display.position)

				--Make movable
				wt.SetMovability(self, true, {
					triggers = { frames.display.overlay, },
					modifier = "SHIFT",
					events = {
						onStop = function()
							--Save the position (for account-wide use)
							wt.CopyValues(wt.PackPosition(self:GetPoint()), RemainingXPDB.display.position)

							--Update in the SavedVariables DB
							RemainingXPDB.display.position = wt.Clone(RemainingXPDB.display.position)

							--Update the GUI options in case the window was open
							options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select)
							options.display.position.anchor.setSelected(RemainingXPDB.display.position.anchor)
							options.display.position.xOffset.setValue(RemainingXPDB.display.position.offset.x)
							options.display.position.yOffset.setValue(RemainingXPDB.display.position.offset.y)

							--Chat response
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.position.save, ns.colors.blue[1]))
						end,
						onCancel = function()
							--Reset the position
							wt.SetPosition(self, RemainingXPDB.display.position)

							--Chat response
							print(wt.Color(ns.title .. ":", ns.colors.purple[1]) .. " " .. wt.Color(ns.strings.chat.position.cancel, ns.colors.blue[1]))
							print(wt.Color(ns.strings.chat.position.error, ns.colors.blue[2]))
						end,
					},
				})

				--Main display
				SetDisplayValues(RemainingXPDB, RemainingXPDBC)

				--Integrated display
				SetIntegrationVisibility(RemainingXPDB.enhancement.enabled)
			end

			--Visibility notice
			if not self:IsVisible() then PrintStatus(true) end
		end,
		PLAYER_ENTERING_WORLD = function(self)
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")

			--XP update
			UpdateXPValues()

			--Set up displays
			ResizeDisplay(RemainingXPDB.display.background.size.width, RemainingXPDB.display.background.size.height)
			UpdateXPDisplayText()
			UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining)

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
			if RemainingXPDB.removals.xpBar then MainStatusTrackingBarContainer:Hide() end

			--Set up Edit Mode exit updates
			EditModeManagerFrame:HookScript("OnHide", function()
				--Removals
				if RemainingXPDB.removals.xpBar then MainStatusTrackingBarContainer:Hide() end
			end)
		end,
		PLAYER_XP_UPDATE = function(_, unit)
			if unit ~= "player" then return end

			--XP update
			local gainedXP, _, oldXP = UpdateXPValues()
			if oldXP == RemainingXPCSC.xp.current then return end --The event fired without actual XP gain

			--Update UI elements
			UpdateXPDisplayText()
			UpdateXPDisplaySegments()
			UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining)

			--Notification
			if RemainingXPDB.notifications.xpGained then
				print(wt.Color(ns.strings.chat.xpGained.text:gsub(
					"#AMOUNT", wt.Color(wt.FormatThousands(gainedXP), ns.colors.purple[1])
				):gsub(
					"#REMAINING", wt.Color(max and ns.strings.chat.lvlUp.disabled.reason:gsub(
						"#MAX", maxLevel
					) or ns.strings.chat.xpGained.remaining:gsub(
						"#AMOUNT", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.remaining), ns.colors.purple[3])
					):gsub(
						"#NEXT", UnitLevel("player") + 1
					), ns.colors.blue[3])
				), ns.colors.blue[1]))
			end

			--Tooltip update
			UpdateXPTooltip()
		end,
		PLAYER_LEVEL_UP = function(self, newLevel)
			max = newLevel >= maxLevel

			if max then
				self:Hide()
				TurnOffIntegration()

				--Notification
				print(wt.Color(ns.strings.chat.lvlUp.disabled.text:gsub(
					"#ADDON", wt.Color(ns.title, ns.colors.purple[1])
				):gsub(
					"#REASON", wt.Color(ns.strings.chat.lvlUp.disabled.reason:gsub(
						"#MAX", maxLevel
					), ns.colors.blue[3])
				) .. " " .. ns.strings.chat.lvlUp.congrats, ns.colors.blue[1]))
			else
				--Notification
				if RemainingXPDB.notifications.lvlUp.congrats then
					print(wt.Color(ns.strings.chat.lvlUp.text:gsub(
						"#LEVEL", wt.Color(newLevel, ns.colors.purple[1])
					) .. " " .. wt.Color(ns.strings.chat.lvlUp.congrats, ns.colors.purple[3]), ns.colors.blue[1]))
					if RemainingXPDB.notifications.lvlUp.timePlayed then RequestTimePlayed() print('HEY') end
				end

				--Tooltip update
				UpdateXPTooltip()
			end
		end,
		UPDATE_EXHAUSTION = function()
			--Update Rested XP
			local _, gainedRestedXP = UpdateXPValues()
			if gainedRestedXP <= 0 then return end

			--Update UI elements
			UpdateXPDisplayText()
			UpdateXPDisplaySegments()
			UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining)

			--Notification
			if RemainingXPDB.notifications.restedXP.gained and not (RemainingXPDB.notifications.restedXP.significantOnly and gainedRestedXP <= math.ceil(RemainingXPCSC.xp.needed / 1000)) then
				print(wt.Color(ns.strings.chat.restedXPGained.text:gsub(
						"#AMOUNT", wt.Color(gainedRestedXP, ns.colors.purple[1])
					):gsub(
						"#TOTAL", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.rested), ns.colors.purple[1])
					):gsub(
						"#PERCENT", wt.Color(ns.strings.chat.restedXPGained.percent:gsub(
							"#VALUE", wt.Color(wt.FormatThousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current) * 100000) / 1000, 3) .. "%%%%", ns.colors.purple[3])
						), ns.colors.blue[3])
					), ns.colors.blue[1])
				)
			end

			--Tooltip update
			UpdateXPTooltip()
		end,
		PLAYER_UPDATE_RESTING = function()
			--Notification
			if RemainingXPDB.notifications.restedXP.gained and RemainingXPDB.notifications.restedXP.accumulated and not IsResting() then
				print((RemainingXPDB.notifications.restedStatus.update and (wt.Color(ns.strings.chat.restedStatus.notResting, ns.colors.purple[1]) .. " ") or "") .. (
					(RemainingXPCSC.xp.accumulatedRested or 0) > 0 and wt.Color(ns.strings.chat.restedXPAccumulated.text:gsub(
						"#AMOUNT", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.accumulatedRested), ns.colors.purple[1])
					):gsub(
						"#TOTAL", wt.Color(wt.FormatThousands(RemainingXPCSC.xp.rested), ns.colors.purple[1])
					):gsub(
						"#PERCENT", wt.Color(ns.strings.chat.restedXPAccumulated.percent:gsub(
							"#VALUE", wt.Color(wt.FormatThousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.needed - RemainingXPCSC.xp.current) * 1000000) / 10000, 4) .. "%%%%", ns.colors.purple[3])
						):gsub(
							"#NEXT", wt.Color(UnitLevel("player") + 1, ns.colors.purple[3])
						), ns.colors.blue[3])
					), ns.colors.blue[1]) or wt.Color(ns.strings.chat.restedXPAccumulated.zero, ns.colors.blue[1])
				))
			end

			--Initiate or remove the cross-session Rested XP accumulation tracking variable
			SetRestedAccumulation(RemainingXPDB.notifications.restedXP.gained and RemainingXPDB.notifications.restedXP.accumulated)

			--Tooltip update
			UpdateXPTooltip()
		end,
		UNIT_ENTERING_VEHICLE = function(self, unit, swapUI) if unit == "player" and swapUI then
			frames.integration.frame:Hide()
			self:Hide()
		end end,
		UNIT_EXITING_VEHICLE = function(self, unit) if unit == "player" then
			if RemainingXPDB.enhancement.enabled then frames.integration.frame:Show() end
			if not RemainingXPDB.display.hidden then self:Show() end
		end end,
		PET_BATTLE_OPENING_START = function(self)
			frames.integration.frame:Hide()
			self:Hide()
		end,
		PET_BATTLE_CLOSE = function(self)
			if RemainingXPDB.enhancement.enabled then frames.integration.frame:Show() end
			if not RemainingXPDB.display.hidden then self:Show() end
		end,
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
						OnEnter = function() if RemainingXPDB.display.fade.enabled then Fade(false) end end,
						onLeave = function() if RemainingXPDB.display.fade.enabled then Fade(true) end end,
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
				relativeTo = MainStatusTrackingBarContainer,
				relativePoint = "BOTTOM",
			},
			keepInBounds = true,
			frameStrata = "HIGH",
			keepOnTop = true,
			size = { width = MainStatusTrackingBarContainer:GetWidth(), height = 17 },
			events = {
				OnEnter = function()
					--Show the enhanced XP text on the default XP bar
					UpdateIntegrationText(true, false)

					--Handling trial accounts & Banked XP
					local label = XPBAR_LABEL
					if GameLimitedMode_IsActive() then
						local rLevel = GetRestrictedAccountData()
						if UnitLevel("player") >= rLevel then
							if RemainingXPCSC.xp.banked > 0 then
								GameTooltip:SetOwner(MainStatusTrackingBarContainer, "ANCHOR_RIGHT", 0, -14)
								local text = TRIAL_CAP_BANKED_XP_TOOLTIP
								if RemainingXPCSC.xp.bankedLevels > 0 then text = TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(RemainingXPCSC.xp.bankedLevels) end
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
					UpdateIntegrationText(RemainingXPDB.enhancement.keep, RemainingXPDB.enhancement.remaining)

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
						offset = { y = 3 }
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