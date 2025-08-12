--[[ NAMESPACE ]]

---Addon namespace table
---@class RemainingXPNamespace
---@field name string Addon namespace name
local ns = select(2, ...)

ns.name = ...

--Addon display title
ns.title = select(2, C_AddOns.GetAddOnInfo(ns.name)):gsub("^%s*(.-)%s*$", "%1")

--Addon root folder
ns.root = "Interface/AddOns/" .. ns.name .. "/"


--[[ STRINGS ]]

--Chat commands
ns.chat = {
	keyword = "remxp",
	commands = {
		options = "options",
		preset = "preset",
		save = "save",
		reset = "reset",
		toggle = "toggle",
		fade = "fade",
		size = "size",
		integration = "integrate",
		profile = "profile",
		defaults = "defaults",
	},
}

--Changelog
ns.changelog = {
	{
		"#V_Version 1.0_# #H_(4/21/2020)_#",
		"#H_It's alive!_#",
	},
	{
		"#V_Version 1.1_# #H_(4/25/2020)_#",
		"#F_Bug fix:_#",
		"Remaining XP will now correctly hide with the rest of the interface - This also enables it to scale with the UI.",
	},
	{
		"#V_Version: 1.2_# #H_(10/22/2020)_#",
		"#N_New features:_#",
		"Savable custom preset location: #H_SHIFT+ drag_# the XP display to the position of your liking then type #H_/remxp save_# to set it as your preset location. You can then apply this preset to each of your characters as you log in with them and use #H_/remxp preset_#",
		"Show/hide/toggle XP display on mouseover: You can opt to having the XP display appear only when you mouse over its location or you can hide it completely until you ask it to be shown again.",
		"Updated chat messages and commands: Colors, Feedback message for every change you make, Clear XP display status info & Separate detailed chat command list.",
		"#C_Change:_#",
		"Max level is 50 (will be patched to 60 when Shadowlands arrives, look out for updates then!)",
		"#O_Note:_#",
		"I wanted make a change that would hide the XP display when the world map is opened in fullscreen - I was not able to figure out a simple way to do it - let me know if you'd want this feature.",
	},
	{
		"#V_Version 1.3_# #H_(10/26/2020)_#",
		"#F_Hotfix:_#",
		"Fixed an issue where loading the addon for the first time would result in an error",
		"Fixed an issue resulting in the XP display to be hidden for all characters after logging in with a max level character",
		"#C_Change:_#",
		"Display settings (whether or not the XP display is hidden, set to toggle or entirely disabled - for max level characters) will now be saved character per character. This means, if you use the toggle feature, you need to set it for all of your leveling characters.",
		"The saved preset location will still be the same for all characters (so you can quickly set up the XP display location on all of your alts). If you want to use different locations for specific characters, you can still move the XP display manually (via Shift + dragging) - the client will remember it's character-specific position.",
		"Remaining XP will display a status message on each login for all characters (not only max levels) to let you know if it's currently visible, hidden or disabled, and is mouseover toggle enabled or not.",
	},
	{
		"#V_Version 1.3.1_# #H_(10/26/2020)_#",
		"#F_Hotfix:_#",
		"With an unintentional change introduced with version 1.2, the character-specific positions set up before have been reset. This was due to the frame name being changed - now this has been reverted back to what it was before. All positions set before the update to 1.2 should be remembered again (however, in turn positions set after updating to 1.2 should be reset after this update.",
	},
	{
		"#V_Version 1.4_# #H_(11/23/2020)_#",
		"#C_Change:_#",
		"Max level changed to 60 with the launch of Shadowlands.",
		"Font has been changed to a more readable and better looking one.",
	},
	{
		"#V_Version 1.5_# #H_(3/12/2021)_#",
		"#F_Hotfix:_#",
		"The XP display will now be correctly disabled when you reach max level.",
		"Fixed all potential issues with previously non-local functions.",
	},
	{
		"#V_Version 1.6_# #H_(3/19/2021)_#",
		"#N_Update:_#",
		"Added 9.1 (with 9.0.5 is still being supported!), Classic (1.13.7) and Burning Crusade Classic (2.5.1) multi-version support.",
	},
	{
		"#V_Version 2.0_# #H_(2/23/2022)_#",
		"#N_Update:_#",
		"Added 9.2 (Retail), 1.14.2 (Classic) and 2.5.3 (BCC) multi-version support.",
		"#N_New features:_#",
		"#H_Added Interface Options:_#",
		"Buttons, sliders, dropdowns and more have been added as alternatives to chat commands (many more new options have not been made available as chat commands).",
		"Included an about page where you can find contact and support links, changelogs and more.",
		"#H_New display options:_#",
		"Background graphic: the display now functions as a customizable XP bar with customizable colors, mouseover fade options.",
		"Font family & color customization (with a fully custom font type option - see the tooltip in the settings).",
		"Multiple display presets have been added to quickly set it up for your needs.",
		"Detailed XP value option.",
		"Fine-tune the position (select an anchor point and change the offset coordinates with sliders).",
		"Raise or lower the display among other UI elements.",
		"#N_New features:_#",
		"XP bar enhancement integration: detailed XP text and tooltip can be enabled to replace the default text and tooltip shown when mousing over the default XP bar.",
		"Added the ability to hide the default Status/XP/Reputation Bars (so it may be replaced with the Remaining XP display).",
		"Chat notifications on event updates like XP or Rested XP gain (with the amount gained), level up and more.",
		"Option for an accumulative Rested XP gain notification showing you a summary of the total amount of Rested XP gained while resting when leaving a rested area.",
		"Import/Export: Back up your settings (or manually edit them - for advanced users).",
		"#C_Other additions & changes:_#",
		"Right click on the display (or the default XP bar when the integration is enabled) to quickly open an options category page.",
		"The chat notification reminder when you are max level and Remaining XP is disabled can now be turned off.",
		"The display now hides during pet battles.",
		"Added localization support, so more languages can be supported besides English in the future (more info soon on how you can help me translate!).",
		"#O_Coming soon:_#",
		"Options profiles for character-specific customization.",
		"Tracking the playtime/real time spent on a level.",
		"Different styles and looks for the custom XP bar.",
		"Event update logs: track your XP, Rested XP gain and more.",
	},
	{
		"#V_Version 2.0.1_# #H_(3/3/2022)_#",
		"#N_New:_#",
		"Added the Wago link of Remaining XP. It's now released and can be updated through the Wago app.\n#H_You may choose to support development through a Wago Subscription._#",
		"Added the date of the last update to the About page.",
		"#F_Hotfix:_#",
		"The interface error appearing after a clean install of Remaining XP in the retail client has been fixed.",
		"The Rested XP accumulation notification will no longer show up for max level characters.",
		"The accumulated Rested XP amount should now be properly stored even after the character relogs in the retail client.",
		"Fixed the max level not being correctly recognized as level 70 in the BCC client.",
		"The trial Banked XP text in the XP tooltip has been fixed in the retail client.",
		"Fixed the label on the load button in the backup popup window.",
		"Hovering over the integrated display will still show the improved tooltip for trial accounts and moving the mouse away will no longer cause an interface error.",
		"Remaining XP will now be disabled right away after logging in to a max level character the very first time after a clean install.",
		"#C_Change:_#",
		"The Remaining XP tooltip will now be refreshed automatically.",
		"Certain interface options will fully take effect immediately after being changed that didn't do so before (they still reset on Cancel).",
		"Swapped the current & required total XP values in the XP display text.",
		"Trial Banked XP and levels info will only be shown on the XP display id details are enabled.",
	},
	{
		"#V_Version 2.0.2_# #H_(3/11/2022)_#",
		"#C_Update:_#",
		"The XP display visibility status chat message has been reinstated.",
		"Several chat command response messages and descriptions have been updated.",
		"The visibility of XP display text and background can't be turned off at the same time. #H_To hide both, you can hide the entire display instead._# (When the addon data is loaded and the visibility of both the text and the background is turned off, set them to visible and hide the XP display instead.)",
		"The XP display will no longer be automatically unhidden when navigating to the display settings page through the shortcut button.",
		"Other small changes.",
		"#N_New:_#",
		"Added an option to disable status notifications on load even for non-max level characters.",
		"Added release dates for past version notes in the changelog.",
		"#F_Hotfix:_#",
		"Saving the Custom preset will now be handled properly.",
		"Fixed the issue of preset changes not being saved correctly when applied through chat commands (and the interface options not being updated correctly - if chat commands were used while the interface options were open).",
		"Fixed the issue of the integrated display not getting hidden upon reaching max level.",
		"Fixed the small issue of the position anchor dropdown not being updated correctly after drag & dropping the XP display.",
		"Typo fixes.",
	},
	{
		"#V_Version 2.0.3_# #H_(3/17/2022)_#",
		"#C_Change:_#",
		"The dropdown menu of the XP display anchor point selection was been changed to a group of radio buttons.",
		"Other small changes & fixes.",
	},
	{
		"#V_Version 2.0.4_# #H_(3/23/2022)_#",
		"#N_Update:_#",
		"New hints have been added to the XP display tooltip.",
		"Chat responses have been added when the XP display is dragged to confirm when the position is saved.",
		"Added 2.5.4 (BCC) support.",
		"#C_Change:_#",
		"The repositioning of the XP display will now be cancelled when SHIFT is released before the mouse button.",
		"The tooltips have been adjusted to fit in more with the base UI.",
		"#F_Hotfix:_#",
		"Fixed an issue with appearing when listing out the chat command list.",
		"Other small changes & fixes.",
		"#H_If you encounter any issues, please, consider reporting them! Try to include when/how they occur, and which addons are you using to give me the best chance to be able to reproduce and fix them._#",
	},
	{
		"#V_Version 2.0.5_# #H_(7/9/2022)_#",
		"#N_Update:_#",
		"Added 9.2.5 (Retail) and 1.14.3 (Classic) support.",
		"Numerous under the hood changes & improvements.",
		"#F_Fix:_#",
		"The integrated display will now readjust when the Honor bar appears/disappears when entering/leaving Arena or a Battleground.",
	},
	{
		"#V_Version 2.0.6_# #H_(8/21/2022)_#",
		"#N_Update:_#",
		"Added 3.4 (WotLK Classic) & 9.2.7 (Retail) support.",
		"Under the hood changes & improvements.",
		"#C_Change:_#",
		"Remaining XP has moved from Bitbucket to GitHub. Links to the Repository & Issues have been updated.\n#H_There is now an opportunity to Sponsor my work on GitHub to support and justify the continued development of my addons should you wish and have the means to do so. Every bit of help is appreciated!_#",
	},
	{
		"#V_Version 2.1_# #H_(11/28/2022)_#",
		"#N_Update:_#",
		"Added Dragonflight (Retail 10.0) support.",
		"Significant under the hood changes & improvements, including new UI widgets and more functionality.",
		"Apply quick display presets right from the context menu (Dragonflight only, for now).",
		"Other smaller changes like an updated logo or improved data restoration from older versions of the addon.",
	},
	{
		"#V_Version 2.2_# #H_(6/15/2023)_#",
		"#N_New:_#",
		"Added 10.1.5 (Dragonflight) & 3.4.2* (WotLK Classic) support. Finally. Sorry for the long wait & thank you all for your patience! <3\n*The current version will run in the WotLK Classic 3.4.2 PTR but it's not yet fully polished (as parts of the UI are still being modernized).",
		"A new Sponsors section has been added to the main Settings page.\n#H_Thank you for your support! It helps me continue to spend time on developing and maintaining these addons. If you are considering supporting development as well, follow the links to see what ways are currently available._#",
		"Added a new option to change the text alignment of the XP Display.",
		"Replaced the \"Appear on top\" checkbox with a new Screen Layer selector (now in the Position section) to allow for more adjustability.",
		"Added a Reset Custom Preset button to the settings.",
		"Added a new \"defaults\" chat command, replacing the old \"reset\" command which now performs the Custom preset restoring functionality.",
		"The Position Offset sliders now support changing the value by 1 point via holding the ALT key to allow for quick fine tuning.",
		"Improved the Rested Status chat notification and tooltip information with maximal Rested XP amounts being noted. Chat notifications can be specified via the new checkboxes added under the Chat Notifications settings in the Event Updates page.",
		"#C_Changes:_#",
		"The About info has been rearranged and combined with the Support links.",
		"Only the most recent update notes will be loaded now. The full Changelog is available in a bigger window when clicking on a new button.",
		"Some settings have been rearranged, the preset options have been moved to the Position panel, and the status & max level reminder chat notice options have been moved to the Visibility panel in the Display & XP Bar page (given that they are more tied to the status of the display rather than XP update events).",
		"The Shortcuts section form the main settings page has been removed in Dragonflight (since the new expansion broke the feature - I may readd it when the issue gets resolved).",
		"The options shortcuts in the XP Display right-click context menu have been replaced with a single button opening the main addon settings page in Dragonflight (until Blizzard readds the support for addons to open settings subcategories).",
		"The Font Family selection dropdown menu now provides a preview of how the fonts look (might not show on first change as the custom fonts need to be loaded).",
		"Made checkboxes a lot easier to click, their tooltips are now visible even when the input is disabled.",
		"The backup string in the Advanced settings will now be updated live as changes are made.",
		"The entire status bar manager frame will no longer be hidden together with the default XP bar when the removal setting is turned on. Now only the XP bar itself will be hidden and the Reputation, Honor and other unique bars will be unaffected in Dragonflight (just like how it's been in Classic).",
		"The significant-only Rested XP gain notification filter has been fine-tuned to only show amounts larger than 0.0001% of the total XP required to level up instead of the flat amount of 10.",
		"General polish & countless other less notable or smaller changes.",
		"#F_Fixes:_#",
		"The integrated display will now also be hidden during a pet battle, and the main display will not appear after it's finished if it was set as hidden.",
		"The old scrollbars have been replaced with the new scrollbars in Dragonflight, fixing any bugs that emerged with 10.1 as a result of deprecation.",
		"Widget Tools will no longer create copies of its Settings after each loading screen.",
		"Fixed an issue with actions being blocked after closing the Settings panel in certain situation (like changing Keybindings) in Dragonflight.",
		"Settings should now be properly saved in Dragonflight, the custom Restore Defaults and Revert Changes functionalities should also work as expected now, on a per Settings page basis (with the option of restoring defaults for the whole addon kept).",
		"Several old and inaccurate descriptions and tooltips have been updated.",
		"No tooltip will stay on the screen after its target was hidden.",
		"Many other under the hood fixes & improvements. Phew.",
		"#H_If you encounter any issues, do not hesitate to report them! Try including when & how they occur, and which other addons are you using to give me the best chance of being able to reproduce & fix them. Try proving any LUA script error messages and if you know how, taint logs as well (when relevant). Thanks a lot for helping!_#",
	},
	{
		"#V_Version 2.3_# #H_(7/23/2023)_#",
		"#C_Changes:_#",
		"The \"Objective Tracker Bar\" (Watch Frame) preset has been added to WotLK Classic as well.",
		"Several Preset values have been adjusted. Presets positioning the XP Display next to other frames will now dynamically be updated to follow those frames instead of being assigned to a static position. #H_After you move a frame, reapply the desired updated preset to move the XP Display back next to it._#",
		"The \"Menu & Bags Small Bar\" has been replaced by the \"Bottom-Right Chunky Bar\" (same as in Classic).",
		"Added more value step options to the other sliders as well. The default step value is now 1 for the offset values.",
		"Rested XP Accumulation notification filter has been further adjusted to skip any amount gained no greater than 0.1% of the total Required XP amount.",
		"The XP Displays will be hidden when entering most vehicles with custom UIs.",
		"The settings category page shortcuts have been removed in WotLK Classic (because the new Settings window broke the feature - I may readd them when the issue gets resolved). The shortcuts have been replaced by an Options button in the right-click menu of the XP Displays.",
		"The custom context menus have been replaced with the basic menu until their quirks are ironed out.",
		"Scrolling has been improved in WotLK Classic.",
		"#F_Fixes:_#",
		"The XP Display size will now properly be able to be set again via Settings after applying a preset.",
		"The default XP Status Bar will now be hidden again after exiting Edit Mode if the \"Hide default XP bar\" option is enabled.",
		"Other small fixes, changes & improvements.",
		"#F_Hotfix 2.3.1 (7/24/2023):_#",
		"The Background and Text \"Visible\" checkboxes will now be updated properly and work as expected when a preset is applied.",
		"Addon data recovery will now work properly when loading old data.",
	},
}

--[ Localization ]

---Localized strings
---@class strings
ns.strings = ns.localizations[GetLocale()]

--| Fill static & internal references

ns.strings.options.main.description = ns.strings.options.main.description:gsub("#KEYWORD", "/" .. ns.chat.keyword)
ns.strings.options.display.referenceName = ns.strings.options.display.referenceName:gsub("#ADDON", ns.name)
ns.strings.options.display.font.color.tooltip = ns.strings.options.display.font.color.tooltip:gsub("#VALUE_COLORING", ns.strings.options.display.font.valueColoring.label)

--| Cleanup

ns.localizations = nil


--[[ ASSETS ]]

--Colors
ns.colors = {
	grey = {
		{ r = 0.54, g = 0.54, b = 0.54 },
		{ r = 0.69, g = 0.69, b = 0.69 },
		{ r = 0.79, g = 0.79, b = 0.79 },
	},
	purple = {
		{ r = 0.83, g = 0.11, b = 0.79 },
		{ r = 0.82, g = 0.34, b = 0.80 },
		{ r = 0.88, g = 0.56, b = 0.86 },
	},
	blue = {
		{ r = 0.06, g = 0.54, b = 1 },
		{ r = 0.46, g = 0.70, b = 0.94 },
		{ r = 0.64, g = 0.80, b = 0.96 },
	},
	rose = {
		{ r = 0.69, g = 0.21, b = 0.47 },
		{ r = 0.84, g = 0.25, b = 0.58 },
		{ r = 0.80, g = 0.47, b = 0.65 },
	},
	peach = {
		{ r = 0.95, g = 0.58, b = 0.52 },
		{ r = 0.96, g = 0.72, b = 0.68 },
		{ r = 0.98, g = 0.81, b = 0.78 },
	}
}

--Fonts
ns.fonts = {
	{ name = ns.strings.misc.default, path = ns.strings.defaultFont },
	{ name = "Arbutus Slab", path = ns.root .. "Fonts/ArbutusSlab.ttf" },
	{ name = "Caesar Dressing", path = ns.root .. "Fonts/CaesarDressing.ttf" },
	{ name = "Germania One", path = ns.root .. "Fonts/GermaniaOne.ttf" },
	{ name = "Mitr", path = ns.root .. "Fonts/Mitr.ttf" },
	{ name = "Oxanium", path = ns.root .. "Fonts/Oxanium.ttf" },
	{ name = "Pattaya", path = ns.root .. "Fonts/Pattaya.ttf" },
	{ name = "Reem Kufi", path = ns.root .. "Fonts/ReemKufi.ttf" },
	{ name = "Source Code Pro", path = ns.root .. "Fonts/SourceCodePro.ttf" },
	{ name = ns.strings.misc.custom, path = ns.root .. "Fonts/CUSTOM.ttf" },
}

--Textures
ns.textures = {
	logo = ns.root .. "Textures/Logo.tga",
}


--[[ DATA ]]

--Defaults
ns.profileDefault = {
	customPreset = {
		name = ns.strings.misc.custom, --Custom
		data = {
			position = {
				anchor = "TOP",
				offset = { x = 0, y = -58 }
			},
			layer = {
				strata = "HIGH",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 116, height = 16, },
			},
		},
	},
	display = {
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -58 }
		},
		layer = {
			strata = "HIGH",
			keepOnTop = false,
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

--Presets
ns.presets = {
	{
		title = ns.strings.options.display.position.presets.list[1], --XP Bar Replacement
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = 0, y = 0 }
			},
			keepInBounds = true,
			layer = {
				strata = "LOW",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 562, height = 16 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[2], --XP Bar Left Text
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = -256, y = 0 }
			},
			keepInBounds = true,
			layer = {
				strata = "HIGH",
				keepOnTop = false,
			},
			background = {
				visible = false,
				size = { width = 68, height = 16 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[3], --XP Bar Right Text
		data = {
			position = {
				anchor = "BOTTOM",
				offset = { x = 252, y = 0 }
			},
			keepInBounds = true,
			layer = {
				strata = "HIGH",
				keepOnTop = false,
			},
			background = {
				visible = false,
				size = { width = 68, height = 16 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[4], --Player Frame Bar Above
		data = {
			position = {
				anchor = "TOPRIGHT",
				relativeTo = PlayerFrame,
				relativePoint = "TOPRIGHT",
				offset = { x = -27, y = -11 }
			},
			keepInBounds = true,
			layer = {
				strata = "MEDIUM",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 126, height = 16 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[5], --Player Frame Text Under
		data = {
			position = {
				anchor = "BOTTOMLEFT",
				relativeTo = PlayerFrame,
				relativePoint = "BOTTOMLEFT",
				offset = { y = 2 }
			},
			keepInBounds = true,
			layer = {
				strata = "MEDIUM",
				keepOnTop = false,
			},
			background = {
				visible = false,
				size = { width = 104, height = 16 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[6], --Objective Tracker Bar
		data = {
			position = {
				anchor = "TOPLEFT",
				relativeTo = ObjectiveTrackerFrame,
				relativePoint = "TOPLEFT",
				offset = { x = 34, y = -5 }
			},
			keepInBounds = true,
			layer = {
				strata = "MEDIUM",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 232, height = 22 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[7], --Bottom-Left Chunky Bar
		data = {
			position = {
				anchor = "BOTTOMLEFT",
				offset = { x = 188, y = 12 }
			},
			keepInBounds = true,
			layer = {
				strata = "MEDIUM",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 490, height = 38 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[8], --Bottom-Right Chunky Bar
		data = {
			position = {
				anchor = "BOTTOMRIGHT",
				offset = { x = -188, y = 12 }
			},
			keepInBounds = true,
			layer = {
				strata = "MEDIUM",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 490, height = 38 },
			},
		},
	},
	{
		title = ns.strings.options.display.position.presets.list[9], --Top-Center Long Bar
		data = {
			position = {
				anchor = "TOP",
				offset = { x = 0, y = 3 }
			},
			keepInBounds = true,
			layer = {
				strata = "MEDIUM",
				keepOnTop = false,
			},
			background = {
				visible = true,
				size = { width = 1248, height = 8 },
			},
		},
	},
}