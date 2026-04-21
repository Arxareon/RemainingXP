--NOTE: Annotations are for development purposes only, providing documentation for use with LUA Language Server. This file does not need to be loaded by the game client.


--[[ LOCALIZATIONS ]]

---English
---@class strings_enUS
local enUS = {
	presets = {
		"XP Bar Replacement",
		"XP Bar Text Left",
		"XP Bar Text Right",
		"Player Frame Bar Above",
		"Player Frame Text Under",
		"Objective Tracker Bar",
		"Bottom-Left Chunky Bar",
		"Bottom-Right Chunky Bar",
		"Top-Center Long Bar",
	},
	options = {
		name = "#ADDON options",
		defaults = "The default options and the #CUSTOM preset have been reset.",
		main = {
			description = "Customize #ADDON to fit your needs.\nType #KEYWORD for chat commands.",
			shortcuts = {
				title = "Shortcuts",
				description = "Access customization options by expanding the #ADDON categories on the left or by clicking a button here.",
			},
			about = {
				title = "About",
				description = "Thanks for using #ADDON! Copy the links to see how to share feedback, get help & support development.",
				version = "Version",
				date = "Date",
				author = "Author",
				license = "License",
				curseForge = "CurseForge Page",
				wago = "Wago Page",
				repository = "GitHub Repository",
				issues = "Issues & Feedback",
				changelog = {
					label = "Update Notes",
					tooltip = "Notes of all the changes, updates & fixes introduced with the latest version.\n\nThe changelog is only available in English for now.",
				},
				openFullChangelog = {
					label = "Open the full Changelog",
					tooltip = "Access the full list of update notes of all addon versions.",
				},
				fullChangelog = {
					label = "#ADDON Changelog",
					tooltip = "Notes of all the changes included in the addon updates for all versions.\n\nThe changelog is only available in English for now.",
				},
			},
			sponsors = {
				title = "Sponsors",
				description = "Your continued support is greatly appreciated! Thank you!",
			},
		},
		display = {
			title = "Display & XP Bar",
			description = "Customize the #ADDON display, change its background and font settings to make it your own.",
			referenceName = "the #ADDON display",
			visibility = {
				title = "Visibility",
				description = "Set the visibility and behavior of the main #ADDON display.",
				hidden = {
					label = "Hidden",
					tooltip = "Hide or show the #ADDON main display.",
				},
				statusNotice = {
					label = "Status notice on load",
					tooltip = "Get a notice in chat about the state of the #ADDON display if it's not visible after the interface loads.",
				},
				maxReminder = {
					label = "Max level reminder",
					tooltip = "Also get a reminder if the functionality of #ADDON is disabled because your character is max level.",
				},
			},
			text = {
				title = "XP Text",
				description = "Select the XP value information shown in the main display text overlay.",
				visible = {
					label = "Visible",
					tooltip = "Toggle the visibility of the XP text overlay.",
				},
				details = {
					label = "Detailed XP Info",
					tooltip = "Show more information in the main display (not just the xp required to reach the next level).",
				},
				base = "Base",
			},
			background = {
				title = "Background: XP Bar",
				description = "Customize the graphical elements of the XP bar background of the main XP display.",
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
				bg = "Background",
				border = "Border",
			},
			fade = {
				title = "Fade",
				description = "Fade the XP value text and background when the cursor is not hovering over the main XP display.",
				toggle = {
					label = "Fade when out of focus",
					tooltip = "Toggle the fading behavior of the display.",
				},
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
		integration = {
			title = "Integration",
			description = "Integrate #ADDON with the default Blizzard XP bar.",
			-- enhancement = { --REMOVE
			-- 	title = "XP Bar Enhancement",
			-- 	description = "Configure how the default XP bar integration should behave.",
			hideXPBar = {
				-- title = "Removals & Replacements", --REMOVE
				-- description = "Choose to hide related elements of the default UI to remove or replace them.",
				-- xpBar = {
				label = "Hide the default XP bar",
				tooltip = "Turn off the default XP bar so you may fully replace it with the custom #ADDON bar.",
				-- },
			},
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
			-- },
		},
		events = {
			title = "Notifications",
			description = "Set up and customize chat notifications and logs for XP and level updates.",
			notifications = {
				title = "Chat Notifications",
				description = "Enable or disable detailed chat notifications for specific XP update events.",
				xpGained = {
					label = "XP Gained",
					tooltip = "Notify in chat whenever your character receives some amount of XP.",
				},
				restedXP = {
					gained = {
						label = "Rested XP Gained",
						tooltip = "Notify in chat whenever your character receives some amount of Rested XP.",
					},
					significantOnly = {
						label = "Significant values only",
						tooltip = "Send Rested XP notifications only when a significant amount was gained (more than 0.1% of the total Required XP amount rounded up), skipping constant updates of the passive Rested XP accumulation when staying inside a Rested Area.",
					},
					accumulated = {
						label = "Passive gain as summary",
						tooltip = {
							"Display the total amount of Rested XP accumulated passively while resting when leaving a Rested Area in a chat notification.",
							"Note: The Rested XP accumulation can't be counted retroactively. The amount of Rested XP gained within the current area prior to installing #ADDON cannot be counted towards the total.",
						},
					},
				},
				restedStatus = {
					update = {
						label = "Rested Status Update",
						tooltip = "Show chat notifications when your rested status changes and whether you can accumulate more Rested XP while staying in a rested area.",
					},
					maxReminder = {
						label = "Max Rested XP Reminder",
						tooltip = "Get a chat message when you have already reached the maximal amount of Rested XP upon entering a rested area.",
					},
				},
				lvlUp = {
					congrats = {
						label = "Level Up Message",
						tooltip = "Get a congratulation message in chat you when you level up.",
					},
					timePlayed = {
						label = "Playtime spent to level up",
						tooltip = "Automatically call /played for you after you level up (required for calculating time spent) and get a notification to see how much time it took.",
					},
				},
			},
			logs = {
				title = "Update Logs",
				description = "Keep, review and export XP and level update event logs. (Soon™)",
			},
		},
		dataManagement = {
			title = "Advanced",
			description = "Configure #ADDON settings further, change options manually or backup your data by importing, exporting settings.",
			profiles = {
				title = "Profiles",
				description = "Create, edit and apply unique options profiles to customize #ADDON separately between your characters. (Soon™)", --# flags will be replaced with 
			},
			backup = {
				title = "Backup",
				description = "Import or export #ADDON options to save, share or apply them between your accounts.",
				backupBox = {
					label = "Import & Export",
					tooltip = {
						"The backup string in this box contains the currently saved addon data and frame positions.",
						"Copy it to save, share or use it for another account.",
						"If you have a string, just override the text inside this box. Select it, and paste your string here. Press ENTER to load the data stored in it.",
						"Note: If you are using a custom font file, that file can not carry over with this string. It will need to be inserted into the addon folder to be applied.",
						"Only load strings that you have verified yourself or trust the source of!",
					},
				},
				compact = {
					label = "Compact",
					tooltip = "Toggle between a compact and a readable view.",
				},
				load = {
					label = "Load",
					tooltip = "Check the current string, and attempt to load all data from it.",
				},
				reset = {
					label = "Reset",
					tooltip = "Reset the string to reflect the currently stored values.",
				},
				import = "Load the string",
				warning = "Are you sure you want to attempt to load the currently inserted string?\n\nIf you've copied it from an online source or someone else has sent it to you, only load it after checking the code inside and you know what you are doing.\n\nIf don't trust the source, you may want to cancel to prevent any unwanted events.",
				error = "The provided backup string could not be validated and no data was loaded. It might be missing some characters, or errors may have been introduced if it was edited.",
			},
		},
	},
	chat = {
		xpGained = {
			text = "You gained #AMOUNT XP #REMAINING.",
			remaining = "(#AMOUNT remaining to reach level #NEXT)",
		},
		restedXPGained = {
			text = "You gained #AMOUNT Rested XP. Total: #TOTAL #PERCENT.",
			percent = "(#VALUE of the remaining XP)",
		},
		restedXPAccumulated = {
			text = "You accumulated #AMOUNT Rested XP while resting.\nTotal: #TOTAL #PERCENT.",
			percent = "(#VALUE of the XP remaining to reach level #NEXT)",
			zero = "You accumulated no Rested XP.",
		},
		restedStatus = {
			resting = "You feel rested.",
			notResting = "You stopped resting.",
			accumulating = "You are accumulating Rested XP.",
			notAccumulating = "You are not accumulating any more Rested XP.",
			atMax = "The maximal Rested XP amount has already been reached (#PERCENT of the Required XP amount).",
			atMaxLast = "The maximal Rested XP amount has already been reached (#PERCENT of the Remaining XP amount).",
		},
		lvlUp = {
			text = "You reached level #LEVEL.",
			disabled = {
				text = "#ADDON features are now disabled for this character #REASON.",
				reason = "(you reached level #MAX)",
			},
			congrats = "Congrats!",
		},
		status = {
			disabled = "#ADDON features are disabled",
			max = "(you are level #MAX).",
			visible = "The XP display is visible (#FADE).",
			hidden = "The XP display is hidden (#FADE).",
			fade = "fade: #STATE",
		},
		help = {
			thanks = "Thank you for using #ADDON!",
			hint = "Type #HELP_COMMAND to see the full command list.",
			move = "Hold SHIFT to drag the #ADDON display anywhere you like.",
		},
		options = {
			description = "open the #ADDON options",
		},
		preset = {
			description = "apply a specified XP display preset (e.g. #INDEX)",
			response = "The #PRESET XP display preset was applied.",
			unchanged = "The preset could not be applied, the display is unchanged.",
			error = "Please enter a valid preset index (e.g. #INDEX).",
			list = "The following presets are available:",
		},
		save = {
			description = "save the current XP display setup as the #CUSTOM preset",
			response = "The current position, background size and visibility of the main XP display were saved to the #CUSTOM preset.",
		},
		reset = {
			description = "reset the #CUSTOM preset to its default state",
			response = "The #CUSTOM preset has been reset to the default preset.",
		},
		toggle = {
			description = "show or hide the XP display (#HIDDEN)",
			hiding = "The XP display has been hidden.",
			unhiding = "The XP display has been made visible.",
			hidden = "hidden",
			notHidden = "not hidden",
		},
		fade = {
			description = "fade the XP display when it's not hovered (#STATE)",
			response = "The XP display fade was set to #STATE.",
		},
		size = {
			description = "change the font size (e.g. #SIZE)",
			response = "The font size was set to #VALUE.",
			unchanged = "The font size was not changed.",
			error = "Please enter a valid number value (e.g. #SIZE).",
		},
		integration = {
			description = "show detailed XP info on the default XP bar",
			response = "The XP bar enhancement integration set to #STATE.",
			notice = "Please, reload the interface to apply pending changes to the XP bar enhancement integration.",
		},
		profile = {
			description = "activate a settings profile (e.g. #INDEX)",
			response = "The #PROFILE settings profile was activated.",
			unchanged = "The specified profile could not be activated.",
			error = "Please enter a valid profile name or index (e.g. #INDEX).",
			list = "The following profiles are available:",
		},
		default = {
			description = "reset the active #PROFILE settings profile to default",
			response = "The active #PROFILE settings profile has been reset to default.",
			responseCategory = "Settings of the #CATEGORY category in the active #PROFILE settings profile have been reset to default.",
		},
		position = {
			save = "The XP display position was saved.",
			cancel = "The repositioning of the XP display was cancelled.",
			error = "Hold SHIFT until the mouse button is released to save the position.",
		},
	},
	xpTooltip = {
		title = "XP details:",
		text = "An updating XP status summary.",
		value = "#VALUE_TYPE: #VALUE",
		percent = "(#PERCENT of #VALUE_TYPE.)",
		requiredLevelUp = "(Total XP required for level #LEVEL.)",
		timeSpent = "Spent #TIME of game time on this level since resting in this area.",
		restedMax = "The maximal amount is #PERCENT_MAX of the Required XP amount (or #PERCENT_REMAINING of the Remaining XP amount at level #LEVEL).",
		restedDescription = "You earn #PERCENT XP (and lose that much Rested XP) for killing monsters and gathering materials until the Rested XP amount is depleted.",
		restedAtMax = "You are no longer accumulating Rested XP. The maximal amount has been reached.",
		accumulated = "You have accumulated #VALUE Rested XP while resting in this area.",
		bankedValue = "#VALUE (#LEVELS banked levels).",
		hintOptions = "Right-click to open specific options.",
		hintMove = "Hold SHIFT & drag to reposition.",
	},
	xpValues = {
		gathered = "Gathered XP",
		required = "Required XP",
		remaining = "Remaining XP",
		rested = "Rested XP",
		banked = "Banked XP",
	},
	xpBar = {
		text = "XP: #GATHERED / #NEEDED (#REMAINING Remaining)",
		rested = "#VALUE Rested (#PERCENT)",
		banked = "#VALUE Banked (#LEVELS levels)",
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
		date = "#MONTH/#DAY/#YEAR",
		options = "Options",
		override = "Override",
		enabled = "enabled",
		disabled = "disabled",
		days = "days",
		hours = "hours",
		minutes = "minutes",
		seconds = "seconds",
	},
}


--[[ NAMESPACE ]]

---Addon namespace table
---@class addonNamespace
---@field name string Addon namespace name
---@field title string Addon displayed name
---@field root string Addon root folder
---@field strings strings

	---Localized strings
	---@alias strings
	---| strings_enUS


---[[ SAVED VARIABLES ]]

---@class database_warband : profileStorage
---@field profiles addonProfile[]

	---@class addonProfile : profile
	---@field data profileData

		---@class profileData
		---@field customPreset presetData
		---@field display displayData
		---@field integration integrationData
		---@field notifications notificationsData

			---@class presetData : positionPresetData
			---@field background displayBackgroundBaseData Background properties tied to the position preset

			---@class displayData : positionPresetData
			---@field hidden boolean The display is disabled
			---@field text displayTextData
			---@field font displayFontData
			---@field background displayBackgroundData
			---@field fade displayFadeData

				---@class displayTextData
				---@field visible boolean The text is shown
				---@field details boolean A more detailed XP text is shown (not just the remaining amount)

				---@class displayFontData : fontOptionsData
				---@field colors xpColorList

					---@class xpColorList
					---@field base color Base text color
					---@field gathered color Gathered XP text color
					---@field required color Required XP text color
					---@field remaining color Remaining XP text color
					---@field rested color Rested XP text color
					---@field banked color Banked text color

				---@class displayBackgroundData : displayBackgroundBaseData
				---@field colors displayBackgroundColorData

					---@class displayBackgroundBaseData
					---@field visible boolean The background is shown
					---@field size sizeData

					---@class displayBackgroundColorData
					---@field bg color Background texture color
					---@field gathered color Gathered XP segment texture color
					---@field rested color Rested XP segment texture color
					---@field border color Border texture color

				---@class displayFadeData
				---@field enabled boolean The display is faded when not hovered
				---@field text number Text fade factor
				---@field background number Background fade factor

			---@class integrationData
			---@field hideXPBar boolean Hide the default XP bar
			---@field enabled boolean Use the integrated display
			---@field keep boolean Always show the integrated display (not just on mouseover)
			---@field remaining boolean Only show the remaining XP amount

			---@class notificationsData
			---@field statusNotice displayStatusNoticeData
			---@field xpGained boolean Chat message on XP gain
			---@field restedXP restedXPNotificationsData
			---@field restedStatus restedStatusNotificationsData
			---@field lvlUp lvlUpNotificationsData

				---@class displayStatusNoticeData
				---@field enabled boolean Chat message on display visibility status
				---@field maxReminder boolean Chat notice for display status at max level

				---@class restedXPNotificationsData
				---@field gained boolean Chat message on rested XP gain
				---@field significantOnly boolean Notify on significant rested XP gain only
				---@field accumulated boolean Chat message of accumulated rested XP on leaving rested area

				---@class restedStatusNotificationsData
				---@field update boolean Chat message on rested status update
				---@field maxReminder boolean Chat notice for rested XP status at max level

				---@class lvlUpNotificationsData
				---@field congrats boolean Congratulatory chat message on level up
				---@field timePlayed boolean Chat message of time played on level up

---@class database_character : characterProfileData

---@class variables_warband : backupboxSettingsData, positionOptionsSettingsData

---@class variables_character
---@field xp xpValues

	---@class xpValues
	---@field gathered number Gathered XP amount
	---@field required number Needed XP amount
	---@field remaining number Remaining XP amount
	---@field rested number Rested XP amount
	---@field accumulatedRested? number Accumulated rested XP amount
	---@field banked? number Banked XP amount
	---@field bankedLevels? number Banked levels