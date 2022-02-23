--Addon namespace
local _, ns = ...

--[[ CHANGELOG ]]

local changelogDB = {
	[0] = {
		[0] = "#V_Version 1.0_#",
		[1] = "#H_It's alive!_#",
	},
	[1] = {
		[0] = "#V_Version 1.1_#",
		[1] = "#F_Bug fix:_#",
		[2] = "Remaining XP will now correctly hide with the rest of the interface - This also enables it to scale with the UI.",
	},
	[2] = {
		[0] = "#V_Version: 1.2_#",
		[1] = "#N_New features:_#",
		[2] = "Savable custom preset location: #H_SHIFT+ drag_# the XP display to the position of your liking then type #H_/remxp save_# to set it as your preset location. You can then apply this preset to each of your characters as you log in with them and use #H_/remxp preset_#",
		[3] = "Show/hide/toggle XP display on mouseover: You can opt to having the XP display appear only when you mouse over its location or you can hide it completely until you ask it to be shown again.",
		[4] = "Updated chat messages and commands: Colors, Feedback message for every change you make, Clear XP display status info & Separate detailed chat command list.",
		[5] = "#C_Change:_#",
		[6] = "Max level is 50 (will be patched to 60 when Shadowlands arrives, look out for updates then!)",
		[7] = "#O_Note:_#",
		[8] = "I wanted make a change that would hide the XP display when the world map is opened in fullscreen - I was not able to figure out a simple way to do it - let me know if you'd want this feature.",
	},
	[3] = {
		[0] = "#V_Version 1.3_#",
		[1] = "#F_Hotfix:_#",
		[2] = "Fixed an issue where loading the addon for the first time would result in an error",
		[3] = "Fixed an issue resulting in the XP display to be hidden for all characters after logging in with a max level character",
		[4] = "#C_Change:_#",
		[5] = "Display settings (whether or not the XP display is hidden, set to toggle or entirely disabled - for max level characters) will now be saved character per character. This means, if you use the toggle feature, you need to set it for all of your leveling characters.",
		[6] = "The saved preset location will still be the same for all characters (so you can quickly set up the XP display location on all of your alts). If you want to use different locations for specific characters, you can still move the XP display manually (via Shift + dragging) - the client will remember it's character-specific position.",
		[7] = "Remaining XP will display a status message on each login for all characters (not only max levels) to let you know if it's currently visible, hidden or disabled, and is mouseover toggle enabled or not.",
	},
	[4] = {
		[0] = "#V_Version 1.3.1_#",
		[1] = "#F_Hotfix:_#",
		[2] = "With an unintentional change introduced with version 1.2, the character-specific positions set up before have been reset. This was due to the frame name being changed - now this has been reverted back to what it was before. All positions set before the update to 1.2 should be remembered again (however, in turn positions set after updating to 1.2 should be reset after this update.",
	},
	[5] = {
		[0] = "#V_Version 1.4_#",
		[1] = "#C_Change:_#",
		[2] = "Max level changed to 60 with the launch of Shadowlands.",
		[3] = "Font has been changed to a more readable and better looking one.",
	},
	[6] = {
		[0] = "#V_Version 1.5_#",
		[1] = "#F_Hotfix:_#",
		[2] = "The XP display will now be correctly disabled when you reach max level.",
		[3] = "Fixed all potential issues with previously non-local functions.",
	},
	[7] = {
		[0] = "#V_Version 1.6_#",
		[1] = "#N_Update:_#",
		[2] = "Added 9.1 (with 9.0.5 is still being supported!), Classic (1.13.7) and Burning Crusade Classic (2.5.1) multi-version support.",
	},
	[8] = {
		[0] = "#V_Version 2.0_#",
		[1] = "#N_Update:_#",
		[2] = "Added 9.2 (Retail), 1.14.2 (Classic) and 2.5.3 (BCC) multi-version support.",
		[3] = "#N_New features:_#",
		[4] = "#H_Added Interface Options:_#",
		[5] = "Buttons, sliders, dropdowns and more have been added as alternatives to chat commands (many more new options have not been made available as chat commands).",
		[6] = "Included an about page where you can find contact and support links, changelogs and more.",
		[7] = "#H_New display options:_#",
		[8] = "Background graphic: the display now functions as a customizable XP bar with customizable colors, mouseover fade options.",
		[9] = "Font family & color customization (with a fully custom font type option - see the tooltip in the settings).",
		[10] = "Multiple display presets have been added to quickly set it up for your needs.",
		[11] = "Detailed XP value option.",
		[12] = "Fine-tune the position (select an anchor point and change the offset coordinates with sliders).",
		[13] = "Raise or lower the display among other UI elements.",
		[14] = "#N_New features:_#",
		[15] = "XP bar enhancement integration: detailed XP text and tooltip can be enabled to replace the default text and tooltip shown when mousing over the default XP bar.",
		[16] = "Added the ability to hide the default Status/XP/Reputation Bars (so it may be replaced with the Remaining XP display).",
		[17] = "Chat notifications on event updates like XP or Rested XP gain (with the amount gained), level up and more.",
		[18] = "Option for an accumulative Rested XP gain notification showing you a summary of the total amount of Rested XP gained while resting when leaving a rested area.",
		[19] = "Import/Export: Back up your settings (or manually edit them - for advanced users).",
		[20] = "#C_Other additions & changes:_#",
		[21] = "Right click on the display (or the default XP bar when the integration is enabled) to quickly open an options category page.",
		[22] = "The chat notification reminder when you are max level and Remaining XP is disabled can now be turned off.",
		[23] = "The display now hides during pet battles.",
		[24] = "Added localization support, so more languages can be supported besides English in the future (more info soon on how you can help me translate!).",
		[25] = "#O_Coming soon:_#",
		[26] = "Options profiles for character-specific customization.",
		[27] = "Tracking the playtime/real time spent on a level.",
		[28] = "Different styles and looks for the custom XP bar.",
		[29] = "Event update logs: track your XP, Rested XP gain and more.",
	},
}

ns.GetChangelog = function()
	--Colors
	local version = "FFFFFFFF"
	local new = "FF66EE66"
	local fix = "FFEE4444"
	local change = "FF8888EE"
	local note = "FFEEEE66"
	local highlight = "FFBBBBBB"
	--Assemble the changelog
	local changelog = ""
		for i = #changelogDB, 0, -1 do
			for j = 0, #changelogDB[i] do
				changelog = changelog .. (j > 0 and "\n\n" or "") .. changelogDB[i][j]:gsub(
					"#V_(.-)_#", (i < #changelogDB and "\n\n\n" or "") .. "|c" .. version .. "%1|r"
				):gsub(
					"#N_(.-)_#", "|c".. new .. "%1|r"
				):gsub(
					"#F_(.-)_#", "|c".. fix .. "%1|r"
				):gsub(
					"#C_(.-)_#", "|c".. change .. "%1|r"
				):gsub(
					"#O_(.-)_#", "|c".. note .. "%1|r"
				):gsub(
					"#H_(.-)_#", "|c".. highlight .. "%1|r"
				)
			end
		end
	return changelog
end


--[[ LOCALIZATIONS ]]

local english = {
	options = {
		name = "#ADDON options",
		defaults = "The default options and the custom preset have been reset.",
		main = {
			name = "Main page",
			description = "Customize #ADDON to fit your needs. Type #KEYWORD for chat commands.", --# flags will be replaced with code
			shortcuts = {
				title = "Shortcuts",
				description = "Access customization options by expanding the #ADDON categories on the left or by clicking a button here.", --# flags will be replaced with code
			},
			about = {
				title = "About",
				description = "Thank you for using #ADDON!", --# flags will be replaced with code
				version = "Version: #VERSION", --# flags will be replaced with code
				author = "Author: #AUTHOR", --# flags will be replaced with code
				license = "License: #LICENSE", --# flags will be replaced with code
				changelog = {
					label = "Changelog",
					tooltip = "Notes of all the changes included in the addon updates for all versions.\n\nThe changelog is only available in English for now.", --\n represents the newline character
				},
			},
			support = {
				title = "Support",
				description = "Follow the links to see how you can provide feedback, report bugs, get help and support development.", --# flags will be replaced with code
				curseForge = "CurseForge Page",
				wago = "Wago Page",
				bitBucket = "BitBucket Repository",
				issues = "Issues & Ideas",
			},
			feedback = {
				title = "Feedback",
				description = "Visit #ADDON online if you have something to report.", --# flags will be replaced with code
			},
		},
		display = {
			title = "Display & XP Bar",
			description = "Customize the #ADDON display, change its background and font settings to make it your own.", --# flags will be replaced with code
			quick = {
				title = "Quick settings",
				description = "Quickly settings enable or disable the entire #ADDON main display or set it up via presets.", --# flags will be replaced with code
				hidden = {
					label = "Hidden",
					tooltip = "Hide or show the #ADDON main display.", --# flags will be replaced with code
				},
				presets = {
					label = "Apply a Preset",
					tooltip = "Swiftly change the position, size and visibility of the display elements by choosing and applying one of these presets.",
					list = {
						[0] = "XP Bar Replacement",
						[1] = "XP Bar Text Left",
						[2] = "XP Bar Text Right",
						[3] = "Player Frame Bar Above",
						[4] = "Player Frame Text Under",
						[5] = "Objective Tracker Bar",
						[6] = "Menu & Bags Small Bar",
						[7] = "Bottom-Left Chunky Bar",
						[8] = "Top-Center Long Bar",
						[9] = "Bottom-Right Chunky Bar", --Classic
					},
					select = "Select a preset…",
				},
				savePreset = {
					label = "Update Custom Preset",
					tooltip = "Save the current position, background size and visibility of the main display to the Custom preset.",
					warning = "Are you sure you want to override the Custom Preset with the current customizations?\n\nThe Custom preset is account-wide.", --\n represents the newline character
				},
			},
			position = {
				title = "Position",
				description = "You may drag the main display while holding #SHIFT to position it anywhere on the screen, fine-tune it here.", --# flags will be replaced with code
				anchor = {
					label = "Screen Anchor Point",
					tooltip = "Select which point of the screen should the display be anchored to.",
				},
				xOffset = {
					label = "Horizontal Offset",
					tooltip = "Set the amount of horizontal offset (X axis) of the display from the selected anchor point.",
				},
				yOffset = {
					label = "Vertical Offset",
					tooltip = "Set the amount of vertical offset (Y axis) of the display from the selected anchor point.",
				},
			},
			text = {
				title = "Text & Font",
				description = "Customize the font and select the information shown in the main display text overlay.",
				visible = {
					label = "Visible",
					tooltip = "Toggle the visibility of the XP text overlay.",
				},
				details = {
					label = "Detailed XP Info",
					tooltip = "Show more information in the main display (not just the xp needed to reach the next level).",
				},
				font = {
					family = {
						label = "Font Family", --font family or type
						tooltip = {
							[0] = "Select the font of the displayed XP value.",
							[1] = "The default option is the font used by Blizzard.",
							[2] = "You may set the #OPTION_CUSTOM option to any font of your liking by replacing the #FILE_CUSTOM file with another TrueType Font file found in:", --# flags will be replaced with code
							[3] = "while keeping the original #FILE_CUSTOM name.", --# flags will be replaced with code
							[4] = "You may need to restart the game client after replacing the Custom font.",
						},
					},
					size = {
						label = "Font Size",
						tooltip = "Specify the font size of the XP value shown on the main display.",
					},
					color = {
						label = "Font Color",
					},
				},
			},
			background = {
				title = "Background: XP Bar",
				description = "Customize the graphical background elements of the mini XP bar in the main display.",
				visible = {
					label = "Visible",
					tooltip = "Toggle the visibility of the backdrop elements of the main XP display.",
				},
				size = {
					width = {
						label = "Background Width",
						tooltip = "Set the width of the background graphic of the main XP display.",
					},
					height = {
						label = "Background Height",
						tooltip = "Set the height of the background graphic of the main XP display.",
					},
				},
				colors = {
					bg = {
						label = "Background Color",
					},
					border = {
						label = "Border Color",
					},
					xp = {
						label = "Current XP Color",
					},
					rested = {
						label = "Rested XP Color",
					},
				},
			},
			visibility = {
				title = "Visibility",
				description = "Set the visibility and behavior of the main #ADDON display.", --# flags will be replaced with code
				raise = {
					label = "Appear on top",
					tooltip = "Raise the display above most of the other UI elements (like the World Map Pane).",
				},
				fade = {
					label = "Fade when out of focus",
					tooltip = "Fade the XP value text and background when the cursor is not hovering over the main display.",
					text = {
						label = "Text Fade Intensity",
						tooltip = "Fade the remaining XP value on the main display when it's not being hovered with 0 being the transparency value of the current font color and 1 completely invisible.",
					},
					background = {
						label = "Background Fade Intensity",
						tooltip = "Fade the background graphic of the main display (if it's enabled) when it's not being hovered with 0 being the transparency value of the current background color and 1 completely invisible.",
					},
				},
			},
		},
		integration = {
			title = "Integration",
			description = "Integrate #ADDON into the default Blizzard XP bar.", --# flags will be replaced with code
			enhancement = {
				title = "XP Bar Enhancement",
				description = "Configure how the default XP bar integration should behave.",
				toggle = {
					label = "Enable Integration",
					tooltip = "Replace the default text shown when the mouse is hovering over the default XP bar with a custom text that includes detailed XP values (and a detailed tooltip).",
				},
				keep = {
					label = "Always Show",
					tooltip = "Keep the XP value visible on the XP bar at all times not only when the bar is being hovered.",
				},
				remaining = {
					label = "Remaining XP Only",
					tooltip = "You may choose to only show the remaining XP value instead of the entire XP text when the mouse is not hovering the XP bar.",
				},
			},
			removals = {
				title = "Removals & Replacements",
				description = "Choose to hide related elements of the default UI to remove or replace them.",
				statusBars = {
					label = "Hide default status bars",
					tooltip = "Turn off the default status bars: experience, reputation or other progression bars below the action bar so you may replace them with the custom #ADDON bar.", --# flags will be replaced with code
					labelClassic = "Hide default XP bar",
					tooltipClassic = "Turn off the default experience bar so you may replace it with the custom #ADDON bar.", --# flags will be replaced with code
				},
			},
		},
		events = {
			title = "Event Updates",
			description = "Set up and customize chat notifications and event logs about XP and level updates.",
			notifications = {
				title = "Chat Notifications",
				description = "Enable or disable detailed chat notifications for specific XP update events.",
				xpGained = {
					label = "XP Gained",
					tooltip = "Notify in chat whenever your character receives some amount of XP.",
				},
				restedXPGained = {
					label = "Rested XP Gained",
					tooltip = "Notify in chat whenever your character receives some amount of Rested XP.",
					significantOnly = {
						label = "Significant values only",
						tooltip = "Send Rested XP notifications only when a significant amount was gained, skipping notifications of the passive Rested XP accumulation when inside a Rested Area.",
					},
					accumulated = {
						label = "Passive gain as summary",
						tooltip = {
							[0] = "Display the total amount of Rested XP accumulated passively while resting when leaving a Rested Area in a chat notification.",
							[1] = "Note: The Rested XP accumulation can't be counted retroactively. The amount of Rested XP gained prior to installing #ADDON cannot be counted towards the total.", --# flags will be replaced with code
						},
					},
				},
				lvlUp = {
					label = "Level Up",
					tooltip = "Get a congratulation you when you level up.",
					timePlayed = {
						label = "Playtime spent to level up",
						tooltip = "Automatically call /played for you after you level up (required for calculating time spent) and get a notification to see how much time it took.",
					},
				},
				maxReminder = {
					label = "Max level reminder",
					tooltip = "Get a reminder that the functionality of #ADDON is disabled when your character is max level when your interface loads.", --# flags will be replaced with code
				},
			},
			logs = {
				title = "Event Logs",
				description = "Keep, review and export XP and level update event logs. (Soon™)",
			},
		},
		advanced = {
			title = "Advanced",
			description = "Configure #ADDON settings further, change options manually or backup your data by importing, exporting settings.", --# flags will be replaced with code
			profiles = {
				title = "Profiles",
				description = "Create, edit and apply unique options profiles to customize #ADDON separately between your characters. (Soon™)", --# flags will be replaced with 
			},
			backup = {
				title = "Backup",
				description = "Import or export #ADDON options to save, share or apply them between your accounts.", --# flags will be replaced with code
				backupBox = {
					label = "Import & Export",
					tooltip = {
						[0] = "The backup string in this box contains the currently saved addon data and frame positions.",
						[1] = "Copy it to save, share or use it for another account.",
						[2] = "If you have a string, just override the text inside this box. Select it, and paste your string here. Press #ENTER to load the data stored in it.", --# flags will be replaced with code
						[3] = "Note: If you are using a custom font file, that file can not carry over with this string. It will need to be inserted into the addon folder to be applied.",
						[4] = "Only load strings that you have verified yourself or trust the source of!",
					},
				},
				compact = {
					label = "Compact",
					tooltip = "Toggle between a compact and a readable view.",
				},
				load = {
					label = "Load",
					tooltip = "Check the current string, and addept to load all data from it.",
				},
				reset = {
					label = "Reset",
					tooltip = "Reset the string to reflect the currently stored values.",
				},
				import = "Load the string",
				warning = "Are you sure you want to attempt to load the currently inserted string?\n\nIf you've copied it from an online source or someone else has sent it to you, only load it after checking the code inside and you know what you are doing.\n\nIf don't trust the source, you may want to cancel to prevent any unwanted events.", --\n represents the newline character
				error = "The provided backup string could not be validated and no data was loaded. It might be missing some characters, or errors may have been introduced if it was edited.",
			},
		},
	},
	chat = {
		status = {
			disabled = "#ADDON is disabled", --# flags will be replaced with code
			max = "(you are level #MAX)", --# flags will be replaced with code
			visible = "#ADDON is visible", --# flags will be replaced with code
			hidden = "#ADDON is not visible", --# flags will be replaced with code
			toggle = "#hidden: #STATE", --# flags will be replaced with code
			fade = "#fade: #STATE", --# flags will be replaced with code
		},
		notifications = {
			xpGained = {
				text = "You gained #AMOUNT XP #REMAINING.", --# flags will be replaced with code
				remaining = "(#AMOUNT remaining to reach level #NEXT)", --# flags will be replaced with code
			},
			restedXPGained = {
				text = "Rested XP increased by #AMOUNT to #TOTAL #PERCENT.", --# flags will be replaced with code
				percent = "(#VALUE of the remaining XP)", --# flags will be replaced with code
			},
			restedXPAccumulated = {
				text = "Rested XP was accumulatively increased by #AMOUNT to #TOTAL while resting #PERCENT.", --# flags will be replaced with code
				percent = "(#VALUE of the XP remaining to reach level #NEXT)", --# flags will be replaced with code
				feels = "You feel rested.", --# flags will be replaced with code
				resting = "You are accumulating Rested XP.", --# flags will be replaced with code
			},
			lvlUp = {
				text = "You have reached level #LEVEL.", --# flags will be replaced with code
				disabled = {
					text = "#ADDON has now been disabled #REASON.", --# flags will be replaced with code
					reason = "(you reached level #MAX)", --# flags will be replaced with code
				},
				congrats = "Congrats!",
			},
		},
		help = {
			command = "help",
			thanks = "Thank you for using #ADDON!", --# flags will be replaced with code
			hint = "Type #HELP_COMMAND to see the full command list.", --# flags will be replaced with code
			move = "Hold #SHIFT to drag the #ADDON display anywhere you like.", --# flags will be replaced with code
			list = "chat command list",
		},
		options = {
			command = "options",
			description = "open the #ADDON options", --# flags will be replaced with code
		},
		save = {
			command = "save",
			description = "save the current display attributes to the Custom preset",
			response = "The current position, background size and visibility of the main display were saved to the Custom preset.",
		},
		preset = {
			command = "preset",
			description = "apply a specified display preset (e.g. #INDEX)", --# flags will be replaced with code
			response = "The specified display preset has been applied.",
			unchanged = "The preset count not be applied, the display is unchanged.",
			error = "Please enter a valid preset index (e.g. #INDEX).", --# flags will be replaced with code
			list = "The following presets are available:",
		},
		toggle = {
			command = "toggle",
			description = "show or hide the XP value display (#HIDDEN)", --# flags will be replaced with code
			response = "The main display is #HIDDEN.", --# flags will be replaced with code
			hidden = "hidden",
			shown = "not hidden",
		},
		fade = {
			command = "fade",
			description = "fade the display when it's not hovered (#STATE)", --# flags will be replaced with code
			response = "The XP display fade is #STATE.", --# flags will be replaced with code
		},
		size = {
			command = "size",
			description = "change the font size (e.g. #SIZE)", --# flags will be replaced with code
			response = "The font size has been set to #VALUE.", --# flags will be replaced with code
			unchanged = "The font size was not changed.",
			error = "Please enter a valid number value (e.g. #SIZE).", --# flags will be replaced with code
		},
		integration = {
			command = "integrate",
			description = "integrate detailed information into default XP bar",
			response = "The XP bar enhancement integration has been #STATE.", --# flags will be replaced with code
			notice = "Please, reload the interface to apply pending changes to the XP bar enhancement integration.",
		},
	},
	xpTooltip = {
		title = "XP details:",
		text = "(These values don't refresh automatically currently.)",
		current = "Current XP: #VALUE", --# flags will be replaced with code
		remaining = "Remaining XP: #VALUE", --# flags will be replaced with code
		percentTotal = "(#PERCENT of the total required XP.)", --# flags will be replaced with code
		needed = "Required XP: #DATA", --# flags will be replaced with code
		valueNeeded = "#VALUE in total for level #LEVEL.", --# flags will be replaced with code
		timeSpent = "Spent #TIME of game time on this level so far since resting in this area.", --# flags will be replaced with code
		rested = "Rested XP: #VALUE", --# flags will be replaced with code
		percentRemaining = "(#PERCENT of the remaining XP amount.)", --# flags will be replaced with code
		restedStatus = "Earn #PERCENT experience from monsters until the Rested XP amount is depleted.", --# flags will be replaced with code
		accumulated = "Accumulated #VALUE Rested XP so far while resting in this area.", --# flags will be replaced with code
		banked = "Banked XP: #DATA", --# flags will be replaced with code
		valueBanked = "#VALUE (#LEVELS banked levels).", --# flags will be replaced with code
	},
	xpBar = {
		text = "XP: #CURRENT / #NEEDED (#REMAINING Remaining)", --# flags will be replaced with code
		rested = "#RESTED Rested (#PERCENT)", --# flags will be replaced with code
		banked = "#VALUE Banked (#LEVELS levels)", --# flags will be replaced with code
	},
	keys = {
		shift = "SHIFT",
		enter = "ENTER",
	},
	points = {
		left = "Left",
		right = "Right",
		center = "Center",
		top = {
			left = "Top Left",
			right = "Top Right",
			center = "Top Center",
		},
		bottom = {
			left = "Bottom Left",
			right = "Bottom Right",
			center = "Bottom Center",
		},
	},
	misc = {
		default = "Default",
		custom = "Custom",
		override = "Override",
		enabled = "enabled",
		disabled = "disabled",
		days = "days",
		hours = "hours",
		minutes = "minutes",
		seconds = "seconds",
	},
}


--[[ Load Localization ]]

--Load the proper localization table based on the client language
ns.LoadLocale = function()
	local strings
	if (GetLocale() == "") then
		--TODO: Add localization for other languages (locales: https://wowwiki-archive.fandom.com/wiki/API_GetLocale#Locales)
		--Different font locales: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/Fonts.xml
	else --Default: English (UK & US)
		strings = english
		strings.options.display.text.font.family.default = UNIT_NAME_FONT_ROMAN:gsub("\\", "/")
	end
	return strings
end