---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Member
---@field class string
---@field distance number
---@field group number Raid group number (9 if temporary moved out of the raid by BOM)
---@field hasArgentumDawn boolean Has AD reputation trinket equipped
---@field hasCarrot boolean Has carrot riding trinket equipped
---@field hasResurrection boolean Was recently resurrected
---@field isConnected boolean Is online
---@field isDead boolean Is this member dead
---@field isGhost boolean Is dead and corpse released
---@field isPlayer boolean Is this a player
---@field isTank boolean Is this member marked as tank
---@field link string
---@field name string
---@field NeedBuff boolean
---@field unitId number
---
---@field MainHandBuff number|nil Temporary enchant on main hand
---@field OffHandBuff number|nil Temporary enchant on off-hand
---@field buffs table<number, Buff> Buffs on player keyed by spell id
BOM.Class.Member = {}
BOM.Class.Member.__index = BOM.Class.Member

local CLASS_TAG = "member"
