local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

BOM.Class = BOM.Class or {}

---
--- A class grouping multiple buffs of same type together
---
---@class BuffClass
---@field title string Name for a class of buffs, to be displayed
---@field spellIds table<number> A list of spellids, indexes in AllSpells

---@type BuffClass
BOM.Class.BuffClass = {}
BOM.Class.BuffClass.__index = BOM.Class.BuffClass

local CLASS_TAG = "buffclass"

---Creates a new BuffClass
---@param title string
---@param spellIds table<number>
---@return BuffClass
function BOM.Class.BuffClass:new(title, spellIds)
  fields = fields or {}
  setmetatable(fields, BOM.Class.BuffClass)

  fields.t = CLASS_TAG
  fields.title = title
  fields.spellIds = spellIds

  return fields
end

