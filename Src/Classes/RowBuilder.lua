local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomRowBuilderModule
local rowBuilderModule = BuffomatModule.DeclareModule("RowBuilder") ---@type BomRowBuilderModule

---@class RowBuilder
---@field prevControl BomControl|nil Previous control in the row
---@field categories table<string, boolean> True if category label was created already

local rowBuilderClass = {} ---@type RowBuilder
rowBuilderClass.__index = rowBuilderClass

---Creates a new RowBuilder
---@field prev_control table Stores last created control, for lining up the following one
---@return RowBuilder
function rowBuilderModule:new()
  local fields = {} ---@type RowBuilder
  setmetatable(fields, rowBuilderClass)

  fields.categories = {}
  fields.prevControl = nil
  fields.dx = 0
  fields.dy = 0

  return fields
end

function rowBuilderClass:StepRight(control, dx)
  self.prevControl = control
  self.dx = dx
end
