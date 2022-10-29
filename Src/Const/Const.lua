local TOCNAME, _ = ...

---@class BomConstModule
local constModule = BuffomatModule.New("Const") ---@type BomConstModule

constModule.TOC_VERSION = GetAddOnMetadata(TOCNAME, "Version") --used for display in options
constModule.TOC_TITLE = GetAddOnMetadata(TOCNAME, "Title") -- Longer title like "Buffomat Classic TBC"
constModule.SHORT_TITLE = "Buffomat"
constModule.MACRO_ICON = "INV_MISC_QUESTIONMARK"
constModule.MACRO_ICON_DISABLED = "INV_MISC_QUESTIONMARK"
constModule.BOM_BEAR_ICON_FULLPATH = "Interface\\ICONS\\Ability_Druid_ChallangingRoar" -- Icon picture used in window title, in the minimap icon, etc

constModule.ICON_FORMAT = "|T%s:0:0:0:0:64:64:4:60:4:60|t"
constModule.PICTURE_FORMAT = "|T%s:0|t"

constModule.MACRO_NAME = "Buff'o'mat"
constModule.BLESSING_ID = "blessing"
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
