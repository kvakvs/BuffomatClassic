local TOCNAME, _ = ...

---@class BomConstModule
local constModule = {}
BomModuleManager.constModule = constModule

constModule.TOC_VERSION = GetAddOnMetadata(TOCNAME, "Version") --used for display in options
constModule.TOC_TITLE = GetAddOnMetadata(TOCNAME, "Title") -- Longer title like "Buffomat Classic TBC"
constModule.SHORT_TITLE = "Buffomat"
constModule.MACRO_ICON = "INV_MISC_QUESTIONMARK"
constModule.MACRO_ICON_DISABLED = "INV_MISC_QUESTIONMARK"
constModule.BOM_BEAR_ICON_FULLPATH = "Interface\\ICONS\\Ability_Druid_ChallangingRoar" -- Icon picture used in window title, in the minimap icon, etc

constModule.ICON_FORMAT = "|T%s:0:0:0:0:64:64:4:60:4:60|t"
constModule.PICTURE_FORMAT = "|T%s:0|t"

constModule.MACRO_NAME = "Buff'o'mat"
--constModule.BLESSING_ID = "blessing"
constModule.LOADING_SCREEN_TIMEOUT = 2

-- Play MP3 from Sounds/ directory when task list is not empty
constModule.TASK_NOTIFICATION_SOUNDS = {
  "bubble-pop-up-alert",
  "computer-processing-short-click",
  "correct-answer-tone",
  "gaming-lock",
  "long-pop",
  "mouse-click",
  "positive-notification",
  "projector-button-push",
}

--Tool.IconClassTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
--Tool.IconClassTextureWithoutBorder = "Interface\\WorldStateFrame\\ICONS-CLASSES"
--Tool.IconClassTextureCoord = CLASS_ICON_TCOORDS

-- The texture is square 4x in a row, 64 px per icon
-- https://github.com/Gethe/wow-ui-textures/blob/live/WorldStateFrame/ICONS-CLASSES.PNG
constModule.CLASS_ICONS = {
  ["WARRIOR"]     = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:0:64|t",
  ["MAGE"]        = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:0:64|t",
  ["ROGUE"]       = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:128:192:0:64|t",
  ["DRUID"]       = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:192:256:0:64|t",

  ["HUNTER"]      = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:64:128|t",
  ["SHAMAN"]      = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:64:128|t",
  ["PRIEST"]      = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:128:192:64:128|t",
  ["WARLOCK"]     = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:192:256:64:128|t",

  ["PALADIN"]     = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:0:64:128:192|t",
  ["DEATHKNIGHT"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:0:0:0:0:256:256:64:128:128:192|t",
}

-- The texture is square 4x in a row, 64 px per icon
-- https://github.com/Gethe/wow-ui-textures/blob/live/WorldStateFrame/ICONS-CLASSES.PNG
constModule.CLASS_ICONS_BIG = {
  ["WARRIOR"]     = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:0:64:0:64|t",
  ["MAGE"]        = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:64:128:0:64|t",
  ["ROGUE"]       = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:128:192:0:64|t",
  ["DRUID"]       = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:192:256:0:64|t",

  ["HUNTER"]      = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:0:64:64:128|t",
  ["SHAMAN"]      = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:64:128:64:128|t",
  ["PRIEST"]      = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:128:192:64:128|t",
  ["WARLOCK"]     = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:192:256:64:128|t",

  ["PALADIN"]     = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:0:64:128:192|t",
  ["DEATHKNIGHT"] = "|TInterface\\WorldStateFrame\\ICONS-CLASSES:18:18:-4:4:256:256:64:128:128:192|t",
}

constModule.RAID_ICON_NAMES = ICON_TAG_LIST
constModule.RAID_ICON = {
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t", -- [1]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t", -- [2]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t", -- [3]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t", -- [4]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t", -- [5]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t", -- [6]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t", -- [7]
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t", -- [8]
}

---@alias BomColor number[] RGB or RGBA color

constModule.CLASSES = CLASS_SORT_ORDER ---@type BomClassName[]
constModule.CLASS_NAME = LOCALIZED_CLASS_NAMES_MALE ---@type table<BomClassName, string>
constModule.CLASS_COLOR = RAID_CLASS_COLORS ---@type table<BomClassName, BomColor>

constModule.NAME_TO_CLASS = --[[---@type {[string]: string}]] {}

for eng, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
  constModule.NAME_TO_CLASS[--[[---@type string]] name] = --[[---@type string]] eng
  constModule.NAME_TO_CLASS[--[[---@type string]] eng] = --[[---@type string]] eng
end
for eng, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
  constModule.NAME_TO_CLASS[--[[---@type string]] name] = --[[---@type string]] eng
end
