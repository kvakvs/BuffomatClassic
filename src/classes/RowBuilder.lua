local TOCNAME, BOM = ...

---@class RowBuilder
BOM.RowBuilder = {}
BOM.RowBuilder.__index = BOM.RowBuilder

local CLASS_TAG = "rowbuilder"

---Creates a new RowBuilder
---@field prev_control table Stores last created control, for lining up the following one
---@return RowBuilder
function BOM.RowBuilder:new()
  local fields = {}
  setmetatable(fields, BOM.RowBuilder)

  fields.t = CLASS_TAG
  fields.prev_control = nil
  fields.dx = 0
  fields.dy = 0
  fields.section = nil

  return fields
end
