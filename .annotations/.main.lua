---[[ SAVED VARIABLES ]]

---@class RemainingXPDB : profileStorage
---@field profiles RemainingXPProfile[]

---@class RemainingXPDBC : characterProfileData

---@class RemainingXPCS : dataManagementSettingsData, positionOptionsSettingsData

---@class RemainingXPCSC
---@field xp xpValues


--[[ PROFILE DATA ]]

---@class RemainingXPProfileData
---@field customPreset RemainingXPPresetData
---@field display displayData
---@field integration integrationData
---@field notifications notificationsData

---@class RemainingXPProfile : profile
---@field data RemainingXPProfileData

--[ Preset ]

---@class RemainingXPPresetData : positionPresetData
---@field background displayBackgroundBaseData Background properties tied to the position preset

--[ Display ]

---@class displayData : positionPresetData
---@field hidden boolean The display is disabled
---@field text displayTextData
---@field font displayFontData
---@field background displayBackgroundData
---@field fade displayFadeData

--| Text

---@class displayTextData
---@field visible boolean The text is shown
---@field details boolean A more detailed XP text is shown (not just the remaining amount)

--| Font

---@class displayFontColorData
---@field base colorData Base text color
---@field gathered colorData Gathered XP text color
---@field needed colorData Needed XP text color
---@field remaining colorData Remaining XP text color
---@field rested colorData Rested XP text color
---@field banked colorData Banked text color

---@class displayFontData
---@field family string Path to font to use
---@field size integer Font size in pixels
---@field alignment JustifyHorizontal Horizontal text alignment
---@field colors displayFontColorData

--| Background

---@class displayBackgroundBaseData
---@field visible boolean The background is shown
---@field size sizeData

---@class displayBackgroundColorData
---@field bg colorData Background texture color
---@field gathered colorData Gathered XP segment texture color
---@field rested colorData Rested XP segment texture color
---@field border colorData Border texture color

---@class displayBackgroundData : displayBackgroundBaseData
---@field colors displayBackgroundColorData

--| Fade

---@class displayFadeData
---@field enabled boolean The display is faded when not hovered
---@field text number Text fade factor
---@field background number Background fade factor

--[ Integration ]

---@class integrationData
---@field hideXPBar boolean Hide the default XP bar
---@field enabled boolean Use the integrated display
---@field keep boolean Always show the integrated display (not just on mouseover)
---@field remaining boolean Only show the remaining XP amount

--[ Notifications ]

---@class notificationsData
---@field statusNotice displayStatusNoticeData
---@field xpGained boolean Chat message on XP gain
---@field restedXP restedXPNotificationsData
---@field restedStatus restedStatusNotificationsData
---@field lvlUp lvlUpNotificationsData

--| Display status

---@class displayStatusNoticeData
---@field enabled boolean Chat message on display visibility status
---@field maxReminder boolean Chat notice for display status at max level

--| Rested XP

---@class restedXPNotificationsData
---@field gained boolean Chat message on rested XP gain
---@field significantOnly boolean Notify on significant rested XP gain only
---@field accumulated boolean Chat message of accumulated rested XP on leaving rested area

--| Rested status

---@class restedStatusNotificationsData
---@field update boolean Chat message on rested status update
---@field maxReminder boolean Chat notice for rested XP status at max level

--| Level up

---@class lvlUpNotificationsData
---@field congrats boolean Congratulatory chat message on level up
---@field timePlayed boolean Chat message of time played on level up


--[[ MISC ]]

---@class xpValues
---@field gathered number Gathered XP amount
---@field needed number Needed XP amount
---@field remaining number Remaining XP amount
---@field rested number Rested XP amount
---@field accumulatedRested? number Accumulated rested XP amount
---@field banked? number Banked XP amount
---@field bankedLevels? number Banked levels