---@type BuffomatAddon
local TOCNAME, BOM = ...

---@class Member
---@field buffs table
---@field class string
---@field distance number
---@field group number
---@field hasArgentumDawn boolean
---@field hasCarrot boolean
---@field hasResurrection boolean
---@field isConnected boolean
---@field isDead boolean
---@field isGhost boolean
---@field isPlayer boolean
---@field isTank boolean
---@field link string
---@field name string
---@field NeedBuff boolean
---@field unitId number
BOM.Member = {}
BOM.Member.__index = BOM.Member

local CLASS_TAG = "ui_control"
