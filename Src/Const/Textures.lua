---@type BuffomatAddon
local TOCNAME, BOM = ...

BOM.ICON_OPT_ENABLED = "Interface\\Buttons\\UI-CheckBox-Check"
BOM.ICON_OPT_DISABLED = "Interface\\Buttons\\UI-CheckBox-Up"

BOM.ICON_SELF_CAST_ON = "Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon"
BOM.ICON_SELF_CAST_OFF = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon"

BOM.CLASS_ICONS_ATLAS = "Interface\\WorldStateFrame\\ICONS-CLASSES"
BOM.CLASS_ICONS_ATLAS_TEX_COORD = CLASS_ICON_TCOORDS
BOM.ICON_EMPTY = "Interface\\Buttons\\UI-MultiCheck-Disabled"

BOM.ICON_SETTING_ON = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
BOM.ICON_SETTING_OFF = BOM.ICON_EMPTY

BOM.ICON_WHISPER_ON = "Interface\\Buttons\\UI-GuildButton-MOTD-Up"
BOM.ICON_WHISPER_OFF = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled"

BOM.ICON_BUFF_ON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
BOM.ICON_BUFF_OFF = BOM.ICON_EMPTY

--Icon for when self cast is enabled
BOM.ICON_DISABLED = "Interface\\FriendsFrame\\StatusIcon-Offline" --grey circle

--"Interface\\COMMON\\VOICECHAT-MUTED"
BOM.ICON_TARGET_ON = "Interface\\CURSOR\\Crosshairs"
BOM.ICON_TARGET_EXCLUDE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
BOM.ICON_TARGET_OFF = BOM.ICON_EMPTY

BOM.ICON_CHECKED = "Interface\\Buttons\\UI-CheckBox-Check"
BOM.ICON_CHECKED_OFF = BOM.ICON_EMPTY

BOM.ICON_GROUP = "Interface\\ICONS\\Achievement_GuildPerk_EverybodysFriend"
BOM.ICON_GROUP_ITEM = "Interface\\Buttons\\UI-PageButton-Background"
BOM.ICON_GROUP_NONE = BOM.ICON_EMPTY
BOM.ICON_GEAR = "Interface\\ICONS\\INV_Misc_Gear_01"

---- Options icons ----
BOM.IconAutoOpenOn = "Interface\\LFGFRAME\\BattlenetWorking1"
BOM.IconAutoOpenOnCoord = { 0.2, 0.8, 0.2, 0.8 }
BOM.IconAutoOpenOff = "Interface\\LFGFRAME\\BattlenetWorking4"
BOM.IconAutoOpenOffCoord = { 0.2, 0.8, 0.2, 0.8 }
BOM.IconDeathBlockOn = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8"
BOM.IconDeathBlockOff = "Interface\\ICONS\\Spell_Holy_ArcaneIntellect"--INV_Enchant_DustVision"
BOM.IconDeathBlockOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconNoGroupBuffOn = BOM.ICON_SELF_CAST_ON
BOM.IconNoGroupBuffOnCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconNoGroupBuffOff = BOM.ICON_SELF_CAST_OFF
BOM.IconNoGroupBuffOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconSameZoneOn = "Interface\\ICONS\\INV_Misc_Map_01"
BOM.IconSameZoneOnCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconSameZoneOff = "Interface\\ICONS\\INV_Scroll_03"
BOM.IconSameZoneOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconResGhostOn = "Interface\\RAIDFRAME\\Raid-Icon-Rez"
BOM.IconResGhostOnCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconResGhostOff = "Interface\\ICONS\\Ability_Vanish"
BOM.IconResGhostOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconReplaceSingleOff = "Interface\\ICONS\\Spell_Holy_DivineSpirit"
BOM.IconReplaceSingleOffCoord = { 0.1, 0.9, 0.1, 0.9 }
BOM.IconReplaceSingleOn = "Interface\\ICONS\\Spell_Holy_PrayerofSpirit"
BOM.IconReplaceSingleOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconArgentumDawnOff = BOM.ICON_EMPTY
BOM.IconArgentumDawnOn = "Interface\\ICONS\\INV_Jewelry_Talisman_07"
BOM.IconArgentumDawnOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconCarrotOff = BOM.ICON_EMPTY
BOM.IconCarrotOn = "Interface\\ICONS\\INV_Misc_Food_54"
BOM.IconCarrotOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconMainHandOff = BOM.ICON_EMPTY
BOM.IconMainHandOn = "Interface\\ICONS\\INV_Weapon_ShortBlade_03"
BOM.IconMainHandOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconSecondaryHandOff = BOM.ICON_EMPTY
BOM.IconSecondaryHandOn = "Interface\\ICONS\\INV_Weapon_Halberd_12"
BOM.IconSecondaryHandOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.ICON_TANK = "Interface\\RAIDFRAME\\UI-RAIDFRAME-MAINTANK"
BOM.ICON_TANK_COORD = { 0.1, 0.9, 0.1, 0.9 }
BOM.ICON_PET = "Interface\\ICONS\\Ability_Mount_JungleTiger"
BOM.ICON_PET_COORD = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconInPVPOff = BOM.ICON_EMPTY
BOM.IconInPVPOn = "Interface\\ICONS\\Ability_DualWield"
BOM.IconInPVPOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconInWorldOff = BOM.ICON_EMPTY
BOM.IconInWorldOn = "Interface\\ICONS\\INV_Misc_Orb_01"
BOM.IconInWorldOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconInInstanceOff = BOM.ICON_EMPTY
BOM.IconInInstanceOn = "Interface\\ICONS\\INV_Misc_Head_Dragon_01"
BOM.IconInInstanceOnCoord = { 0.1, 0.9, 0.1, 0.9 }

BOM.IconUseRankOff = BOM.ICON_EMPTY
BOM.IconUseRankOn = "Interface\\Buttons\\JumpUpArrow"
