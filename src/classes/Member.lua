---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class Member
---@field class string
---@field distance number
---@field group number
---@field hasArgentumDawn boolean
---@field hasCarrot boolean
---@field hasResurrection boolean Was recently resurrected
---@field isConnected boolean Is online
---@field isDead boolean Is dead
---@field isGhost boolean Is dead and corpse released
---@field isPlayer boolean
---@field isTank boolean
---@field link string
---@field name string
---@field NeedBuff boolean
---@field unitId number
---
---@field MainHandBuff number|nil
---@field OffHandBuff number|nil
---@field buffs table<number, Buff> Buffs on player keyed by spell id
BOM.Class.Member = {}
BOM.Class.Member.__index = BOM.Class.Member

local CLASS_TAG = "member"
