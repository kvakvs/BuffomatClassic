local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class RowBuilder
---@field section string

---@type RowBuilder
BOM.Class.RowBuilder = {}
BOM.Class.RowBuilder.__index = BOM.Class.RowBuilder

local CLASS_TAG = "rowbuilder"

---Creates a new RowBuilder
---@field prev_control table Stores last created control, for lining up the following one
---@return RowBuilder
function BOM.Class.RowBuilder:new()
  local fields = {}
  setmetatable(fields, BOM.Class.RowBuilder)

  fields.t = CLASS_TAG
  fields.prev_control = nil
  fields.dx = 0
  fields.dy = 0
  fields.section = nil

  return fields
end
