--| Namespace

---@class addonNamespace
local ns = select(2, ...)

--| Shortcuts

local cr = C_ColorUtil.WrapTextInColor

---@type toolbox
local wt = ns[C_AddOns.GetAddOnMetadata(ns.name, "X-WidgetTools-AddToNamespace")]

---@type widgetToolsResources
local rs = WidgetTools.resources

---@type widgetToolsUtilities
local us = WidgetTools.utilities

--| Locals

---@class main
local main = {}

---@class display
local display = { frame = {} }

---@class integration
local integration = {}

---@class events
local events = {}

---@class options
local options = {}

---@type profilemanager|profilesPage|{ data: profileData }
local profiles

---@type chatCommandManager
local chatCommands

local tooltip = wt.CreateGameTooltip(ns.name)

--| Properties

local maxLevel = GetMaxPlayerLevel()
local atMax = UnitLevel("player") >= maxLevel


--[[ UTILITIES ]]

--[ Settings ]

--Make sure both the display text & background can't be turned off while the display is not set as hidden
local function EnsureVisibility()
	if not profiles.data.display.background.visible then
		options.display.text.visible.setEnabled(false, true)
		options.display.text.visible.widget:EnableMouse(false)
		options.display.text.visible.frame:SetAlpha(0.4)
	else
		if not profiles.data.display.hidden then
			options.display.text.visible.setEnabled(true, true)
			options.display.text.visible.widget:EnableMouse(true)
		end
		options.display.text.visible.frame:SetAlpha(1)
	end
	if not profiles.data.display.text.visible then
		options.display.background.visible.setEnabled(false, true)
		options.display.background.visible.widget:EnableMouse(false)
		options.display.background.visible.frame:SetAlpha(0.4)
	else
		if not profiles.data.display.hidden then
			options.display.background.visible.setEnabled(true, true)
			options.display.background.visible.widget:EnableMouse(true)
		end
		options.display.background.visible.frame:SetAlpha(1)
	end
end

--[ Chat Control ]

---Print visibility info
---@param load? boolean ***Default:*** false
local function PrintStatus(load)
	if load == true and not profiles.data.notifications.statusNotice.enabled then return end

	local status = cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(
		display.frame:IsVisible() and ns.strings.chat.status.visible or ns.strings.chat.status.hidden, ns.colors.blue[1]
	):gsub(
		"#FADE", cr(ns.strings.chat.status.fade:gsub(
			"#STATE", cr(profiles.data.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
		), ns.colors.blue[2])
	)

	if atMax then if profiles.data.notifications.statusNotice.maxReminder then
		status = cr(ns.strings.chat.status.disabled:gsub(
			"#ADDON", cr(ns.title, ns.colors.purple[1])
		) .." " ..  cr(ns.strings.chat.status.max:gsub(
			"#MAX", cr(tostring(maxLevel), ns.colors.purple[2])
		), ns.colors.blue[2]), ns.colors.blue[1])
	else return end end

	print(status)
end

--[ XP Update ]

---Initiate or remove the cross-session variable storing the Rested XP accumulation while inside a Rested Area
---@param enabled boolean
local function SetRestedAccumulation(enabled)
	if not IsResting() then RemainingXPCSC.xp.accumulatedRested = nil return end

	if RemainingXPCSC.xp.accumulatedRested == nil then RemainingXPCSC.xp.accumulatedRested = 0 end

	--| Chat notifications

	if not enabled then return end
	if not profiles.data.notifications.restedStatus.update then return end

	local isMaxed = us.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.required, 3) >= 1.5
	local isMaxedLastLevel = UnitLevel("player") == maxLevel - 1 and us.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.remaining, 3) >= 1

	--Stared resting status update
	print(cr(ns.strings.chat.restedStatus.resting, ns.colors.purple[1]) .. " " .. cr(
		(isMaxed or isMaxedLastLevel) and ns.strings.chat.restedStatus.notAccumulating or ns.strings.chat.restedStatus.accumulating, ns.colors.blue[1]
	))

	--Max Rested XP reminder
	if profiles.data.notifications.restedStatus.maxReminder then
		if isMaxed then
			print(cr(ns.strings.chat.restedStatus.atMax:gsub("#PERCENT", cr("150%%", ns.colors.purple[2])), ns.colors.blue[2]))
		elseif isMaxedLastLevel then
			print(cr(ns.strings.chat.restedStatus.atMaxLast:gsub("#PERCENT", cr("100%%", ns.colors.purple[2])), ns.colors.blue[2]))
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
	local oldXP = RemainingXPCSC.xp.gathered or UnitXP("player")
	local oldNeededXP = RemainingXPCSC.xp.required or UnitXPMax("player")
	local oldRestedXP = RemainingXPCSC.xp.rested or GetXPExhaustion() or 0

	--| Update the XP values

	RemainingXPCSC.xp.gathered = UnitXP("player")
	RemainingXPCSC.xp.required = UnitXPMax("player")
	RemainingXPCSC.xp.rested = GetXPExhaustion() or 0
	RemainingXPCSC.xp.remaining = RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered


	local gainedXP = oldXP < RemainingXPCSC.xp.gathered and RemainingXPCSC.xp.gathered - oldXP or oldNeededXP - oldXP + RemainingXPCSC.xp.gathered
	local gainedRestedXP = RemainingXPCSC.xp.rested - oldRestedXP

	--Accumulating Rested XP
	if gainedRestedXP > 0 and RemainingXPCSC.xp.accumulatedRested ~= nil and IsResting() then --CHECK condition
		RemainingXPCSC.xp.accumulatedRested = RemainingXPCSC.xp.accumulatedRested + gainedRestedXP
	end

	return gainedXP, gainedRestedXP, oldXP, oldRestedXP, oldNeededXP
end

--Update the position, width and visibility of the main XP display bar segments with the current XP values
local function UpdateXPDisplaySegments()
	--Current XP segment
	display.xp:SetWidth(RemainingXPCSC.xp.gathered / RemainingXPCSC.xp.required * display.frame:GetWidth())

	--Rested XP segment
	if RemainingXPCSC.xp.rested == 0 then display.rested:Hide() else
		display.rested:Show()
		if display.xp:GetWidth() == 0 then display.rested:SetPoint("LEFT") else display.rested:SetPoint("LEFT", display.xp, "RIGHT") end --CHECK
		display.rested:SetWidth((RemainingXPCSC.xp.gathered + RemainingXPCSC.xp.rested > RemainingXPCSC.xp.required and RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered or RemainingXPCSC.xp.rested) / RemainingXPCSC.xp.required * display.frame:GetWidth()) --CHECK if can bee simplified
	end
end

--Update the main XP display bar segments and text with the current XP values
local function UpdateXPDisplayText()
	local text = "" --REPLACE with pre-colored xpText
	local rc = us.Clone(profiles.data.display.font.colors.rested)

	if profiles.data.display.text.details then
		text = cr(us.Thousands(RemainingXPCSC.xp.gathered), profiles.data.display.font.colors.gathered)
		text = text .. " / " .. cr(us.Thousands(RemainingXPCSC.xp.required), profiles.data.display.font.colors.required)
		text = text .. " (" .. cr(us.Thousands(RemainingXPCSC.xp.remaining), profiles.data.display.font.colors.remaining) .. ")"
		if RemainingXPCSC.xp.rested > 0 then
			text = text .. " + " .. cr(us.Thousands(RemainingXPCSC.xp.rested), rc) .. " (" .. cr(us.Thousands(
				math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered) * 10000) / 100
			) .. "%", wt.AdjustGamma(rc)) ..  ")"
		end
	else text = cr(us.Thousands(RemainingXPCSC.xp.remaining), profiles.data.display.font.colors.remaining) end

	display.text:SetText(text)
end

---Update the default XP bar integration display with the current XP values
---@param remaining boolean Whether or not only the remaining XP should be visible when the text is always shown
local function UpdateIntegrationText(keep, remaining)
	if not integration.frame:IsVisible() then return end

	local rc = us.Clone(profiles.data.display.font.colors.rested)

	wt.SetVisibility(integration.text, keep)

	if remaining and not integration.frame:IsMouseOver() then integration.text:SetText(us.Thousands(RemainingXPCSC.xp.remaining)) return end

	integration.text:SetText(
		ns.strings.xpBar.text:gsub( --REPLACE with pre-colored xpText
			"#GATHERED", cr(us.Thousands(RemainingXPCSC.xp.gathered), profiles.data.display.font.colors.gathered)
		):gsub(
			"#NEEDED", cr(us.Thousands(RemainingXPCSC.xp.required), profiles.data.display.font.colors.required)
		):gsub(
			"#REMAINING", cr(us.Thousands(RemainingXPCSC.xp.remaining), profiles.data.display.font.colors.remaining)
		) .. (
			RemainingXPCSC.xp.rested > 0 and (" + " .. cr(ns.strings.xpBar.rested:gsub(
				"#VALUE", us.Thousands(RemainingXPCSC.xp.rested)
			):gsub(
				"#PERCENT", cr(us.Thousands(
					math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered) * 10000) / 100
				) .. "%%", wt.AdjustGamma(rc))
			), rc)) or ""
		)
	)
end

---Assemble the detailed text lines for xp tooltip
---@return tooltipLineData[] textLines
local function GetXPTooltipTextlines()
	local textLines = {
		{ text = ns.strings.xpTooltip.text, },

		--| Gathered XP

		{
			text = "\n" .. ns.strings.xpTooltip.value:gsub("#VALUE_TYPE", ns.strings.xpValues.gathered):gsub(
				"#VALUE", cr(us.Thousands(RemainingXPCSC.xp.gathered), ns.colors.purple[2])
			),
			font = GameTooltipText,
			color = ns.colors.purple[1],
		},
		{
			text = ns.strings.xpTooltip.percent:gsub("#VALUE_TYPE", ns.strings.xpValues.required):gsub(
				"#PERCENT", cr(us.Thousands(math.floor(RemainingXPCSC.xp.gathered / RemainingXPCSC.xp.required * 10000) / 100, 3) .. "%%", ns.colors.purple[2])
			),
			color = ns.colors.purple[3],
		},

		--| Remaining XP

		{
			text = "\n" .. ns.strings.xpTooltip.value:gsub("#VALUE_TYPE", ns.strings.xpValues.remaining):gsub(
				"#VALUE", cr(us.Thousands(RemainingXPCSC.xp.remaining), ns.colors.rose[2])
			),
			font = GameTooltipText,
			color = ns.colors.rose[1],
		},
		{
			text = ns.strings.xpTooltip.percent:gsub("#VALUE_TYPE", ns.strings.xpValues.required):gsub(
				"#PERCENT", cr(us.Thousands(math.floor((RemainingXPCSC.xp.remaining / RemainingXPCSC.xp.required) * 10000) / 100, 3) .. "%%", ns.colors.rose[2])
			),
			color = ns.colors.rose[3],
		},

		--| Required XP

		{
			text = "\n" .. ns.strings.xpTooltip.value:gsub("#VALUE_TYPE", ns.strings.xpValues.required):gsub(
				"#VALUE", cr(us.Thousands(RemainingXPCSC.xp.required), ns.colors.peach[2])
			),
			font = GameTooltipText,
			color = ns.colors.peach[1],
		},
		{
			text = ns.strings.xpTooltip.requiredLevelUp:gsub(
				"#LEVEL", cr(tostring(UnitLevel("player") + 1), ns.colors.peach[2])
			),
			color = ns.colors.peach[3],
		},

		--| Playtime

		--Playtime --ADD time played info
		-- {
		-- 	text = "\n" .. ns.strings.xpTooltip.timeSpent:gsub("#TIME", "?") .. " (Soon™)",
		-- },
	}

	--| Rested XP

	if RemainingXPCSC.xp.rested > 0 then
		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.value:gsub("#VALUE_TYPE", ns.strings.xpValues.rested):gsub(
				"#VALUE", cr(us.Thousands(RemainingXPCSC.xp.rested), ns.colors.blue[2])
			),
			font = GameTooltipText,
			color = ns.colors.blue[1],
		})

		table.insert(textLines, {
			text = ns.strings.xpTooltip.percent:gsub("#VALUE_TYPE", ns.strings.xpValues.remaining):gsub(
				"#PERCENT", cr(us.Thousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered) * 10000) / 100, 3) .. "%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})

		table.insert(textLines, {
			text = ns.strings.xpTooltip.percent:gsub("#VALUE_TYPE", ns.strings.xpValues.required):gsub(
				"#PERCENT", cr(us.Thousands(math.floor(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.required * 10000) / 100, 3) .. "%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})

		--| Description

		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.restedMax:gsub(
				"#PERCENT_MAX", cr("150%%", ns.colors.blue[2])
			):gsub(
				"#PERCENT_REMAINING", cr("100%%", ns.colors.blue[2])
			):gsub(
				"#LEVEL", cr(tostring(maxLevel - 1), ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})

		table.insert(textLines, {
			text = "\n" .. ns.strings.xpTooltip.restedDescription:gsub(
				"#PERCENT", cr("200%%", ns.colors.blue[2])
			),
			color = ns.colors.blue[3],
		})
	end

	--| Resting status

	if IsResting() then
		table.insert(textLines, {
			text = "\n" .. ns.strings.chat.restedStatus.resting,
			font = GameTooltipText,
			color = ns.colors.blue[1],
		})

		local isMaxed = us.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.required, 3) >= 1.5
		local isMaxedLastLevel = UnitLevel("player") == maxLevel - 1 and us.Round(RemainingXPCSC.xp.rested / RemainingXPCSC.xp.remaining, 3) >= 1

		table.insert(textLines, {
			text = (isMaxed or isMaxedLastLevel) and (ns.strings.xpTooltip.restedAtMax) or ns.strings.chat.restedStatus.accumulating,
			color = ns.colors.blue[2],
		})
	end

	--| Accumulated Rested XP

	if (RemainingXPCSC.xp.accumulatedRested or 0) > 0 then table.insert(textLines, {
		text = "\n" .. ns.strings.xpTooltip.accumulated:gsub(
			"#VALUE", cr(us.Thousands(RemainingXPCSC.xp.accumulatedRested or 0), ns.colors.blue[2])
		),
		color = ns.colors.blue[3],
	}) end

	--| Hints

	table.insert(textLines, {
		text = "\n" .. ns.strings.xpTooltip.hintOptions,
		font = GameFontNormalSmall,
		color = ns.colors.grey[1],
	})

	if display.border:IsMouseOver() then table.insert(textLines, {
		text = ns.strings.xpTooltip.hintMove:gsub("#SHIFT", ns.strings.keys.shift),
		font = GameFontNormalSmall,
		color = ns.colors.grey[1],
	}) end

	return textLines
end

--Update the text of the xp tooltip
local function UpdateXPTooltip()
	if not tooltip:IsVisible() then return end

	local owner = integration.frame:IsMouseOver() and integration.frame or display.border:IsMouseOver() and display.border or nil --CHECK if required
	if owner then wt.UpdateTooltip(owner, { lines = GetXPTooltipTextlines(), }) end
end

--[ Main XP Display ]

---Fade the main display in or out
---@param state? boolean ***Default:*** **profiles.data.display.fade.enabled**
local function Fade(state)
	if state == nil then state = profiles.data.display.fade.enabled end

	--| Text

	local r, g, b, a = wt.UnpackColor(profiles.data.display.font.colors.base)
	display.text:SetTextColor(r, g, b, (a or 1) * (state and 1 - profiles.data.display.fade.text or 1))

	--| Background

	if not profiles.data.display.background.visible then return end

	--Backdrop
	r, g, b, a = wt.UnpackColor(profiles.data.display.background.colors.bg)
	display.frame:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - profiles.data.display.fade.background or 1))

	--Current XP segment
	r, g, b, a = wt.UnpackColor(profiles.data.display.background.colors.gathered)
	display.xp:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - profiles.data.display.fade.background or 1))

	--Rested XP segment
	r, g, b, a = wt.UnpackColor(profiles.data.display.background.colors.rested)
	display.rested:SetBackdropColor(r, g, b, (a or 1) * (state and 1 - profiles.data.display.fade.background or 1))

	--Border & text overlay
	r, g, b, a = wt.UnpackColor(profiles.data.display.background.colors.border)
	display.border:SetBackdropBorderColor(r, g, b, (a or 1) * (state and 1 - profiles.data.display.fade.background or 1))
end

---Set the size of the main display elements
---@param width number
---@param height number
local function SetDisplaySize(width, height)
	--Background
	display.frame:SetSize(width, height)

	--XP bar segments
	display.xp:SetHeight(height)
	display.rested:SetHeight(height)
	UpdateXPDisplaySegments()

	--Border & text overlay
	display.border:SetSize(width, height)
end

---Set the backdrop of the main display elements
---@param enabled boolean Whether to add or remove the backdrop elements of the main display
---@param backdropColors displayBackgroundColorData
local function SetDisplayBackdrop(enabled, backdropColors)
	if not enabled then
		display.frame:SetBackdrop(nil)
		display.xp:SetBackdrop(nil)
		display.rested:SetBackdrop(nil)
		display.border:SetBackdrop(nil)
	else
		--Background
		display.frame:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		display.frame:SetBackdropColor(wt.UnpackColor(backdropColors.bg))

		--Current XP segment
		display.xp:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		display.xp:SetBackdropColor(wt.UnpackColor(backdropColors.gathered))

		--Rested XP segment
		display.rested:SetBackdrop({
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true, tileSize = 5,
		})
		display.rested:SetBackdropColor(wt.UnpackColor(backdropColors.rested))

		--Border & text overlay
		display.border:SetBackdrop({
			edgeFile = "Interface/ChatFrame/ChatFrameBackground",
			edgeSize = 1,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		display.border:SetBackdropBorderColor(wt.UnpackColor(backdropColors.border))
	end
end

---Set the visibility, backdrop, font family, size and color of the main display to the currently saved values
---@param data table Profile data table to set the main display values from
local function SetDisplayValues(data)
	--Position
	display.frame:SetClampedToScreen(data.display.keepInBounds)

	--Visibility
	display.frame:SetFrameStrata(data.display.layer.strata)
	wt.SetVisibility(display.frame, not data.display.hidden)

	--Backdrop elements
	SetDisplayBackdrop(data.display.background.visible, data.display.background.colors)

	--Font & text
	display.text:SetFont(data.display.font.path, data.display.font.size, "OUTLINE")
	display.text:SetTextColor(wt.UnpackColor(data.display.font.colors.base))
	display.text:SetJustifyH(data.display.font.alignment)
	wt.SetPosition(display.text, {
		anchor = data.display.font.alignment,
		offset = { x = 2 * (data.display.font.alignment == "CENTER" and 0 or data.display.font.alignment == "RIGHT" and -1 or 1), },
	})

	--Fade
	Fade(data.display.fade.enabled)
end

--[ Integrated Display ]

--"xpBarText" CVar snapshot
local alwaysShow = C_CVar.GetCVar("xpBarText")

--Turn off the integrated display and hide the frame
local function TurnOffIntegration()
	integration.frame:Hide()
	C_CVar.SetCVar("xpBarText", alwaysShow)
end

---Set the visibility of the integrated display frame
---@param enabled boolean Whether or not the default XP bar integration is enabled
local function SetIntegrationVisibility(enabled)
	if enabled and not atMax then
		integration.frame:Show()
		C_CVar.SetCVar("xpBarText", 0)
	else TurnOffIntegration() end
end


--[[ INITIALIZATION ]]

--Create main addon frame & display frames
main.frame = wt.CreateFrame({
	name = ns.name,
	keepOnTop = true,
	onEvent = {
		ADDON_LOADED = function(self, addon)
			if addon ~= ns.name then return end

			self:UnregisterEvent("ADDON_LOADED")


			--[[ DATA ]]

			---@type database_warband
			RemainingXPDB = RemainingXPDB or {}

			---@type database_character
			RemainingXPDBC = RemainingXPDBC or {}

			---@type variables_warband
			RemainingXPCS = us.Fill(RemainingXPCS, {
				compactBackup = true,
				keepInPlace = true,
			})

			---@type variables_character
			RemainingXPCSC = RemainingXPCSC or {}

			---@type profilemanager|profilesPage|{ data: profileData }
			profiles = wt.CreateProfilemanager(RemainingXPDB, RemainingXPDBC, ns.profileDefault, {
				valueChecker = function(key, value) if type(value) == "number" then
					if key == "size" then return value > 0 end
					if key == "r" or key == "g" or key == "b" or key == "a" then return value >= 0 and value <= 1 end
					if key == "anchor" then return false end
				end return true end,
				recoveryMap = function(data) return {
					["hidden"] = { saveTo = data.display, saveKey = "hidden" },
					["customPreset.position.point"] = { saveTo = data.customPreset.position, saveKey = "anchor" },
					["position.point"] = { saveTo = data.display.position, saveKey = "anchor" },
					["display.position.point"] = { saveTo = data.display.position, saveKey = "anchor" },
					["appearance.frameStrata"] = { saveTo = data.display.layer, saveKey = "strata" },
					["display.visibility.frameStrata"] = { saveTo = data.display.layer, saveKey = "strata" },
					["text.font.family"] = { saveTo = data.display.font, saveKey = "path" },
					["display.font.family"] = { saveTo = data.display.font, saveKey = "path" },
					["text.font.size"] = { saveTo = data.display.font, saveKey = "size" },
					["text.alignment"] = { saveTo = data.display.font, saveKey = "alignment" },
					["text.font.color.r"] = { saveTo = data.display.font.colors.base, saveKey = "r" },
					["text.font.color.g"] = { saveTo = data.display.font.colors.base, saveKey = "g" },
					["text.font.color.b"] = { saveTo = data.display.font.colors.base, saveKey = "b" },
					["text.font.color.a"] = { saveTo = data.display.font.colors.base, saveKey = "a" },
					["background.size.width"] = { saveTo = data.display.background.size, saveKey = "w" },
					["background.size.height"] = { saveTo = data.display.background.size, saveKey = "h" },
					["appearance.backdrop.visible"] = { saveTo = data.display.background, saveKey = "visible" },
					["appearance.backdrop.color.r"] = { saveTo = data.display.background.colors.bg, saveKey = "r" },
					["appearance.backdrop.color.g"] = { saveTo = data.display.background.colors.bg, saveKey = "g" },
					["appearance.backdrop.color.b"] = { saveTo = data.display.background.colors.bg, saveKey = "b" },
					["appearance.backdrop.color.a"] = { saveTo = data.display.background.colors.bg, saveKey = "a" },
					["mouseover"] = { saveTo = data.display.fade, saveKey = "enabled" },
					["display.visibility.fade"] = { saveTo = data.display.fade, saveKey = "enabled" },
					["enhancement.enabled"] = { saveTo = data.integration, saveKey = "enabled" },
					["enhancement.keep"] = { saveTo = data.integration, saveKey = "keep" },
					["enhancement.remaining"] = { saveTo = data.integration, saveKey = "remaining" },
					["removals.statusBars"] = { saveTo = data.integration, saveKey = "hideXPBar" },
					["removals.xpBar"] = { saveTo = data.integration, saveKey = "hideXPBar" },
					["notifications.maxReminder"] = { saveTo = data.notifications.statusNotice, saveKey = "maxReminder" },
				} end,
				listeners = {
					activated = { { handler = function(_, _, title, success, user) if success and user then
						display.settings.load(true)
						integration.settings.load(true)
						events.settings.load(true)
						profiles.settings.load(true)

						chatCommands.print(ns.strings.chat.profile.response:gsub("#PROFILE", cr(title, ns.colors.blue[3])))
					end end, }, },
					deleted = { { handler = function(_, success, _, title) if success then
						chatCommands.print(ns.strings.chat.default.response:gsub("#PROFILE", cr(title, ns.colors.blue[3])))
					end end, }, },
					reset = { { handler = function (_, success, _, title) if success then
						chatCommands.print(ns.strings.chat.reset.response:gsub("#PROFILE", cr(title, ns.colors.blue[3])))
					end end, }, },
				},
				onRecovery = function(data) if not data.display.text.visible and not data.display.background.visible then
					data.display.hidden = true
					data.display.text.visible = true
					data.display.background.visible = true
				end end,
			})


			--[[ SETTINGS ]]

			main.settings = wt.CreateAboutPage(ns.name, {
				register = true,
				name = "Main",
				description = ns.strings.options.main.description:gsub("#ADDON", ns.title),
				changelog = ns.changelog
			})

			--[ XP Display ]

			display.settings = wt.CreateSettingsPage(ns.name, {
				register = main.settings,
				name = "Display",
				title = ns.strings.options.display.title,
				description = ns.strings.options.display.description:gsub("#ADDON", ns.title),
				scroll = {},
				dataManagement = {
					category = ns.name .. "Display",
					keys = {
						"Visibility",
						"Position",
						"Text",
						"Font",
						"Background",
						"Fade",
					},
				},
				onLoad = EnsureVisibility,
				onSave = function()
					if not atMax then return end

					display.frame:Hide()

					if profiles.data.notifications.statusNotice.maxReminder and atMax then PrintStatus() end
				end,
				onDefault = function(user)
					-- ResetCustomPreset() --REPLACE

					if not user then return end

					--Notification
					-- print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.reset.response:gsub(
					-- 	"#CUSTOM", cr(presets[1].name, ns.colors.purple[3]) --REPLACE
					-- ), ns.colors.blue[3]))
					-- print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.default.response:gsub(
					-- 	"#CATEGORY", cr(ns.strings.options.display.title, ns.colors.purple[3])
					-- ), ns.colors.blue[3]))
				end,
				arrangement = {},
				initialize = function(canvas, _, _, category, keys)
					options.display = {}


					--[[ VISIBILITY ]]

					local visibilityHiddenDependency

					wt.CreatePanel({
						parent = canvas,
						name = keys[1],
						title = ns.strings.options.display.title,
						description = ns.strings.options.display.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key)
							local hidden = wt.CreateCheckbox({
								parent = panel,
								name = "Hidden",
								title = ns.strings.options.display.visibility.hidden.label,
								tooltip = { lines = { { text = ns.strings.options.display.visibility.hidden.tooltip:gsub("#ADDON", ns.title), }, } },
								arrange = {},
								getData = function() return profiles.data.display.hidden end,
								saveData = function(value) profiles.data.display.hidden = value end,
								default = ns.profileDefault.display.hidden,
								dataManagement = {
									category = category,
									key = key,
									onChange = {
										DisplayToggle = function() wt.SetVisibility(display.frame, not (profiles.data.display.hidden or atMax)) end,
										EnsureVisibility = EnsureVisibility,
									},
								},
							})

							visibilityHiddenDependency = { frame = hidden, evaluate = function(state) return not state end }

							local status = wt.CreateCheckbox({
								parent = panel,
								name = " StatusNotice",
								title = ns.strings.options.display.visibility.statusNotice.label,
								tooltip = { lines = { { text = ns.strings.options.display.visibility.statusNotice.tooltip:gsub("#ADDON", ns.title), }, } },
								arrange = { wrap = false, },
								getData = function() return profiles.data.notifications.statusNotice.enabled end,
								saveData = function(value) profiles.data.notifications.statusNotice.enabled = value end,
								default = ns.profileDefault.notifications.statusNotice.enabled,
								dataManagement = {
									category = category,
									key = key,
								},
							})

							options.display.visibility = {
								hidden = hidden,
								status = status,
								maxReminder = wt.CreateCheckbox({
									parent = panel,
									name = "MaxReminder",
									title = ns.strings.options.display.visibility.maxReminder.label,
									tooltip = { lines = { { text = ns.strings.options.display.visibility.maxReminder.tooltip:gsub("#ADDON", ns.title), }, } },
									arrange = { wrap = false, },
									dependencies = { { frame = status, }, },
									getData = function() return profiles.data.notifications.statusNotice.maxReminder end,
									saveData = function(value) profiles.data.notifications.statusNotice.maxReminder = value end,
									default = ns.profileDefault.notifications.statusNotice.maxReminder,
									dataManagement = {
										category = category,
										key = key,
									},
								}),
							}
						end,
					})


					--[[ POSITION ]]

					options.display.position = wt.CreatePositionOptions(ns.name, display.frame, function()
						return profiles.data.display
					end, ns.profileDefault.display, RemainingXPCS, {
						canvas = canvas,
						frameName = ns.strings.options.display.referenceName,
						presets = {
							items = {
								{ title = CUSTOM, }, --Custom
								{
									title = ns.strings.presets[1], --XP Bar Replacement
									data = {
										position = {
											anchor = "BOTTOM",
											relativePoint = "BOTTOM",
											offset = { x = 0, y = 40.5 }
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
											keepOnTop = false,
										},
										background = {
											visible = true,
											size = { w = 1014, h = 10 },
										},
									},
								},
								{
									title = ns.strings.presets[2], --XP Bar Left Text
									data = {
										position = {
											anchor = "BOTTOM",
											relativePoint = "BOTTOM",
											offset = { x = -485, y = 40.5 }
										},
										keepInBounds = true,
										layer = {
											strata = "HIGH",
											keepOnTop = false,
										},
										background = {
											visible = false,
											size = { w = 64, h = 10 },
										},
									},
								},
								{
									title = ns.strings.presets[3], --XP Bar Right Text
									data = {
										position = {
											anchor = "BOTTOM",
											relativePoint = "BOTTOM",
											offset = { x = 485, y = 40.5 }
										},
										keepInBounds = true,
										layer = {
											strata = "HIGH",
											keepOnTop = false,
										},
										background = {
											visible = false,
											size = { w = 64, h = 10 },
										},
									},
								},
								{
									title = ns.strings.presets[4], --Player Frame Bar Above
									data = {
										position = {
											anchor = "TOPRIGHT",
											relativeTo = PlayerFrame,
											relativePoint = "TOPRIGHT",
											offset = { x = -8, y = -5.5 }
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
											keepOnTop = false,
										},
										background = {
											visible = true,
											size = { w = 124, h = 16 },
										},
									},
								},
								{
									title = ns.strings.presets[5], --Player Frame Text Under
									data = {
										position = {
											anchor = "BOTTOMLEFT",
											relativeTo = PlayerFrame,
											relativePoint = "BOTTOMLEFT",
											offset = { x = 22, y = 2 }
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
											keepOnTop = false,
										},
										background = {
											visible = false,
											size = { w = 104, h = 16 },
										},
									},
								},
								{
									title = ns.strings.presets[6], --Objective Tracker Bar
									data = {
										position = {
											anchor = "TOPLEFT",
											relativeTo = WatchFrame,
											relativePoint = "TOPLEFT",
											offset = { x = 30, y = -5 }
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
											keepOnTop = false,
										},
										background = {
											visible = true,
											size = { w = 174, h = 24 },
										},
									},
								},
								{
									title = ns.strings.presets[7], --Bottom-Left Chunky Bar
									data = {
										position = {
											anchor = "BOTTOMLEFT",
											relativePoint = "BOTTOMLEFT",
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
											keepOnTop = false,
										},
										background = {
											visible = true,
											size = { w = 154, h = 34 },
										},
									},
								},
								{
									title = ns.strings.presets[8], --Bottom-Right Chunky Bar
									data = {
										position = {
											anchor = "BOTTOMRIGHT",
											relativePoint = "BOTTOMRIGHT",
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
											keepOnTop = false,
										},
										background = {
											visible = true,
											size = { w = 154, h = 34 },
										},
									},
								},
								{
									title = ns.strings.presets[9], --Top-Center Long Bar
									data = {
										position = {
											anchor = "TOP",
											relativePoint = "TOP",
											offset = { x = 0, y = 3 },
										},
										keepInBounds = true,
										layer = {
											strata = "MEDIUM",
										},
										background = {
											visible = true,
											size = { w = 980, h = 8 },
										},
									},
								},
							},
							onPreset = function(preset)
								options.display.background.visible.setData(preset.data.background.visible)
								options.display.background.size.w.setData(preset.data.background.size.w)
								options.display.background.size.h.setData(preset.data.background.size.h)

								--Make sure the speed display is visible
								options.display.visibility.hidden.setData(false)
								if not preset.data.background.visible then options.display.text.visible.setData(true) end

								chatCommands.print(ns.strings.chat.preset.response:gsub("#PRESET", cr(preset.title, ns.colors.blue[3])))
							end,
							custom = {
								getData = function() return profiles.data.customPreset end,
								defaultsTable = ns.profileDefault.customPreset,
								onSave = function() chatCommands.print(ns.strings.chat.save.response:gsub("#CUSTOM", cr(CUSTOM, ns.colors.blue[3]))) end,
								onReset = function() chatCommands.print(ns.strings.chat.reset.response:gsub("#CUSTOM", cr(CUSTOM, ns.colors.blue[3]))) end,
							}
						},
						setMovable = {
							triggers = { display.border },
							events = {
								onStop = function() chatCommands.print(ns.strings.chat.position.save) end,
								onCancel = function()
									chatCommands.print(ns.strings.chat.position.cancel)
									print(cr(ns.strings.chat.position.error, ns.colors.blue[3]))
								end,
							},
						},
						dependencies = { visibilityHiddenDependency, },
						dataManagement = { category = category, },
					})


					--[[ TEXT ]]

					local textVisibleDependency

					wt.CreatePanel({
						parent = canvas,
						name = keys[3],
						title = ns.strings.options.display.text.title,
						description = ns.strings.options.display.text.description,
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key)
							local visible = wt.CreateCheckbox({
								parent = panel,
								name = "Visible",
								title = ns.strings.options.display.text.visible.label,
								tooltip = { lines = { { text = ns.strings.options.display.text.visible.tooltip, }, } },
								arrange = {},
								dependencies = { visibilityHiddenDependency, },
								getData = function() return profiles.data.display.text.visible end,
								saveData = function(value) profiles.data.display.text.visible = value end,
								default = ns.profileDefault.display.text.visible,
								dataManagement = {
									category = category,
									key = key,
									onChange = {
										ToggleDisplayText = function() wt.SetVisibility(display.text, profiles.data.display.text.visible) end,
										"EnsureVisibility",
									},
								},
							})

							textVisibleDependency = { frame = visible, }

							options.display.text = {
								visible = visible,
								details = wt.CreateCheckbox({
									parent = panel,
									name = "Details",
									title = ns.strings.options.display.text.details.label,
									tooltip = { lines = { { text = ns.strings.options.display.text.details.tooltip, }, } },
									arrange = { wrap = false, },
									dependencies = { visibilityHiddenDependency, textVisibleDependency },
									getData = function() return profiles.data.display.text.details end,
									saveData = function(value) profiles.data.display.text.details = value end,
									default = ns.profileDefault.display.text.details,
									dataManagement = {
										category = category,
										key = key,
										onChange = { UpdateDisplayText = UpdateXPDisplayText, },
									},
								}),
							}
						end,
					})


					--[[ FONT ]]

					options.display.font = wt.CreateFontOptions(ns.name, display.text, function() return profiles.data.display.font end, ns.profileDefault.display.font, {
						canvas = canvas,
						colors = {
							gathered = {
								name = ns.strings.xpValues.gathered,
								index = 1,
							},
							required = {
								name = ns.strings.xpValues.required,
								index = 2,
							},
							remaining = {
								name = ns.strings.xpValues.remaining,
								index = 3,
							},
							rested = {
								name = ns.strings.xpValues.rested,
								index = 4,
							},
							base = {
								name = ns.strings.options.display.text.base,
								index = 5,
								wrap = true,
							},
						},
						dependencies = {
							visibilityHiddenDependency,
							{ frame = options.display.text.visible, },
						},
						dataManagement = { category = category, },
						onChangeFont = function() SetDisplaySize(profiles.data.display.background.size.w, profiles.data.display.background.size.h) end,
						onChangeSize = function() SetDisplaySize(profiles.data.display.background.size.w, profiles.data.display.background.size.h) end,
						onChangeAlignment = function() wt.SetPosition(display.text, { anchor = profiles.data.display.font.alignment, }) end,
						onChangeColor = UpdateXPDisplayText,
					})


					--[[ BACKGROUND ]]

					local backgroundVisibleDependency

					wt.CreatePanel({
						parent = canvas,
						name = keys[5],
						title = ns.strings.options.display.background.title,
						description = ns.strings.options.display.background.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key)
							local visible = wt.CreateCheckbox({
								parent = panel,
								name = "Visible",
								title = ns.strings.options.display.background.visible.label,
								tooltip = { lines = { { text = ns.strings.options.display.background.visible.tooltip, }, } },
								arrange = {},
								dependencies = { visibilityHiddenDependency, },
								getData = function() return profiles.data.display.background.visible end,
								saveData = function(value) profiles.data.display.background.visible = value end,
								default = ns.profileDefault.display.background.visible,
								dataManagement = {
									category = category,
									key = key,
									onChange = {
										ToggleDisplayBackdrop = function()
											SetDisplayBackdrop(profiles.data.display.background.visible, profiles.data.display.background.colors)
										end,
										"EnsureVisibility",
										UpdateFade = Fade,
									},
								},
							})

							backgroundVisibleDependency = { frame = visible, }

							options.display.background = {
								visible = visible,
								size = {
									w = wt.CreateSlider({
										parent = panel,
										name = "Width",
										title = ns.strings.options.display.background.size.width.label,
										tooltip = { lines = { { text = ns.strings.options.display.background.size.width.tooltip, }, } },
										arrange = { wrap = false, },
										min = 64,
										max = UIParent:GetWidth() - math.fmod(UIParent:GetWidth(), 1),
										step = 2,
										altStep = 8,
										dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, },
										getData = function() return profiles.data.display.background.size.w end,
										saveData = function(value) profiles.data.display.background.size.w = value end,
										default = ns.profileDefault.display.background.size.w,
										dataManagement = {
											category = category,
											key = key,
											onChange = { UpdateDisplaySize = function()
												SetDisplaySize(profiles.data.display.background.size.w, profiles.data.display.background.size.h)
											end, },
										},
									}),
									h = wt.CreateSlider({
										parent = panel,
										name = "Height",
										title = ns.strings.options.display.background.size.height.label,
										tooltip = { lines = { { text = ns.strings.options.display.background.size.height.tooltip, }, } },
										arrange = { wrap = false, },
										min = 2,
										max = 80,
										step = 2,
										altStep = 8,
										dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, },
										getData = function() return profiles.data.display.background.size.h end,
										saveData = function(value) profiles.data.display.background.size.h = value end,
										default = ns.profileDefault.display.background.size.h,
										dataManagement = {
											category = category,
											key = key,
											onChange = { "UpdateDisplaySize", },
										},
									}),
								},
								colors = {
									bg = wt.CreateColorpicker({
										parent = panel,
										name = "Color",
										title = wt.strings.font.color.label:gsub("#COLOR_TYPE", ns.strings.options.display.background.bg),
										arrange = {},
										dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, },
										getData = function() return profiles.data.display.background.colors.bg end,
										saveData = function(value) profiles.data.display.background.colors.bg = value end,
										default = ns.profileDefault.display.background.colors.bg,
										dataManagement = {
											category = category,
											key = key,
											onChange = {
												UpdateDisplayBackgroundColor = function() if display.frame:GetBackdrop() ~= nil then
													display.frame:SetBackdropColor(wt.UnpackColor(profiles.data.display.background.colors.bg))
												end end,
												"UpdateFade",
											},
										},
									}),
									border = wt.CreateColorpicker({
										parent = panel,
										name = "BorderColor",
										title = wt.strings.font.color.label:gsub("#COLOR_TYPE", ns.strings.options.display.background.border),
										arrange = { wrap = false, },
										dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, },
										getData = function() return profiles.data.display.background.colors.border end,
										saveData = function(value) profiles.data.display.background.colors.border = value end,
										default = ns.profileDefault.display.background.colors.border,
										dataManagement = {
											category = category,
											key = key,
											onChange = {
												UpdateDisplayBorderColor = function() if display.frame:GetBackdrop() ~= nil then
													display.frame:SetBackdropColor(wt.UnpackColor(profiles.data.display.background.colors.border))
												end end,
												"UpdateFade",
											},
										},
									}),
									gathered = wt.CreateColorpicker({
										parent = panel,
										name = "XPColor",
										title = wt.strings.font.color.label:gsub("#COLOR_TYPE", ns.strings.xpValues.gathered),
										arrange = { wrap = false, },
										dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, },
										getData = function() return profiles.data.display.background.colors.gathered end,
										saveData = function(value) profiles.data.display.background.colors.gathered = value end,
										default = ns.profileDefault.display.background.colors.gathered,
										dataManagement = {
											category = category,
											key = key,
											onChange = {
												UpdateDisplayXPColor = function() if display.frame:GetBackdrop() ~= nil then
													display.frame:SetBackdropColor(wt.UnpackColor(profiles.data.display.background.colors.gathered))
												end end,
												"UpdateFade",
											},
										},
									}),
									rested = wt.CreateColorpicker({
										parent = panel,
										name = "RestedColor",
										title = wt.strings.font.color.label:gsub("#COLOR_TYPE", ns.strings.xpValues.rested),
										arrange = { wrap = false, },
										dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, },
										getData = function() return profiles.data.display.background.colors.rested end,
										saveData = function(value) profiles.data.display.background.colors.rested = value end,
										default = ns.profileDefault.display.background.colors.rested,
										dataManagement = {
											category = category,
											key = key,
											onChange = {
												UpdateDisplayBorderColor = function() if display.frame:GetBackdrop() ~= nil then
													display.frame:SetBackdropColor(wt.UnpackColor(profiles.data.display.background.colors.rested))
												end end,
												"UpdateFade",
											},
										},
									}),
								},
							}
						end,
					})


					--[[ FADE ]]

					wt.CreatePanel({
						parent = canvas,
						name = keys[6],
						title = ns.strings.options.display.fade.title,
						description = ns.strings.options.display.fade.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key)
							local toggle = wt.CreateCheckbox({
								parent = panel,
								name = "FadeToggle",
								title = ns.strings.options.display.fade.toggle.label,
								tooltip = { lines = { { text = ns.strings.options.display.fade.toggle.tooltip, }, } },
								arrange = { wrap = false, },
								dependencies = { visibilityHiddenDependency, },
								getData = function() return profiles.data.display.fade.enabled end,
								saveData = function(value) profiles.data.display.fade.enabled = value end,
								default = ns.profileDefault.display.fade.enabled,
								dataManagement = {
									category = category,
									key = key,
									onChange = { "UpdateFade", },
								},
							})

							options.display.fade = {
								toggle = toggle,
								text = wt.CreateSlider({
									parent = panel,
									name = " TextFade",
									title = ns.strings.options.display.fade.text.label,
									tooltip = { lines = { { text = ns.strings.options.display.fade.text.tooltip, }, } },
									arrange = { wrap = false, },
									min = 0,
									max = 1,
									step = 0.05,
									altStep = 0.2,
									dependencies = { visibilityHiddenDependency, textVisibleDependency, { frame = toggle, }, },
									getData = function() return profiles.data.display.fade.text end,
									saveData = function(value) profiles.data.display.fade.text = value end,
									default = ns.profileDefault.display.fade.text,
									dataManagement = {
										category = category,
										key = key,
										onChange = { "UpdateFade", },
									},
								}),
								background = wt.CreateSlider({
									parent = panel,
									name = "BackgroundFade",
									title = ns.strings.options.display.fade.background.label,
									tooltip = { lines = { { text = ns.strings.options.display.fade.background.tooltip, }, } },
									arrange = { wrap = false, },
									min = 0,
									max = 1,
									step = 0.05,
									altStep = 0.2,
									dependencies = { visibilityHiddenDependency, backgroundVisibleDependency, { frame = toggle, }, },
									getData = function() return profiles.data.display.fade.background end,
									saveData = function(value) profiles.data.display.fade.background = value end,
									default = ns.profileDefault.display.fade.background,
									dataManagement = {
										category = category,
										key = key,
										onChange = { "UpdateFade", },
									},
								}),
							}
						end,
					})
				end,
			})

			--[ XP Bar Integration ]

			integration.settings = wt.CreateSettingsPage(ns.name, {
				register = main.settings,
				name = "Integration",
				title = ns.strings.options.integration.title,
				description = ns.strings.options.integration.description:gsub("#ADDON", ns.title),
				dataManagement = {
					category = ns.name .. "Integration",
					keys = {
						"Enhancement",
						"Removals",
					},
				},
				optionsKeys = { ns.name .. "" },
				onDefault = function(user)
					if not user then return end

					--Notification
					print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.default.response:gsub(
						"#CATEGORY", cr(ns.strings.options.integration.title, ns.colors.purple[3])
					), ns.colors.blue[3]))
				end,
				arrangement = {},
				initialize = function (canvas, _, _, category, keys)
					options.integration = {}


					--[[ REMOVALS ]]

					wt.CreatePanel({
						parent = canvas,
						name = keys[2],
						title = "Removals", --REPLACE
						-- title = ns.strings.options.integration.removals.title, --REMOVE
						-- description = ns.strings.options.integration.removals.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key) options.integration.hideXPBar = wt.CreateCheckbox({
							parent = panel,
							name = "HideXPBar",
							title = ns.strings.options.integration.hideXPBar.label,
							tooltip = { lines = { { text = ns.strings.options.integration.hideXPBar.tooltip:gsub("#ADDON", ns.title), }, } },
							arrange = {},
							getData = function() return profiles.data.integration.hideXPBar end,
							saveData = function(value) profiles.data.integration.hideXPBar = value end,
							default = ns.profileDefault.integration.hideXPBar,
							dataManagement = {
								category = category,
								key = key,
								onChange = { ToggleXPBar = function() wt.SetVisibility(MainMenuExpBar, not profiles.data.integration.hideXPBar) end, },
							},
						}) end,
					})

					--[ Enhancement ]

					wt.CreatePanel({
						parent = canvas,
						name = keys[1],
						title = "Enhancement", --REPLACE
						-- title = ns.strings.options.integration.title, --REMOVE
						-- description = ns.strings.options.integration.description:gsub("#ADDON", ns.title),
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key)
							options.integration.toggle = wt.CreateCheckbox({
								parent = panel,
								name = "EnableIntegration",
								title = ns.strings.options.integration.toggle.label,
								tooltip = { lines = { { text = ns.strings.options.integration.toggle.tooltip, }, } },
								arrange = {},
								getData = function() return profiles.data.integration.enabled end,
								saveData = function(value) profiles.data.integration.enabled = value end,
								default = ns.profileDefault.integration.enabled,
								dataManagement = {
									category = category,
									key = key,
									onChange = { ToggleIntegration = function()
										SetIntegrationVisibility(profiles.data.integration.enabled)
										UpdateIntegrationText(profiles.data.integration.keep, profiles.data.integration.remaining)
									end, },
								},
							})
							options.integration.keep = wt.CreateCheckbox({
								parent = panel,
								name = "KeepText",
								title = ns.strings.options.integration.keep.label,
								tooltip = { lines = { { text = ns.strings.options.integration.keep.tooltip, }, } },
								arrange = { wrap = false, },
								dependencies = { { frame = options.integration.toggle, }, },
								getData = function() return profiles.data.integration.keep end,
								saveData = function(value) profiles.data.integration.keep = value end,
								default = ns.profileDefault.integration.keep,
								dataManagement = {
									category = category,
									key = key,
									onChange = { UpdateIntegrationText = function()
										UpdateIntegrationText(profiles.data.integration.keep, profiles.data.integration.remaining)
									end, },
								},
							})
							options.integration.remaining = wt.CreateCheckbox({
								parent = panel,
								name = "RemainingOnly",
								title = ns.strings.options.integration.remaining.label,
								tooltip = { lines = { { text = ns.strings.options.integration.remaining.tooltip, }, } },
								arrange = { wrap = false, },
								dependencies = {
									{ frame = options.integration.toggle, },
									{ frame = options.integration.keep, },
								},
								getData = function() return profiles.data.integration.remaining end,
								saveData = function(value) profiles.data.integration.remaining = value end,
								default = ns.profileDefault.integration.remaining,
								dataManagement = {
									category = category,
									key = key,
									onChange = { "UpdateIntegrationText", },
								},
							})
						end,
					})
				end,
			})

			--[ Notifications ]

			events.settings = wt.CreateSettingsPage(ns.name, {
				register = main.settings,
				name = "Events",
				title = ns.strings.options.events.title,
				description = ns.strings.options.events.description:gsub("#ADDON", ns.title),
				dataManagement = {
					category = ns.name .. "Events",
					keys = {
						"ChatNotifications",
						"Logs",
					},
				},
				onDefault = function(user)
					if not user then return end

					--Notification
					print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.default.response:gsub(
						"#CATEGORY", cr(ns.strings.options.events.title, ns.colors.purple[3])
					), ns.colors.blue[3]))
				end,
				arrangement = {},
				initialize = function (canvas, _, _, category, keys)


					--[[ NOTIFICATIONS ]]

					wt.CreatePanel({
						parent = canvas,
						name = keys[1],
						title = ns.strings.options.events.notifications.title,
						description = ns.strings.options.events.notifications.description,
						arrange = {},
						arrangement = {},
						initialize = function(panel, _, _, key)
							local restedXPGained = wt.CreateCheckbox({
								parent = panel,
								name = "RestedXPGained",
								title = ns.strings.options.events.notifications.restedXP.gained.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedXP.gained.tooltip, }, } },
								arrange = {},
								getData = function() return profiles.data.notifications.restedXP.gained end,
								saveData = function(value) profiles.data.notifications.restedXP.gained = value end,
								default = ns.profileDefault.notifications.restedXP.gained,
								dataManagement = {
									category = category,
									key = key,
								},
							})

							local restedStatusUpdate = wt.CreateCheckbox({
								parent = panel,
								name = "RestedStatusUpdate",
								title = ns.strings.options.events.notifications.restedStatus.update.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedStatus.update.tooltip, }, } },
								arrange = {},
								getData = function() return profiles.data.notifications.restedStatus.update end,
								saveData = function(value) profiles.data.notifications.restedStatus.update = value end,
								default = ns.profileDefault.notifications.restedStatus.update,
								dataManagement = {
									category = category,
									key = key,
								},
							})
							
							options.events = {
							xpGained = wt.CreateCheckbox({
								parent = panel,
								name = "XPGained",
								title = ns.strings.options.events.notifications.xpGained.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.xpGained.tooltip, }, } },
								arrange = {},
								getData = function() return profiles.data.notifications.xpGained end,
								saveData = function(value) profiles.data.notifications.xpGained = value end,
								default = ns.profileDefault.notifications.xpGained,
								dataManagement = {
									category = category,
									key = key,
								},
							}),
							restedXPGained = restedXPGained,
							significantRestedOnly = wt.CreateCheckbox({
								parent = panel,
								name = "SignificantRestedOnly",
								title = ns.strings.options.events.notifications.restedXP.significantOnly.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedXP.significantOnly.tooltip, }, } },
								arrange = { wrap = false, },
								dependencies = { { frame = restedXPGained, }, },
								getData = function() return profiles.data.notifications.restedXP.significantOnly end,
								saveData = function(value) profiles.data.notifications.restedXP.significantOnly = value end,
								default = ns.profileDefault.notifications.restedXP.significantOnly,
								dataManagement = {
									category = category,
									key = key,
								},
							}),
							restedXPAccumulated = wt.CreateCheckbox({
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
								arrange = { wrap = false, },
								dependencies = { { frame = restedXPGained, }, },
								getData = function() return profiles.data.notifications.restedXP.accumulated end,
								saveData = function(value) profiles.data.notifications.restedXP.accumulated = value end,
								default = ns.profileDefault.notifications.restedXP.accumulated,
								dataManagement = {
									category = category,
									key = key,
									onChange = { UpdateRestedAccumulation = function()
										SetRestedAccumulation(profiles.data.notifications.restedXP.gained and profiles.data.notifications.restedXP.accumulated and atMax)
									end, },
								},
							}),
							restedStatusUpdate = restedStatusUpdate,
							maxRestedXPReminder = wt.CreateCheckbox({
								parent = panel,
								name = "MaxRestedXPReminder",
								title = ns.strings.options.events.notifications.restedStatus.maxReminder.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.restedStatus.maxReminder.tooltip, }, } },
								arrange = { wrap = false, },
								dependencies = { { frame = restedStatusUpdate, }, },
								getData = function() return profiles.data.notifications.restedStatus.maxReminder end,
								saveData = function(value) profiles.data.notifications.restedStatus.maxReminder = value end,
								default = ns.profileDefault.notifications.restedStatus.maxReminder,
								dataManagement = {
									category = category,
									key = key,
								},
							}),
							lvlUp = wt.CreateCheckbox({
								parent = panel,
								name = "LevelUp",
								title = ns.strings.options.events.notifications.lvlUp.congrats.label,
								tooltip = { lines = { { text = ns.strings.options.events.notifications.lvlUp.congrats.tooltip, }, } },
								arrange = {},
								getData = function() return profiles.data.notifications.lvlUp.congrats end,
								saveData = function(value) profiles.data.notifications.lvlUp.congrats = value end,
								default = ns.profileDefault.notifications.lvlUp.congrats,
								dataManagement = {
									category = category,
									key = key,
								},
							}),
							timePlayed = wt.CreateCheckbox({
								parent = panel,
								name = "TimePlayed",
								title = ns.strings.options.events.notifications.lvlUp.timePlayed.label .. " (Soon™)",
								tooltip = { lines = { { text = ns.strings.options.events.notifications.lvlUp.timePlayed.tooltip, }, } },
								arrange = { wrap = false, },
								disabled = true --ADD time played notifications
								-- dependencies = { { frame = options.notifications.lvlUp, }, },
								-- getData = function() return profiles.data.notifications.lvlUp.timePlayed end,
								-- saveData = function(value) profiles.data.notifications.lvlUp.timePlayed = value end,
								-- default = ns.profileDefault.notifications.lvlUp.timePlayed,
								-- dataManagement = {
								-- 	category = category,
								-- 	key = key,
								-- },
							}),
						} end,
					})


					--[[ LOGS ]]

					wt.CreatePanel({
						parent = canvas,
						name = keys[2],
						title = ns.strings.options.events.logs.title,
						description = ns.strings.options.events.logs.description,
						arrange = {},
						size = { height = 64 },
						initialize = function(panel, _, _, key)
							--ADD logs options
						end,
					})
				end,
			})

			--[ Profiles ]

			---@type profilemanager|profilesPage|{ data: profileData }
			profiles = wt.CreateProfilesPage(ns.name, RemainingXPDB, RemainingXPDBC, ns.profileDefault, RemainingXPCS, {
				register = main.settings,
				onImport = function(success) if success then
					display.settings.load(true)
					integration.settings.load(true)
					events.settings.load(true)
					profiles.settings.load(true)
				else chatCommands.print(wt.strings.backup.error) end end,
				onImportAllProfiles = function(success) if not success then chatCommands.print(wt.strings.backup.error) end end,
			}, profiles)


			--[[ CHAT CONTROL ]]

			---@type chatCommandManager
			chatCommands = wt.RegisterChatCommands(ns.name, { ns.chat.keyword }, {
				commands = {
					{
						command = ns.chat.commands.options,
						description = ns.strings.chat.options.description:gsub("#ADDON", ns.title),
						handler = function() main.settings.open() end,
					},
					{
						command = ns.chat.commands.preset,
						description = ns.strings.chat.preset.description:gsub(
							"#INDEX", cr(ns.chat.commands.preset .. " " .. 1, ns.colors.purple[3])
						),
						handler = function(_, parameter)
							if atMax then
								PrintStatus()
								return nil
							end

							return options.display.position.applyPreset(tonumber(parameter))
						end,
						error = ns.strings.chat.preset.unchanged .. "\n" .. cr(ns.strings.chat.preset.error:gsub(
							"#INDEX", cr(ns.chat.commands.preset .. " " .. 1, ns.colors.purple[2])
						), ns.colors.blue[2]),
						onError = function()
							print(cr(ns.strings.chat.preset.list, ns.colors.blue[1]))
							for i = 1, #options.display.position.presets, 2 do
								local list = "    " .. cr(tostring(i), ns.colors.purple[3]) .. cr(" • " .. options.display.position.presets[i].title, ns.colors.blue[3])

								if i + 1 <= #options.display.position.presets then
									list = list .. "    " .. cr(tostring(i + 1), ns.colors.purple[3]) .. cr(" • " .. options.display.position.presets[i + 1].title, ns.colors.blue[3])
								end

								print(list)
							end
						end,
					},
					{
						command = ns.chat.commands.save,
						description = function() return (ns.strings.chat.save.description:gsub("#CUSTOM", cr(options.display.position.presets[1].title, ns.colors.purple[3])))
						end,
						handler = function() options.display.position.saveCustomPreset() end,
					},
					{
						command = ns.chat.commands.reset,
						description = ns.strings.chat.reset.description:gsub(
							"#CUSTOM", cr(options.display.position.presets[1].title, ns.colors.purple[3])
						),
						handler = function() options.display.position.resetCustomPreset() end,
					},
					{
						command = ns.chat.commands.toggle,
						description = function() return (ns.strings.chat.toggle.description:gsub(
							"#HIDDEN", cr(profiles.data.display.hidden and ns.strings.chat.toggle.hidden or ns.strings.chat.toggle.notHidden, ns.colors.purple[3])
						)) end,
						handler = function()
							options.display.visibility.hidden.setData(not profiles.data.display.hidden)

							return true
						end,
						onSuccess = function()
							print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(
								profiles.data.display.hidden and ns.strings.chat.toggle.hiding or ns.strings.chat.toggle.unhiding, ns.colors.blue[2])
							)
							if atMax then PrintStatus() end
						end,
					},
					{
						command = ns.chat.commands.fade,
						description = function() return (ns.strings.chat.fade.description:gsub(
							"#STATE", cr(profiles.data.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[3])
						)) end,
						handler = function()
							options.display.fade.toggle.setData(not profiles.data.display.fade.enabled)

							return true
						end,
						onSuccess = function()
							print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.fade.response:gsub(
								"#STATE", cr(profiles.data.display.fade.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
							), ns.colors.blue[2]))
							if atMax then PrintStatus() end
						end,
					},
					{
						command = ns.chat.commands.size,
						description = ns.strings.chat.size.description:gsub(
							"#SIZE", cr(ns.chat.commands.size .. " " .. ns.profileDefault.display.font.size, ns.colors.purple[3])
						),
						handler = function(parameter)
							local size = tonumber(parameter)

							if not size then return false end

							options.display.font.widgets.size.setData(size)

							return true, size
						end,
						onSuccess = function(_, size)
							print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.size.response:gsub(
								"#VALUE", cr(size, ns.colors.purple[2])
							), ns.colors.blue[2]))
							if atMax then PrintStatus() end
						end,
						onError = function()
							print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.size.unchanged, ns.colors.blue[1]))
							print(cr(ns.strings.chat.size.error:gsub(
								"#SIZE", cr(ns.chat.commands.size .. " " .. ns.profileDefault.display.font.size, ns.colors.purple[2])
							), ns.colors.blue[2]))
						end,
					},
					{
						command = ns.chat.commands.integration,
						description = ns.strings.chat.integration.description,
						handler = function()
							options.integration.toggle.setData(not profiles.data.integration.enabled)

							return true
						end,
						onSuccess = function()
							print(cr(ns.title .. ":", ns.colors.purple[1]) .. " " .. cr(ns.strings.chat.integration.response:gsub(
								"#STATE", cr(profiles.data.integration.enabled and ns.strings.misc.enabled or ns.strings.misc.disabled, ns.colors.purple[2])
							), ns.colors.blue[2]))
							if atMax then PrintStatus() end
						end,
					},
					{
						command = ns.chat.commands.profile,
						description = ns.strings.chat.profile.description:gsub(
							"#INDEX", cr(ns.chat.commands.profile .. " " .. 1, ns.colors.purple[3])
						),
						handler = function(_, p) return profiles.activate(tonumber(p)) ~= nil end,
						error = ns.strings.chat.profile.unchanged .. "\n" .. cr(ns.strings.chat.profile.error:gsub(
							"#INDEX", cr(ns.chat.commands.profile .. " " .. 1, ns.colors.purple[3])
						), ns.colors.blue[3]),
						onError = function()
							print(cr(ns.strings.chat.profile.list, ns.colors.blue[1]))
							for i = 1, #RemainingXPDB.profiles, 4 do
								local list = "    " .. cr(tostring(i), ns.colors.purple[3]) .. cr(" • " .. RemainingXPDB.profiles[i].title, ns.colors.blue[3])

								for j = i + 1, min(i + 3, #RemainingXPDB.profiles) do
									list = list .. "    " .. cr(tostring(j), ns.colors.purple[3]) .. cr(" • " .. RemainingXPDB.profiles[j].title, ns.colors.blue[3])
								end

								print(list)
							end
						end,
					},
					{
						command = ns.chat.commands.default,
						description = function() return (ns.strings.chat.default.description:gsub(
							"#PROFILE", cr(RemainingXPDB.profiles[RemainingXPDBC.activeProfile].title, ns.colors.blue[1])
						)) end,
						handler = function() return profiles.reset() end,
					},
					{
						command = "hi",
						hidden = true,
						handler = function(manager) manager.welcome() end,
					},
				},
				colors = {
					title = ns.colors.purple[1],
					content = ns.colors.blue[1],
					command = ns.colors.purple[3],
					description = ns.colors.blue[3]
				},
				onWelcome = function()
					print(cr(ns.strings.chat.help.thanks:gsub("#ADDON", cr(ns.title, ns.colors.purple[1])), ns.colors.blue[1]))
					PrintStatus()
					print(cr(ns.strings.chat.help.hint:gsub("#HELP_COMMAND", cr("/" .. ns.chat.keyword .. " " .. ns.chat.commands.help, ns.colors.purple[3])), ns.colors.blue[3]))
					print(cr(ns.strings.chat.help.move:gsub("#ADDON", ns.title), ns.colors.blue[3]))
				end,
			})

			if profiles.firstLoad then chatCommands.welcome() end


			--[[ XP DISPLAY SETUP ]]

			if atMax then
				display.frame:Hide()
				TurnOffIntegration()

				self:UnregisterAllEvents()
			else
				RemainingXPCSC.xp = RemainingXPCSC.xp or {}

				wt.SetPosition(display.frame, us.Fill({ relativePoint = profiles.data.display.position.anchor, }, profiles.data.display.position))
				wt.ConvertToAbsolutePosition(display.frame)
				SetDisplayValues(profiles.data)

				SetIntegrationVisibility(profiles.data.integration.enabled)

				--Shared context menu
				wt.CreateContextMenu({ triggers = { { frame = display.border, }, { frame = integration.frame, }, }, initialize = function(menu)
					wt.CreateMenuTextline(menu, { text = ns.title, })
					wt.CreateSubmenu(menu, { title = ns.strings.misc.options, initialize = function(optionsMenu)
						wt.CreateMenuButton(optionsMenu, {
							title = wt.strings.about.title,
							tooltip = { lines = { { text = ns.strings.options.main.description:gsub("#ADDON", ns.title), }, } },
							action = main.settings.open,
						})
						wt.CreateMenuButton(optionsMenu, {
							title = ns.strings.options.display.title:gsub("#TYPE", ns.strings.options.display.title),
							tooltip = { lines = { { text = ns.strings.options.display.description, }, } },
							action = display.settings.open,
						})
						wt.CreateMenuButton(optionsMenu, {
							title = ns.strings.options.integration.title:gsub("#TYPE", ns.strings.options.integration.title),
							tooltip = { lines = { { text = ns.strings.options.integration.description, }, } },
							action = integration.settings.open,
						})
						wt.CreateMenuButton(optionsMenu, {
							title = ns.strings.options.events.title:gsub("#TYPE", ns.strings.options.events.title),
							tooltip = { lines = { { text = ns.strings.options.events.description, }, } },
							action = events.settings.open,
						})
						wt.CreateMenuButton(optionsMenu, {
							title = wt.strings.dataManagement.title,
							tooltip = { lines = { { text = wt.strings.dataManagement.description:gsub("#ADDON", ns.title), }, } },
							action = profiles.settings.open,
						})
					end })
					wt.CreateSubmenu(menu, { title = wt.strings.presets.apply.label, initialize = function(presetsMenu)
						for i = 1, #options.display.position.presets do wt.CreateMenuButton(presetsMenu, {
							title = options.display.position.presets[i].title,
							action = function() options.display.position.applyPreset(i) end,
						}) end
					end })
				end })
			end

			if not self:IsVisible() then PrintStatus(true) end
		end,
		PLAYER_ENTERING_WORLD = atMax and nil or function(self)
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")

			UpdateXPValues()

			SetDisplaySize(profiles.data.display.background.size.w, profiles.data.display.background.size.h)
			UpdateXPDisplayText()
			UpdateIntegrationText(profiles.data.integration.keep, profiles.data.integration.remaining)

			--| Initialize display tooltips

			wt.AddTooltip(display.border, {
				tooltip = tooltip,
				title = ns.strings.xpTooltip.title,
				anchor = "ANCHOR_BOTTOMRIGHT",
				offset = { y = display.border:GetHeight() },
				flipColors = true,
			})
			display.border:HookScript("OnEnter", UpdateXPTooltip)

			wt.AddTooltip(integration.frame, {
				tooltip = tooltip,
				title = ns.strings.xpTooltip.title,
				anchor = "ANCHOR_NONE",
				offset = { x = -11, y = 115 },
				position = { anchor = "BOTTOMRIGHT" },
				flipColors = true,
			})
			integration.frame:HookScript("OnEnter", UpdateXPTooltip)

			--| Removals

			if profiles.data.integration.hideXPBar then MainMenuExpBar:Hide() end
		end,
		PLAYER_XP_UPDATE = atMax and nil or function(_, unit)
			if unit ~= "player" then return end

			local gainedXP, _, oldXP = UpdateXPValues()
			if oldXP == RemainingXPCSC.xp.gathered then return end --The event fired without actual XP gain

			UpdateXPDisplayText()
			UpdateXPDisplaySegments()
			UpdateIntegrationText(profiles.data.integration.keep, profiles.data.integration.remaining)

			if profiles.data.notifications.xpGained then
				print(cr(ns.strings.chat.xpGained.text:gsub(
					"#AMOUNT", cr(us.Thousands(gainedXP), ns.colors.purple[1])
				):gsub(
					"#REMAINING", cr(atMax and ns.strings.chat.lvlUp.disabled.reason:gsub(
						"#MAX", maxLevel
					) or ns.strings.chat.xpGained.remaining:gsub(
						"#AMOUNT", cr(us.Thousands(RemainingXPCSC.xp.remaining), ns.colors.purple[3])
					):gsub(
						"#NEXT", UnitLevel("player") + 1
					), ns.colors.blue[3])
				), ns.colors.blue[1]))
			end

			UpdateXPTooltip()
		end,
		PLAYER_LEVEL_UP = atMax and nil or function(_, newLevel)
			atMax = newLevel >= maxLevel

			if atMax then
				display.frame:Hide()
				TurnOffIntegration()

				print(cr(ns.strings.chat.lvlUp.disabled.text:gsub(
					"#ADDON", cr(ns.title, ns.colors.purple[1])
				):gsub(
					"#REASON", cr(ns.strings.chat.lvlUp.disabled.reason:gsub(
						"#MAX", maxLevel
					), ns.colors.blue[3])
				) .. " " .. ns.strings.chat.lvlUp.congrats, ns.colors.blue[1]))
			else
				if profiles.data.notifications.lvlUp.congrats then
					print(cr(ns.strings.chat.lvlUp.text:gsub(
						"#LEVEL", cr(newLevel, ns.colors.purple[1])
					) .. " " .. cr(ns.strings.chat.lvlUp.congrats, ns.colors.purple[3]), ns.colors.blue[1]))
					if profiles.data.notifications.lvlUp.timePlayed then RequestTimePlayed() print('HEY') end
				end

				UpdateXPTooltip()
			end
		end,
		UPDATE_EXHAUSTION = atMax and nil or function()
			local _, gainedRestedXP = UpdateXPValues()
			if gainedRestedXP <= 0 then return end

			UpdateXPDisplayText()
			UpdateXPDisplaySegments()
			UpdateIntegrationText(profiles.data.integration.keep, profiles.data.integration.remaining)

			if profiles.data.notifications.restedXP.gained and not (profiles.data.notifications.restedXP.significantOnly and gainedRestedXP <= math.ceil(RemainingXPCSC.xp.required / 1000)) then
				print(cr(ns.strings.chat.restedXPGained.text:gsub(
						"#AMOUNT", cr(tostring(gainedRestedXP), ns.colors.purple[1])
					):gsub(
						"#TOTAL", cr(us.Thousands(RemainingXPCSC.xp.rested), ns.colors.purple[1])
					):gsub(
						"#PERCENT", cr(ns.strings.chat.restedXPGained.percent:gsub(
							"#VALUE", cr(us.Thousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered) * 100000) / 1000, 3) .. "%%%%", ns.colors.purple[3])
						), ns.colors.blue[3])
					), ns.colors.blue[1])
				)
			end

			UpdateXPTooltip()
		end,
		PLAYER_UPDATE_RESTING = atMax and nil or function()
			if profiles.data.notifications.restedXP.gained and profiles.data.notifications.restedXP.accumulated and not IsResting() then
				print((profiles.data.notifications.restedStatus.update and (cr(ns.strings.chat.restedStatus.notResting, ns.colors.purple[1]) .. " ") or "") .. (
					(RemainingXPCSC.xp.accumulatedRested or 0) > 0 and cr(ns.strings.chat.restedXPAccumulated.text:gsub(
						"#AMOUNT", cr(us.Thousands(RemainingXPCSC.xp.accumulatedRested), ns.colors.purple[1])
					):gsub(
						"#TOTAL", cr(us.Thousands(RemainingXPCSC.xp.rested), ns.colors.purple[1])
					):gsub(
						"#PERCENT", cr(ns.strings.chat.restedXPAccumulated.percent:gsub(
							"#VALUE", cr(us.Thousands(math.floor(RemainingXPCSC.xp.rested / (RemainingXPCSC.xp.required - RemainingXPCSC.xp.gathered) * 1000000) / 10000, 4) .. "%%%%", ns.colors.purple[3])
						):gsub(
							"#NEXT", cr(tostring(UnitLevel("player") + 1), ns.colors.purple[3])
						), ns.colors.blue[3])
					), ns.colors.blue[1]) or cr(ns.strings.chat.restedXPAccumulated.zero, ns.colors.blue[1])
				))
			end

			SetRestedAccumulation(profiles.data.notifications.restedXP.gained and profiles.data.notifications.restedXP.accumulated)
			UpdateXPTooltip()
		end,
	},
	initialize = atMax and nil or function(_, _, _, name)

		--[ Main Display ]

		display.frame = wt.CreateCustomFrame({
			parent = UIParent,
			name = name .. "MainDisplay",
			initialize = function(displayFrame)
				display.xp = wt.CreateCustomFrame({
					parent = displayFrame,
					name = "CurrentXPSegment",
					position = { anchor = "LEFT", },
				})

				display.rested = wt.CreateCustomFrame({
					parent = displayFrame,
					name = "RestedXPSegment",
					position = {
						anchor = "LEFT",
						relativeTo = display.xp,
						relativePoint = "RIGHT",
					},
				})

				display.border = wt.CreateCustomFrame({
					parent = displayFrame,
					name = "BorderOverlay",
					position = { anchor = "CENTER", },
					events = {
						OnEnter = function() if profiles.data.display.fade.enabled then Fade(false) end end,
						onLeave = function() if profiles.data.display.fade.enabled then Fade(true) end end,
					},
				})

				display.text = wt.CreateText({
					parent = display.border,
					name = "Text",
					position = { anchor = "CENTER", },
					layer = "OVERLAY",
					wrap = false,
				})
			end,
		})

		--[ Integrated Display ]

		integration.frame = wt.CreateCustomFrame({
			parent = UIParent,
			name = name .. "IntegratedDisplay",
			position = {
				anchor = "BOTTOM",
				relativeTo = MainMenuExpBar,
				relativePoint = "BOTTOM",
			},
			keepInBounds = true,
			frameStrata = "HIGH",
			keepOnTop = true,
			size = { width = MainMenuExpBar:GetWidth(), height = 17 },
			events = {
				OnEnter = function()
					--Show the enhanced XP text on the default XP bar
					UpdateIntegrationText(true, false)

					-- ExhaustionTickMixin:ExhaustionToolTipText() --Show the default Rested XP tooltip
				end,
				onLeave = function()
					--Hide the enhanced XP text on the default XP bar
					UpdateIntegrationText(profiles.data.integration.keep, profiles.data.integration.remaining)

					--Default trial tooltip
					if GameLimitedMode_IsActive() and IsTrialAccount() then
						--Stop the store button from flashing
						MicroButtonPulseStop(StoreMicroButton)

						--Hide the default trial tooltip
						GameTooltip:Hide()
					end
				end,
			},
			initialize = function(displayFrame) integration.text = wt.CreateText({
				parent = displayFrame,
				name = "Text",
				position = {
					anchor = "CENTER",
					offset = { y = 3 }
				},
				layer = "OVERLAY",
				font = "TextStatusBarText",
				wrap = false,
			}) end,
		})
	end
})