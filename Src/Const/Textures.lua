-- defined in WowInventory.lua ---@alias WowIconId string|number

---@alias WowTexCoord number[]

---@class TexturesModule
---@field CLASS_ICONS_ATLAS string
---@field CLASS_ICONS_ATLAS_TEX_COORD {[ClassName]: WowTexCoord}
---@field CLASS_ICONS_BUNDLED {[ClassName]: string}
---@field ICON_BUFF_OFF string
---@field ICON_BUFF_ON string
---@field ICON_CHECKED string
---@field ICON_CHECKED_OFF string
---@field ICON_DISABLED string
---@field ICON_EMPTY string
---@field ICON_GEAR string
---@field ICON_GROUP string
---@field ICON_GROUP_ITEM string
---@field ICON_GROUP_NONE string
---@field ICON_OPT_DISABLED string
---@field ICON_OPT_ENABLED string
---@field ICON_PET string
---@field ICON_PET_COORD WowTexCoord
---@field ICON_SELF_CAST_OFF string
---@field ICON_SELF_CAST_ON string
---@field ICON_SETTING_OFF string
---@field ICON_SETTING_ON string
---@field ICON_TANK string
---@field ICON_TANK_COORD WowTexCoord
---@field ICON_TARGET_EXCLUDE string
---@field ICON_TARGET_OFF string
---@field ICON_TARGET_ON string
---@field ICON_WHISPER_OFF string
---@field ICON_WHISPER_ON string
---@field ICON_COORD_09 WowTexCoord
---@field ICON_COORD_08 WowTexCoord

local texturesModule = LibStub("Buffomat-Textures") --[[@as TexturesModule]]

texturesModule.ICON_COORD_09 = { 0.1, 0.9, 0.1, 0.9 }
texturesModule.ICON_COORD_08 = { 0.2, 0.8, 0.2, 0.8 }

texturesModule.ICON_OPT_ENABLED = "Interface\\Buttons\\UI-CheckBox-Check"
texturesModule.ICON_OPT_DISABLED = "Interface\\Buttons\\UI-CheckBox-Up"

texturesModule.ICON_SELF_CAST_ON = "Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon"
texturesModule.ICON_SELF_CAST_OFF = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon"

texturesModule.CLASS_ICONS_ATLAS = "Interface\\WorldStateFrame\\ICONS-CLASSES"
texturesModule.CLASS_ICONS_ATLAS_TEX_COORD = CLASS_ICON_TCOORDS --[[@as {[ClassName]: WowTexCoord} ]]
texturesModule.ICON_EMPTY = "Interface\\Buttons\\UI-MultiCheck-Disabled"

---@deprecated Unused
texturesModule.ICON_SETTING_ON = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
---@deprecated Unused
texturesModule.ICON_SETTING_OFF = texturesModule.ICON_EMPTY

texturesModule.ICON_WHISPER_ON = "Interface\\Buttons\\UI-GuildButton-MOTD-Up"
texturesModule.ICON_WHISPER_OFF = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled"

texturesModule.ICON_BUFF_ON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
texturesModule.ICON_BUFF_OFF = texturesModule.ICON_EMPTY

--Icon for when self cast is enabled
texturesModule.ICON_DISABLED = "Interface\\FriendsFrame\\StatusIcon-Offline" --grey circle

--"Interface\\COMMON\\VOICECHAT-MUTED"
texturesModule.ICON_TARGET_ON = "Interface\\CURSOR\\Crosshairs"
texturesModule.ICON_TARGET_EXCLUDE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
texturesModule.ICON_TARGET_OFF = texturesModule.ICON_EMPTY

texturesModule.ICON_CHECKED = "Interface\\Buttons\\UI-CheckBox-Check"
texturesModule.ICON_CHECKED_OFF = texturesModule.ICON_EMPTY

texturesModule.ICON_GROUP = "Interface\\ICONS\\Achievement_GuildPerk_EverybodysFriend"
texturesModule.ICON_GROUP_ITEM = "Interface\\Buttons\\UI-PageButton-Background"
texturesModule.ICON_GROUP_NONE = texturesModule.ICON_EMPTY
texturesModule.ICON_GEAR = "Interface\\ICONS\\INV_Misc_Gear_01"

texturesModule.ICON_MAINHAND_OFF = texturesModule.ICON_EMPTY
texturesModule.ICON_MAINHAND_ON = "Interface\\ICONS\\INV_Weapon_ShortBlade_03"
texturesModule.ICON_MAINHAND_COORD = texturesModule.ICON_COORD_09

texturesModule.ICON_OFFHAND_OFF = texturesModule.ICON_EMPTY
texturesModule.ICON_OFFHAND_ON = "Interface\\ICONS\\INV_Weapon_Halberd_12"
texturesModule.ICON_OFFHAND_COORD = texturesModule.ICON_COORD_09

texturesModule.ICON_TANK = "Interface\\RAIDFRAME\\UI-RAIDFRAME-MAINTANK"
texturesModule.ICON_TANK_COORD = texturesModule.ICON_COORD_09

texturesModule.ICON_PET = "Interface\\ICONS\\Ability_Mount_JungleTiger"
texturesModule.ICON_PET_COORD = texturesModule.ICON_COORD_09

texturesModule.ON_ICON = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:0:0:0:0:64:64:4:60:4:60|t"
texturesModule.OFF_ICON = "|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:0:0:0:0:64:64:4:60:4:60|t"

---@type {[ClassName]: string}
texturesModule.CLASS_ICONS_BUNDLED = {
  ["WARRIOR"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_warrior",
  ["MAGE"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_mage",
  ["PALADIN"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_paladin",
  ["HUNTER"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_hunter",
  ["DRUID"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_druid",
  ["SHAMAN"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_shaman",
  ["PRIEST"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_priest",
  ["WARLOCK"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_warlock",
  ["ROGUE"]     = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_rogue",
  ["DEATHKNIGHT"] = "Interface\\Addons\\BuffomatClassic\\Textures\\classicon_deathknight",
  ["pet"] = "Interface\\Addons\\BuffomatClassic\\Textures\\icon_pet",
  ["tank"] = "Interface\\Addons\\BuffomatClassic\\Textures\\icon_tank",
}
